local filename = "sounds"   -- string : name of .json file containing sound list
local noteBlock             -- table : peripheral, note block
local monitor               -- table : peripheral, display monitor
local conf = {}             -- table : configuration (x,y,z coords of the computer)

--- UTILS ---
local function actualizeDisplay()
    local native = term.native()
    if monitor ~= nil then
        term.redirect(monitor)
        sound.displaySounds(filename, true)
    end
    sound.displaySounds(filename, false)
    term.redirect(native)
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
        print("Please enter computer coordinates :")
        while type(conf["x"]) ~= "number" do
            print("X :")
            conf["x"] = tonumber(io.read())
        end
        while type(conf["y"]) ~= "number" do
            print("y :")
            conf["y"] = tonumber(io.read())
        end
        while type(conf["z"]) ~= "number" do
            print("z :")
            conf["z"] = tonumber(io.read())
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
        actualizeDisplay()
    end
end

--- FUNCTIONS ---
-- add a new sound to json file containing all the sounds with informations provided by user
local function addSound()
    print("Adding new sound, please specify :\nSound name : ")
    local soundName = io.read()
    print("Sound ID : ")
    local soundID = io.read()
    if sound.addSound(filename, soundName, soundID) then
        print("Sound [" .. soundName .. "] with ID [" .. soundID .. "] added to list.")
    else
        print("No new sound have been added.")
    end
    actualizeDisplay()
end

-- delete a sound from json file containing all the sounds
local function delSound()
    print("Deleting a sound, please specify :\nSound name : ")
    local soundName = io.read()
    local soundID = sound.delSound(filename, soundName)
    if soundID ~= nil then
        print("Sound [" .. soundName .. "] which ID was [" .. soundID .. "] removed from list.")
    else
        print("This sound does not exist.")
    end
    actualizeDisplay()
end

-- return delta vector bewteen user location and coordinates he enters
local function getCoords()
    print("Enter coordinates :")
    print("X : ")
    local x2 = tonumber(io.read())
    x2 = type(x2) == "number" and x2 or 0
    print("Y : ")
    local y2 = tonumber(io.read())
    y2 = type(y2) == "number" and y2 or 0
    print("Z : ")
    local z2 = tonumber(io.read())
    z2 = type(z2) == "number" and z2 or 0
    return x2 - conf["x"], y2 - conf["y"], z2 - conf["z"]
end

-- play a sound that is registered in json sound list
local function playSound(here)
    local soundID
    print("Playing a sound, please specify:")
    print("Sound name : ")
    local soundName = io.read()
    local soundID = sound.getSoundID(filename, soundName)
    if soundID == nil then
        print("No sound matching this name.")
        return
    end
    if here then
        sound.playSound(noteBlock, soundID)
    else
        local x, y, z = getCoords()
        sound.playSound(noteBlock, soundID, x, y, z)
    end
end

-- play a sound registered in json sound list or with an ID, can specify each parameter
local function playCustomSound(here)
    print("Playing a sound, please specify:\nUsing ID (Y/N) ?")
    local usingID = io.read()
    local soundID
    if string.upper(usingID) == "Y" then
        print("SoundID : ")
        soundID = io.read()
    else
        print("Sound name : ")
        local soundName = io.read()
        local soundID = sound.getSoundID(filename, soundName)
        if soundID == nil then
            print("No sound matching this name.")
            return
        end
    end
    print("Volume (0-1000) : ")
    local volume = tonumber(io.read())
    print("Pitch (0.0-2.0) : ")
    local pitch = tonumber(io.read())
    if here then
        sound.playSound(noteBlock, soundID, 1, 1, 1, pitch, volume)
    else
        local x, y, z = getCoords()
        sound.playSound(noteBlock, soundID, x, y, z, pitch, volume)
    end
end

-- parse the instructions and call the corresponding function
local function parse(input)
    if string.upper(input) == "ADD" then addSound()
    elseif string.upper(input) == "DEL" then delSound()
    elseif string.upper(input) == "PLAY" then playSound(false)
    elseif string.upper(input) == "PLAY_HERE" then playSound(true)
    elseif string.upper(input) == "PLAY_CUSTOM" then playCustomSound(false)
    elseif string.upper(input) == "PLAY_CUSTOM_HERE" then playCustomSound(true)
    elseif string.upper(input) == "DISPLAY" then actualizeDisplay()
    else
        print("Input not recognized as an instruction.")
        sleep(2)
    end
end

local function main()
    loadAPIs()
    loadConfig()
    init()
    local inst = {"ADD", "DEL", "PLAY", "PLAY_HERE", "PLAY_CUSTOM", "PLAY_CUSTOM_HERE", "DISPLAY"}
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