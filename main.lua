local filename = "sounds"   -- string : name of .json file containing sound list
local noteBlock             -- table : peripheral, note block

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
end

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
end

local function delSound()
    print("Deleting a sound, please specify :\nSound Name : ")
    local soundName = io.read()
    local soundID = sound.delSound(filename, soundName)
    if soundID ~= nil then
        print("Sound [" .. soundName .. "] which ID was [" .. soundID .. "] removed from list.")
    else
        print("This sound does not exist.")
    end
end

local function getCoords()
    print("Enter coordinates :")
    print("X : ")
    local x2 = tonumber(io.read())
    print("Y : ")
    local y2 = tonumber(io.read())
    print("Z : ")
    local z2 = tonumber(io.read())
    local x,y,z = gps.locate()
    return x2 - x, y2 - y, z2 - z
end

local function playSound(here)
    local soundID
    print("Playing a sound, please specify:")
    print("SoundName : ")
    local soundName = io.read()
    local soundID = sounds.getSoundID(filename, soundName)
    if soundID == nil then
        print("No sound matching this name.")
        return
    end
    if here then
        sound.playSound(noteBlock, soundID)
    else
        local x,y,z = getCoords()
        sound.playSound(noteBlock, soundID, x, y, z)
    end
end

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
        local x,y,z = getCoords()
        sound.playSound(noteBlock, soundID, pitch, volume, x, y, z)
    end
end

local function parse(input)
    if string.upper(input) == "ADD" then addSound()
    elseif string.upper(input) == "DEL" then delSound()
    elseif string.upper(input) == "PLAY" then playSound(false)
    elseif string.upper(input) == "PLAY_HERE" then playSound(true)
    elseif string.upper(input) == "PLAY_CUSTOM" then playCustomSound(false)
    elseif string.upper(input) == "PLAY_CUSTOM_HERE" then playCustomSound(true)
    else print("Input not recognized as an instruction.")
    end
end

local function main()
    loadAPIs()
    init()
    local inst = {"ADD", "DEL", "PLAY"}
    while true do
        term.clear()
        print("\nWaiting for an instruction...")
        table.foreach(inst, print)
        local input = io.read()
        parse(input)
    end
end

main()