# RobloxGUI Studio Plugin

One-click import plugin for [RobloxGUI](https://robloxgui.dev) — generate Roblox GUI code with AI on the website and send it straight into Roblox Studio.

## What it does

- Opens a small panel inside Roblox Studio.
- Generates a short 6-digit pairing code.
- Polls `https://robloxgui.dev/api/plugin/jobs/{code}`.
- Creates the generated `LocalScript` in `StarterPlayerScripts` (and a `Script` in `ServerScriptService` if the scene needs server logic).

## What it does NOT do

- It does not collect any data.
- It does not talk to any third-party endpoints besides `robloxgui.dev`.
- It does not modify or publish your live game automatically.

## Install

1. Download [`RobloxGUIPlugin.rbxmx`](https://robloxgui.dev/downloads/RobloxGUIPlugin.rbxmx) from [robloxgui.dev/plugin](https://robloxgui.dev/plugin).
2. Drag the file into Roblox Studio's **Plugins** folder (`Plugins → Plugins Folder`).
3. Restart Studio and click the **RobloxGUI** toolbar button.
4. Generate a GUI on [robloxgui.dev](https://robloxgui.dev), paste the 6-digit code, and click **Send**.

## Source

The entire plugin is a single file: [`RobloxGUIPlugin.lua`](./RobloxGUIPlugin.lua). Feel free to inspect it before installing.

## License

MIT
