local filename = "sounds"   -- string : name of .json file containing sound list
local noteBlock             -- table : peripheral, note block
local monitor               -- table : peripheral, display monitor
local conf = {}             -- table : configuration (x,y,z coords of the computer)

--- UTILS ---
local function actualizeDisplay(onMonitor)
    term.clear()
    if monitor ~= nil and onMonitor then
        local native = term.native()
        term.redirect(monitor)
        term.clear()
        sound.displaySounds(filename, true)
        term.redirect(native)
    end
    sound.displaySounds(filename, false)
end

local function waitForEchap()
    local event, nbKey
    while event ~= "key" and nbKey ~= 211 do
        sleep(0)
    end
end

--- INIT ---
local function loadAPIs()
    if not fs.exists("lib/objectJSON") then
        error("[lib/objectJSON] not found.")
    end
    os.loadAPI("lib/objectJSON")
    objectJSON.init()

    if not fs.exists("lib/sound") then
        error("[lib/sound] not found.")
    end
    os.loadAPI("lib/sound")
end

local function loadConfig()
    if fs.exists("config") then
        conf = objectJSON.decodeFromFile("config")
    end
    if next(conf) == nil then
        print("\nPlease enter computer coordinates :")
        while type(conf["x"]) ~= "number" do
            print("X :")
            conf["x"] = tonumber(io.read())
        end
        while type(conf["y"]) ~= "number" do
            print("Y :")
            conf["y"] = tonumber(io.read())
        end
        while type(conf["z"]) ~= "number" do
            print("Z :")
            conf["z"] = tonumber(io.read())
        end
        while type(conf["radius"]) ~= "number" and type(conf["radius"]) < 0 do
            print("\nMap radius :")
            conf["radius"] = tonumber(io.read())
        end
        objectJSON.encodeAndSavePretty("config", conf)
    end
end

local function init()
    if not fs.exists("sounds") then
        error("[sounds] not found.")
    end
    noteBlock = peripheral.find("note_block")
    if noteBlock == nil then
        error("NoteBlock peripheral not found.")
    end
    monitor = peripheral.find("monitor")
    if monitor ~= nil then
        actualizeDisplay(true)
    end
end

--- FUNCTIONS ---
-- adds a new sound to json file containing all the sounds with informations provided by user
local function addSound()
    print("\nAdding new sound, please specify :\n\nSound name : ")
    local soundName = io.read()
    print("\nSound ID : ")
    local soundID = io.read()
    if sound.addSound(filename, soundName, soundID) then
        print("\nSound [" .. soundName .. "] with ID [" .. soundID .. "] added to list.")
    else
        print("\nNo new sound have been added.")
    end
    actualizeDisplay(true)
end

-- deletes a sound from json file containing all the sounds
local function delSound()
    print("\nDeleting a sound, please specify :\n\nSound name : ")
    local soundName = io.read()
    local soundID = sound.delSound(filename, soundName)
    if soundID ~= nil then
        print("\nSound [" .. soundName .. "] which ID was [" .. soundID .. "] removed from list.")
    else
        print("\nThis sound does not exist.")
    end
    actualizeDisplay(true)
end

-- plays a sound and ask to repeat
local function playSoundAndRepeat(noteBlock, soundID, dx, dy, dz, pitch, volume)
    local play = ""
    while play == "" do
        sound.playSound(noteBlock, soundID, dx, dy, dz, pitch, volume)
        print("\nPlay the sound again ?")
        print(" - *nothing* : repeat the sound 1 time")
        print(" - spam : ask to repeat the sound multiple times")
        print(" - anything else will stop the program")
        play = io.read()
        if string.upper(play) == "SPAM" then
            print("\nTimes the sound will be repeated (nothing = unlimited)")
            local times = tonumber(io.read())
            print("\nDelay between two sounds in second (nothing = no delay)")
            local delay = tonumber(io.read())
            print("\nPress *supp* to stop...")
            parallel.waitForAny(waitForEchap, function() sound.playSoundMultipleTimes(noteBlock, soundID, times, delay, x, y, z, pitch, volume) end)
        end
    end
