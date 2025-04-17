--[[
    SynthwaveUI Library
    A modern, customizable UI library with synthwave aesthetics for Roblox
    Version: 1.0.1 (Fixed)
    
    Features:
    - Modern, clean UI with synthwave/retro aesthetic
    - Customizable color scheme
    - Responsive and intuitive interface
    - Multiple UI elements (buttons, toggles, sliders, dropdowns, etc.)
    - Notification system
    - Toast notifications
    - Tab organization
    
    Fixed issues:
    - Fixed ThumbnailSize error by using valid size (Size352x352)
    - Added slider handle visual element for better visibility
    - Fixed TweenInfo errors with proper duration validation
    - Fixed minimize/maximize gray background issue
    - Improved notification system with better timing and cleanup
    - Added close button to toast notifications
    - Fixed dropdown Select method compatibility
]]

-- Services
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local TextService = game:GetService("TextService")
local CoreGui = game:GetService("CoreGui")
local GuiService = game:GetService("GuiService")

-- Variables
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local SynthwaveUI = {}
local DraggingUI = false
local SelectedTab = nil
local TabButtons = {}
local UIElements = {}
local ActiveToasts = {}
local ToastQueue = {}
local ColorScheme = {
    Background = Color3.fromRGB(16, 8, 32),
    Accent1 = Color3.fromRGB(155, 89, 182),
    Accent2 = Color3.fromRGB(52, 152, 219),
    Text = Color3.fromRGB(255, 255, 255),
    Secondary = Color3.fromRGB(26, 31, 44),
    Success = Color3.fromRGB(46, 204, 113),
    Error = Color3.fromRGB(231, 76, 60),
    Warning = Color3.fromRGB(241, 196, 15)
}

-- Constants
local TWEEN_SPEED = 0.25
local TOAST_DURATION = 3
local TOAST_STAGGER = 0.15
local MAX_TOASTS = 5
local DRAG_SPEED = 0.1
local CORNER_RADIUS = UDim.new(0, 6)
local BLUR_SIZE = 15
local FONT = Enum.Font.GothamBold
local REGULAR_FONT = Enum.Font.Gotham

-- Utility Functions
local function Create(instanceType)
    return function(properties)
        local instance = Instance.new(instanceType)
        for property, value in next, properties do
            if property ~= "Parent" then
                instance[property] = value
            end
        end
        if properties.Parent then
            instance.Parent = properties.Parent
        end
        return instance
    end
end

local function Tween(instance, properties, duration, style, direction)
    -- Ensure duration is a valid number to prevent TweenInfo errors
    if duration ~= nil and type(duration) ~= "number" then
        duration = TWEEN_SPEED
    end
    
    local tween = TweenService:Create(
        instance,
        TweenInfo.new(duration or TWEEN_SPEED, style or Enum.EasingStyle.Quart, direction or Enum.EasingDirection.Out),
        properties
    )
    tween:Play()
    return tween
end

local function RoundNumber(number, decimalPlaces)
    decimalPlaces = decimalPlaces or 0
    local multiplier = 10 ^ decimalPlaces
    return math.floor(number * multiplier + 0.5) / multiplier
end

local function CreateRipple(parent)
    local ripple = Create("Frame")({
        Name = "Ripple",
        Parent = parent,
        BackgroundColor3 = ColorScheme.Text,
        BackgroundTransparency = 0.8,
        BorderSizePixel = 0,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(0, 0, 0, 0)
    })

    local corner = Create("UICorner")({
        CornerRadius = UDim.new(1, 0),
        Parent = ripple
    })

    local size = math.max(parent.AbsoluteSize.X, parent.AbsoluteSize.Y) * 2
    local mousePos = UserInputService:GetMouseLocation() - parent.AbsolutePosition
    ripple.Position = UDim2.new(0, mousePos.X, 0, mousePos.Y)

    Tween(ripple, {Size = UDim2.new(0, size, 0, size), BackgroundTransparency = 1}, 0.5)

    task.delay(0.5, function()
        ripple:Destroy()
    end)
end

