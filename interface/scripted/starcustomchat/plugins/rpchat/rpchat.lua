require "/interface/scripted/starcustomchat/plugin.lua"

rpchat = PluginClass:new(
  { name = "rpchat" }
)

function rpchat:onSendMessage(data)
  if data.mode == "Announcement" then
    data.text = self.announcementPrefix .. data.text
    chat.send(data.text, "Broadcast")
  end
end

function rpchat:formatIncomingMessage(message)

  if string.find(message.text, "^" .. self.announcementPrefix) then
    message.mode = "Announcement"
    message.text = string.sub(message.text, string.len(self.announcementPrefix) + 1)
    message.portrait = message.portrait and message.portrait ~= '' and message.portrait or self.modeIcons.server
  end

  message.text = string.gsub(message.text, "%b**", "^" .. self.customChat:getColor("actionstext") .. ";%1^reset;")
  message.text = string.gsub(message.text, "%b%%", "^" .. self.customChat:getColor("thoughtstext") .. ";%1^reset;")
  
  return message
end