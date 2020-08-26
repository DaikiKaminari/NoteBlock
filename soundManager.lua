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
    print("API [soundManager] initialized")
end


--- UTILS ----
-- stop when supp key is pressed
local function waitForEchap()
    local event, nbKey
    while true do
        event, nbKey = os.pullEvent()
        if event == "key" and nbKey == 211 then
            return
        end
        sleep(0)
    end
end

-- returns true if an element is present as a key of a table
local function isKeyPresent(tab, key)
    for k,_ in pairs(tab) do
        if k == key then
            return true
        end
    end
    return false
end

-- returns an input entered by the user
local function getInput(question)
    if question then
        print(question)
    end
    term.setTextColor(colors.blue)
    local answer = io.read()
    term.setTextColor(colors.white)
    return answer
end

--- FUNCTIONS ---
-- adds a new sound to json file containing all the sounds with informations provided by user
function addSound(filename, soundID)
    local soundName = getInput("\nAdding new sound, please specify :\n\nSound name : ")
    if soundID == nil then
        soundID = getInput("\nSound ID : ")
    end
    if sound.addSound(filename, soundName, soundID) then
        print("\nSound [" .. soundName .. "] with ID [" .. soundID .. "] added to list.")
    else
        print("\nNo new sound have been added.")
    end
    getInput("Press enter...")
end

-- modify a sound name
function modifySound(filename)
    local soundName = getInput("\nEnter the name of the sound you want to modify :")
    local newSoundName = getInput("\nEnter the new name :")
    if sound.modifySound(filename, soundName, newSoundName) then
        print("\nSound [" .. soundName .. "] modified for [" .. newSoundName .. "].")
    else
        print("\nSound [" .. soundName .. "] not modified.")
    end
end

-- deletes a sound from json file containing all the sounds
function delSound(filename)
    local soundName = getInput("\nDeleting a sound, please specify :\n\nSound name : ")
    local soundID = sound.delSound(filename, soundName)
    if soundID ~= nil then
        print("\nSound [" .. soundName .. "] which ID was [" .. soundID .. "] removed from list.")
    else
        print("\nThis sound does not exist.")
    end
    getInput("Press enter...")
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
        print(" - anything else : menu")
        play = getInput()
        if string.upper(play) == "SPAM" then
            local times = tonumber(getInput("\nTimes the sound will be repeated (nothing = unlimited)"))
            local delay = tonumber(getInput("\nDelay between two sounds in second (nothing = no delay)"))
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
    local x = tonumber(getInput("X : ")) or conf["x"]
    local y = tonumber(getInput("Y : ")) or conf["y"]
    local z = tonumber(getInput("Z : ")) or conf["z"]
    return x - conf["x"], y - conf["y"], z - conf["z"]
end

-- play a sound that is registered in json sound list
function playSound(filename, noteBlock, here)
    local soundID
    print("\nPlaying a sound, please specify:")
    local soundName = getInput("\nSound name : ")
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
    local usingID = getInput('\nPlaying a sound, please specify:\nUsing ID (enter "y" for yes) ?')
    local soundID
    if string.upper(usingID) == "Y" then
        soundID = getInput("\nSoundID : ")
    else
        local soundName = getInput("\nSound name : ")
        soundID = sound.getSoundID(filename, soundName)
        if soundID == nil then
            print("No sound matching this name.")
            return
        end
    end
    local volume = tonumber(getInput("\nVolume (0-1000) : "))
    local pitch = tonumber(getInput("\nPitch (0.0-2.0) : "))
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
    local soundName = getInput("\nSound name : ")
    local soundID = sound.getSoundID(filename, soundName)
    if soundID == nil then
        print("No sound matching this name.")
        return
    end
    local pitch = tonumber(getInput("\nPitch (0.0-2.0) : "))
    playSoundAndRepeat(true, noteBlock, soundID, nil, nil, nil, pitch)
end

-- core function for testSound()
local function testSoundCore(noteBlock, filename)
    local soundID
    while true do
        soundID = getInput("\nEnter sound ID :")
        if string.upper(soundID) == "STOP" then
            return
        end
        sound.playSound(noteBlock, soundID, 1, 4)
        local input = getInput("Want to add it (y/n) ?")
        if string.upper(input) == "Y" then
            addSound(filename, soundID)
        end
    end
end

-- plays a sound once and where the computer is asking only the ID of the sound
function testSound(noteBlock, filename)
    print('\nPress *supp* to stop.')
    parallel.waitForAny(waitForEchap, function() testSoundCore(noteBlock, filename) end)
end