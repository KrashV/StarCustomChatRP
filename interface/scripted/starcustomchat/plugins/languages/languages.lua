require "/interface/scripted/starcustomchat/plugin.lua"
require "/interface/BiggerChat/scripts/utf8.lua"

languages = PluginClass:new(
  { name = "languages" }
)

function languages:init(chat)
  PluginClass.init(self, chat)

  widget.setButtonEnabled("lytLeftMenu.saButtons.btnSelectRPLanguage", false)
  self.defaultLi = ""
  self.languagesLevels = player.getProperty("scc_rp_languages", {})
  self.serverLanguagesData = nil

  if self.stagehandType and self.stagehandType ~= "" then
    self.requestDataCoroutine = coroutine.wrap(function()
      while not player.id() or not world.entityPosition(player.id()) do
        coroutine.yield()
      end

      starcustomchat.utils.createStagehandWithData(self.stagehandType, {
        message = "retrieveLanguages",
        data = {
          playerId = player.id()
        }
      })
      self.requestDataCoroutine = nil
      return true
    end)
  end
end

function languages:registerMessageHandlers()

  starcustomchat.utils.setMessageHandler( "scc_rp_languages", function(_, _, serverLanguagesData)
    if serverLanguagesData then
      self.serverLanguagesData = serverLanguagesData
      widget.setButtonEnabled("lytLeftMenu.saButtons.btnSelectRPLanguage", true)
      self:populateLanguageList()
    end
  end)
end

function languages:update(dt)
  if self.requestDataCoroutine then
    self.requestDataCoroutine()
  end
  promises:update()
end

function languages:openSettings(settingsInterface)
  settingsInterface.serverLanguagesData = self.serverLanguagesData
end

function languages:populateLanguageList()
  widget.clearListItems("lytSelectLanguage.saLanguages.listChatLanguages")

  self.defaultLi = widget.addListItem("lytSelectLanguage.saLanguages.listChatLanguages")
  widget.setText("lytSelectLanguage.saLanguages.listChatLanguages." .. self.defaultLi .. ".name", starcustomchat.utils.getTranslation("chat.language.disabled"))
  widget.setListSelected("lytSelectLanguage.saLanguages.listChatLanguages", self.defaultLi)

  for code, langConfig in pairs(self.serverLanguagesData) do 
    local li = widget.addListItem("lytSelectLanguage.saLanguages.listChatLanguages")

    local difficulty = self.serverLanguagesData[code].difficulty or 1
    local percProf
    if difficulty == 0 then
      percProf = 100
    else
      percProf = (self.languagesLevels[code] and self.languagesLevels[code].knowledge or 0) / difficulty * 100
    end

    local data = {
      code = code,
      displayPlainText = (langConfig.description and langConfig.description .. " " or "") .. starcustomchat.utils.getTranslation("tooltips.languages.proficiency", string.format("%.0f%%", percProf))
    }
    
    widget.setProgress("lytSelectLanguage.saLanguages.listChatLanguages." .. li .. ".lagnuageProgress", percProf / 100)
    widget.setText("lytSelectLanguage.saLanguages.listChatLanguages." .. li .. ".name", langConfig.name)
    widget.setData("lytSelectLanguage.saLanguages.listChatLanguages." .. li, data)
    widget.setData("lytSelectLanguage.saLanguages.listChatLanguages." .. li .. ".background", data)
    
    if code == self.selectedLanguage then
      widget.setListSelected("lytSelectLanguage.saLanguages.listChatLanguages", li)
    end
  end
end

function shuffleFunction(content, myLevel, difficulty, specialCharacters)
  -- If difficulty is 0, we assume the player knows the language, return the content as is
  myLevel = myLevel or 0

  if difficulty == 0 then
    return content
  end

  -- If difficulty is 1 and myLevel > 0, the player knows the language, return the content as is
  if difficulty == 1 and myLevel > 0 then
    return content
  end

  -- Calculate the "knowledge fraction" between myLevel and difficulty
  local knowledgeFraction = math.min(myLevel / difficulty, 1)

  -- If myLevel is 0 and difficulty isn't 0, obfuscate the text
  if myLevel ~= difficulty then
    local obfuscatedContent = {}

    local shuffleIntensity = math.max(0, 1 - knowledgeFraction)

    for word in content:gmatch("%S+") do
      if math.random() < shuffleIntensity then
        -- Obfuscate the word
        table.insert(obfuscatedContent, obfuscateWord(word, specialCharacters or {}))
      else
        -- Keep the word as is
        table.insert(obfuscatedContent, word)
      end
    end

    return table.concat(obfuscatedContent, " ")
  end

  return content
