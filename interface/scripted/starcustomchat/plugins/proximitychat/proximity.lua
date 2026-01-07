require "/interface/scripted/starcustomchat/plugin.lua"

proximitychat = PluginClass:new(
  { name = "proximitychat" }
)

function proximitychat:init()
  self:_loadConfig()
  self.proximityRadius = root.getConfiguration("scc_proximity_radius") or self.proximityRadius
  self.receivingRestricted = root.getConfiguration("scc_proximity_restricted") or false
  widget.setText("lytProxChangeRadius.lblProxRadiusValue", self.proximityRadius)
  widget.setSliderRange("lytProxChangeRadius.sldProxRadius", 0, 90, 1)
  widget.setSliderValue("lytProxChangeRadius.sldProxRadius", self.proximityRadius - 10)
end

function proximitychat:onSendMessage(message)
  if message.mode == "Proximity" then
    message.proximityRadius = self.proximityRadius
    
    if self.uniqueStagehandType and self.uniqueStagehandType ~= "" then
      starcustomchat.utils.sendMessageToUniqueStagehand(self.uniqueStagehandType, "icc_sendMessage", message)
    elseif self.stagehandType and self.stagehandType ~= "" then
      starcustomchat.utils.createStagehandWithData(self.stagehandType, {message = "sendProxyMessage", data = message})
    else
      
      local function sendMessageToPlayers()
        local position = player.id() and world.entityPosition(player.id())
        if position then
          local players = world.playerQuery(position, message.proximityRadius)
          for _, pl in ipairs(players) do 
            world.sendEntityMessage(pl, "scc_add_message", message)
          end
          return true
        end
      end

      local sendMessagePromise = {
        finished = sendMessageToPlayers,
        succeeded = function() return true end
      }

      promises:add(sendMessagePromise)
    end

    if not message.outloud then
      player.say(message.text)
    end
  end
end

function proximitychat:formatIncomingMessage(message)
  if message.mode == "Proximity" then
    if self.receivingRestricted and message.connection then
      local authorEntityId = message.connection * -65536
      if world.entityExists(authorEntityId) then
        if world.magnitude(world.entityPosition(player.id()), world.entityPosition(authorEntityId)) > self.proximityRadius then
          message.text = ""
        end
      end
    end
    message.portrait = message.portrait and message.portrait ~= "" and message.portrait or message.connection
  end
  return message
end

function proximitychat:onReceiveMessage(message)
  if message.connection ~= 0 and message.mode == "Proximity" then
    sb.logInfo("Chat: <%s> %s", message.nickname, message.text)
  end
end

function proximitychat:onSettingsUpdate(data)
  if data then
    if data.newProximityRadius then
      self.proximityRadius = data.newProximityRadius
      widget.setText("lytProxChangeRadius.lblProxRadiusValue", self.proximityRadius)
      widget.setSliderValue("lytProxChangeRadius.sldProxRadius", self.proximityRadius - 10)
      root.setConfiguration("scc_proximity_radius", self.proximityRadius)
    elseif data.newProximityRestriction then
      self.receivingRestricted = data.newProximityRestriction or false
      root.setConfiguration("scc_proximity_restricted", self.receivingRestricted)
    end
  end
end

function proximitychat:onCursorOverride(screenPosition)
  local id = findButtonByMode("Proximity")

  if player.id() and world.entityPosition(player.id()) then
    if widget.inMember("rgChatMode." .. id, screenPosition) then
      starcustomchat.utils.drawCircle(world.entityPosition(player.id()), self.proximityRadius, "green")
    end

    if widget.getSelectedData("rgChatMode").mode == "Proximity" and (
    widget.inMember("rgChatMode." .. id, screenPosition) or widget.inMember("lytProxChangeRadius", screenPosition)) then
      widget.setVisible("lytProxChangeRadius", true)

      if widget.inMember("lytProxChangeRadius.sldProxRadius", screenPosition) then
        starcustomchat.utils.drawCircle(world.entityPosition(player.id()), self.proximityRadius, "green")
      end
    else
      widget.setVisible("lytProxChangeRadius", false)
    end
  end
end

function proximitychat:onLocaleChange()
  widget.setText("lytProxChangeRadius.lblRadius", starcustomchat.utils.getTranslation("settings.proximity.radius"))
end


function proximitychat:onCustomButtonClick(widgetName)
  if widgetName == "sldProxRadius" then
    self:onSettingsUpdate({
      newProximityRadius = widget.getSliderValue("lytProxChangeRadius.sldProxRadius") + 10
    })
  end
end