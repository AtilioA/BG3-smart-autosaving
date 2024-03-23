[size=5][b]Overview[/b][/size]
Smart Autosaving is a mod designed to autosave regularly while minimizing gameplay interruption. Works with single-save mode.
[size=2][size=2]The mod works out of the box, but you can configure a lot of options through a JSON file.[/size][/size]
[size=4][b]
Features[/b][/size]
[list]
[*][b]Condition-based autosaving[/b]: The mod autosaves at regular intervals (10 minutes by default), but it also checks various in-game states, like whether the player is in dialogue, trading, combat, lockpicking, etc. Based on these checks, it decides whether to trigger an autosave.
[/list][list]
[*][b]Autosave postponement[/b]: If a save is due (based on the timer) but the player is in a restricted state (like dialogue), instead of skipping the autosave entirely, the mod waits until the player leaves that state before autosaving.
[/list][list]
[*][b]Save and load-aware[/b]: The mod will reset the timer if any other save is created, be it manual or otherwise, or when loading saves, so as to not create saves unnecessarily. You set it to save every 15 minutes but you saved at minute 14? It will now autosave only after minute 29.
[/list][line][b][size=5][b]
Installation[/b][/size][/b]
[list=1]
[*]Download the .zip file and install using BG3MM.

[/list][b][size=4]Requirements
[/size][/b][size=2]-[b] [url=https://www.nexusmods.com/baldursgate3/mods/7676]Volition Cabinet[/url][/b][/size][size=2]
- [url=https://github.com/Norbyte/bg3se]BG3 Script Extender[/url] [size=2](you can easily install it with BG3MM through its [i]Tools[/i] tab or by pressing CTRL+SHIFT+ALT+T while its window is focused)
[line]
[/size][/size][size=5][b]Configuration[/b][/size][size=2][size=2]
[b]As of version 2.0.0, Smart Autosaving supports configuration via a smart_autosaving_config.json file![/b] When you load a save with the mod for the first time, it will automatically create this JSON file with default options (saves every 10 minutes, postponement enabled for all events).

You can easily navigate to it on Windows by pressing WIN+R and entering
[quote][code]explorer %LocalAppData%\Larian Studios\Baldur's Gate 3\Script Extender\SmartAutosaving[/code][/quote]
Open the JSON file with any text editor, even regular Notepad will work. Here's what each option inside does (order doesn't matter):

[/size][/size][size=2][size=2]
[font=Courier New]"FEATURES"[/font]: Configures game events that affect autosaving behavior.
[font=Courier New]   ﻿"POSTPONE_ON"[/font]: Determines when autosaves are postponed.[/size][/size]
[size=2][size=2][font=Courier New]   ﻿   ﻿"combat"              [/font]: Set to true to postpone autosaving during combat. Enabled by default.
[font=Courier New]   ﻿   ﻿"combat_turn"         [/font]: Set to true to allow autosaving during combat, but only after your turn ends [/size](these two aren't mutually exclusive)[size=2]. Enabled by default.
[font=Courier New]   ﻿   ﻿"dialogue"            [/font]: Set to true to postpone autosaving during dialogue. Enabled by default.
[font=Courier New]   ﻿   ﻿"idle"                [/font]: Set to true to postpone [/size][/size][size=2][size=2]autosaving [/size][/size][size=2][size=2]if you're idle. Enabled by default.
[font=Courier New]   ﻿   ﻿"lockpicking"         [/font]: Set to true to postpone [size=2][size=2]autosaving[/size][/size] during lockpicking. Enabled by default.
[font=Courier New]   ﻿   ﻿"looting_characters"  [/font]: Set to true to postpone [/size][/size][size=2][size=2]autosaving[/size][/size][size=2][size=2] when looting characters. Enabled by default.
[font=Courier New]   ﻿   ﻿"movement"            [/font]: Set to true to postpone [/size][/size][size=2][size=2]autosaving[/size][/size][size=2][size=2] when any party member is moving. Enabled by default.
[font=Courier New]   ﻿   ﻿"respec_and_mirror"   [/font]: Set to true to postpone [/size][/size][size=2][size=2]autosaving[/size][/size][size=2][size=2] when respeccing or using the mirror. Enabled by default.
[font=Courier New]   ﻿   ﻿"trade"               [/font]: Set to true to postpone [/size][/size][size=2][size=2]autosaving[/size][/size][size=2][size=2] when trading/bartering. Enabled by default.
[font=Courier New]   ﻿   ﻿"turn_based_mode"     [/font]: Set to true to postpone [/size][/size][size=2][size=2]autosaving[/size][/size][size=2][size=2] when in turn-based mode. Enabled by default.
[font=Courier New]   ﻿   ﻿"using_items"         [/font]: Set to true to postpone [/size][/size][size=2][size=2]autosaving[/size][/size][size=2][size=2] when using items. Enabled by default.

[font=Courier New]   ﻿"TIMER"[/font]: Configures the autosaving timer.
[font=Courier New]   ﻿   ﻿"autosaving_period_in_minutes" [/font]: Interval in minutes for autosaving. Set to 10 for a ten-minute interval.
[font=Courier New]   ﻿   ﻿"load_aware"                   [/font]: Set to true to reset the timer upon loading a save. Enabled by default.
[font=Courier New]   ﻿   ﻿"save_aware"                   [/font]: Set to true to reset the timer when any save is made. Enabled by default.

[font=Courier New]"GENERAL"[/font]: General mod settings.
[font=Courier New]   ﻿"enabled" [/font]: [/size]Set it to false to disable the mod without uninstalling it. Enabled by default.[/size]
[size=2][size=2]
[font=Courier New]"DEBUG"[/font]: Controls debug logging level.
[font=Courier New]   ﻿"level"[/font]: [/size][/size] [size=2]Set to 0 for no debug, 1 for minimal, and 2 for verbose logs. You can ignore this[/size][/size] if you're not a developer/debugging events.
[size=2][size=2]
[size=2][size=2]Load a save to see your changes reflected, or run [font=Courier New]!sa_reload[/font] in the SE console.[/size][/size]
[/size][/size][line][size=5][b]
Caveats[/b][u]
[/u][/size][list]
[*][b]The mod requires autosaves to be turned on[/b] since it calls the same autosaving function as the vanilla game. They will both count towards the limit of autosaves you have set in the game's settings. There's also probably no way to replace vanilla autosaves, and they'll work in tandem.
[*]I expect a few very specific unhandled edge cases to be present, but I don't plan on solving them. Feel free to report them, though.
[*][b]The mod works in multiplayer[/b], but players performing certain operations simultaneously (looting containers, etc) might cause unintended autosaves for at least one of the players. I do not intend to address these scenarios by implementing a system that manages the interactions/states of all players.
[*]Just like with [url=https://www.nexusmods.com/baldursgate3/mods/5622?tab=description]Aether's mod[/url], [b]having cloud saves enabled might potentially cause your game to freeze up[/b] with this mod installed.
[/list]
[size=4][b]Compatibility[/b][/size]
This mod should be compatible with most game versions and other mods, as it mostly just listens to game events and triggers autosaves.
[line][size=4][b]
Special Thanks[/b][/size]
Thanks to Aetherpoint for her [url=https://www.nexusmods.com/baldursgate3/mods/5622]original mod[/url], which served as an inspiration to improve upon; to FocusBG3 for providing some helper functions through Focus Core; to folks over Larian's Discord server; and to Norbyte, for the script extender.

[size=4][b]Source Code
[/b][/size]The source code is available on [url=https://github.com/AtilioA/BG3-smart-autosaving]GitHub[/url] or by unpacking the .pak file. Endorse on Nexus and give it a star on GitHub if you liked it!
[line]
[center][b][size=4][/size][/b][center][b][size=4]My mods[/size][/b][size=2]
[url=https://www.nexusmods.com/baldursgate3/mods/6995]Waypoint Inside Emerald Grove[/url] - 'adds' a waypoint inside Emerald Grove
[b][size=4][url=https://www.nexusmods.com/baldursgate3/mods/7035][size=4][size=2]Auto Send Read Books To Camp[/size][/size][/url]﻿[size=4][size=2] [/size][/size][/size][/b][size=4][size=4][size=2]- [/size][/size][/size][size=2]send read books to camp chest automatically[/size]
[url=https://www.nexusmods.com/baldursgate3/mods/6880]Auto Use Soap[/url]﻿ - automatically use soap after combat/entering camp
[url=https://www.nexusmods.com/baldursgate3/mods/6540]Send Wares To Trader[/url]﻿[b] [/b]- automatically send all party members' wares to a character that initiates a trade[b]
[/b][b][url=https://www.nexusmods.com/baldursgate3/mods/6313]Preemptively Label Containers[/url]﻿[/b] - automatically tag nearby containers with 'Empty' or their item count[b]
[/b][url=https://www.nexusmods.com/baldursgate3/mods/5899]Smart Autosaving[/url] - create conditional autosaves at set intervals
[url=https://www.nexusmods.com/baldursgate3/mods/6086]Auto Send Food To Camp[/url] - send food to camp chest automatically
[url=https://www.nexusmods.com/baldursgate3/mods/6188]Auto Lockpicking[/url] - initiate lockpicking automatically
[size=2]
[/size][url=https://ko-fi.com/volitio][img]https://raw.githubusercontent.com/doodlum/nexusmods-widgets/main/Ko-fi_40px_60fps.png[/img][/url]﻿
[url=https://www.nexusmods.com/baldursgate3/mods/7294] [img]https://i.imgur.com/hOoJ9Yl.png[/img][/url][/size][/center][/center]
