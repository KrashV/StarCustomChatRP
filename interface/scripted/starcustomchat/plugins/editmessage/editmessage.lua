require "/interface/scripted/starcustomchat/plugin.lua"

editmessage = PluginClass:new(
  { name = "editmessage" }
)

function editmessage:init(chat)
  PluginClass.init(self, chat)
  self.editingMessage = config.getParameter("editingMessage")

  if self.editingMessage then
    self.customChat:openSubMenu("edit", starcustomchat.utils.getTranslation("chat.editing.hint"), self:cropMessage(self.editingMessage.text))
  end

  self.stagehandType = self.stagehandType ~= "" and self.stagehandType or nil
end

function editmessage:cropMessage(text)
  return utf8.len(text) < self.trimLength and text or starcustomchat.utils.utf8Substring(text, 1, self.trimLength) .. "..."
end

function editmessage:onLocaleChange()
  if self.editingMessage then
    self.customChat:openSubMenu("edit", starcustomchat.utils.getTranslation("chat.editing.hint"), self:cropMessage(self.editingMessage.text))
  end
end

function editmessage:registerMessageHandlers()
  starcustomchat.utils.setMessageHandler("scc_edit_message", function(_, _, data)
    local msgInd = self.customChat:findMessageByUUID(data.uuid)
    if msgInd then
      data = self.customChat.callbackPlugins("formatIncomingMessage", data)
      local message = self.customChat.messages[msgInd]
      message.text = data.text
      message.mode = data.mode
      message.textHeight = nil
      if not message.edited then
        message.time = "^set;^lightgray;(" .. starcustomchat.utils.getTranslation("chat.message.edited") .. ")^reset; "
          .. (message.time or "")
        message.edited = true
      end

      local newUUID = util.hashString(data.connection .. data.text)
      local oldUUID = message.uuid
      self.customChat:replaceUUID(oldUUID, newUUID)

      self.customChat:processQueue()
    end
  end)
end

function editmessage:update(dt)
  if self.editingMessage then
    self.customChat:highlightMessage(self.editingMessage, self.highlightEditColor)
  end
end

function editmessage:onSubMenuReopen(type)
  if type ~= "edit" then
    self.editingMessage = nil
  end
end

function editmessage:onTextboxEnter()
  if self.editingMessage then
    local data = {
      text = widget.getText("tbxInput"),
      uuid = self.editingMessage.uuid,
      connection = self.editingMessage.connection,
      mode = self.editingMessage.mode,
      nickname = self.editingMessage.nickname
    }
    if self.stagehandType and self.stagehandType ~= "" then
      starcustomchat.utils.createStagehandWithData(self.stagehandType, {message = "editMessage", data = data})
    else
      for _, pl in ipairs(world.playerQuery(world.entityPosition(player.id()), 100)) do 
        world.sendEntityMessage(pl, "scc_edit_message", data)
      end
    end

    self.customChat:closeSubMenu()
    self.editingMessage = nil
    return true
  end
end

function editmessage:onTextboxEscape()
  if self.editingMessage then
    self.customChat:closeSubMenu()
    self.editingMessage = nil
    return false
  end
end

function editmessage:contextMenuButtonFilter(buttonName, screenPosition, selectedMessage)
  if selectedMessage and buttonName == "edit" and not selectedMessage.image then
    -- FezzedOne: Allows edits to work on xStarbound clients after swapping players.
    local playerId = player.id()
    local clientMatchesPlayer = playerId >= selectedMessage.connection * -65536 and playerId < (selectedMessage.connection - 1) * -65536
    return selectedMessage and clientMatchesPlayer
      and selectedMessage.uuid
      and selectedMessage.mode ~= "CommandResult"
  end
end

function clearMetatags(text)
  return text:gsub("%^.-;", "")
end

function editmessage:contextMenuButtonClick(buttonName, selectedMessage)
  if selectedMessage and buttonName == "edit" then
    self.editingMessage = selectedMessage

    local cleartext = clearMetatags(selectedMessage.text)
    self.customChat:openSubMenu("edit", starcustomchat.utils.getTranslation("chat.editing.hint"), self:cropMessage(cleartext))
    widget.focus("tbxInput")
    widget.setText("tbxInput", cleartext)
  end
end

function editmessage:onBackgroundChange(chatConfig)
  chatConfig.editingMessage = self.editingMessage
  return chatConfig
end


function editmessage:onCustomButtonClick(buttonName, data)
  if self.editingMessage then
    self.customChat:closeSubMenu()
    self.editingMessage = nil
    widget.blur("tbxInput")
  end
end