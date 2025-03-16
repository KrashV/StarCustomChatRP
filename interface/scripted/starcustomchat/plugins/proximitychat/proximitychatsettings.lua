require "/interface/scripted/starcustomchatsettings/settingsplugin.lua"

proximitychat = SettingsPluginClass:new(
  { name = "proximitychat" }
)


-- Settings
function proximitychat:init()
  self:_loadConfig()

  self.proximityRadius = root.getConfiguration("scc_proximity_radius") or self.proximityRadius
  self.widget.setSliderRange("sldProxRadius", 0, 90, 1)
  self.widget.setSliderValue("sldProxRadius", self.proximityRadius - 10)
  self.widget.setText("lblProxRadiusValue", self.proximityRadius)

  self.widget.setChecked("chkRestrictReceiving", root.getConfiguration("scc_proximity_restricted") or false)
end

function proximitychat:cursorOverride(screenPosition)
  if widget.active(self.layoutWidget) and (self.widget.inMember("sldProxRadius", screenPosition) 
    or self.widget.inMember("lblProxRadiusValue", screenPosition) 
    or self.widget.inMember("lblProxRadiusHint", screenPosition)) then
    
    if player.id() and world.entityPosition(player.id()) then
      starcustomchat.utils.drawCircle(world.entityPosition(player.id()), self.proximityRadius, "green")
    end
  end
end

function proximitychat:updateProxRadius(widgetName)
  self.proximityRadius = self.widget.getSliderValue("" .. widgetName) + 10
  self.widget.setText("lblProxRadiusValue", self.proximityRadius)
  root.setConfiguration("scc_proximity_radius", self.proximityRadius)
  save()
end

function proximitychat:restrictReceiving()
  root.setConfiguration("scc_proximity_restricted", self.widget.getChecked("chkRestrictReceiving"))
  save()
end