local fileName = "sounds"   -- string : name of .json file containing sound list

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
    if not exists("sounds") then
        error("[sounds] not found.")
    end
end

local function addSound(filename, soundName, soundID)
    if sound.addSound(filename, soundName, soundID) then
        print("Sound [" .. soundName .. "] with ID [" .. soundID .. "] added to list.")
    else
        print("No new sound have been added.")
    end
end

local function delSound(filename, soundName)
    local soundID = sound.delSound(filename, soundName)
    if soundID ~= nil then
        print("Sound [" .. soundName .. "] which ID was [" .. soundID .. "] removed from list.")
    end
end

local function parse(input)
    while true do
        local input = io.read()
        if input == "add" then
            print("\nAdding new sound, please specify :")
            local soundName = io.read("Sound Name :")
            local soundID = io.read("Sound ID :")
            addSound("sounds", soundName, soundID)
        elseif input == "del" then
            print("\nDeleting a sound, please specify :")
            local soundName = io.read("Sound Name :")
            delSound("sounds", soundName)
        end
    end
end

local function main()
    loadAPIs()
    init()
    while true do
        term.clear()
        print("Waiting for an instruction...")
        local input = io.read()
        parse(input)
    end
end

main()