end

-- return delta vector bewteen user location and coordinates he enters
local function getCoords()
    print("\nEnter coordinates :")
    print("X : ")
    local x = tonumber(io.read())
    x = type(x) == "number" and x or conf["x"]
    print("Y : ")
    local y2 = tonumber(io.read())
    y = type(y) == "number" and y or conf["y"]
    print("Z : ")
    local z = tonumber(io.read())
    z = type(z) == "number" and z or conf["z"]
    return x - conf["x"], y - conf["y"], z - conf["z"]
end

-- play a sound that is registered in json sound list
local function playSound(here)
    actualizeDisplay(true)
    local soundID
    print("\nPlaying a sound, please specify:")
    print("\nSound name : ")
    local soundName = io.read()
    local soundID = sound.getSoundID(filename, soundName)
    if soundID == nil then
        print("No sound matching this name.")
        return
    end
    if here then
        playSoundAndRepeat(noteBlock, soundID)
    else
        local dx, dy, dz = getCoords()
        playSoundAndRepeat(noteBlock, soundID, dx, dy, dz)
    end
end

-- play a sound registered in json sound list or with an ID, can specify each parameter
local function playCustomSound(here)
    actualizeDisplay(true)
    print('\nPlaying a sound, please specify:\nUsing ID (enter "y" for yes) ?')
    local usingID = io.read()
    local soundID
    if string.upper(usingID) == "Y" then
        print("\nSoundID : ")
        soundID = io.read()
    else
        print("\nSound name : ")
        local soundName = io.read()
        soundID = sound.getSoundID(filename, soundName)
        if soundID == nil then
            print("No sound matching this name.")
            return
        end
    end
    print("\nVolume (0-1000) : ")
    local volume = tonumber(io.read())
    print("\nPitch (0.0-2.0) : ")
    local pitch = tonumber(io.read())
    if here then
        playSoundAndRepeat(noteBlock, soundID, 0, 0, 0, pitch, volume)
    else
        local dx, dy, dz = getCoords()
        playSoundAndRepeat(noteBlock, soundID, dx, dy, dz, pitch, volume)
    end
end

-- plays the sound on the whole map
local function playSoundGlobally()
    actualizeDisplay(true)
    local soundID
    print("\nPlaying a sound, please specify:")
    print("\nSound name : ")
    local soundName = io.read()
    local soundID = sound.getSoundID(filename, soundName)
    if soundID == nil then
        print("No sound matching this name.")
        return
    end
    print("\nPitch (0.0-2.0) : ")
    local pitch = tonumber(io.read())
    sound.playSoundGlobally(noteBlock, soundID, conf["radius"], conf["x"], conf["y"], conf["z"], pitch)
end

-- parses the instructions and call the corresponding function
local function parse(input)
    term.clear()
    if string.upper(input) == "ADD" then addSound()
    elseif string.upper(input) == "DEL" then delSound()
    elseif string.upper(input) == "PLAY" then playSound(false)
    elseif string.upper(input) == "PLAY_HERE" then playSound(true)
    elseif string.upper(input) == "PLAY_CUSTOM" then playCustomSound(false)
    elseif string.upper(input) == "PLAY_CUSTOM_HERE" then playCustomSound(true)
    elseif string.upper(input) == "PLAY_GLOBALLY" then playSoundGlobally()
    elseif string.upper(input) == "DISPLAY" then
        if monitor ~= nil then
            actualizeDisplay(true)
        end
    else
        print("Input not recognized as an instruction.")
        sleep(2)
    end
end

local function main()
    loadAPIs()
    loadConfig()
    init()
    local inst = {"ADD", "DEL", "PLAY", "PLAY_HERE", "PLAY_CUSTOM", "PLAY_CUSTOM_HERE", "PLAY_GLOBALLY", "DISPLAY"}
    local input = ""
    while true do
        if string.upper(input) ~= "DISPLAY" then
            term.clear()
        end
        print("\nWaiting for an instruction...")
        for _,v in pairs(inst) do
            print(" - " .. v)
        end
        input = io.read()
        parse(input)
    end
end

main()