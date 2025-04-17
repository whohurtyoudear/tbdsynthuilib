--[[
    SynthwaveUI Example Script
    This script demonstrates how to use the fixed SynthwaveUI library with all its features.
    
    Version 1.0.1
    - All elements properly working with error handling
    - Proper thumbnail loading with fallbacks
    - Improved slider visibility with handle
    - Working executor compatibility
]]

-- Load the SynthwaveUI library
local SynthwaveUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/whohurtyoudear/synthwaveuihub/refs/heads/main/luasource.lua"))()

-- Initialize the UI with a title and accent color
-- Parameters: title (string), accent color (Color3)
local UI = SynthwaveUI:Create("SynthwaveUI Example", Color3.fromRGB(155, 89, 182))

---------------------------
-- Tab 1: Main Features
---------------------------
local MainTab = UI:AddTab("Main", "rbxassetid://7059346373") -- Optional icon

-- Add a section to organize related elements
local DemoSection = MainTab:AddSection("Basic Elements")

-- Button Example
-- Parameters: text (string), callback (function)
DemoSection:AddButton("Click Me", function()
    print("Button clicked!")
    UI:Toast("Button", "You clicked the button!", "Success")
end)

-- Toggle Example
-- Parameters: text (string), default state (boolean), callback (function)
local toggle = DemoSection:AddToggle("Enable Feature", false, function(value)
    print("Toggle set to:", value)
    if value then
        UI:Toast("Toggle", "Feature enabled", "Success")
    else
        UI:Toast("Toggle", "Feature disabled", "Info")
    end
end)

-- Methods: toggle:Set(boolean), toggle:Get()
task.spawn(function()
    task.wait(1)
    toggle:Set(true) -- Programmatically set the toggle
    task.wait(0.5)
    local state = toggle:Get() -- Get current toggle state
    print("Current toggle state:", state)
end)

-- Slider Example
-- Parameters: text (string), min (number), max (number), default (number), increment (number), callback (function)
local slider = DemoSection:AddSlider("Adjust Value", 0, 100, 50, 5, function(value)
    print("Slider value:", value)
end)

-- Methods: slider:Set(number), slider:Get()
task.spawn(function()
    task.wait(2)
    slider:Set(75) -- Set the slider value
    task.wait(0.5)
    local value = slider:Get() -- Get current value
    print("Current slider value:", value)
end)

---------------------------
-- Tab 2: Configuration
---------------------------
local ConfigTab = UI:AddTab("Config", "rbxassetid://7059348203")

-- Dropdown Section
local DropdownSection = ConfigTab:AddSection("Dropdown & Input")

-- Dropdown Example
-- Parameters: text (string), options (table), callback (function)
local dropdown = DropdownSection:AddDropdown("Select Item", {"Option 1", "Option 2", "Option 3", "Option 4"}, function(selected)
    print("Selected:", selected)
    UI:Toast("Selection", "You selected: " .. selected, "Info")
end)

-- Methods: dropdown:Select(string), dropdown:Get(), dropdown:Refresh(table)
task.spawn(function()
    task.wait(1)
    dropdown:Select("Option 3") -- Select an option
    task.wait(1)
    local currentOption = dropdown:Get() -- Get current selection
    print("Current dropdown selection:", currentOption)
    
    -- Update the dropdown options
    task.wait(1)
    dropdown:Refresh({"New Option A", "New Option B", "New Option C"})
    task.wait(0.5)
    dropdown:Select("New Option B")
end)

-- Textbox Example
-- Parameters: text (string), default (string), placeholder (string), callback (function)
local textbox = DropdownSection:AddTextbox("Enter Text", "Default Value", "Type something...", function(text, enterPressed)
    if enterPressed then
        print("Text submitted:", text)
        UI:Toast("Input", "You entered: " .. text, "Info")
    else
        print("Text changed:", text)
    end
end)

-- Methods: textbox:Set(string), textbox:Get()
task.spawn(function()
    task.wait(3)
    textbox:Set("New Text Value") -- Set text programmatically
    task.wait(0.5)
    local currentText = textbox:Get() -- Get current text
    print("Current textbox value:", currentText)
end)

-- Information Section
local InfoSection = ConfigTab:AddSection("Information")

-- Label Example (Simple text display)
-- Parameters: text (string)
InfoSection:AddLabel("SynthwaveUI supports labels, buttons, toggles, sliders, dropdowns, and textboxes.")
InfoSection:AddLabel("Labels automatically wrap text and can be used for longer explanations or instructions to the user.")

---------------------------
-- Tab 3: Player Settings
---------------------------
local PlayerTab = UI:AddTab("Player", "rbxassetid://7059346217")

local PlayerSection = PlayerTab:AddSection("Character Settings")

-- Functional sliders that modify player properties
PlayerSection:AddSlider("Walk Speed", 16, 100, 16, 1, function(value)
    local player = game:GetService("Players").LocalPlayer
    if player and player.Character and player.Character:FindFirstChild("Humanoid") then
        player.Character.Humanoid.WalkSpeed = value
    end
end)

PlayerSection:AddSlider("Jump Power", 50, 200, 50, 1, function(value)
    local player = game:GetService("Players").LocalPlayer
    if player and player.Character and player.Character:FindFirstChild("Humanoid") then
        player.Character.Humanoid.JumpPower = value
    end
end)

local PlayerInfoSection = PlayerTab:AddSection("Player Info")

PlayerInfoSection:AddLabel("This UI library includes error handling for player thumbnails and DisplayName to ensure compatibility with Roblox executors.")

---------------------------
-- Notifications
---------------------------

-- Full notification
-- Parameters: title (string), message (string), type (string), duration (number)
UI:Notify("Welcome!", "SynthwaveUI example is now running", "success", 5)

-- Toast notification (smaller, less intrusive)
-- Parameters: title (string), message (string), type (string)
task.wait(1)
UI:Toast("Initialized", "All components loaded successfully", "Info")

-- Demonstrate different notification types
task.spawn(function()
    task.wait(2)
    UI:Toast("Info Toast", "This is an informational message", "Info")
    task.wait(1)
    UI:Toast("Success Toast", "Operation completed successfully", "Success")
    task.wait(1)
    UI:Toast("Warning Toast", "Please be cautious", "Warning")
    task.wait(1)
    UI:Toast("Error Toast", "An error has occurred", "Error")
    task.wait(1)
    UI:Notify("Notifications", "SynthwaveUI offers full notifications and smaller toast messages", "info", 5)
end)

print("SynthwaveUI Example loaded successfully!")
