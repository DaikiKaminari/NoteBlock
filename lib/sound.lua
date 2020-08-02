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
-- returns sound ID corresponding to a sound name
function getSoundID(filename, soundName)
    local sounds = objectJSON.decodeFromFile(filename)
    return sounds[soundName]
end

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
    end
    if volume == nil then
        volume = 100
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
    objectJSON.encodeAndSavePretty(filename, sounds)
    return true
end

-- remove a sound from the list
function delSound(filename, soundName)
    if soundName == nil then
        error("[soundName] is nil.")
    end
    local sounds = objectJSON.decodeFromFile(filename)
    local soundID = removekey(sounds, soundName)
    objectJSON.encodeAndSavePretty(filename, sounds)
    return soundID
end

-- display all sounds
function displaySounds(filename, oneByLine)
    local sounds = objectJSON.decodeFromFile(filename)
    local w, h = term.getSize()
    term.clear()
    if oneByLine then
        for k,_ in pairs(sounds) do
            print(k)
        end
    else
        local line = ""
        for k,_ in pairs(sounds) do
            if string.len(line .. k) + 3 <= w then
                line = line .. " / " .. k
            else
                print(line)
                line = ""
            end
        end
        if line ~= "" then
            print(line)
        end
    end
end