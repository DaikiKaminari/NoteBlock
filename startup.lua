local filename = "sounds"   -- string : json file where sounds will be registered
local noteBlock             -- table : peripheral, note block
local monitor               -- table : peripheral, display monitor
local conf = {}             -- table : configuration (x,y,z coords of the computer)

--- UTILS ---
-- returns an input entered by the user
local function getInput(question)
    if not question then
        print(question)
    end
    term.setTextColor(colors.blue)
    local answer = io.read()
    term.setTextColor(colors.white)
    return answer
end

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
            conf["x"] = tonumber(getInput("X :"))
        end
        while type(conf["y"]) ~= "number" do
            conf["y"] = tonumber(getInput("Y :"))
        end
        while type(conf["z"]) ~= "number" do
            conf["z"] = tonumber(getInput("Z :"))
        end
        while type(conf["radius"]) ~= "number" or conf["radius"] < 0 do
            conf["radius"] = tonumber(getInput("\nMap radius (>= 0) :"))
        end
        print("\nMap center coordinates :")
        while type(conf["x0"]) ~= "number" do
            conf["x0"] = tonumber(getInput("X0 :"))
        end
        while type(conf["y0"]) ~= "number" do
            conf["y0"] = tonumber(getInput("Y0 :"))
        end
        while type(conf["z0"]) ~= "number" do
            conf["z0"] = tonumber(getInput("Z0 :"))
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
        input = getInput()
        actualizeDisplay()
        parser.parse(filename, noteBlock, input)
        if input == "ADD" or input == "MODIFY" or input == "DEL" then
            actualizeDisplay(true)
        end
    end
end

main()