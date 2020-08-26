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

-- returns true if an element is present as a key of a table
local function isKeyPresent(tab, key)
    for k,_ in pairs(tab) do
        if k == key then
            return true
        end
    end
    return false
end

-- returns true if an element is present as a value of a table
local function isValuePresent(tab, value)
    for _,v in pairs(tab) do
        if v == value then
            return true
        end
    end
    return false
end

-- returns first key found corresponding to a value
local function getKey(tab, value)
    for k,v in pairs(tab) do
        if v == value then
            return k
        end
    end
    return nil
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
-- returns sound ID corresponding to a sound name
function getSoundID(filename, soundName)
    if soundName == "" or soundName == nil then
        return nil
    end
    local sounds = objectJSON.decodeFromFile(filename)
    local soundID = sounds[soundName]
    if soundID == nil then
        soundID = sounds[string.upper(soundName)]
    end
    if soundID == nil then
        soundID = sounds[string.lower(soundName)]
    end
    return soundID
end

-- add a new sound to the list
function addSound(filename, soundName, soundID)
    if soundName == nil or then
        error("soundName cannot be nil or empty.")
        return false
    end
    if soundID == nil or soundID == "" then
        print("soundID cannot be nil or empty.")
        return false
    end
    local sounds = objectJSON.decodeFromFile(filename)
    if sounds[soundName] ~= nil then
        print("\nSound [" .. soundName .. "] already exists with ID : [" .. sounds[soundID] .. "].")
        local answer = getInput("Would you like to change sound ID  from [" .. sounds[soundID] .. "] to [" .. soundID .. "] ? (Y/N)")
        if string.upper(answer) ~= "Y" then
            return false
        end
    end
    if isValuePresent(sounds, soundID) then
        print("\nSound ID [" .. soundID .. "] already exist with sound name [" .. getKey(sounds, soundID) .. "].")
        local answer = getInput("Would you like to change sound name from [" .. getKey(sounds, soundID) .. "] to [" .. soundName .. "] ? (Y/N)")
        if string.upper(answer) ~= "Y" then
            return false
        end
        removekey(sounds, soundName)
    end
    sounds[soundName] = soundID
    objectJSON.encodeAndSavePretty(filename, sounds)
    return true
end

-- modify sound name
function modifySound(filename, soundName, newSoundName)
    if filename == nil then
        print("filename cannot be nil.")
        return false
    end
    if soundName == nil or soundName == "" then
        print("soundName cannot be empty or nil.")
        return false
    end
    if newSoundName == nil or newSoundName == "" then
        print("newSoundName cannot be empty or nil.")
        return false
    end
    local sounds = objectJSON.decodeFromFile(filename)
    if not isKeyPresent(sounds, soundName) then
        print("\nSound name [" .. soundName .. "] not present.")
        return false
    end
    local soundID = sounds[soundName]
    removekey(sounds, soundName)
    sounds[newSoundName] = soundID
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
function displaySounds(filename, multipleColumns)
    local sounds = objectJSON.decodeFromFile(filename)
    if next(sounds) == nil then
        print("No sound registered yet.")
        return
    end
    local soundNames = {}
    for name,_ in pairs(sounds) do
        soundNames[#soundNames + 1] = name
    end
    table.sort(soundNames)
    local w, h = term.getSize()
    term.clear()
    if multipleColumns then -- prints multiple columns of names in alphabetical order
        local _,l = term.getSize()
        local x = 1
        local y = 1
        for _,name in ipairs(soundNames) do
            term.setCursorPos(x,y)
            term.write(name)
            y = y + 1
            if y >= l then
                y = 1
                x = x + 16
            end
        end
    else                    -- prints names one after another in the most compacted way
        local line          
        for _,name in ipairs(soundNames) do
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

-- display sound name and sound IDs
function displaySoundIDs(filename) -- WIP
    local _,l = term.getSize()
    local sounds = objectJSON.decodeFromFile(filename)
    if next(sounds) == nil then
        print("No sound registered yet.")
        return
    end
    local soundNames = {}
    for name,_ in pairs(sounds) do
        soundNames[#soundNames + 1] = name
    end
    table.sort(soundNames)
    local w, h = term.getSize()

    term.clear()
    local y = 1
    for _,name in ipairs(soundNames) do
        term.setCursorPos(1, y)
        term.write(name .. " - " .. sounds[name])
        y = y + 1
        if n >= l then
            getInput("Press enter...")
            term.clear()
            y = 1
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
    pitch = pitch or 1
    volume = volume or 10
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
    local yMin = 45
    for xTarget=32-mapRadius, mapRadius, 64 do
        for zTarget=32-mapRadius, mapRadius, 64 do
            for yTarget=yMin, 256-yMin, yMin*2 do
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
        times = times - 1
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