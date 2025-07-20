require "/interface/scripted/starcustomchat/plugin.lua"

proximitychat = PluginClass:new(
  { name = "proximitychat" }
)

function proximitychat:init()
  self:_loadConfig()
  self.proximityRadius = root.getConfiguration("scc_proximity_radius") or self.proximityRadius
  self.receivingRestricted = root.getConfiguration("scc_proximity_restricted") or false
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
  self.proximityRadius = root.getConfiguration("scc_proximity_radius") or self.proximityRadius
  self.receivingRestricted = root.getConfiguration("scc_proximity_restricted") or false
end

function proximitychat:onCursorOverride(screenPosition)
  local id = findButtonByMode("Proximity")

  if widget.inMember("rgChatMode." .. id, screenPosition) and player.id() and world.entityPosition(player.id()) then
    starcustomchat.utils.drawCircle(world.entityPosition(player.id()), self.proximityRadius, "green")
  end
end