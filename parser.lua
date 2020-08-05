--- INIT ---
function init()
    if not fs.exists("soundManager") then
        error("[soundManager] not found.")
    end
    os.loadAPI("soundManager")
end

--- FUNCTIONS ---
-- parses the instructions and call the corresponding function
function parse(filename, noteBlock, input)
    if string.upper(input) == "ADD" then soundManager.addSound(filename)
    elseif string.upper(input) == "DEL" then soundManager.delSound(filename)
    elseif string.upper(input) == "PLAY" then soundManager.playSound(filename, noteBlock, false)
    elseif string.upper(input) == "PLAY_HERE" then soundManager.playSound(filename, noteBlock, true)
    elseif string.upper(input) == "PLAY_CUSTOM" then soundManager.playCustomSound(filename, noteBlock, false)
    elseif string.upper(input) == "PLAY_CUSTOM_HERE" then soundManager.playCustomSound(filename, noteBlock, true)
    elseif string.upper(input) == "PLAY_GLOBALLY" then soundManager.playSoundGlobally(filename, noteBlock)
    elseif string.upper(input) == "RESET_CONFIG" then fs.delete("config") os.reboot()
    else
        print("Input not recognized as an instruction.")
        sleep(2)
    end
end