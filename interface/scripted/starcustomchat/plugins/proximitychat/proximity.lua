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
    message.time = printTime()
    -- FezzedOne: Add a sender ID to proximity messages because xStarbound clients can control
    -- multiple players. Good practice to do it for all senders anyway.
    message.senderId = player.id()
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
            -- FezzedOne: Also add a receiver ID to proximity messages. This is currently used for
            -- receiver tags on xStarbound and must be done by the sender, no matter the client,
            -- so that receiving xStarbound clients can disambiguate.
            message.receiverId = pl
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
      -- FezzedOne: Check the sender ID on messages so that clients don't sometimes incorrectly ignore
      -- messages sent from xStarbound clients.
      local authorEntityId = message.senderId or starcustomchat.utils.getPlayerIdFromConnection(message.connection)
      if world.entityExists(authorEntityId) then
        if world.magnitude(world.entityPosition(player.id()), world.entityPosition(authorEntityId)) > self.proximityRadius then
          message.text = ""
        end
      end
    end
    -- FezzedOne: Show receiver tags in nicknames on xStarbound. Just in case an xStarbound client
    -- is controlling multiple players potentially far away from each other, this will show which
    -- players actually «saw» or «heard» a proximity message.
    if xsb then
      if message.receiverId and world.entityExists(message.receiverId) and #world.ownPlayers() ~= 1 then
        message.nickname = message.nickname .. " -> " .. (world.entityName(message.receiverId) or "<n/a>")
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