end

function obfuscateWord(word, specialCharacters)
  local obfuscatedWord = {}
  local similarCharacters = {
    -- Lowercase English
    ["a"] = "@", ["b"] = "8", ["c"] = "(", ["d"] = "|)", ["e"] = "3", ["f"] = "ph", ["g"] = "9", ["h"] = "#", ["i"] = "!", 
    ["j"] = ";", ["k"] = "|<", ["l"] = "1", ["m"] = "/\\/\\", ["n"] = "|\\|", ["o"] = "0", ["p"] = "|*", ["q"] = "9", 
    ["r"] = "2", ["s"] = "$", ["t"] = "+", ["u"] = "|_|", ["v"] = "\\/", ["w"] = "\\/\\/", ["x"] = "%", ["y"] = "`/", ["z"] = "2",
  
    -- Uppercase English
    ["A"] = "@", ["B"] = "8", ["C"] = "(", ["D"] = "|)", ["E"] = "3", ["F"] = "PH", ["G"] = "9", ["H"] = "#", ["I"] = "!", 
    ["J"] = ";", ["K"] = "|<", ["L"] = "1", ["M"] = "/\\/\\", ["N"] = "|\\|", ["O"] = "0", ["P"] = "|*", ["Q"] = "9", 
    ["R"] = "2", ["S"] = "$", ["T"] = "+", ["U"] = "|_|", ["V"] = "\\/", ["W"] = "\\/\\/", ["X"] = "%", ["Y"] = "`/", ["Z"] = "2",
  
    -- Lowercase Russian
    ["а"] = "@", ["б"] = "6", ["в"] = "B", ["г"] = "r", ["д"] = "g", ["е"] = "3", ["ё"] = "e", ["ж"] = "X", ["з"] = "3", 
    ["и"] = "u", ["й"] = "u~", ["к"] = "k", ["л"] = "JI", ["м"] = "M", ["н"] = "H", ["о"] = "0", ["п"] = "n", ["р"] = "p", 
    ["с"] = "c", ["т"] = "T", ["у"] = "y", ["ф"] = "o", ["х"] = "x", ["ц"] = "u", ["ч"] = "4", ["ш"] = "w", ["щ"] = "w~", 
    ["ъ"] = "b", ["ы"] = "bl", ["ь"] = "b", ["э"] = "3", ["ю"] = "10", ["я"] = "R",
  
    -- Uppercase Russian
    ["А"] = "@", ["Б"] = "6", ["В"] = "B", ["Г"] = "r", ["Д"] = "g", ["Е"] = "3", ["Ё"] = "E", ["Ж"] = "X", ["З"] = "3", 
    ["И"] = "U", ["Й"] = "U~", ["К"] = "K", ["Л"] = "JI", ["М"] = "M", ["Н"] = "H", ["О"] = "0", ["П"] = "N", ["Р"] = "P", 
    ["С"] = "C", ["Т"] = "T", ["У"] = "Y", ["Ф"] = "O", ["Х"] = "X", ["Ц"] = "U", ["Ч"] = "4", ["Ш"] = "W", ["Щ"] = "W~", 
    ["Ъ"] = "B", ["Ы"] = "BL", ["Ь"] = "B", ["Э"] = "3", ["Ю"] = "10", ["Я"] = "R"
  }

  for i, c in utf8.codes(word) do
    local char = utf8.char(c)
    if not char:match("[%s%p%c]") then
      -- Replace with a visually similar character or random special character
      if math.random() < 0.5 then
        char = similarCharacters[char] or char
      else
        char = getRandomCharacter(specialCharacters)
      end
    end
    table.insert(obfuscatedWord, char)
  end

  -- Randomly shuffle the obfuscated word slightly
  if #obfuscatedWord > 1 then
    for i = 1, math.random(1, #obfuscatedWord // 2) do
      local idx1 = math.random(1, #obfuscatedWord)
      local idx2 = math.random(1, #obfuscatedWord)
      obfuscatedWord[idx1], obfuscatedWord[idx2] = obfuscatedWord[idx2], obfuscatedWord[idx1]
    end
  end

  return table.concat(obfuscatedWord)
end


function getRandomCharacter(specialCharacters)
  local randomChars = {
    "A", "a", "B", "b", "C", "c", "D", "d", "E", "e", "F", "f", "G", "g", "H", "h",
    "I", "i", "J", "j", "K", "k", "L", "l", "M", "m", "N", "n", "O", "o", "P", "p",
    "Q", "q", "R", "r", "S", "s", "T", "t", "U", "u", "V", "v", "W", "w", "X", "x",
    "Y", "y", "Z", "z", "'", table.unpack(specialCharacters)
  }
  return randomChars[math.random(#randomChars)]
end

function languages:formatIncomingMessage(message)
  if self.serverLanguagesData and message.text then

    message.text = message.text:gsub('%b""', function(quoted)
      local content = quoted:sub(2, -2)
      for code, language in pairs(self.serverLanguagesData) do 
        if content:find("^clear;" .. code .. "^reset;", nil, true) then
          content = content:sub(string.len("^clear;" .. code .. "^reset;") + 1)
          math.randomseed(message.uuid)
          content = shuffleFunction(content, self.languagesLevels[code] and self.languagesLevels[code].knowledge, language.difficulty or 1, language.specialCharacters)
          message.languageName = language.name
          message.languageCode = code
          break
        end
      end
      return '"' .. content .. '"'
    end)
  end

  return message
end

function languages:onCreateTooltip(screenPosition)
  local selectedMessage = self.customChat:selectMessage()
  if selectedMessage and selectedMessage.languageName then
    return starcustomchat.utils.getTranslation("tooltips.languages.name", selectedMessage.languageName)
  end
end

function languages:formatOutcomingMessage(message)
  if self.serverLanguagesData and self.selectedLanguage and message.text then
    local originalText = message.text

    message.text = message.text:gsub('%b""', function(quoted)
      return '"^clear;' .. self.selectedLanguage .. "^reset;" .. quoted:sub(2)
    end)

    message.silent = true
    if message.mode ~= "Whisper" then
      player.say(originalText:gsub('%b""', function(quoted)
        return shuffleFunction(quoted, 0, 1)
      end))
    end
  end
  return message
end

function languages:onSettingsUpdate(data)
  self.languagesLevels = player.getProperty("scc_rp_languages", {})
  if self.serverLanguagesData then
    self:populateLanguageList()
  end
end

function languages:onCustomButtonClick(btnName, data)
  if btnName == "btnSelectRPLanguage" then
    widget.setVisible("lytSelectLanguage", not widget.active("lytSelectLanguage"))
  elseif btnName == "listChatLanguages" then
    local li = widget.getListSelected("lytSelectLanguage.saLanguages.listChatLanguages")
    if li then
      local data = widget.getData("lytSelectLanguage.saLanguages.listChatLanguages." .. li)
      if data and data.code then
        local code = data.code
        if self.serverLanguagesData and self.serverLanguagesData[code] then
          if (not self.serverLanguagesData[code].difficulty or self.serverLanguagesData[code].difficulty ~= 0) 
          and (not self.languagesLevels[code] or self.languagesLevels[code].knowledge == 0) then
            starcustomchat.utils.alert("chat.alerts.languages.unknown", self.serverLanguagesData[code].name)
            widget.setListSelected("lytSelectLanguage.saLanguages.listChatLanguages", self.defaultLi)
            self.selectedLanguage = nil
          else
            self.selectedLanguage = code
            starcustomchat.utils.alert("chat.alerts.languages.selected", self.serverLanguagesData[code].name)
            widget.setVisible("lytSelectLanguage", false)
          end
        end
      else
        self.selectedLanguage = nil
        widget.setVisible("lytSelectLanguage", false)
      end
    end
    widget.setButtonImages("lytLeftMenu.saButtons.btnSelectRPLanguage", {
      base = string.format("/interface/scripted/starcustomchat/plugins/languages/interface/languages%s.png", self.selectedLanguage and "selected" or ""),
      hover = string.format("/interface/scripted/starcustomchat/plugins/languages/interface/languages%shover.png",  self.selectedLanguage and "selected" or "")
    })
  end
end

function languages:onChatScroll(screenPosition)
  return widget.active("lytSelectLanguage") and widget.inMember("lytSelectLanguage", screenPosition)
end