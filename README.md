# SynthwaveUI

![SynthwaveUI](https://i.ibb.co/RF96GJH/standard-9.gif)

A modern, responsive UI library for Roblox with a synthwave aesthetic. SynthwaveUI provides a full suite of UI components with a sleek design that works in both standard Roblox environments and executor scripts.

## Features

- **Sleek, Modern Design**: Synthwave-inspired UI with customizable accent colors
- **Comprehensive Elements**: Buttons, toggles, sliders, dropdowns, textboxes, and labels
- **Tab-based Organization**: Group your elements logically in tabs and sections
- **Notifications System**: Full-size notifications and smaller toast messages
- **Executor Compatible**: Works seamlessly in both Roblox games and executor environments
- **Responsive**: Automatically adapts to different screen sizes and resolutions
- **Customizable**: Change colors, add icons, and style to fit your needs
- **Error Handling**: Robust error recovery for maximum compatibility

## Quick Start

```lua
-- Load the library
local SynthwaveUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/whohurtyoudear/synthwaveuihub/refs/heads/main/luasource.lua"))()

-- Create the UI
local UI = SynthwaveUI:Create("My First UI", Color3.fromRGB(155, 89, 182))

-- Add a tab
local MainTab = UI:AddTab("Main")

-- Add a section
local FeaturesSection = MainTab:AddSection("Features")

-- Add a button
FeaturesSection:AddButton("Click Me", function()
    UI:Toast("Button Clicked", "You clicked the button!", "Success")
end)

-- Add a toggle
local toggle = FeaturesSection:AddToggle("Enable Feature", false, function(value)
    print("Toggle set to:", value)
end)

-- Add a slider
local slider = FeaturesSection:AddSlider("Adjustment", 0, 100, 50, 1, function(value)
    print("Slider value:", value)
end)
```

## Available Elements

- **Tabs**: Organize your UI into different sections
- **Sections**: Group related elements within tabs
- **Buttons**: Trigger actions when clicked
- **Toggles**: Enable/disable features with on/off switches
- **Sliders**: Select numeric values with an interactive slider
- **Dropdowns**: Choose from a list of options
- **Textboxes**: Input text with customizable callbacks
- **Labels**: Display information text

## Notifications

```lua
-- Full notification
UI:Notify("Title", "This is a notification message", "success", 5)

-- Toast message (smaller, less intrusive)
UI:Toast("Title", "This is a toast message", "Info")
```

## Compatibility

SynthwaveUI is designed to work flawlessly in both standard Roblox environments and with executors. The library includes:

- Error handling for player thumbnails with fallback images
- Safe access to player properties like DisplayName
- Proper cleanup of events and connections
- Validation of input parameters to prevent errors

## Documentation

For complete documentation, usage examples, and advanced features, see the [DOCUMENTATION.md](DOCUMENTATION.md) file.

For a full implementation example showing all features, check out [example.lua](example.lua).

## License

SynthwaveUI is available under the MIT License. See the LICENSE file for more information.

## Credits

- Created by whohurtyoudear
- Additional fixes and improvements by the Roblox development community
