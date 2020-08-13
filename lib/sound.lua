--- INIT ---
function init()
    print("\n--- INIT sound ---")
    if not fs.exists("lib/objectJSON") then
        error("[lib/objectJSON] not found.")
    end
    os.loadAPI("lib/objectJSON")
    objectJSON.init()
    print("API [lib/sound] initialized")
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
    if soundName == "" or soundName == nil then
        return nil
    end
    local sounds = objectJSON.decodeFromFile(filename)
    local soundID = sounds[soundName]
    if soundID == nil then
        soundID = sounds[sting.upper(soundName)]
    end
    if soundID == nil then
        soundID = sounds[sting.lower(soundName)]
    end
    return soundID
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
        error("soundName is nil.")
    end
    local sounds = objectJSON.decodeFromFile(filename)
    local soundID = removekey(sounds, soundName)
    objectJSON.encodeAndSavePretty(filename, sounds)
    return soundID
end

-- display all sounds
function displaySounds(filename, oneByLine)
    local sounds = objectJSON.decodeFromFile(filename)
    if next(sounds) == nil then
        print("No sound registered yet.")
        return
    end
    local soundNames = {}
    for name,_ in sounds do
        soundNames[#soundNames] = soundNames
    end
    table.sort(soundNames)
    local w, h = term.getSize()
    term.clear()
    if oneByLine then
        for _,name in ipairs(soundNames) do
            print(name .. " - " .. sounds[name])
        end
    else
        local line
        for _,name in ipairs(sounds) do
            if line == nil then
                line = name
            elseif string.len(line .. name) + 3 <= w then
                line = line .. " / " .. name
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

-- plays a sound thanks to it's ID
function playSound(noteBlock, soundID, dX, dY, dZ, pitch, volume)
    if noteBlock == nil then
        error("noteBlock peripheral is nil.")
    end
    if soundID == nil then
        error("soundID is nil.")
    end
    if pitch == nil then
        pitch = 1 
    end
    if volume == nil then
        volume = 1000
    end
    if dX == nil then
        noteBlock.playSound(soundID, pitch, volume)
    else
        noteBlock.playSound(soundID, pitch, volume, dX, dY, dZ)
    end
end

-- plays a sound on the whole map
function playSoundGlobally(noteBlock, soundID, mapRadius, x0, y0, z0, pitch)
    if soundID == nil or soundID == "" then
        error("soundID cannot be nil or empty : " .. tostring(soundID))
    end
    if mapRadius == nil or x0 == nil or y0 == nil or z0 == nil then
        error("mapRadius, x, y, z cannot be nil : " .. tostring(mapRadius) .. ", " ..
        tostring(x0) .. ", " .. tostring(y0) .. ", " .. tostring(z0))
    end
    pitch = pitch or 1
    for xTarget=32-mapRadius, mapRadius, 64 do
        for zTarget=32-mapRadius, mapRadius, 64 do
            for yTarget=36, 220, 72 do
                playSound(noteBlock, soundID, xTarget - x0, yTarget - y0, zTarget - z0, pitch, 1000)
            end
        end
    end
end

-- plays a sound multiple times
function playSoundMultipleTimes(noteBlock, soundID, times, delay, dX, dY, dZ, pitch, volume)
    delay = delay or 0.2
    while not times or times > 0 do
        playSound(noteBlock, soundID, dX, dY, dZ, pitch, volume)
        sleep(delay)
    end
end

-- plays a sound on the whole map multiple times
function playGlobalSoundMultipleTimes(noteBlock, soundID, times, delay, mapRadius, x0, y0, z0, pitch)
    delay = delay or 0.2
    mapRadius = mapRadius or 5000
    while not times or times > 0 do
        playSoundGlobally(noteBlock, soundID, mapRadius, x0, y0, z0, pitch)
        if times then
            times = times - 1
        end
        sleep(delay)
    end
end