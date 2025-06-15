require "/interface/scripted/starcustomchatsettings/settingsplugin.lua"

myname = SettingsPluginClass:new(
  { name = "myname" }
)


-- Settings
function myname:init()
  self:_loadConfig()

  self.myNameList = player.getProperty("scc_myname_list") or {}
  local coloring = root.getConfiguration("coloringscc_myname_coloring_enabled") or false
  local pingEnabled = root.getConfiguration("scc_myname_ping_enabled") or false
  local backgroundEnabled = root.getConfiguration("scc_myname_background_enabled") or false

  self.widget.setChecked("chkColoringEnabled", coloring)
  self.widget.setChecked("chkPingEnabled", pingEnabled)
  self.widget.setChecked("chkBackgroundEnabled", backgroundEnabled)
end

function myname:openTab()
  self.widget.registerMemberCallback("saScrollArea.listItems", "removeName", function(_, data)
    self:removeName(_, data)
  end)
  self:populateScrollArea()
end

function myname:populateScrollArea()
  self.widget.clearListItems("saScrollArea.listItems")

  -- Always starts with player name
  local li = self.widget.addListItem("saScrollArea.listItems")
  self.widget.setText("saScrollArea.listItems." .. li .. ".name", player.name())
  self.widget.setButtonEnabled("saScrollArea.listItems." .. li .. ".btnRemove", false)
  self.widget.removeChild("saScrollArea.listItems." .. li, "btnRemove")

  for _, name in ipairs(self.myNameList) do
    local li = self.widget.addListItem("saScrollArea.listItems")
    self.widget.setText("saScrollArea.listItems." .. li .. ".name", name)
    self.widget.setData("saScrollArea.listItems." .. li .. ".btnRemove", {
      displayText = "settings.plugins.myname.remove_name",
      name = name
    })
  end

end

function myname:removeName(_, data)
  local li = self.widget.getListSelected("saScrollArea.listItems")
  if not li or li == 1 then
    return
  end

  local ind = index(self.myNameList, data.name)
  if ind then
    table.remove(self.myNameList, ind)
    player.setProperty("scc_myname_list", self.myNameList)
    self:populateScrollArea()
  end
end

function myname:addNewName()
  local name = self.widget.getText("tbxAddNewName")
  if name == "" then
    return
  end


  local li = self.widget.addListItem("saScrollArea.listItems")
  self.widget.setText("saScrollArea.listItems." .. li .. ".name", name)
  self.widget.setText("tbxAddNewName", "")
  self.widget.setData("saScrollArea.listItems." .. li .. ".btnRemove", {
    displayText = "settings.plugins.myname.remove_name",
    name = name
  })

  table.insert(self.myNameList, name)
  player.setProperty("scc_myname_list", self.myNameList)
  self.widget.blur("tbxAddNewName")
end

function myname:toggleMyNameEnabled()
  local coloring = self.widget.getChecked("chkColoringEnabled")
  root.setConfiguration("coloringscc_myname_coloring_enabled", coloring)
  save()
end

function myname:togglePingEnabled()
  local pingEnabled = self.widget.getChecked("chkPingEnabled")
  root.setConfiguration("scc_myname_ping_enabled", pingEnabled)
  save()
end

function myname:toggleBackgroundEnabled()
  local backgroundEnabled = self.widget.getChecked("chkBackgroundEnabled")
  root.setConfiguration("scc_myname_background_enabled", backgroundEnabled)
  save()
end