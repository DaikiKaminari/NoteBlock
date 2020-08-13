-- [V1.32]
--- INIT ---
function init()
	print("\n--- INIT objectJSON ---")
	if not fs.exists("lib/json") then
		error("File not found : [lib/json]")
	end
	os.loadAPI("lib/json")
	print("API [lib/json] initialized")
end

--- FUNCTIONS ---
-- returns json object with the list of players
function listConnectedPlayers()
	local obj = http.get("http://api.mineaurion.com/v1/serveurs")
	if obj == nil then
		print("Warning : HTTP request on [http://api.mineaurion.com/v1/serveurs] failed.")
		return nil
	end
	local str = obj.readAll()
	local arrObj = json.decode(str) -- array of json object containing each server
	return arrObj
end

-- convert text (in json format) into a JSON object (table) and returns it
function decode(text)
	if text == nil then
		error("text cannot be nil.")
	end
	return json.decode(text)
end

-- get the content of a file and returns a JSON object (table)
function decodeFromFile(filename)
	if filename == nil then
		error("filename cannot be nil.")
	end
	if not fs.exists(filename) then
		error("[" .. filename .. "] not found.")
	end
	return json.decodeFromFile(filename)
end

-- get the content of a HTTP link and returns a JSON object (table)
function decodeHTTP(link)
	if link == nil then
		error("link cannot be nil.")
	end
	local request = http.get(link)
	if request == nil then
		print("Warning : HTTP request on [" .. link .. "] failed.")
		return nil
	end
	return json.decode(request.readAll())
end

-- get the content of a HTTP link and save it to a file
function decodeHTTPSave(link, filename)
	if link == nil then
		error("link cannot be nil.")
	end
	if filename == nil then
		error("filename cannot be nil.")
	end
	local request = http.get(link)
	if request == nil then
		print("Warning : HTTP request on [" .. link .. "] failed.")
		return nil
	end
	local h = fs.open(filename, "w")
	h.write(encodePretty(decode(request.readAll())))
	h.close()
end

-- convert JSON object (table) into a string
function encode(obj)
	if obj == nil then
		error("obj cannot be nil.")
	end
	return json.encore(obj)
end

-- convert JSON object (table) into a string (pretty json)
function encodePretty(obj)
	if obj == nil then
		error("obj cannot be nil.")
	end
	return json.encore(obj)
end

-- save a table to a JSON file
function encodeAndSavePretty(filename, obj)
	if filename == nil then
		error("filename cannot be nil.")
	end
	if obj == nil then
		error("obj cannot be nil.")
	end
	if not fs.exists(filename) then
		print("Creating file [" .. filename .. "]")
	end
	local h = fs.open(filename, "w")
	h.write(json.encodePretty(obj))
	h.close()
end