--- INIT ---
function init()
    if not fs.exists("soundManager") then
        error("[soundManager] not found.")
    end
    os.loadAPI("soundManager")
end

--- FUNCTIONS ---
-- parses the instructions and call the corresponding function
function parse(input)
    soundManager.actualizeDisplay(true)
    if string.upper(input) == "ADD" then soundManager.addSound()
    elseif string.upper(input) == "DEL" then soundManager.delSound()
    elseif string.upper(input) == "PLAY" then soundManager.playSound(false)
    elseif string.upper(input) == "PLAY_HERE" then soundManager.playSound(true)
    elseif string.upper(input) == "PLAY_CUSTOM" then soundManager.playCustomSound(false)
    elseif string.upper(input) == "PLAY_CUSTOM_HERE" then soundManager.playCustomSound(true)
    elseif string.upper(input) == "PLAY_GLOBALLY" then soundManager.playSoundGlobally()
    elseif string.upper(input) == "DISPLAY" then
    else
        print("Input not recognized as an instruction.")
        sleep(2)
    end
end