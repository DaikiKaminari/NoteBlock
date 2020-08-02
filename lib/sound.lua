--- INIT ---
function init()
    if not fs.exists("lib/objectJSON") then
        error("[lib/objectJSON] not found.")
    end
    os.loadAPI("lib/objectJSON")
    objectJSON.init()
end

--- GLOBAL VARIABLES ---

--- UTILS ---
-- set a key to nil and returns corresponding value
local function removekey(tab, key)
    local element = tab[key]
    tab[key] = nil
    return element
end

--- FUNCTIONS ---
-- play a sound thanks to it's ID
function playSound(noteBlock, soundID, dX, dY, dZ, pitch, volume)
    if noteBlock == nil then
        error("[noteBlock] peripheral is nil.")
    end
    if soundID == nil then
        error("[soundID] is nil.")
    end
    if pitch == nil then
        pitch = 1 
        volume = 0
    else
        if volume < 0 or volume > 1000 then
            error("[volume] value must be between 0 and 1000.")
        end
    end
    if dX == nil then
        noteBlock.playSound(soundID, pitch, volume)
    else
        noteBlock.playSound(soundID, pitch, volume, dX, dY, dZ)
    end
end

-- add a new sound to the list
function addSound(filename, soundName, soundID)
    if soundName == nil then
        error("[soundName] is nil.")
    elseif soundName == "" then
        print("[soundName] cannot be empty.")
        return false
    end
    local sounds = objectJSON.decodeFromFile(filename)
    if sounds[soundName] ~= nil then
        print("Sound [" .. soundName .. "] already exists with ID : [" .. sounds[soundID] .. "].")
        print("Would you like to change sound ID [" .. sounds[soundID] .. "] to [" .. soundID .. "] ? (Y/N)")
        local answer = io.read()
        if answer ~= "Y" and answer ~= "y" then
            return false
        end
    end
    sounds[soundName] = soundID
    encodeAndSavePretty(filename, sounds)
    return true
end

-- remove a sound from the list
function delSound(filename, soundName)
    if soundName == nil then
        error("[soundName] is nil.")
    end
    local sounds = objectJSON.decodeFromFile(filename)
    local soundID = removekey(sounds, soundName)
    encodeAndSavePretty(filename, sounds)
    return soundID
end

