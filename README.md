# StarCustomChat: Roleplay

This plugin for [StarCustomChat](https://github.com/KrashV/StarCustomChat) is dedicated to the roleplay aspects of the game. It consists of the following modules:

## Edit message
You can edit the message using the context menu. The changes will only be seen for the players on the same players as you.

> [!NOTE]
> Without a server-specific patch to specify the stagehand that correctly handles the editing message, the edit will be only seen for the players around you.

## Proximity chat
You can specify the stagehand that would receive the message and then resend it to people around, or you can skip the stagehand and send the message around your character. 
![Proximity chat showcase](https://i.imgur.com/fbnNKF0.png)
*Obviously, only people with the mod installed will receive this message*

## OOC chat
A simple tab that automatically adds double brackets around your message (( )). Also places the OOC messages in a separate channel which you can turn off.
![OOC chat showcase](https://i.imgur.com/AeTFO7a.png)

## RP Chat

This plugin brings an ability to color the \*Actions* and %Thoughts% within messsages into custom, user-specific colors.

![RP Color Codes showcase](https://i.imgur.com/ZXh5DKo.png)

Also, people with the Admin permissions can fire an Announcement message in your face, that will ignore all your filters and will have the scary red color.

![I came to make an announcement](https://i.imgur.com/PLWKb4a.png)
*Now you can truly make an announcement about what exactly Shadow the Hedgehog did to your wife*

## RP Languages

> This requires Starbound server administrators to set up the language support on their side

> People without the mod will see the normal message - with some extra spaces in it - when you use this functionality.

You can specify the language your character will be speaking in "Quotation marks", so that the characters who don't know this language might find it hard to read.

![RP Languages](https://i.imgur.com/FxM7l4p.png)


### Stagehand example
Here is the example of the simplies stagehand configuration. You can use it for both `Edit message` and `RP languages` plugin - just don't forget to create a separate, server-specifc mod with a path specifying the stagehand type. It should look like this:

#### editmessage.json.patch
```diff
[
  { "op": "replace", "path": "/parameters/stagehandType", "value": "myserverchatstagehand"}
]
```

#### myserverchatstagehand.lua
And here's the simple example of the stagehand script - you basically need to return a valid Json on a `scc_retreive_languages` entity message. Here we store the languages data in some file in the server mod.
```lua
function init()
  message.setHandler("scc_retreive_languages", function()
    return root.assetJson("/your/path/to/the/languages/json/file")
  end)
end
```

The example of the json file is provided below:
```json
{
    "CoolServ_DR": {
      "name": "Draconic",
      "difficulty": 3,
      "description": "Language of dragons, kobolds and other liz-zards"
    },
    "CoolServ_EL": {
      "name": "Elvish"
    },
    "CoolServ_AF": {
      "name": "Infernal",
      "difficulty": 10,
      "specialCharacters": ["ç", "ñ", "ß", "ø", "å", "æ", "œ", "ý", "ÿ"]
    },
    "CoolServ_CO": {
      "name": "Common",
      "difficulty": 0
    }
}
```
* **Key** [Mandatory] - A unique language code. It must be unique not only within one server but across all servers. Users will not see this directly.
* **Name** [Mandatory] - The name of the language displayed to the user.
* **Description** [Optional] - A description of the language that appears on the settings tab.
* **Difficulty** [Optional] - The number of increments of "learning" (*pressing the "up" button on the knowledge spinner*) required to learn the language. If omitted, the default value is `1`. A value of `0` means the language is known to everyone and does not require learning.
* **SpecialCharacters** [Optional] - A list of characters that can appear in the message, beyond the standard ASCII alphabet.