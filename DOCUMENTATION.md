# SynthwaveUI Documentation

SynthwaveUI is a modern, responsive UI library for Roblox, providing a sleek user interface with a synthwave aesthetic. This comprehensive library includes various UI elements commonly needed in Roblox scripts and offers full customization options.

## Table of Contents

1. [Installation](#installation)
2. [Getting Started](#getting-started)
3. [UI Elements](#ui-elements)
   - [Tabs](#tabs)
   - [Sections](#sections)
   - [Buttons](#buttons)
   - [Toggles](#toggles)
   - [Sliders](#sliders)
   - [Dropdowns](#dropdowns)
   - [Textboxes](#textboxes)
   - [Labels](#labels)
4. [Notifications](#notifications)
5. [Styling](#styling)
6. [Executor Compatibility](#executor-compatibility)
7. [Advanced Usage](#advanced-usage)
8. [Troubleshooting](#troubleshooting)

## Installation

### Option 1: LoadString from GitHub (Recommended)

```lua
local SynthwaveUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/whohurtyoudear/tbdsynthuilib/refs/heads/main/source.lua"))()
```

### Option 2: Local File in Executor

```lua
local SynthwaveUI = loadstring(readfile("SynthwaveUI.lua"))()
```

### Option 3: Roblox Module Script

```lua
local SynthwaveUI = require(script.Parent.SynthwaveUI)
```

## Getting Started

Creating a basic UI is simple:

```lua
-- Initialize the library with a title and accent color
local UI = SynthwaveUI:Create("My UI Title", Color3.fromRGB(155, 89, 182))

-- Create a tab
local MainTab = UI:AddTab("Main", "rbxassetid://7059346373") -- Icon is optional

-- Add a section to organize elements
local Section = MainTab:AddSection("Features")

-- Add UI elements
Section:AddButton("Click Me", function()
    print("Button clicked!")
end)
```

## UI Elements

### Tabs

Tabs are the main organizational structure of the UI. Each tab contains sections and elements.

```lua
-- Parameters: name (string), icon (string, optional)
local MyTab = UI:AddTab("Tab Name", "rbxassetid://7059346373")
```

### Sections

Sections help organize related elements within a tab.

```lua
-- Parameters: name (string)
local MySection = MyTab:AddSection("Section Name")
```

### Buttons

Buttons trigger an action when clicked.

```lua
-- Parameters: text (string), callback (function)
MySection:AddButton("Button Text", function()
    -- Action to perform when clicked
    print("Button clicked!")
end)
```

### Toggles

Toggles represent a boolean state that can be toggled on/off.

```lua
-- Parameters: text (string), default (boolean), callback (function)
local myToggle = MySection:AddToggle("Toggle Feature", false, function(value)
    print("Toggle state:", value)
    -- Do something with the toggle state
end)

-- Methods
myToggle:Set(true) -- Programmatically set the toggle state
local state = myToggle:Get() -- Get current toggle state
```

### Sliders

Sliders allow selecting a numeric value within a range.

```lua
-- Parameters: text (string), min (number), max (number), default (number), increment (number), callback (function)
local mySlider = MySection:AddSlider("Adjustment", 0, 100, 50, 1, function(value)
    print("Slider value:", value)
    -- Do something with the slider value
end)

-- Methods
mySlider:Set(75) -- Programmatically set the slider value
local value = mySlider:Get() -- Get current slider value
```

### Dropdowns

Dropdowns allow selecting an option from a list.

```lua
-- Parameters: text (string), options (table), callback (function)
local myDropdown = MySection:AddDropdown("Select Option", {"Option 1", "Option 2", "Option 3"}, function(selected)
    print("Selected:", selected)
    -- Do something with the selected option
end)

-- Methods
myDropdown:Select("Option 2") -- Programmatically select an option
local selected = myDropdown:Get() -- Get current selection
myDropdown:Refresh({"New Option A", "New Option B"}) -- Update the options list
```

### Textboxes

Textboxes allow input of text.

```lua
-- Parameters: text (string), default (string), placeholder (string), callback (function)
local myTextbox = MySection:AddTextbox("Input Text", "Default", "Enter text...", function(text, enterPressed)
    if enterPressed then
        print("Text submitted:", text)
    else
        print("Text changed:", text)
    end
    -- Do something with the input text
end)

-- Methods
myTextbox:Set("New Value") -- Programmatically set the text
local text = myTextbox:Get() -- Get current text
```

### Labels

Labels display non-interactive text.

```lua
-- Parameters: text (string)
MySection:AddLabel("This is an informational label that can span multiple lines and will automatically adjust its height based on content.")
```

## Notifications

SynthwaveUI provides two types of notifications:

### Full Notifications

Larger notifications for important information.

```lua
-- Parameters: title (string), message (string), type (string), duration (number)
UI:Notify("Title", "This is a full notification message", "success", 5)
```

Notification types:
- `"success"` - Green notification
- `"info"` - Blue notification
- `"warning"` - Yellow notification
- `"error"` - Red notification

### Toast Notifications

Smaller, less intrusive notifications for general information.

```lua
-- Parameters: title (string), message (string), type (string)
UI:Toast("Title", "This is a toast notification", "Info")
```

Toast types:
- `"Success"` - Green toast
- `"Info"` - Blue toast
- `"Warning"` - Yellow toast
- `"Error"` - Red toast

## Styling

SynthwaveUI comes with a modern, synthwave-inspired design. The accent color can be customized when creating the UI:

```lua
-- Create UI with custom accent color (purple)
local UI = SynthwaveUI:Create("My UI", Color3.fromRGB(155, 89, 182))

-- Create UI with custom accent color (cyan)
local UI = SynthwaveUI:Create("My UI", Color3.fromRGB(52, 235, 229))
```

## Executor Compatibility

SynthwaveUI is designed to work in both regular Roblox environments and with executors. The library includes the following compatibility features:

- Error handling for player thumbnails with fallback placeholder images
- Safe handling of DisplayName property
- Error handling for game information
- Proper cleanup of event connections to prevent memory leaks
- Input validation to prevent nil reference errors

## Advanced Usage

### Combining Elements for Player Controls

```lua
local PlayerTab = UI:AddTab("Player", "rbxassetid://7059346217")
local PlayerSection = PlayerTab:AddSection("Character")

-- Walk Speed Control
PlayerSection:AddSlider("Walk Speed", 16, 100, 16, 1, function(value)
    local player = game:GetService("Players").LocalPlayer
    if player and player.Character and player.Character:FindFirstChild("Humanoid") then
        player.Character.Humanoid.WalkSpeed = value
    end
end)

-- Jump Power Control
PlayerSection:AddSlider("Jump Power", 50, 200, 50, 1, function(value)
    local player = game:GetService("Players").LocalPlayer
    if player and player.Character and player.Character:FindFirstChild("Humanoid") then
        player.Character.Humanoid.JumpPower = value
    end
end)

-- Flight Toggle
local flyEnabled = false
local flyConnection
PlayerSection:AddToggle("Flight Mode", false, function(value)
    flyEnabled = value
    local player = game:GetService("Players").LocalPlayer
    
    if flyEnabled and player.Character then
        -- Enable flight
        local humanoid = player.Character:FindFirstChild("Humanoid")
        if humanoid then
            flyConnection = game:GetService("RunService").RenderStepped:Connect(function()
                -- Flight implementation
                if humanoid and humanoid.Parent and flyEnabled then
                    -- Flight logic here
                end
            end)
        end
    else
        -- Disable flight
        if flyConnection then
            flyConnection:Disconnect()
            flyConnection = nil
        end
    end
end)
```

### Creating Dynamic Configurations

```lua
local ConfigTab = UI:AddTab("Settings")
local ConfigSection = ConfigTab:AddSection("Configuration")

local settings = {
    speed = 50,
    jumpBoost = false,
    theme = "Dark"
}

-- Create UI elements for each setting
local speedSlider = ConfigSection:AddSlider("Speed", 0, 100, settings.speed, 1, function(value)
    settings.speed = value
    saveSettings() -- Function to save settings
end)

local jumpToggle = ConfigSection:AddToggle("Jump Boost", settings.jumpBoost, function(value)
    settings.jumpBoost = value
    saveSettings()
end)

local themeDropdown = ConfigSection:AddDropdown("Theme", {"Dark", "Light", "Neon"}, function(selected)
    settings.theme = selected
    saveSettings()
    applyTheme(selected) -- Function to apply theme
end)

-- Select current theme
themeDropdown:Select(settings.theme)

-- Save/load functions
function saveSettings()
    -- Save settings logic (e.g., using writefile in executors)
    local json = game:GetService("HttpService"):JSONEncode(settings)
    writefile("settings.json", json)
end

function loadSettings()
    -- Load settings logic
    if isfile("settings.json") then
        local json = readfile("settings.json")
        local loadedSettings = game:GetService("HttpService"):JSONDecode(json)
        
        settings = loadedSettings
        speedSlider:Set(settings.speed)
        jumpToggle:Set(settings.jumpBoost)
        themeDropdown:Select(settings.theme)
    end
end

-- Try to load settings
pcall(loadSettings)
```

## Troubleshooting

### Common Issues

1. **Thumbnails Not Loading**
   - SynthwaveUI includes error handling for thumbnails and will show a placeholder if loading fails
   - Executors might not have permission to load player thumbnails

2. **Size/Position Errors**
   - Ensure you're using valid UDim2 values
   - Library includes validation to prevent nil errors

3. **Element Callbacks Not Firing**
   - Check that your callback function doesn't have errors
   - Use pcall around callback code to catch and debug issues

4. **UI Not Appearing**
   - The UI is created as part of the player's CoreGui
   - Some executors might have restrictions on GUI creation

### Error Handling

SynthwaveUI includes extensive error handling to ensure stability, but for best practices:

```lua
-- Surround complex operations with pcall
pcall(function()
    -- Your code that might error
    local result = complexOperation()
    UI:Toast("Success", "Operation completed", "Success")
end, function(err)
    -- Error handler
    UI:Toast("Error", "Operation failed: " .. tostring(err), "Error")
    print("Error:", err)
end)
```

For questions, feature requests, or to report bugs, please open an issue on the GitHub repository.
