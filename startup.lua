local filename = "sounds"   -- string : json file where sounds will be registered
local noteBlock             -- table : peripheral, note block
local monitor               -- table : peripheral, display monitor
local conf = {}             -- table : configuration (x,y,z coords of the computer)

--- INIT ---
local function loadAPIs(apis)
    for _,path in pairs(apis) do
        if not fs.exists(path) then
            error("API [" .. path .. "] does not exist.")
        end
        print("\nLoading API : [" .. path .. "]")
        os.loadAPI(path)
    end
end

local function loadConfig()
    if fs.exists("config") then
        conf = objectJSON.decodeFromFile("config")
    end
    if next(conf) == nil then
        print("\nPlease enter note block coordinates :")
        while type(conf["x"]) ~= "number" do
            print("X :")
            conf["x"] = tonumber(io.read())
        end
        while type(conf["y"]) ~= "number" do
            print("Y :")
            conf["y"] = tonumber(io.read())
        end
        while type(conf["z"]) ~= "number" do
            print("Z :")
            conf["z"] = tonumber(io.read())
        end
        while type(conf["radius"]) ~= "number" or conf["radius"] < 0 do
            print("\nMap radius (>= 0) :")
            conf["radius"] = tonumber(io.read())
        end
        print("\nMap center coordinates :")
        while type(conf["x0"]) ~= "number" do
            print("\nX0 :")
            conf["x0"] = tonumber(io.read())
        end
        while type(conf["y0"]) ~= "number" do
            print("\nY0 :")
            conf["y0"] = tonumber(io.read())
        end
        while type(conf["z0"]) ~= "number" do
            print("\nZ0 :")
            conf["z0"] = tonumber(io.read())
        end
        objectJSON.encodeAndSavePretty("config", conf)
    end
end

local function init(apis)
    --load APIs
    loadAPIs(apis)
    -- initialize global variables and peripherals
    noteBlock = peripheral.find("note_block")
    if noteBlock == nil then
        error("NoteBlock peripheral not found.")
    end
    monitor = peripheral.find("monitor")
    -- run init() for each API
    for _,path in pairs(apis) do
        local api
        for v in path:gmatch("([^/]+)") do
            api = v
        end
        if _G[api].init ~= nil then
            _G[api].init()
        end
    end
    -- load or create configuration
    loadConfig()
end

--- FUNCTIONS ---
-- prints all registered sounds
local function actualizeDisplay(doNotClear)
    if not doNotClear then
        term.clear()
    end
    sound.displaySounds(filename, false)
    if monitor ~= nil then
        local native = term.native()
        term.redirect(monitor)
        sound.displaySounds(filename, true)
        term.redirect(native)
    end
end


--- MAIN CALL ---
local function main()
    init({"lib/sound", "soundManager", "parser"})
    if monitor ~= nil then
        actualizeDisplay()
    end
    
    local inst = {"ADD", "MODIFY", "DEL", "PLAY", "PLAY_HERE", "PLAY_CUSTOM", "PLAY_CUSTOM_HERE", "PLAY_GLOBALLY", "TEST_SOUND", "RESET_CONFIG"}
    local input = ""
    while true do
        print("\nWaiting for an instruction...")
        for _,v in pairs(inst) do
            print(" - " .. v)
        end
        input = io.read()
        actualizeDisplay()
        parser.parse(filename, noteBlock, input)
        if input == "ADD" or input == "MODIFY" or input == "DEL" then
            actualizeDisplay(true)
        end
    end
end

main()