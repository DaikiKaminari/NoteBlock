--- INIT ---
function init()
    print("\n--- INIT soundManager ---")
    if not fs.exists("lib/objectJSON") then
        error("[lib/objectJSON] not found.")
    end
    os.loadAPI("lib/objectJSON")
    objectJSON.init()

    if not fs.exists("lib/sound") then
        error("[lib/sound] not found.")
    end
    os.loadAPI("lib/sound")
    if not fs.exists("config") then
        error("[config] not found.")
    end
    print("API [soundManager] initialized")
end


--- UTILS ----
-- stop when supp key is pressed
local function waitForEchap()
    local event, nbKey
    while event ~= "key" and nbKey ~= 211 do
        sleep(0)
        event, nbKey = os.pullEvent()
    end
end

--- FUNCTIONS ---
-- adds a new sound to json file containing all the sounds with informations provided by user
function addSound(filename)
    print("\nAdding new sound, please specify :\n\nSound name : ")
    local soundName = io.read()
    print("\nSound ID : ")
    local soundID = io.read()
    if sound.addSound(filename, soundName, soundID) then
        print("\nSound [" .. soundName .. "] with ID [" .. soundID .. "] added to list.")
    else
        print("\nNo new sound have been added.")
    end
    print("Press enter...")
    io.read()
end

-- deletes a sound from json file containing all the sounds
function delSound(filename)
    print("\nDeleting a sound, please specify :\n\nSound name : ")
    local soundName = io.read()
    local soundID = sound.delSound(filename, soundName)
    if soundID ~= nil then
        print("\nSound [" .. soundName .. "] which ID was [" .. soundID .. "] removed from list.")
        print("Press enter...")
        io.read()
    else
        print("\nThis sound does not exist.")
    end
    print("Press enter...")
    io.read()
end

-- plays a sound and ask to repeat
local function playSoundAndRepeat(isGlobal, noteBlock, soundID, dx, dy, dz, pitch, volume)
    local conf = objectJSON.decodeFromFile("config")
    local play = ""
    while play == "" do
        if isGlobal then
            sound.playSoundGlobally(noteBlock, soundID, conf["radius"], conf["x"], conf["y"], conf["z"], pitch)
        else
            sound.playSound(noteBlock, soundID, dx, dy, dz, pitch, volume)
        end
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
            if isGlobal then
                parallel.waitForAny(waitForEchap, function() sound.playGlobalSoundMultipleTimes(noteBlock, soundID, times, delay, conf["radius"], conf["x"], conf["y"], conf["z"], pitch, volume) end)
            else
                parallel.waitForAny(waitForEchap, function() sound.playSoundMultipleTimes(noteBlock, soundID, times, delay, dx, dy, dz, pitch, volume) end)
            end
        end
    end
end

-- return delta vector bewteen user location and coordinates he enters
local function getCoords()
    local conf = objectJSON.decodeFromFile("config")
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
function playSound(filename, noteBlock, here)
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
        playSoundAndRepeat(false, noteBlock, soundID)
    else
        local dx, dy, dz = getCoords()
        playSoundAndRepeat(false, noteBlock, soundID, dx, dy, dz)
    end
end

-- play a sound registered in json sound list or with an ID, can specify each parameter
function playCustomSound(filename, noteBlock, here)
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
        playSoundAndRepeat(false, noteBlock, soundID, 0, 0, 0, pitch, volume)
    else
        local dx, dy, dz = getCoords()
        playSoundAndRepeat(false, noteBlock, soundID, dx, dy, dz, pitch, volume)
    end
end

-- plays the sound on the whole map
function playSoundGlobally(filename, noteBlock)
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
    playSoundAndRepeat(true, noteBlock, soundID)
end