-- Main UI Creation
function SynthwaveUI:Create(title, accentColor)
    if accentColor then
        ColorScheme.Accent1 = accentColor
    end

    -- Check if UI already exists
    if CoreGui:FindFirstChild("SynthwaveUI") then
        CoreGui:FindFirstChild("SynthwaveUI"):Destroy()
    end

    -- Create main UI
    local UI = Create("ScreenGui")({
        Name = "SynthwaveUI",
        Parent = CoreGui,
        IgnoreGuiInset = true,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        ResetOnSpawn = false
    })

    -- Create blur effect
    local blur = Create("BlurEffect")({
        Name = "SynthwaveBlur",
        Parent = game:GetService("Lighting"),
        Size = 0
    })

    Tween(blur, {Size = BLUR_SIZE}, 0.5)

    -- Main frame
    local mainFrame = Create("Frame")({
        Name = "MainFrame",
        Parent = UI,
        BackgroundColor3 = ColorScheme.Background,
        BorderSizePixel = 0,
        Position = UDim2.new(0.5, 0, 0.5, 0), -- Center position
        Size = UDim2.new(0, 800, 0, 500),
        ClipsDescendants = true,
        AnchorPoint = Vector2.new(0.5, 0.5) -- Center anchor point
    })

    local mainCorner = Create("UICorner")({
        CornerRadius = CORNER_RADIUS,
        Parent = mainFrame
    })

    local mainStroke = Create("UIStroke")({
        Parent = mainFrame,
        Color = ColorScheme.Accent1,
        Thickness = 2,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Transparency = 0.2
    })

    -- Grid background
    local gridBg = Create("Frame")({
        Name = "GridBackground",
        Parent = mainFrame,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 1, 0),
        ZIndex = 0
    })

    local gridImage = Create("ImageLabel")({
        Name = "GridPattern",
        Parent = gridBg,
        BackgroundTransparency = 1,
        Image = "rbxassetid://6764432408", -- Grid pattern image
        ImageTransparency = 0.95,
        ScaleType = Enum.ScaleType.Tile,
        TileSize = UDim2.new(0, 50, 0, 50),
        Size = UDim2.new(1, 0, 1, 0),
        ZIndex = 0
    })

    -- Top bar
    local topBar = Create("Frame")({
        Name = "TopBar",
        Parent = mainFrame,
        BackgroundColor3 = ColorScheme.Secondary,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 35),
    })

    local topCorner = Create("UICorner")({
        CornerRadius = CORNER_RADIUS,
        Parent = topBar
    })

    local bottomBarCover = Create("Frame")({
        Name = "BottomBarCover",
        Parent = topBar,
        BackgroundColor3 = ColorScheme.Secondary,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 1, -10),
        Size = UDim2.new(1, 0, 0, 10)
    })

    -- Title
    local titleLabel = Create("TextLabel")({
        Name = "Title",
        Parent = topBar,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 15, 0, 0),
        Size = UDim2.new(0.5, 0, 1, 0),
        Font = FONT,
        Text = title or "SynthwaveUI",
        TextColor3 = ColorScheme.Text,
        TextSize = 18,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    -- Buttons (Close, Minimize)
    local buttonsHolder = Create("Frame")({
        Name = "Buttons",
        Parent = topBar,
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -80, 0, 0),
        Size = UDim2.new(0, 80, 1, 0)
    })

    local minimizeBtn = Create("TextButton")({
        Name = "MinimizeBtn",
        Parent = buttonsHolder,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(0, 40, 1, 0),
        Font = FONT,
        Text = "−",
        TextColor3 = ColorScheme.Text,
        TextSize = 20
    })

    local closeBtn = Create("TextButton")({
        Name = "CloseBtn",
        Parent = buttonsHolder,
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -40, 0, 0),
        Size = UDim2.new(0, 40, 1, 0),
        Font = FONT,
        Text = "×",
        TextColor3 = ColorScheme.Text,
        TextSize = 20
    })

    -- Sidebar
    local sidebar = Create("Frame")({
        Name = "Sidebar",
        Parent = mainFrame,
        BackgroundColor3 = ColorScheme.Secondary,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, 35),
        Size = UDim2.new(0, 150, 1, -35)
    })

    local sidebarCorner = Create("UICorner")({
        CornerRadius = CORNER_RADIUS,
        Parent = sidebar
    })

    local rightCover = Create("Frame")({
        Name = "RightCover",
        Parent = sidebar,
        BackgroundColor3 = ColorScheme.Secondary,
        BorderSizePixel = 0,
        Position = UDim2.new(1, -10, 0, 0),
        Size = UDim2.new(0, 10, 1, 0)
    })

    -- Player info section
    local playerSection = Create("Frame")({
        Name = "PlayerSection",
        Parent = sidebar,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 100),
        ClipsDescendants = true
    })

    local avatarHolder = Create("Frame")({
        Name = "AvatarHolder",
        Parent = playerSection,
        BackgroundTransparency = 1,
        Position = UDim2.new(0.5, 0, 0, 10),
        Size = UDim2.new(0, 60, 0, 60),
        AnchorPoint = Vector2.new(0.5, 0)
    })

    -- Create the avatar image with default transparent background
    local avatarImage = Create("ImageLabel")({
        Name = "Avatar",
        Parent = avatarHolder,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Image = "", -- Will be set below
        ScaleType = Enum.ScaleType.Fit
    })
    
    -- Try to get the player thumbnail with proper error handling for executors
    local success, result = pcall(function()
        return Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size352x352)
    end)
    
    if success then
        avatarImage.Image = result
    else
        -- Fallback to default avatar or placeholder if thumbnail fails
        avatarImage.Image = "rbxassetid://7050349404" -- Default avatar placeholder
        -- Print error to console for debugging
        print("SynthwaveUI: Could not load avatar thumbnail. Using placeholder instead.")
        print("Error: " .. tostring(result))
    end

    local avatarCorner = Create("UICorner")({
        CornerRadius = UDim.new(1, 0),
        Parent = avatarImage
    })

    local avatarStroke = Create("UIStroke")({
        Parent = avatarImage,
        Color = ColorScheme.Accent1,
        Thickness = 2,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    })

    -- Get player name with error handling in case DisplayName is not accessible
    local playerName = "User"
    local success, result = pcall(function()
        return LocalPlayer.DisplayName or LocalPlayer.Name
    end)
    
    if success and result then
        playerName = result
    end
    
    local usernameLabel = Create("TextLabel")({
        Name = "Username",
        Parent = playerSection,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 75),
        Size = UDim2.new(1, 0, 0, 20),
        Font = FONT,
        Text = playerName,
        TextColor3 = ColorScheme.Text,
        TextSize = 14
    })

    -- Tab buttons container
    local tabsContainer = Create("ScrollingFrame")({
        Name = "TabsContainer",
        Parent = sidebar,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 100),
        Size = UDim2.new(1, 0, 1, -100),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = ColorScheme.Accent1,
        BorderSizePixel = 0,
        ScrollingEnabled = true
    })

    local tabsLayout = Create("UIListLayout")({
        Parent = tabsContainer,
        Padding = UDim.new(0, 5),
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        SortOrder = Enum.SortOrder.LayoutOrder
    })
    
    local tabsPadding = Create("UIPadding")({
        Parent = tabsContainer,
        PaddingTop = UDim.new(0, 5),
        PaddingBottom = UDim.new(0, 5),
        PaddingLeft = UDim.new(0, 5),
        PaddingRight = UDim.new(0, 5)
    })

    -- Auto-update canvas size based on content
    tabsLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        tabsContainer.CanvasSize = UDim2.new(0, 0, 0, tabsLayout.AbsoluteContentSize.Y + 10)
    end)

    -- Content area
    local contentContainer = Create("Frame")({
        Name = "ContentContainer",
        Parent = mainFrame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 150, 0, 35),
        Size = UDim2.new(1, -150, 1, -35),
        ClipsDescendants = true
    })

    -- Bottom bar with game info
    local bottomBar = Create("Frame")({
        Name = "BottomBar",
        Parent = mainFrame,
        BackgroundColor3 = ColorScheme.Secondary,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 1, -20),
        Size = UDim2.new(1, 0, 0, 20),
        ZIndex = 10 -- Ensure bottom bar shows above other content
    })

    -- Get game information with error handling for executors
    local gameName = "Unknown"
    local placeId = "Unknown"
    
    local gameNameSuccess, gameNameResult = pcall(function()
        return game.Name
    end)
    
    local placeIdSuccess, placeIdResult = pcall(function()
        return tostring(game.PlaceId)
    end)
    
    if gameNameSuccess and gameNameResult then
        gameName = gameNameResult
    end
    
    if placeIdSuccess and placeIdResult then
        placeId = placeIdResult
    end
    
    local bottomGameInfo = Create("TextLabel")({
        Name = "GameInfo",
        Parent = bottomBar,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Font = REGULAR_FONT,
        TextColor3 = ColorScheme.Text,
        TextSize = 12,
        Text = "Game: " .. gameName .. " | Place ID: " .. placeId,
        TextXAlignment = Enum.TextXAlignment.Center
    })

    -- Dragging functionality
    local dragging = false
    local dragInput
    local dragStart
    local startPos

    -- Improved drag function for better reliability
    local function UpdateDrag(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            mainFrame.Position = UDim2.new(
                startPos.X.Scale, 
                startPos.X.Offset + delta.X, 
                startPos.Y.Scale, 
                startPos.Y.Offset + delta.Y
            )
        end
    end

    -- Improved dragging implementation for reliable dragging in Roblox
    topBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = mainFrame.Position
            
            -- Create connection to track mouse movement
            local dragConnection
            local endConnection
            
            dragConnection = UserInputService.InputChanged:Connect(function(changedInput)
                if dragging and changedInput.UserInputType == Enum.UserInputType.MouseMovement then
                    local delta = changedInput.Position - dragStart
                    mainFrame.Position = UDim2.new(
                        startPos.X.Scale, 
                        startPos.X.Offset + delta.X, 
                        startPos.Y.Scale, 
                        startPos.Y.Offset + delta.Y
                    )
                end
            end)
            
            -- Handle when mouse button is released
            endConnection = UserInputService.InputEnded:Connect(function(endedInput)
                if endedInput.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = false
                    if dragConnection then 
                        dragConnection:Disconnect()
                    end
                    if endConnection then
                        endConnection:Disconnect()
                    end
                end
            end)
        end
    end)

    -- Button functionality
    closeBtn.MouseButton1Click:Connect(function()
        CreateRipple(closeBtn)
        Tween(blur, {Size = 0}, 0.5)
        Tween(mainFrame, {Position = UDim2.new(0.5, 0, 1.5, 0)}, 0.5, Enum.EasingStyle.Back, Enum.EasingDirection.In)
        task.wait(0.5)
        UI:Destroy()
        blur:Destroy()
    end)

    local minimized = false
    minimizeBtn.MouseButton1Click:Connect(function()
        CreateRipple(minimizeBtn)
        minimized = not minimized
        
        if minimized then
            -- Hide content and only show top bar
            Tween(mainFrame, {Size = UDim2.new(0, 800, 0, 35)}, 0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
            
            -- Hide elements that shouldn't be visible when minimized
            for _, element in pairs({sidebar, contentContainer, bottomBar, gridBg}) do
                if element then
                    Tween(element, {BackgroundTransparency = 1}, 0.3)
                    
                    -- Also tween children to be transparent
                    for _, child in pairs(element:GetChildren()) do
                        if child:IsA("GuiObject") and not child:IsA("UIStroke") and not child:IsA("UICorner") then
                            Tween(child, {BackgroundTransparency = 1}, 0.3)
                        end
                    end
                end
            end
            
            -- Make elements non-interactive when minimized
            task.delay(0.3, function()
                if minimized then
                    sidebar.Visible = false
                    contentContainer.Visible = false
                    bottomBar.Visible = false
                    gridBg.Visible = false
                end
            end)
        else
            -- Make elements visible again
            sidebar.Visible = true
            contentContainer.Visible = true
            bottomBar.Visible = true
            gridBg.Visible = true
            
            -- Restore transparency
            sidebar.BackgroundTransparency = 0
            contentContainer.BackgroundTransparency = 0
            bottomBar.BackgroundTransparency = 0
            gridBg.BackgroundTransparency = 1 -- Note: gridBg is already transparent by design
            
            -- Restore original transparency for all children
            for _, element in pairs({sidebar, contentContainer, bottomBar, gridBg}) do
                if element then
                    for _, child in pairs(element:GetChildren()) do
                        if child:IsA("GuiObject") and not child:IsA("UIStroke") and not child:IsA("UICorner") then
                            -- Skip transparency restoration for elements that should be transparent
                            if child.Name ~= "GridPattern" then
                                child.BackgroundTransparency = child.Name:find("Cover") and 0 or 1
                            end
                        end
                    end
                end
            end
            
            -- Ensure grid pattern is visible but transparent
            if gridImage then
                gridImage.BackgroundTransparency = 1
                gridImage.ImageTransparency = 0.95
            end
            
            -- Restore full size
            Tween(mainFrame, {Size = UDim2.new(0, 800, 0, 500)}, 0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
        end
    end)

    -- Tab creation functionality
    local library = {}
    library.Tabs = {}
    
    function library:AddTab(title, icon)
        -- Create tab button
        local tabButton = Create("TextButton")({
            Name = title .. "Tab",
            Parent = tabsContainer,
            BackgroundColor3 = ColorScheme.Background,
            Size = UDim2.new(1, -10, 0, 35),
            Text = "",
            AutoButtonColor = false
        })
        
        local tabCorner = Create("UICorner")({
            CornerRadius = CORNER_RADIUS,
            Parent = tabButton
        })
        
        local tabStroke = Create("UIStroke")({
            Parent = tabButton,
            Color = ColorScheme.Accent1,
            Thickness = 1,
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
            Transparency = 0.8
        })
        
        local iconLabel = Create("ImageLabel")({
            Name = "Icon",
            Parent = tabButton,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 10, 0.5, 0),
            Size = UDim2.new(0, 16, 0, 16),
            AnchorPoint = Vector2.new(0, 0.5),
            Image = icon or "",
            ImageColor3 = ColorScheme.Text
        })
        
        -- Only show icon if provided
        iconLabel.Visible = icon ~= nil and icon ~= ""
        
        local nameLabel = Create("TextLabel")({
            Name = "Title",
            Parent = tabButton,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, icon and 36 or 10, 0, 0),
            Size = UDim2.new(1, icon and -46 or -20, 1, 0),
            Font = FONT,
            Text = title,
            TextColor3 = ColorScheme.Text,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left
        })
        
        -- Create tab content container
        local tabContent = Create("ScrollingFrame")({
            Name = title .. "Content",
            Parent = contentContainer,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Position = UDim2.new(0, 0, 0, 0),
            Size = UDim2.new(1, 0, 1, 0),
            ScrollBarThickness = 4,
            ScrollBarImageColor3 = ColorScheme.Accent1,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            Visible = false,
            ScrollingEnabled = true,
            AutomaticCanvasSize = Enum.AutomaticSize.Y
        })
        
        local contentLayout = Create("UIListLayout")({
            Parent = tabContent,
            Padding = UDim.new(0, 8),
            HorizontalAlignment = Enum.HorizontalAlignment.Center,
            SortOrder = Enum.SortOrder.LayoutOrder
        })
        
        local contentPadding = Create("UIPadding")({
            Parent = tabContent,
            PaddingTop = UDim.new(0, 15),
            PaddingBottom = UDim.new(0, 15),
            PaddingLeft = UDim.new(0, 15),
            PaddingRight = UDim.new(0, 15)
        })
        
        -- Tab switching logic
        tabButton.MouseButton1Click:Connect(function()
            CreateRipple(tabButton)
            
            -- Hide all tabs
            for _, tab in pairs(library.Tabs) do
                tab.Content.Visible = false
                Tween(tab.Button, {BackgroundColor3 = ColorScheme.Background})
                Tween(tab.Stroke, {Transparency = 0.8})
            end
            
            -- Show selected tab
            tabContent.Visible = true
            Tween(tabButton, {BackgroundColor3 = ColorScheme.Accent1})
            Tween(tabStroke, {Transparency = 0})
            
            -- Update selected tab
            SelectedTab = title
        end)
        
        -- Store tab information
        local tab = {
            Button = tabButton,
            Content = tabContent,
            Stroke = tabStroke,
            Name = title
        }
        
        table.insert(library.Tabs, tab)
        
        -- If this is the first tab, select it automatically
        if #library.Tabs == 1 then
            -- Manually trigger the tab selection logic instead of trying to fire the event
            tabContent.Visible = true
            Tween(tabButton, {BackgroundColor3 = ColorScheme.Accent1})
            Tween(tabStroke, {Transparency = 0})
            SelectedTab = title
        end
        
        -- Section Creator
        local sectionFunctions = {}
        
        function sectionFunctions:AddSection(sectionTitle)
            local section = Create("Frame")({
                Name = sectionTitle .. "Section",
                Parent = tabContent,
                BackgroundColor3 = ColorScheme.Secondary,
                Size = UDim2.new(1, 0, 0, 40), -- Initial size, will be updated
                AutomaticSize = Enum.AutomaticSize.Y
            })
            
            local sectionCorner = Create("UICorner")({
                CornerRadius = CORNER_RADIUS,
                Parent = section
            })
            
            local sectionStroke = Create("UIStroke")({
                Parent = section,
                Color = ColorScheme.Accent1,
                Thickness = 1,
                ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                Transparency = 0.9
            })
            
            local sectionTitle = Create("TextLabel")({
                Name = "Title",
                Parent = section,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0, 0),
                Size = UDim2.new(1, -20, 0, 30),
                Font = FONT,
                Text = sectionTitle,
                TextColor3 = ColorScheme.Text,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left
            })
            
            local sectionContent = Create("Frame")({
                Name = "Content",
                Parent = section,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 0, 0, 30),
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y
            })
            
            local contentLayout = Create("UIListLayout")({
                Parent = sectionContent,
                Padding = UDim.new(0, 8),
                HorizontalAlignment = Enum.HorizontalAlignment.Center,
                SortOrder = Enum.SortOrder.LayoutOrder
            })
            
            local contentPadding = Create("UIPadding")({
                Parent = sectionContent,
                PaddingTop = UDim.new(0, 5),
                PaddingBottom = UDim.new(0, 10),
                PaddingLeft = UDim.new(0, 10),
                PaddingRight = UDim.new(0, 10)
            })
            
            -- Elements Creation Functions
            local elementFunctions = {}
            
            -- Button Element
            function elementFunctions:AddButton(btnText, callback)
                callback = callback or function() end
                
                local button = Create("TextButton")({
                    Name = btnText .. "Button",
                    Parent = sectionContent,
                    BackgroundColor3 = ColorScheme.Background,
                    Size = UDim2.new(1, 0, 0, 35),
                    Text = "",
                    AutoButtonColor = false
                })
                
                local buttonCorner = Create("UICorner")({
                    CornerRadius = CORNER_RADIUS,
                    Parent = button
                })
                
                local buttonStroke = Create("UIStroke")({
                    Parent = button,
                    Color = ColorScheme.Accent1,
                    Thickness = 1,
                    ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                    Transparency = 0.8
                })
                
                local buttonText = Create("TextLabel")({
                    Name = "ButtonText",
                    Parent = button,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 10, 0, 0),
                    Size = UDim2.new(1, -20, 1, 0),
                    Font = FONT,
                    Text = btnText,
                    TextColor3 = ColorScheme.Text,
                    TextSize = 14
                })
                
                button.MouseEnter:Connect(function()
                    Tween(button, {BackgroundColor3 = ColorScheme.Accent1}, 0.2)
                end)
                
                button.MouseLeave:Connect(function()
                    Tween(button, {BackgroundColor3 = ColorScheme.Background}, 0.2)
                end)
                
                button.MouseButton1Click:Connect(function()
                    CreateRipple(button)
                    callback()
                end)
                
                return button
            end
            
            -- Toggle Element
            function elementFunctions:AddToggle(toggleText, default, callback)
                default = default or false
                callback = callback or function() end
                
                local toggleValue = default
                
                local toggle = Create("Frame")({
                    Name = toggleText .. "Toggle",
                    Parent = sectionContent,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 35)
                })
                
                local toggleLabel = Create("TextLabel")({
                    Name = "Label",
                    Parent = toggle,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 0, 0, 0),
                    Size = UDim2.new(1, -60, 1, 0),
                    Font = REGULAR_FONT,
                    Text = toggleText,
                    TextColor3 = ColorScheme.Text,
                    TextSize = 14,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                
                local toggleButton = Create("Frame")({
                    Name = "ToggleButton",
                    Parent = toggle,
                    BackgroundColor3 = default and ColorScheme.Accent1 or ColorScheme.Secondary,
                    Position = UDim2.new(1, -50, 0.5, 0),
                    Size = UDim2.new(0, 50, 0, 24),
                    AnchorPoint = Vector2.new(0, 0.5)
                })
                
                local toggleCorner = Create("UICorner")({
                    CornerRadius = UDim.new(1, 0),
                    Parent = toggleButton
                })
                
                local toggleCircle = Create("Frame")({
                    Name = "Circle",
                    Parent = toggleButton,
                    BackgroundColor3 = ColorScheme.Text,
                    Position = default and UDim2.new(1, -22, 0.5, 0) or UDim2.new(0, 2, 0.5, 0),
                    Size = UDim2.new(0, 20, 0, 20),
                    AnchorPoint = Vector2.new(0, 0.5)
                })
                
                local circleCorner = Create("UICorner")({
                    CornerRadius = UDim.new(1, 0),
                    Parent = toggleCircle
                })
                
                -- Clickable area
                local toggleClickArea = Create("TextButton")({
                    Name = "ClickArea",
                    Parent = toggle,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 1, 0),
                    Text = "",
                    ZIndex = 10
                })
                
                toggleClickArea.MouseButton1Click:Connect(function()
                    toggleValue = not toggleValue
                    
                    if toggleValue then
                        Tween(toggleButton, {BackgroundColor3 = ColorScheme.Accent1}, 0.2)
                        Tween(toggleCircle, {Position = UDim2.new(1, -22, 0.5, 0)}, 0.2)
                    else
                        Tween(toggleButton, {BackgroundColor3 = ColorScheme.Secondary}, 0.2)
                        Tween(toggleCircle, {Position = UDim2.new(0, 2, 0.5, 0)}, 0.2)
                    end
                    
                    callback(toggleValue)
                    CreateRipple(toggle)
                end)
                
                -- Methods
                local toggleFunctions = {}
                
                function toggleFunctions:Set(value)
                    toggleValue = value
                    
                    if toggleValue then
                        Tween(toggleButton, {BackgroundColor3 = ColorScheme.Accent1}, 0.2)
                        Tween(toggleCircle, {Position = UDim2.new(1, -22, 0.5, 0)}, 0.2)
                    else
                        Tween(toggleButton, {BackgroundColor3 = ColorScheme.Secondary}, 0.2)
                        Tween(toggleCircle, {Position = UDim2.new(0, 2, 0.5, 0)}, 0.2)
                    end
                    
                    callback(toggleValue)
                end
                
                function toggleFunctions:Get()
                    return toggleValue
                end
                
                return toggleFunctions
            end
            
            -- Slider Element
            function elementFunctions:AddSlider(sliderText, min, max, default, increment, callback)
                min = min or 0
                max = max or 100
                default = default or min
                increment = increment or 1
                callback = callback or function() end
                
                local sliderValue = default
                
                local slider = Create("Frame")({
                    Name = sliderText .. "Slider",
                    Parent = sectionContent,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 50)
                })
                
                local sliderLabel = Create("TextLabel")({
                    Name = "Label",
                    Parent = slider,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 0, 0, 0),
                    Size = UDim2.new(1, 0, 0, 20),
                    Font = REGULAR_FONT,
                    Text = sliderText,
                    TextColor3 = ColorScheme.Text,
                    TextSize = 14,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                
                local valueLabel = Create("TextLabel")({
                    Name = "Value",
                    Parent = slider,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(1, -40, 0, 0),
                    Size = UDim2.new(0, 40, 0, 20),
                    Font = FONT,
                    Text = tostring(default),
                    TextColor3 = ColorScheme.Text,
                    TextSize = 14
                })
                
                local sliderBg = Create("Frame")({
                    Name = "Background",
                    Parent = slider,
                    BackgroundColor3 = ColorScheme.Secondary,
                    Position = UDim2.new(0, 0, 0, 25),
                    Size = UDim2.new(1, 0, 0, 10)
                })
                
                local bgCorner = Create("UICorner")({
                    CornerRadius = UDim.new(1, 0),
                    Parent = sliderBg
                })
                
                local sliderFill = Create("Frame")({
                    Name = "Fill",
                    Parent = sliderBg,
                    BackgroundColor3 = ColorScheme.Accent1,
                    Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
                })
                
                local fillCorner = Create("UICorner")({
                    CornerRadius = UDim.new(1, 0),
                    Parent = sliderFill
                })
                
                -- Add slider handle/knob (circle) for better visibility
                local sliderHandle = Create("Frame")({
                    Name = "SliderHandle",
                    Parent = sliderBg,
                    BackgroundColor3 = ColorScheme.Text,
                    Position = UDim2.new((default - min) / (max - min), 0, 0.5, 0),
                    Size = UDim2.new(0, 14, 0, 14),
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    ZIndex = 2
                })
                
                local handleCorner = Create("UICorner")({
                    CornerRadius = UDim.new(1, 0),
                    Parent = sliderHandle
                })
                
                local handleStroke = Create("UIStroke")({
                    Parent = sliderHandle,
                    Color = ColorScheme.Accent1,
                    Thickness = 1,
                    ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                })
                
                local sliderButton = Create("TextButton")({
                    Name = "SliderButton",
                    Parent = slider,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 0, 0, 20),
                    Size = UDim2.new(1, 0, 0, 20),
                    Text = ""
                })
                
                local function updateSlider(input)
                    -- Make sure input has a valid Position property
                    if not input or not input.Position then
                        return
                    end
                    
                    -- Get absolute positions and validate
                    local sliderAbsPosition = sliderBg.AbsolutePosition
                    local sliderAbsSize = sliderBg.AbsoluteSize
                    
                    if not sliderAbsPosition or not sliderAbsSize then
                        return
                    end
                    
                    -- Calculate normalized value safely
                    local sizeX = math.clamp((input.Position.X - sliderAbsPosition.X) / sliderAbsSize.X, 0, 1)
                    local value = min + ((max - min) * sizeX)
                    
                    -- Apply increment
                    value = min + (math.floor((value - min) / increment + 0.5) * increment)
                    
                    -- Clamp value to min/max
                    value = math.clamp(value, min, max)
                    
                    -- Round to avoid floating point issues
                    value = RoundNumber(value, 2)
                    
                    -- Update UI
                    sliderValue = value
                    valueLabel.Text = tostring(value)
                    sliderFill.Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
                    -- Update handle position to match slider value
                    sliderHandle.Position = UDim2.new((value - min) / (max - min), 0, 0.5, 0)
                    
                    -- Call the callback with the new value
                    callback(value)
                end
                
                sliderButton.MouseButton1Down:Connect(function()
                    local connection
                    connection = UserInputService.InputChanged:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseMovement then
                            updateSlider(input)
                        end
                    end)
                    
                    UserInputService.InputEnded:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 then
                            if connection then connection:Disconnect() end
                        end
                    end)
                end)
                
                sliderButton.MouseButton1Click:Connect(function(input)
                    if input and input.Position then
                        updateSlider(input)
                    end
                end)
                
                -- Methods
                local sliderFunctions = {}
                
                function sliderFunctions:Set(value)
                    value = math.clamp(value, min, max)
                    sliderValue = value
                    valueLabel.Text = tostring(value)
                    sliderFill.Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
                    -- Update handle position to match slider value
                    sliderHandle.Position = UDim2.new((value - min) / (max - min), 0, 0.5, 0)
                    callback(value)
                end
                
                function sliderFunctions:Get()
                    return sliderValue
                end
                
                return sliderFunctions
            end
            
            -- Dropdown Element
            function elementFunctions:AddDropdown(dropText, options, callback)
                options = options or {}
                callback = callback or function() end
                
                local selectedOption = options[1] or "Select..."
                local dropdownOpen = false
                
                local dropdown = Create("Frame")({
                    Name = dropText .. "Dropdown",
                    Parent = sectionContent,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 65), -- Height will change when open/closed
                    ClipsDescendants = true
                })
                
                local dropdownLabel = Create("TextLabel")({
                    Name = "Label",
                    Parent = dropdown,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 0, 0, 0),
                    Size = UDim2.new(1, 0, 0, 20),
                    Font = REGULAR_FONT,
                    Text = dropText,
                    TextColor3 = ColorScheme.Text,
                    TextSize = 14,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                
                local dropdownButton = Create("TextButton")({
                    Name = "Button",
                    Parent = dropdown,
                    BackgroundColor3 = ColorScheme.Secondary,
                    Position = UDim2.new(0, 0, 0, 25),
                    Size = UDim2.new(1, 0, 0, 35),
                    Text = "",
                    AutoButtonColor = false
                })
                
                local buttonCorner = Create("UICorner")({
                    CornerRadius = CORNER_RADIUS,
                    Parent = dropdownButton
                })
                
                local buttonStroke = Create("UIStroke")({
                    Parent = dropdownButton,
                    Color = ColorScheme.Accent1,
                    Thickness = 1,
                    ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                    Transparency = 0.8
                })
                
                local selectedLabel = Create("TextLabel")({
                    Name = "SelectedOption",
                    Parent = dropdownButton,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 10, 0, 0),
                    Size = UDim2.new(1, -50, 1, 0),
                    Font = REGULAR_FONT,
                    Text = selectedOption,
                    TextColor3 = ColorScheme.Text,
                    TextSize = 14,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                
                local arrowIcon = Create("TextLabel")({
                    Name = "Arrow",
                    Parent = dropdownButton,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(1, -30, 0, 0),
                    Size = UDim2.new(0, 20, 1, 0),
                    Font = FONT,
                    Text = "▼",
                    TextColor3 = ColorScheme.Text,
                    TextSize = 14
                })
                
                local optionsContainer = Create("Frame")({
                    Name = "OptionsContainer",
                    Parent = dropdown,
                    BackgroundColor3 = ColorScheme.Secondary,
                    Position = UDim2.new(0, 0, 0, 65),
                    Size = UDim2.new(1, 0, 0, 0), -- Will be resized based on options
                    Visible = false
                })
                
                local containerCorner = Create("UICorner")({
                    CornerRadius = CORNER_RADIUS,
                    Parent = optionsContainer
                })
                
                local containerStroke = Create("UIStroke")({
                    Parent = optionsContainer,
                    Color = ColorScheme.Accent1,
                    Thickness = 1,
                    ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                    Transparency = 0.8
                })
                
                local optionsList = Create("ScrollingFrame")({
                    Name = "OptionsList",
                    Parent = optionsContainer,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 1, 0),
                    CanvasSize = UDim2.new(0, 0, 0, 0),
                    ScrollBarThickness = 2,
                    ScrollBarImageColor3 = ColorScheme.Accent1,
                    BorderSizePixel = 0,
                    ScrollingEnabled = true
                })
                
                local optionsLayout = Create("UIListLayout")({
                    Parent = optionsList,
                    Padding = UDim.new(0, 5),
                    HorizontalAlignment = Enum.HorizontalAlignment.Center,
                    SortOrder = Enum.SortOrder.LayoutOrder
                })
                
                local optionsPadding = Create("UIPadding")({
                    Parent = optionsList,
                    PaddingTop = UDim.new(0, 5),
                    PaddingBottom = UDim.new(0, 5),
                    PaddingLeft = UDim.new(0, 5),
                    PaddingRight = UDim.new(0, 5)
                })
                
                -- Populate options
                local function createOptions()
                    -- Clear existing options
                    for _, child in pairs(optionsList:GetChildren()) do
                        if child:IsA("TextButton") then
                            child:Destroy()
                        end
                    end
                    
                    -- Calculate container height (limit to 150px max)
                    local totalHeight = math.min(#options * 30 + (#options - 1) * 5 + 10, 150)
                    optionsContainer.Size = UDim2.new(1, 0, 0, totalHeight)
                    
                    -- Update canvas size
                    optionsList.CanvasSize = UDim2.new(0, 0, 0, #options * 30 + (#options - 1) * 5 + 10)
                    
                    -- Create option buttons
                    for i, option in ipairs(options) do
                        local optionButton = Create("TextButton")({
                            Name = "Option_" .. i,
                            Parent = optionsList,
                            BackgroundColor3 = ColorScheme.Background,
                            Size = UDim2.new(1, 0, 0, 30),
                            Text = "",
                            AutoButtonColor = false
                        })
                        
                        local optionCorner = Create("UICorner")({
                            CornerRadius = CORNER_RADIUS,
                            Parent = optionButton
                        })
                        
                        local optionText = Create("TextLabel")({
                            Name = "OptionText",
                            Parent = optionButton,
                            BackgroundTransparency = 1,
                            Size = UDim2.new(1, 0, 1, 0),
                            Font = REGULAR_FONT,
                            Text = option,
                            TextColor3 = ColorScheme.Text,
                            TextSize = 14
                        })
                        
                        optionButton.MouseEnter:Connect(function()
                            Tween(optionButton, {BackgroundColor3 = ColorScheme.Accent1}, 0.2)
                        end)
                        
                        optionButton.MouseLeave:Connect(function()
                            Tween(optionButton, {BackgroundColor3 = ColorScheme.Background}, 0.2)
                        end)
                        
                        optionButton.MouseButton1Click:Connect(function()
                            selectedOption = option
                            selectedLabel.Text = option
                            
                            -- Close dropdown
                            dropdownOpen = false
                            optionsContainer.Visible = false
                            arrowIcon.Text = "▼"
                            dropdown.Size = UDim2.new(1, 0, 0, 65)
                            
                            callback(option)
                            CreateRipple(optionButton)
                        end)
                    end
                end
                
                -- Toggle dropdown
                dropdownButton.MouseButton1Click:Connect(function()
                    dropdownOpen = not dropdownOpen
                    
                    if dropdownOpen then
                        createOptions()
                        optionsContainer.Visible = true
                        arrowIcon.Text = "▲"
                        dropdown.Size = UDim2.new(1, 0, 0, 65 + optionsContainer.Size.Y.Offset + 5)
                    else
                        optionsContainer.Visible = false
                        arrowIcon.Text = "▼"
                        dropdown.Size = UDim2.new(1, 0, 0, 65)
                    end
                    
                    CreateRipple(dropdownButton)
                end)
                
                -- Methods
                local dropdownFunctions = {}
                
                function dropdownFunctions:Set(option)
                    if table.find(options, option) then
                        selectedOption = option
                        selectedLabel.Text = option
                        callback(option)
                    end
                end
                
                -- Add Select method (alias for Set) to fix compatibility with example code
                function dropdownFunctions:Select(option)
                    self:Set(option)
                end
                
                function dropdownFunctions:Get()
                    return selectedOption
                end
                
                function dropdownFunctions:Refresh(newOptions)
                    options = newOptions
                    selectedOption = newOptions[1] or "Select..."
                    selectedLabel.Text = selectedOption
                    
                    if dropdownOpen then
                        createOptions()
                    end
                end
                
                return dropdownFunctions
            end
            
            -- Input Field Element
            function elementFunctions:AddTextbox(boxText, defaultText, placeholder, callback)
                defaultText = defaultText or ""
                placeholder = placeholder or "Enter text..."
                callback = callback or function() end
                
                local textbox = Create("Frame")({
                    Name = boxText .. "Textbox",
                    Parent = sectionContent,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 65)
                })
                
                local boxLabel = Create("TextLabel")({
                    Name = "Label",
                    Parent = textbox,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 0, 0, 0),
                    Size = UDim2.new(1, 0, 0, 20),
                    Font = REGULAR_FONT,
                    Text = boxText,
                    TextColor3 = ColorScheme.Text,
                    TextSize = 14,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                
                local inputBox = Create("Frame")({
                    Name = "InputBox",
                    Parent = textbox,
                    BackgroundColor3 = ColorScheme.Secondary,
                    Position = UDim2.new(0, 0, 0, 25),
                    Size = UDim2.new(1, 0, 0, 35)
                })
                
                local boxCorner = Create("UICorner")({
                    CornerRadius = CORNER_RADIUS,
                    Parent = inputBox
                })
                
                local boxStroke = Create("UIStroke")({
                    Parent = inputBox,
                    Color = ColorScheme.Accent1,
                    Thickness = 1,
                    ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                    Transparency = 0.8
                })
                
                local textInput = Create("TextBox")({
                    Name = "TextInput",
                    Parent = inputBox,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 10, 0, 0),
                    Size = UDim2.new(1, -20, 1, 0),
                    Font = REGULAR_FONT,
                    PlaceholderText = placeholder,
                    Text = defaultText,
                    TextColor3 = ColorScheme.Text,
                    TextSize = 14,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ClearTextOnFocus = false
                })
                
                textInput.Focused:Connect(function()
                    Tween(boxStroke, {Transparency = 0}, 0.2)
                end)
                
                textInput.FocusLost:Connect(function(enterPressed)
                    Tween(boxStroke, {Transparency = 0.8}, 0.2)
                    callback(textInput.Text, enterPressed)
                end)
                
                -- Methods
                local textboxFunctions = {}
                
                function textboxFunctions:Set(text)
                    textInput.Text = text
                    callback(text, false)
                end
                
                function textboxFunctions:Get()
                    return textInput.Text
                end
                
                return textboxFunctions
            end
            
            -- Label Element
            function elementFunctions:AddLabel(labelText)
                local label = Create("TextLabel")({
                    Name = "InfoLabel",
                    Parent = sectionContent,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 30),
                    Font = REGULAR_FONT,
                    Text = labelText,
                    TextColor3 = ColorScheme.Text,
                    TextSize = 14,
                    TextWrapped = true
                })
                
                -- Automatically adjust height based on text
                local textSize = TextService:GetTextSize(
                    labelText,
                    14,
                    REGULAR_FONT,
                    Vector2.new(label.AbsoluteSize.X, math.huge)
                )
                
                label.Size = UDim2.new(1, 0, 0, textSize.Y + 10)
                
                -- Methods
                local labelFunctions = {}
                
                function labelFunctions:Set(text)
                    label.Text = text
                    
                    -- Update size
                    local newTextSize = TextService:GetTextSize(
                        text,
                        14,
                        REGULAR_FONT,
                        Vector2.new(label.AbsoluteSize.X, math.huge)
                    )
                    
                    label.Size = UDim2.new(1, 0, 0, newTextSize.Y + 10)
                end
                
                return labelFunctions
            end
            
            return elementFunctions
        end
        
        return sectionFunctions
    end
    
    -- Notification system (larger, more prominent notifications)
    function library:Notify(title, message, notifyType, duration)
        -- Convert duration to number to ensure it's valid
        local durationNum = tonumber(duration) or 5
        notifyType = notifyType or "info" -- "info", "success", "error", "warning"
        
        -- Determine color based on type
        local notifyColor
        if notifyType == "success" then
            notifyColor = ColorScheme.Success or Color3.fromRGB(0, 170, 126)
        elseif notifyType == "error" then
            notifyColor = ColorScheme.Error or Color3.fromRGB(255, 61, 61)
        elseif notifyType == "warning" then
            notifyColor = ColorScheme.Warning or Color3.fromRGB(255, 170, 0)
        else
            notifyColor = ColorScheme.Accent1
        end
        
        -- Create notification container if it doesn't exist
        if not UI:FindFirstChild("NotificationContainer") then
            local notifyContainer = Create("Frame")({
                Name = "NotificationContainer",
                Parent = UI,
                BackgroundTransparency = 1,
                Position = UDim2.new(0.5, 0, 0, 0),
                Size = UDim2.new(1, 0, 1, 0),
                AnchorPoint = Vector2.new(0.5, 0),
                ZIndex = 100
            })
        end
        
        local container = UI:FindFirstChild("NotificationContainer")
        
        -- Create notification UI
        local notifyUI = Create("Frame")({
            Name = "Notification_" .. os.time(),
            Parent = container,
            BackgroundColor3 = ColorScheme.Secondary,
            Position = UDim2.new(0.5, 0, 0, -100), -- Start off-screen
            Size = UDim2.new(0, 300, 0, 100),
            AnchorPoint = Vector2.new(0.5, 0),
            ZIndex = 101
        })
        
        local notifyCorner = Create("UICorner")({
            CornerRadius = CORNER_RADIUS,
            Parent = notifyUI
        })
        
        local notifyStroke = Create("UIStroke")({
            Parent = notifyUI,
            Color = notifyColor,
            Thickness = 2,
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        })
        
        local notifyIcon = Create("TextLabel")({
            Name = "Icon",
            Parent = notifyUI,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 15, 0, 0),
            Size = UDim2.new(0, 30, 0, 30),
            Font = FONT,
            TextSize = 20,
            TextColor3 = notifyColor
        })
        
        -- Set icon based on type
        if notifyType == "success" then
            notifyIcon.Text = "✓"
        elseif notifyType == "error" then
            notifyIcon.Text = "✗"
        elseif notifyType == "warning" then
            notifyIcon.Text = "⚠"
        else
            notifyIcon.Text = "ℹ"
        end
        
        local notifyTitle = Create("TextLabel")({
            Name = "Title",
            Parent = notifyUI,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 50, 0, 10),
            Size = UDim2.new(1, -65, 0, 20),
            Font = FONT,
            Text = title or "",
            TextColor3 = ColorScheme.Text,
            TextSize = 18,
            TextXAlignment = Enum.TextXAlignment.Left
        })
        
        local notifyMessage = Create("TextLabel")({
            Name = "Message",
            Parent = notifyUI,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 50, 0, 35),
            Size = UDim2.new(1, -65, 0, 55),
            Font = REGULAR_FONT,
            Text = message or "",
            TextColor3 = ColorScheme.Text,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top,
            TextWrapped = true
        })
        
        -- Close button
        local closeButton = Create("TextButton")({
            Name = "CloseButton",
            Parent = notifyUI,
            BackgroundTransparency = 1,
            Position = UDim2.new(1, -25, 0, 5),
            Size = UDim2.new(0, 20, 0, 20),
            Text = "×",
            TextColor3 = ColorScheme.Text,
            TextSize = 20,
            Font = FONT,
            ZIndex = 102
        })
        
        -- Function to close the notification
        local function closeNotification()
            -- Animate out
            local closeTween = Tween(notifyUI, {Position = UDim2.new(0.5, 0, 0, -100)}, 0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
            
            -- After tween completes, destroy the notification
            task.delay(0.5, function()
                if notifyUI and notifyUI.Parent then
                    notifyUI:Destroy()
                end
            end)
        end
        
        closeButton.MouseButton1Click:Connect(closeNotification)
        
        -- Progress bar
        local progressBar = Create("Frame")({
            Name = "ProgressBar",
            Parent = notifyUI,
            BackgroundColor3 = notifyColor,
            Position = UDim2.new(0, 0, 1, -2),
            Size = UDim2.new(1, 0, 0, 2),
            BorderSizePixel = 0
        })
        
        -- Animate in
        Tween(notifyUI, {Position = UDim2.new(0.5, 0, 0, 20)}, 0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
        
        -- Progress bar animation (shrinks over time)
        local progressTween = Tween(progressBar, {Size = UDim2.new(0, 0, 0, 2)}, durationNum)
        
        -- Auto close after duration
        task.spawn(function()
            task.wait(durationNum)
            
            -- Only animate out if not already closed
            if notifyUI and notifyUI.Parent then
                closeNotification()
            end
        end)
        
        -- Return the notification object so it can be referenced
        return {
            UI = notifyUI,
            Close = closeNotification
        }
    end
    
    -- Toast notification system (smaller, less intrusive notifications)
    function library:Toast(message, toastType, duration)
        -- Convert duration to number to ensure it's valid
        local durationNum = tonumber(duration) or TOAST_DURATION or 3
        local toastType = toastType or "Info" -- "Info", "Success", "Error", "Warning"
        
        -- Determine color based on type
        local toastColor
        if toastType == "Success" then
            toastColor = ColorScheme.Success or Color3.fromRGB(0, 170, 126)
        elseif toastType == "Error" then
            toastColor = ColorScheme.Error or Color3.fromRGB(255, 61, 61)
        elseif toastType == "Warning" then
            toastColor = ColorScheme.Warning or Color3.fromRGB(255, 170, 0)
        else
            toastColor = ColorScheme.Accent1
        end
        
        -- Initialize ActiveToasts table if it doesn't exist
        if not ActiveToasts then
            ActiveToasts = {}
        end
        
        -- Create toast container if it doesn't exist
        if not UI:FindFirstChild("ToastContainer") then
            local toastContainer = Create("Frame")({
                Name = "ToastContainer",
                Parent = UI,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 0, 0, 0),
                Size = UDim2.new(1, 0, 1, 0),
                ZIndex = 95
            })
        end
        
        local container = UI:FindFirstChild("ToastContainer")
        
        -- Create toast UI
        local toastUI = Create("Frame")({
            Name = "Toast_" .. os.time(),
            Parent = container,
            BackgroundColor3 = ColorScheme.Secondary,
            Position = UDim2.new(1, 20, 0.5, 0), -- Start off-screen
            Size = UDim2.new(0, 300, 0, 80),
            AnchorPoint = Vector2.new(0, 0.5),
            ZIndex = 96
        })
        
        local toastCorner = Create("UICorner")({
            CornerRadius = CORNER_RADIUS,
            Parent = toastUI
        })
        
        local toastStroke = Create("UIStroke")({
            Parent = toastUI,
            Color = toastColor,
            Thickness = 2,
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        })
        
        local toastIcon = Create("TextLabel")({
            Name = "Icon",
            Parent = toastUI,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 15, 0, 0),
            Size = UDim2.new(0, 30, 1, 0),
            Font = FONT,
            TextSize = 20,
            TextColor3 = toastColor
        })
        
        -- Set icon based on type
        if toastType == "Success" then
            toastIcon.Text = "✓"
        elseif toastType == "Error" then
            toastIcon.Text = "✗"
        elseif toastType == "Warning" then
            toastIcon.Text = "⚠"
        else
            toastIcon.Text = "ℹ"
        end
        
        local toastTitle = Create("TextLabel")({
            Name = "Title",
            Parent = toastUI,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 50, 0, 10),
            Size = UDim2.new(1, -65, 0, 20),
            Font = FONT,
            Text = toastType,
            TextColor3 = ColorScheme.Text,
            TextSize = 16,
            TextXAlignment = Enum.TextXAlignment.Left
        })
        
        local toastMessage = Create("TextLabel")({
            Name = "Message",
            Parent = toastUI,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 50, 0, 35),
            Size = UDim2.new(1, -65, 0, 35),
            Font = REGULAR_FONT,
            Text = message or "",
            TextColor3 = ColorScheme.Text,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextWrapped = true
        })
        
        -- Close button
        local closeButton = Create("TextButton")({
            Name = "CloseButton",
            Parent = toastUI,
            BackgroundTransparency = 1,
            Position = UDim2.new(1, -25, 0, 5),
            Size = UDim2.new(0, 20, 0, 20),
            Text = "×",
            TextColor3 = ColorScheme.Text,
            TextSize = 20,
            Font = FONT,
            ZIndex = 97
        })
        
        -- Progress bar
        local progressBar = Create("Frame")({
            Name = "ProgressBar",
            Parent = toastUI,
            BackgroundColor3 = toastColor,
            Position = UDim2.new(0, 0, 1, -2),
            Size = UDim2.new(1, 0, 0, 2),
            BorderSizePixel = 0
        })
        
        -- Function to close and remove the toast
        local function closeToast()
            -- Find index of this toast
            local index = table.find(ActiveToasts, toastUI)
            if index then
                table.remove(ActiveToasts, index)
            end
            
            -- Animate out
            Tween(toastUI, {Position = UDim2.new(1, 20, toastUI.Position.Y.Scale, toastUI.Position.Y.Offset)}, 0.5)
            
            -- Reposition remaining toasts
            for i, toast in ipairs(ActiveToasts) do
                local targetPos = UDim2.new(1, -320, 0, 100 + (i * 90))
                Tween(toast, {Position = targetPos}, 0.3)
            end
            
            -- Destroy toast after animation
            task.delay(0.5, function()
                if toastUI and toastUI.Parent then
                    toastUI:Destroy()
                end
            end)
        end
        
        -- Connect close button
        closeButton.MouseButton1Click:Connect(closeToast)
        
        -- Position toast and animate in
        -- Reposition other toasts if any
        for i, toast in ipairs(ActiveToasts) do
            if toast and toast.Parent then
                local targetPos = UDim2.new(1, -320, 0, 100 + (i * 90))
                Tween(toast, {Position = targetPos}, 0.3)
            end
        end
        
        -- Insert this toast at the beginning of the active toasts list
        table.insert(ActiveToasts, 1, toastUI)
        
        -- Animate in
        Tween(toastUI, {Position = UDim2.new(1, -320, 0, 100)}, 0.5, Enum.EasingStyle.Back)
        
        -- Progress bar animation (shrinks over time)
        local progressTween = Tween(progressBar, {Size = UDim2.new(0, 0, 0, 2)}, durationNum)
        
        -- Auto close after duration
        task.spawn(function()
            task.wait(durationNum)
            
            -- Only close if not already closed
            if toastUI and toastUI.Parent then
                closeToast()
            end
        end)
        
        -- Return the toast object so it can be referenced
        return {
            UI = toastUI,
            Close = closeToast
        }
    end
    
    -- Return the library interface
    return library
end

-- Return the module
return SynthwaveUI
