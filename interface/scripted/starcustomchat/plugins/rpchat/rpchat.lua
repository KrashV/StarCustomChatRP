require "/interface/scripted/starcustomchat/plugin.lua"

rpchat = PluginClass:new(
  { name = "rpchat" }
)

function rpchat:onSendMessage(message)
  if message.mode == "Announcement" then
    local originalText = message.text
    message.text = self.announcementPrefix .. originalText
    chat.send(message.text, "Broadcast", true, message.data)
    player.say(originalText)
  end
end

function rpchat:formatIncomingMessage(message)

  if string.find(message.text, self.announcementPrefix, 1, true) then
    message.mode = "Announcement"
    message.text = string.sub(message.text, string.len(self.announcementPrefix) + 1)
    message.portrait = message.portrait and message.portrait ~= '' and message.portrait or self.modeIcons.server
  end

  message.text = string.gsub(message.text, "%b**", "^" .. self.customChat:getColor("actionstext") .. ";^font=" .. self.customChat:getFont("actionstext") .. ";%1^reset;")
  message.text = string.gsub(message.text, "%b%%", "^" .. self.customChat:getColor("thoughtstext") .. ";^font=" .. self.customChat:getFont("thoughtstext") .. ";%1^reset;")
  
  return message
end