require "/interface/scripted/starcustomchatsettings/settingsplugin.lua"
require "/scripts/util.lua"

languages = SettingsPluginClass:new(
  { name = "languages" }
)

function languages:init()
  self:_loadConfig()

  self.languagesLevels = player.getProperty("scc_rp_languages", {})
  self.serverLanguagesData = config.getParameter("serverLanguagesData")

  if self.stagehandType and self.stagehandType ~= "" then
    if self.serverLanguagesData then
      self:buildLanguagesList()
    else
      self.widget.setVisible("lblWarningNoLanguagesSupport", true)
    end
  else
    self.widget.setVisible("lblWarningLanguagesDisabled", true)
  end
end

function languages:isAvailable()
  return config.getParameter("serverLanguagesData")
end

function languages:buildLanguagesList()
  self.widget.clearListItems("lytBase.saLanguages.listItems")
  if self.serverLanguagesData then
    self.serverLanguagesData = copy(self.serverLanguagesData)
    self.widget.setVisible("lytBase.saLanguages", true)
    self.widget.clearListItems("lytBase.saLanguages.listItems")

    for code, language in pairs(self.serverLanguagesData) do
      local li = self.widget.addListItem("lytBase.saLanguages.listItems")
      local difficulty = self.serverLanguagesData[code].difficulty or 1

      local percProf
      if difficulty == 0 then
        percProf = 100
      else
        percProf = (self.languagesLevels[code] and self.languagesLevels[code].knowledge or 0) / difficulty * 100
      end

      self.widget.setText("lytBase.saLanguages.listItems." .. li .. ".name", language.name)
      self.widget.setProgress("lytBase.saLanguages.listItems." .. li .. ".lagnuageProgress", percProf / 100)
      self.widget.setData("lytBase.saLanguages.listItems." .. li, code)
    end
  end
end

function languages:getSelectedLanguageData()
  local li = self.widget.getListSelected("lytBase.saLanguages.listItems")
  if li then
    return self.widget.getData("lytBase.saLanguages.listItems." .. li)
  end
end


function languages:selectLanguage()

  self.widget.setVisible("lytBase.lblLanguageName", true)
  self.widget.setVisible("lytBase.lblDescription", true)
  self.widget.setVisible("lytBase.lblDifficultyValue", true)
  self.widget.setVisible("lytBase.lblKnowledgeHint", true)
  self.widget.setVisible("lytBase.lblKnowledgePercent", true)
  self.widget.setVisible("lytBase.spnKnowledge", true)
  self.widget.setVisible("lytBase.lblDifficultyHint", true)


  local code = self:getSelectedLanguageData()
  if code then
    self.widget.setText("lytBase.lblLanguageName", self.serverLanguagesData[code].name)
    self.widget.setText("lytBase.lblDescription", self.serverLanguagesData[code].description or "")

    local diff = self.serverLanguagesData[code].difficulty
    self.widget.setText("lytBase.lblDifficultyValue", diff and (diff == 0 and starcustomchat.utils.getTranslation("settings.plugins.languages.difficulty_zero") or diff) or 1)
    
    self:printCurrentLevel(self.languagesLevels[code] and self.languagesLevels[code].knowledge, diff)
  end
end


function languages:printCurrentLevel(level, max)
  local percentLevel = 0
  level = level or 0
  max = max or 1

  if max == 0 then
    percentLevel = 100
  else
    percentLevel = level / max * 100
  end

  local li = self.widget.getListSelected("lytBase.saLanguages.listItems")
  self.widget.setProgress("lytBase.saLanguages.listItems." .. li .. ".lagnuageProgress", percentLevel / 100)
  self.widget.setText("lytBase.lblKnowledgePercent", string.format("%.0f%%", percentLevel))
end

languages.spnKnowledge = {}

function languages.spnKnowledge:up()

  local code = self:getSelectedLanguageData()
  if code then
    local currentKnowledge = self.languagesLevels[code] and self.languagesLevels[code].knowledge or 0
    currentKnowledge = util.clamp(currentKnowledge + 1, 0, self.serverLanguagesData[code].difficulty or 1)
    self.languagesLevels[code] = {
      knowledge = currentKnowledge
    }
    player.setProperty("scc_rp_languages", self.languagesLevels)
    self:printCurrentLevel(currentKnowledge, self.serverLanguagesData[code].difficulty)
    save()
  end
end

function languages.spnKnowledge:down()
  local code = self:getSelectedLanguageData()
  if code then
    local currentKnowledge = self.languagesLevels[code] and self.languagesLevels[code].knowledge or 0
    currentKnowledge = util.clamp(currentKnowledge - 1, 0, self.serverLanguagesData[code].difficulty or 1)
    self.languagesLevels[code] = {
      knowledge = currentKnowledge
    }
    player.setProperty("scc_rp_languages", self.languagesLevels)
    self:printCurrentLevel(currentKnowledge, self.serverLanguagesData[code].difficulty)
    save()
  end
end