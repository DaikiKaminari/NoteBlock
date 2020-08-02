local filename = "sounds"   -- string : name of .json file containing sound list
local noteBlock             -- table : peripheral, note block
local monitor               -- table : peripheral, display monitor


--- UTILS ---
local function actualizeDisplay()
    local native = term.native()
    term.redirect(monitor)
    if monitor ~= nil then
        term.redirect(monitor)
    end
    sound.displaySounds(filename)
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

local function init()
    if not fs.exists("sounds") then
        error("[sounds] not found.")
    end
    noteBlock = peripheral.find("note_block")
    if noteBlock == nil then
        error("NoteBlock peripheral not found.")
    end
    monitor = peripheral.find("monitor")
    actualizeDisplay()
end

--- FUNCTIONS ---
-- add a new sound to json file containing all the sounds with informations provided by user
local function addSound()
    print("Adding new sound, please specify :\nSound Name : ")
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
    print("Deleting a sound, please specify :\nSound Name : ")
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
    print("Y : ")
    local y2 = tonumber(io.read())
    print("Z : ")
    local z2 = tonumber(io.read())
    local x,y,z = gps.locate()
    if x2 == nil or y2 == nil or z2 == nil then
        return x, y, z
    else
        return x2 - x, y2 - y, z2 - z
    end
end

-- play a sound that is registered in json sound list
local function playSound(here)
    local soundID
    print("Playing a sound, please specify:")
    print("SoundName : ")
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
    if usingID == "Y" then
        print("SoundID : ")
        soundID = io.read()
    else
        local soundName = io.read()
        local soundID = sounds.getSoundID(filename, soundName)
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
        sound.playSound(noteBlock, soundID, pitch, volume, 1, 1, 1)
    else
        local x, y, z = getCoords()
        sound.playSound(noteBlock, soundID, pitch, volume, x, y, z)
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
    else
        print("Input not recognized as an instruction.")
        sleep(2)
    end
end

local function main()
    loadAPIs()
    init()
    local inst = {"ADD", "DEL", "PLAY", "PLAY_HERE", "PLAY_CUSTOM", "PLAY_CUSTOM_HERE"}
    while true do
        term.clear()
        print("\nWaiting for an instruction...")
        for _,v in pairs(inst) do
            print(" - " .. v)
        end
        local input = io.read()
        parse(input)
    end
end

main()