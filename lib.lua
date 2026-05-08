-- Silence UI Library v1.0.0
-- A modern, feature-rich UI library for Roblox executors
-- Created by combining patterns from Obsidian, Linoria, Fluent, and VibeUI

local Silence = {}
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui") or game:GetService("StarterGui")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- Utility Functions
local Utility = {}

function Utility.DeepCopy(original)
    local copy = {}
    for k, v in pairs(original) do
        if type(v) == "table" then
            v = Utility.DeepCopy(v)
        end
        copy[k] = v
    end
    return copy
end

function Utility.TableToJSON(tbl)
    local success, result = pcall(function()
        return HttpService:JSONEncode(tbl)
    end)
    return success and result or "{}"
end

function Utility.JSONToTable(json)
    local success, result = pcall(function()
        return HttpService:JSONDecode(json)
    end)
    return success and result or {}
end

function Utility.CreateTween(obj, props, duration, easingStyle, easingDirection)
    easingStyle = easingStyle or Enum.EasingStyle.Quad
    easingDirection = easingDirection or Enum.EasingDirection.Out
    local tweenInfo = TweenInfo.new(duration, easingStyle, easingDirection)
    local tween = TweenService:Create(obj, tweenInfo, props)
    return tween
end

function Utility.Round(num, decimals)
    local mult = 10 ^ (decimals or 0)
    return math.floor(num * mult + 0.5) / mult
end

-- Color Management
local Colors = {}
Colors.Themes = {
    Dark = {
        Name = "Dark",
        Background = Color3.fromRGB(20, 20, 30),
        Surface = Color3.fromRGB(30, 30, 40),
        Primary = Color3.fromRGB(100, 100, 255),
        Secondary = Color3.fromRGB(40, 40, 50),
        Text = Color3.fromRGB(255, 255, 255),
        SubText = Color3.fromRGB(180, 180, 180),
        Accent = Color3.fromRGB(100, 130, 255),
        Shadow = Color3.fromRGB(0, 0, 0)
    },
    Light = {
        Name = "Light",
        Background = Color3.fromRGB(240, 240, 245),
        Surface = Color3.fromRGB(255, 255, 255),
        Primary = Color3.fromRGB(80, 80, 240),
        Secondary = Color3.fromRGB(230, 230, 235),
        Text = Color3.fromRGB(20, 20, 30),
        SubText = Color3.fromRGB(100, 100, 110),
        Accent = Color3.fromRGB(80, 100, 240),
        Shadow = Color3.fromRGB(200, 200, 210)
    },
    Midnight = {
        Name = "Midnight",
        Background = Color3.fromRGB(10, 10, 25),
        Surface = Color3.fromRGB(20, 20, 45),
        Primary = Color3.fromRGB(80, 80, 200),
        Secondary = Color3.fromRGB(30, 30, 55),
        Text = Color3.fromRGB(220, 220, 255),
        SubText = Color3.fromRGB(150, 150, 200),
        Accent = Color3.fromRGB(100, 100, 255),
        Shadow = Color3.fromRGB(0, 0, 20)
    },
    Ocean = {
        Name = "Ocean",
        Background = Color3.fromRGB(10, 30, 50),
        Surface = Color3.fromRGB(20, 50, 80),
        Primary = Color3.fromRGB(0, 150, 255),
        Secondary = Color3.fromRGB(30, 60, 90),
        Text = Color3.fromRGB(200, 230, 255),
        SubText = Color3.fromRGB(140, 180, 220),
        Accent = Color3.fromRGB(0, 200, 255),
        Shadow = Color3.fromRGB(0, 20, 40)
    },
    Forest = {
        Name = "Forest",
        Background = Color3.fromRGB(15, 35, 20),
        Surface = Color3.fromRGB(25, 55, 35),
        Primary = Color3.fromRGB(50, 200, 80),
        Secondary = Color3.fromRGB(35, 65, 45),
        Text = Color3.fromRGB(220, 255, 230),
        SubText = Color3.fromRGB(150, 220, 170),
        Accent = Color3.fromRGB(70, 255, 100),
        Shadow = Color3.fromRGB(5, 25, 10)
    },
    Sunset = {
        Name = "Sunset",
        Background = Color3.fromRGB(40, 20, 30),
        Surface = Color3.fromRGB(60, 30, 45),
        Primary = Color3.fromRGB(255, 150, 50),
        Secondary = Color3.fromRGB(70, 40, 55),
        Text = Color3.fromRGB(255, 230, 220),
        SubText = Color3.fromRGB(240, 180, 160),
        Accent = Color3.fromRGB(255, 120, 30),
        Shadow = Color3.fromRGB(30, 10, 20)
    },
    Lava = {
        Name = "Lava",
        Background = Color3.fromRGB(40, 15, 10),
        Surface = Color3.fromRGB(60, 25, 15),
        Primary = Color3.fromRGB(255, 80, 20),
        Secondary = Color3.fromRGB(70, 30, 20),
        Text = Color3.fromRGB(255, 220, 200),
        SubText = Color3.fromRGB(255, 160, 120),
        Accent = Color3.fromRGB(255, 100, 0),
        Shadow = Color3.fromRGB(30, 5, 0)
    },
    Ice = {
        Name = "Ice",
        Background = Color3.fromRGB(20, 40, 50),
        Surface = Color3.fromRGB(30, 60, 75),
        Primary = Color3.fromRGB(100, 220, 255),
        Secondary = Color3.fromRGB(40, 70, 85),
        Text = Color3.fromRGB(230, 250, 255),
        SubText = Color3.fromRGB(180, 220, 240),
        Accent = Color3.fromRGB(80, 240, 255),
        Shadow = Color3.fromRGB(10, 30, 40)
    },
    Galaxy = {
        Name = "Galaxy",
        Background = Color3.fromRGB(15, 10, 35),
        Surface = Color3.fromRGB(30, 20, 60),
        Primary = Color3.fromRGB(150, 80, 255),
        Secondary = Color3.fromRGB(40, 25, 70),
        Text = Color3.fromRGB(230, 210, 255),
        SubText = Color3.fromRGB(190, 160, 240),
        Accent = Color3.fromRGB(180, 100, 255),
        Shadow = Color3.fromRGB(5, 0, 25)
    },
    Neon = {
        Name = "Neon",
        Background = Color3.fromRGB(15, 15, 20),
        Surface = Color3.fromRGB(25, 25, 35),
        Primary = Color3.fromRGB(0, 255, 200),
        Secondary = Color3.fromRGB(35, 35, 45),
        Text = Color3.fromRGB(200, 255, 240),
        SubText = Color3.fromRGB(150, 230, 210),
        Accent = Color3.fromRGB(0, 255, 150),
        Shadow = Color3.fromRGB(5, 5, 10)
    },
    Pastel = {
        Name = "Pastel",
        Background = Color3.fromRGB(230, 220, 235),
        Surface = Color3.fromRGB(245, 240, 250),
        Primary = Color3.fromRGB(180, 150, 220),
        Secondary = Color3.fromRGB(235, 230, 240),
        Text = Color3.fromRGB(80, 70, 90),
        SubText = Color3.fromRGB(130, 120, 140),
        Accent = Color3.fromRGB(200, 160, 240),
        Shadow = Color3.fromRGB(200, 190, 210)
    },
    Monochrome = {
        Name = "Monochrome",
        Background = Color3.fromRGB(30, 30, 30),
        Surface = Color3.fromRGB(45, 45, 45),
        Primary = Color3.fromRGB(200, 200, 200),
        Secondary = Color3.fromRGB(50, 50, 50),
        Text = Color3.fromRGB(240, 240, 240),
        SubText = Color3.fromRGB(180, 180, 180),
        Accent = Color3.fromRGB(220, 220, 220),
        Shadow = Color3.fromRGB(15, 15, 15)
    },
    Sepia = {
        Name = "Sepia",
        Background = Color3.fromRGB(50, 40, 30),
        Surface = Color3.fromRGB(70, 55, 40),
        Primary = Color3.fromRGB(180, 140, 90),
        Secondary = Color3.fromRGB(80, 60, 45),
        Text = Color3.fromRGB(240, 230, 210),
        SubText = Color3.fromRGB(200, 180, 150),
        Accent = Color3.fromRGB(200, 150, 80),
        Shadow = Color3.fromRGB(30, 20, 10)
    },
    Cyberpunk = {
        Name = "Cyberpunk",
        Background = Color3.fromRGB(20, 10, 30),
        Surface = Color3.fromRGB(40, 15, 50),
        Primary = Color3.fromRGB(255, 0, 150),
        Secondary = Color3.fromRGB(50, 20, 60),
        Text = Color3.fromRGB(255, 200, 240),
        SubText = Color3.fromRGB(240, 150, 210),
        Accent = Color3.fromRGB(0, 255, 255),
        Shadow = Color3.fromRGB(10, 0, 20)
    },
    RetroTerminal = {
        Name = "Retro Terminal",
        Background = Color3.fromRGB(10, 15, 10),
        Surface = Color3.fromRGB(15, 25, 15),
        Primary = Color3.fromRGB(0, 255, 0),
        Secondary = Color3.fromRGB(20, 30, 20),
        Text = Color3.fromRGB(200, 255, 200),
        SubText = Color3.fromRGB(150, 230, 150),
        Accent = Color3.fromRGB(0, 255, 100),
        Shadow = Color3.fromRGB(0, 5, 0)
    },
    MatrixGreen = {
        Name = "Matrix Green",
        Background = Color3.fromRGB(5, 15, 5),
        Surface = Color3.fromRGB(10, 25, 10),
        Primary = Color3.fromRGB(0, 230, 50),
        Secondary = Color3.fromRGB(15, 30, 15),
        Text = Color3.fromRGB(150, 255, 160),
        SubText = Color3.fromRGB(100, 230, 110),
        Accent = Color3.fromRGB(0, 255, 70),
        Shadow = Color3.fromRGB(0, 5, 0)
    },
    Halloween = {
        Name = "Halloween",
        Background = Color3.fromRGB(25, 15, 20),
        Surface = Color3.fromRGB(40, 20, 30),
        Primary = Color3.fromRGB(255, 100, 30),
        Secondary = Color3.fromRGB(45, 25, 35),
        Text = Color3.fromRGB(255, 220, 200),
        SubText = Color3.fromRGB(240, 180, 150),
        Accent = Color3.fromRGB(180, 50, 255),
        Shadow = Color3.fromRGB(15, 5, 10)
    },
    Christmas = {
        Name = "Christmas",
        Background = Color3.fromRGB(20, 25, 25),
        Surface = Color3.fromRGB(30, 40, 40),
        Primary = Color3.fromRGB(220, 30, 40),
        Secondary = Color3.fromRGB(35, 45, 45),
        Text = Color3.fromRGB(240, 240, 240),
        SubText = Color3.fromRGB(190, 200, 200),
        Accent = Color3.fromRGB(0, 180, 80),
        Shadow = Color3.fromRGB(10, 15, 15)
    },
    Valentine = {
        Name = "Valentine",
        Background = Color3.fromRGB(40, 20, 30),
        Surface = Color3.fromRGB(60, 30, 45),
        Primary = Color3.fromRGB(255, 80, 120),
        Secondary = Color3.fromRGB(65, 35, 50),
        Text = Color3.fromRGB(255, 230, 235),
        SubText = Color3.fromRGB(240, 180, 190),
        Accent = Color3.fromRGB(255, 60, 100),
        Shadow = Color3.fromRGB(25, 10, 20)
    },
    AquaGlass = {
        Name = "Aqua Glass",
        Background = Color3.fromRGB(15, 40, 50),
        Surface = Color3.fromRGB(25, 60, 75),
        Primary = Color3.fromRGB(50, 200, 220),
        Secondary = Color3.fromRGB(30, 70, 85),
        Text = Color3.fromRGB(210, 250, 255),
        SubText = Color3.fromRGB(160, 220, 230),
        Accent = Color3.fromRGB(40, 220, 240),
        Shadow = Color3.fromRGB(5, 30, 40)
    },
    FrostedMetal = {
        Name = "Frosted Metal",
        Background = Color3.fromRGB(40, 42, 48),
        Surface = Color3.fromRGB(55, 58, 65),
        Primary = Color3.fromRGB(140, 160, 200),
        Secondary = Color3.fromRGB(60, 63, 70),
        Text = Color3.fromRGB(230, 235, 240),
        SubText = Color3.fromRGB(180, 185, 195),
        Accent = Color3.fromRGB(160, 180, 220),
        Shadow = Color3.fromRGB(25, 27, 33)
    },
    RoyalPurple = {
        Name = "Royal Purple",
        Background = Color3.fromRGB(25, 15, 40),
        Surface = Color3.fromRGB(40, 25, 60),
        Primary = Color3.fromRGB(160, 80, 220),
        Secondary = Color3.fromRGB(45, 30, 65),
        Text = Color3.fromRGB(240, 220, 255),
        SubText = Color3.fromRGB(200, 170, 240),
        Accent = Color3.fromRGB(180, 90, 240),
        Shadow = Color3.fromRGB(15, 5, 30)
    },
    Emerald = {
        Name = "Emerald",
        Background = Color3.fromRGB(10, 30, 20),
        Surface = Color3.fromRGB(20, 50, 35),
        Primary = Color3.fromRGB(30, 200, 100),
        Secondary = Color3.fromRGB(25, 55, 40),
        Text = Color3.fromRGB(210, 255, 230),
        SubText = Color3.fromRGB(160, 230, 190),
        Accent = Color3.fromRGB(40, 255, 120),
        Shadow = Color3.fromRGB(5, 20, 10)
    },
    Ruby = {
        Name = "Ruby",
        Background = Color3.fromRGB(35, 10, 15),
        Surface = Color3.fromRGB(55, 20, 25),
        Primary = Color3.fromRGB(230, 40, 60),
        Secondary = Color3.fromRGB(60, 25, 30),
        Text = Color3.fromRGB(255, 220, 225),
        SubText = Color3.fromRGB(240, 160, 170),
        Accent = Color3.fromRGB(255, 50, 70),
        Shadow = Color3.fromRGB(20, 0, 5)
    },
    Sapphire = {
        Name = "Sapphire",
        Background = Color3.fromRGB(10, 15, 40),
        Surface = Color3.fromRGB(20, 25, 60),
        Primary = Color3.fromRGB(50, 100, 240),
        Secondary = Color3.fromRGB(25, 30, 65),
        Text = Color3.fromRGB(210, 220, 255),
        SubText = Color3.fromRGB(160, 170, 240),
        Accent = Color3.fromRGB(70, 120, 255),
        Shadow = Color3.fromRGB(5, 5, 25)
    },
    Amber = {
        Name = "Amber",
        Background = Color3.fromRGB(35, 25, 10),
        Surface = Color3.fromRGB(55, 40, 20),
        Primary = Color3.fromRGB(240, 160, 30),
        Secondary = Color3.fromRGB(60, 45, 25),
        Text = Color3.fromRGB(255, 240, 210),
        SubText = Color3.fromRGB(240, 200, 150),
        Accent = Color3.fromRGB(255, 180, 40),
        Shadow = Color3.fromRGB(20, 15, 0)
    },
    RoseGold = {
        Name = "Rose Gold",
        Background = Color3.fromRGB(40, 25, 30),
        Surface = Color3.fromRGB(60, 40, 45),
        Primary = Color3.fromRGB(230, 140, 150),
        Secondary = Color3.fromRGB(65, 45, 50),
        Text = Color3.fromRGB(255, 235, 240),
        SubText = Color3.fromRGB(240, 190, 195),
        Accent = Color3.fromRGB(250, 160, 170),
        Shadow = Color3.fromRGB(25, 15, 20)
    },
    Mint = {
        Name = "Mint",
        Background = Color3.fromRGB(15, 35, 30),
        Surface = Color3.fromRGB(25, 55, 50),
        Primary = Color3.fromRGB(60, 220, 170),
        Secondary = Color3.fromRGB(30, 60, 55),
        Text = Color3.fromRGB(210, 255, 240),
        SubText = Color3.fromRGB(160, 230, 210),
        Accent = Color3.fromRGB(80, 240, 190),
        Shadow = Color3.fromRGB(5, 25, 20)
    },
    Lavender = {
        Name = "Lavender",
        Background = Color3.fromRGB(30, 25, 40),
        Surface = Color3.fromRGB(50, 40, 60),
        Primary = Color3.fromRGB(170, 140, 230),
        Secondary = Color3.fromRGB(55, 45, 65),
        Text = Color3.fromRGB(240, 230, 255),
        SubText = Color3.fromRGB(200, 180, 240),
        Accent = Color3.fromRGB(190, 150, 250),
        Shadow = Color3.fromRGB(20, 15, 30)
    },
    Coffee = {
        Name = "Coffee",
        Background = Color3.fromRGB(35, 25, 15),
        Surface = Color3.fromRGB(55, 40, 25),
        Primary = Color3.fromRGB(180, 120, 70),
        Secondary = Color3.fromRGB(60, 45, 30),
        Text = Color3.fromRGB(240, 225, 200),
        SubText = Color3.fromRGB(210, 180, 150),
        Accent = Color3.fromRGB(200, 140, 80),
        Shadow = Color3.fromRGB(20, 10, 5)
    },
    Sand = {
        Name = "Sand",
        Background = Color3.fromRGB(50, 45, 35),
        Surface = Color3.fromRGB(70, 65, 50),
        Primary = Color3.fromRGB(220, 180, 120),
        Secondary = Color3.fromRGB(75, 70, 55),
        Text = Color3.fromRGB(255, 250, 240),
        SubText = Color3.fromRGB(230, 210, 180),
        Accent = Color3.fromRGB(240, 200, 130),
        Shadow = Color3.fromRGB(35, 30, 20)
    },
    Charcoal = {
        Name = "Charcoal",
        Background = Color3.fromRGB(25, 25, 28),
        Surface = Color3.fromRGB(38, 38, 42),
        Primary = Color3.fromRGB(120, 120, 130),
        Secondary = Color3.fromRGB(42, 42, 47),
        Text = Color3.fromRGB(220, 220, 225),
        SubText = Color3.fromRGB(170, 170, 175),
        Accent = Color3.fromRGB(140, 140, 150),
        Shadow = Color3.fromRGB(15, 15, 18)
    },
    Vibrant = {
        Name = "Vibrant",
        Background = Color3.fromRGB(20, 15, 40),
        Surface = Color3.fromRGB(35, 25, 65),
        Primary = Color3.fromRGB(255, 100, 255),
        Secondary = Color3.fromRGB(40, 30, 70),
        Text = Color3.fromRGB(255, 230, 255),
        SubText = Color3.fromRGB(240, 180, 240),
        Accent = Color3.fromRGB(255, 150, 255),
        Shadow = Color3.fromRGB(10, 5, 30)
    }
}

-- Default Theme
Colors.CurrentTheme = Colors.Themes.Dark
Colors.AccentColor = Colors.CurrentTheme.Accent
Colors.Transparency = 0.15

-- Icon System
local Icons = {
    Solar = {
        Home = "rbxassetid://7072706675",
        Settings = "rbxassetid://7072720870",
        User = "rbxassetid://7072719335",
        Search = "rbxassetid://7072717738",
        Close = "rbxassetid://7072720180",
        Minimize = "rbxassetid://7072721384",
        Maximize = "rbxassetid://7072719987"
    },
    Lucide = {
        Home = "rbxassetid://10709751398",
        Settings = "rbxassetid://10709751284",
        User = "rbxassetid://10709751469",
        Search = "rbxassetid://10709751343",
        Close = "rbxassetid://10709751128",
        Minimize = "rbxassetid://10709751230",
        Maximize = "rbxassetid://10709751205"
    },
    Fallback = {
        Home = "",
        Settings = "",
        User = "",
        Search = "",
        Close = "",
        Minimize = "",
        Maximize = ""
    }
}

-- Save Manager
local SaveManager = {}
SaveManager.Configs = {}
SaveManager.CurrentConfig = "Default"
SaveManager.AutoSaveEnabled = true

function SaveManager:Save(name)
    name = name or self.CurrentConfig
    local data = {
        theme = Colors.CurrentTheme.Name,
        transparency = Colors.Transparency,
        accentColor = {Colors.AccentColor.R, Colors.AccentColor.G, Colors.AccentColor.B},
        elements = {},
        floatingButtonPos = {}
    }
    
    -- Save element states
    for _, element in pairs(Silence.Elements or {}) do
        if element.Type == "Toggle" then
            data.elements[element.Id] = element:GetValue()
        elseif element.Type == "Slider" then
            data.elements[element.Id] = element:GetValue()
        elseif element.Type == "Dropdown" then
            data.elements[element.Id] = element:GetValue()
        elseif element.Type == "Keybind" then
            data.elements[element.Id] = element:GetValue()
        end
    end
    
    -- Save floating button position
    if Silence.FloatingButton then
        data.floatingButtonPos = {
            X = Silence.FloatingButton.Position.X.Scale,
            Y = Silence.FloatingButton.Position.Y.Scale
        }
    end
    
    self.Configs[name] = data
    
    -- Attempt to save to file
    pcall(function()
        if writefile then
            writefile("Silence_Config_" .. name .. ".json", Utility.TableToJSON(data))
        end
    end)
    
    return true
end

function SaveManager:Load(name)
    name = name or self.CurrentConfig
    local data = self.Configs[name]
    
    if not data then
        -- Try loading from file
        pcall(function()
            if readfile and isfile then
                local path = "Silence_Config_" .. name .. ".json"
                if isfile(path) then
                    data = Utility.JSONToTable(readfile(path))
                    self.Configs[name] = data
                end
            end
        end)
    end
    
    if data then
        -- Apply theme
        if data.theme and Colors.Themes[data.theme] then
            Silence:ApplyTheme(Colors.Themes[data.theme])
        end
        
        if data.transparency then
            Colors.Transparency = data.transparency
            Silence:UpdateTransparency()
        end
        
        if data.accentColor then
            Colors.AccentColor = Color3.fromRGB(unpack(data.accentColor))
        end
        
        -- Load element states
        if data.elements then
            for id, value in pairs(data.elements) do
                if Silence.Elements and Silence.Elements[id] then
                    Silence.Elements[id]:SetValue(value)
                end
            end
        end
        
        -- Load floating button position
        if data.floatingButtonPos and Silence.FloatingButton then
            Silence.FloatingButton.Position = UDim2.new(
                data.floatingButtonPos.X or 0.01,
                0,
                data.floatingButtonPos.Y or 0.5,
                0
            )
        end
        
        self.CurrentConfig = name
        return true
    end
    
    return false
end

function SaveManager:ExportConfig(name)
    name = name or self.CurrentConfig
    self:Save(name)
    local data = self.Configs[name]
    if data then
        return Utility.TableToJSON(data)
    end
    return "{}"
end

function SaveManager:ImportConfig(jsonString, name)
    local data = Utility.JSONToTable(jsonString)
    if data then
        self.Configs[name or "Imported"] = data
        self:Load(name or "Imported")
        return true
    end
    return false
end

-- Notification System
local Notifications = {}
Notifications.List = {}
Notifications.ActiveNotifications = {}

function Notifications:Show(title, message, duration, icon)
    duration = duration or 3
    local notification = {
        Title = title or "Notification",
        Message = message or "",
        Duration = duration,
        Icon = icon,
        TimeCreated = tick(),
        Frame = nil
    }
    
    table.insert(self.List, notification)
    
    -- Create visual notification
    spawn(function()
        local notifFrame = Instance.new("Frame")
        notifFrame.Size = UDim2.new(0, 250, 0, 60)
        notifFrame.Position = UDim2.new(1, 20, 0.8, -(#self.ActiveNotifications * 70))
        notifFrame.BackgroundColor3 = Colors.CurrentTheme.Surface
        notifFrame.BorderSizePixel = 0
        notifFrame.BackgroundTransparency = 0.2
        notifFrame.Parent = Silence.Parent
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 8)
        corner.Parent = notifFrame
        
        local titleLabel = Instance.new("TextLabel")
        titleLabel.Size = UDim2.new(1, -20, 0, 25)
        titleLabel.Position = UDim2.new(0, 10, 0, 5)
        titleLabel.Text = title
        titleLabel.TextColor3 = Colors.CurrentTheme.Text
        titleLabel.BackgroundTransparency = 1
        titleLabel.Font = Enum.Font.GothamBold
        titleLabel.TextSize = 14
        titleLabel.TextXAlignment = Enum.TextXAlignment.Left
        titleLabel.Parent = notifFrame
        
        local messageLabel = Instance.new("TextLabel")
        messageLabel.Size = UDim2.new(1, -20, 0, 25)
        messageLabel.Position = UDim2.new(0, 10, 0, 30)
        messageLabel.Text = message
        messageLabel.TextColor3 = Colors.CurrentTheme.SubText
        messageLabel.BackgroundTransparency = 1
        messageLabel.Font = Enum.Font.Gotham
        messageLabel.TextSize = 12
        messageLabel.TextXAlignment = Enum.TextXAlignment.Left
        messageLabel.Parent = notifFrame
        
        notification.Frame = notifFrame
        self.ActiveNotifications[notifFrame] = notification
        
        -- Slide in animation
        notifFrame:TweenPosition(
            UDim2.new(1, -270, 0.8, -(#self.ActiveNotifications * 70)),
            Enum.EasingDirection.Out,
            Enum.EasingStyle.Quad,
            0.3,
            true
        )
        
        -- Auto dismiss
        delay(duration, function()
            if notifFrame and notifFrame.Parent then
                notifFrame:TweenPosition(
                    UDim2.new(1, 20, notifFrame.Position.Y.Scale, notifFrame.Position.Y.Offset),
                    Enum.EasingDirection.In,
                    Enum.EasingStyle.Quad,
                    0.3,
                    true
                )
                delay(0.3, function()
                    if notifFrame and notifFrame.Parent then
                        notifFrame:Destroy()
                        self.ActiveNotifications[notifFrame] = nil
                    end
                end)
            end
        end)
        
        -- Click to dismiss
        notifFrame.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                notifFrame:Destroy()
                self.ActiveNotifications[notifFrame] = nil
            end
        end)
    end)
end

-- Dialog System
local Dialog = {}

function Dialog:Confirm(title, message, callback)
    local dialogFrame = Instance.new("Frame")
    dialogFrame.Size = UDim2.new(0, 300, 0, 150)
    dialogFrame.Position = UDim2.new(0.5, -150, 0.5, -75)
    dialogFrame.BackgroundColor3 = Colors.CurrentTheme.Background
    dialogFrame.BorderSizePixel = 0
    dialogFrame.BackgroundTransparency = 0.1
    dialogFrame.ZIndex = 10
    dialogFrame.Parent = Silence.Parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = dialogFrame
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -20, 0, 30)
    titleLabel.Position = UDim2.new(0, 10, 0, 10)
    titleLabel.Text = title
    titleLabel.TextColor3 = Colors.CurrentTheme.Text
    titleLabel.BackgroundTransparency = 1
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 16
    titleLabel.Parent = dialogFrame
    
    local messageLabel = Instance.new("TextLabel")
    messageLabel.Size = UDim2.new(1, -20, 0, 60)
    messageLabel.Position = UDim2.new(0, 10, 0, 45)
    messageLabel.Text = message
    messageLabel.TextColor3 = Colors.CurrentTheme.SubText
    messageLabel.BackgroundTransparency = 1
    messageLabel.Font = Enum.Font.Gotham
    messageLabel.TextSize = 13
    messageLabel.TextWrapped = true
    messageLabel.Parent = dialogFrame
    
    local yesButton = Instance.new("TextButton")
    yesButton.Size = UDim2.new(0, 100, 0, 30)
    yesButton.Position = UDim2.new(0.5, -110, 1, -45)
    yesButton.Text = "Yes"
    yesButton.TextColor3 = Colors.CurrentTheme.Text
    yesButton.BackgroundColor3 = Colors.CurrentTheme.Primary
    yesButton.BorderSizePixel = 0
    yesButton.Font = Enum.Font.GothamBold
    yesButton.TextSize = 14
    yesButton.Parent = dialogFrame
    
    local yesCorner = Instance.new("UICorner")
    yesCorner.CornerRadius = UDim.new(0, 6)
    yesCorner.Parent = yesButton
    
    local noButton = Instance.new("TextButton")
    noButton.Size = UDim2.new(0, 100, 0, 30)
    noButton.Position = UDim2.new(0.5, 10, 1, -45)
    noButton.Text = "No"
    noButton.TextColor3 = Colors.CurrentTheme.Text
    noButton.BackgroundColor3 = Colors.CurrentTheme.Secondary
    noButton.BorderSizePixel = 0
    noButton.Font = Enum.Font.GothamBold
    noButton.TextSize = 14
    noButton.Parent = dialogFrame
    
    local noCorner = Instance.new("UICorner")
    noCorner.CornerRadius = UDim.new(0, 6)
    noCorner.Parent = noButton
    
    yesButton.MouseButton1Click:Connect(function()
        dialogFrame:Destroy()
        if callback then callback(true) end
    end)
    
    noButton.MouseButton1Click:Connect(function()
        dialogFrame:Destroy()
        if callback then callback(false) end
    end)
    
    return dialogFrame
end

function Dialog:Alert(title, message)
    local dialogFrame = Instance.new("Frame")
    dialogFrame.Size = UDim2.new(0, 300, 0, 150)
    dialogFrame.Position = UDim2.new(0.5, -150, 0.5, -75)
    dialogFrame.BackgroundColor3 = Colors.CurrentTheme.Background
    dialogFrame.BorderSizePixel = 0
    dialogFrame.BackgroundTransparency = 0.1
    dialogFrame.ZIndex = 10
    dialogFrame.Parent = Silence.Parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = dialogFrame
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -20, 0, 30)
    titleLabel.Position = UDim2.new(0, 10, 0, 10)
    titleLabel.Text = title
    titleLabel.TextColor3 = Colors.CurrentTheme.Text
    titleLabel.BackgroundTransparency = 1
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 16
    titleLabel.Parent = dialogFrame
    
    local messageLabel = Instance.new("TextLabel")
    messageLabel.Size = UDim2.new(1, -20, 0, 60)
    messageLabel.Position = UDim2.new(0, 10, 0, 45)
    messageLabel.Text = message
    messageLabel.TextColor3 = Colors.CurrentTheme.SubText
    messageLabel.BackgroundTransparency = 1
    messageLabel.Font = Enum.Font.Gotham
    messageLabel.TextSize = 13
    messageLabel.TextWrapped = true
    messageLabel.Parent = dialogFrame
    
    local okButton = Instance.new("TextButton")
    okButton.Size = UDim2.new(0, 100, 0, 30)
    okButton.Position = UDim2.new(0.5, -50, 1, -45)
    okButton.Text = "OK"
    okButton.TextColor3 = Colors.CurrentTheme.Text
    okButton.BackgroundColor3 = Colors.CurrentTheme.Primary
    okButton.BorderSizePixel = 0
    okButton.Font = Enum.Font.GothamBold
    okButton.TextSize = 14
    okButton.Parent = dialogFrame
    
    local okCorner = Instance.new("UICorner")
    okCorner.CornerRadius = UDim.new(0, 6)
    okCorner.Parent = okButton
    
    okButton.MouseButton1Click:Connect(function()
        dialogFrame:Destroy()
    end)
    
    return dialogFrame
end

-- Core UI Library
local function CreateInstance(className, properties)
    local instance = Instance.new(className)
    for prop, value in pairs(properties) do
        pcall(function()
            instance[prop] = value
        end)
    end
    return instance
end

function Silence:CreateWindow(title)
    local Window = {}
    Window.Title = title or "Silence UI"
    Window.Tabs = {}
    Window.Elements = {}
    Window.Draggable = true
    
    -- Create parent ScreenGui
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "SilenceUI"
    ScreenGui.Parent = CoreGui
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    Silence.Parent = ScreenGui
    
    -- Main window frame with acrylic effect
    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 550, 0, 400)
    MainFrame.Position = UDim2.new(0.5, -275, 0.5, -200)
    MainFrame.BackgroundColor3 = Colors.CurrentTheme.Background
    MainFrame.BackgroundTransparency = Colors.Transparency
    MainFrame.BorderSizePixel = 0
    MainFrame.ClipsDescendants = true
    MainFrame.Parent = ScreenGui
    
    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 12)
    MainCorner.Parent = MainFrame
    
    -- Shadow effect
    local Shadow = Instance.new("ImageLabel")
    Shadow.Size = UDim2.new(1, 20, 1, 20)
    Shadow.Position = UDim2.new(0, -10, 0, -10)
    Shadow.BackgroundTransparency = 1
    Shadow.Image = "rbxassetid://6014261993"
    Shadow.ImageColor3 = Colors.CurrentTheme.Shadow
    Shadow.ImageTransparency = 0.6
    Shadow.ScaleType = Enum.ScaleType.Slice
    Shadow.SliceCenter = Rect.new(49, 49, 49, 49)
    Shadow.ZIndex = -1
    Shadow.Parent = MainFrame
    
    -- Title bar
    local TitleBar = Instance.new("Frame")
    TitleBar.Size = UDim2.new(1, 0, 0, 35)
    TitleBar.BackgroundColor3 = Colors.CurrentTheme.Surface
    TitleBar.BackgroundTransparency = 0.3
    TitleBar.BorderSizePixel = 0
    TitleBar.Parent = MainFrame
    
    local TitleCorner = Instance.new("UICorner")
    TitleCorner.CornerRadius = UDim.new(0, 12)
    TitleCorner.Parent = TitleBar
    
    -- Window controls (Mac OS style)
    local CloseButton = Instance.new("TextButton")
    CloseButton.Size = UDim2.new(0, 14, 0, 14)
    CloseButton.Position = UDim2.new(0, 12, 0, 10)
    CloseButton.BackgroundColor3 = Color3.fromRGB(255, 90, 90)
    CloseButton.Text = ""
    CloseButton.BorderSizePixel = 0
    CloseButton.Parent = TitleBar
    
    local CloseCorner = Instance.new("UICorner")
    CloseCorner.CornerRadius = UDim.new(1, 0)
    CloseCorner.Parent = CloseButton
    
    CloseButton.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
        if SaveManager.AutoSaveEnabled then
            SaveManager:Save()
        end
    end)
    
    local MinimizeButton = Instance.new("TextButton")
    MinimizeButton.Size = UDim2.new(0, 14, 0, 14)
    MinimizeButton.Position = UDim2.new(0, 32, 0, 10)
    MinimizeButton.BackgroundColor3 = Color3.fromRGB(255, 200, 70)
    MinimizeButton.Text = ""
    MinimizeButton.BorderSizePixel = 0
    MinimizeButton.Parent = TitleBar
    
    local MinCorner = Instance.new("UICorner")
    MinCorner.CornerRadius = UDim.new(1, 0)
    MinCorner.Parent = MinimizeButton
    
    MinimizeButton.MouseButton1Click:Connect(function()
        MainFrame.Visible = not MainFrame.Visible
    end)
    
    local FullscreenButton = Instance.new("TextButton")
    FullscreenButton.Size = UDim2.new(0, 14, 0, 14)
    FullscreenButton.Position = UDim2.new(0, 52, 0, 10)
    FullscreenButton.BackgroundColor3 = Color3.fromRGB(90, 220, 90)
    FullscreenButton.Text = ""
    FullscreenButton.BorderSizePixel = 0
    FullscreenButton.Parent = TitleBar
    
    local FullCorner = Instance.new("UICorner")
    FullCorner.CornerRadius = UDim.new(1, 0)
    FullCorner.Parent = FullscreenButton
    
    local isFullscreen = false
    local lastSize, lastPos
    
    FullscreenButton.MouseButton1Click:Connect(function()
        if not isFullscreen then
            lastSize = MainFrame.Size
            lastPos = MainFrame.Position
            MainFrame:TweenSize(UDim2.new(0.8, 0, 0.8, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.3, true)
            MainFrame:TweenPosition(UDim2.new(0.1, 0, 0.1, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.3, true)
        else
            MainFrame:TweenSize(lastSize, Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.3, true)
            MainFrame:TweenPosition(lastPos, Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.3, true)
        end
        isFullscreen = not isFullscreen
    end)
    
    -- Title text
    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Size = UDim2.new(1, -120, 1, 0)
    TitleLabel.Position = UDim2.new(0, 75, 0, 0)
    TitleLabel.Text = Window.Title
    TitleLabel.TextColor3 = Colors.CurrentTheme.Text
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextSize = 14
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Parent = TitleBar
    
    -- Dragging functionality
    local dragStart, startPos
    TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragStart = input.Position
            startPos = MainFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragStart = nil
                end
            end)
        end
    end)
    
    TitleBar.InputChanged:Connect(function(input)
        if dragStart and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            local newX = math.clamp(startPos.X.Offset + delta.X, -MainFrame.Size.X.Offset + 100, game.Workspace.CurrentCamera.ViewportSize.X - 100)
            local newY = math.clamp(startPos.Y.Offset + delta.Y, 0, game.Workspace.CurrentCamera.ViewportSize.Y - 50)
            MainFrame.Position = UDim2.new(0, newX, 0, newY)
        end
    end)
    
    -- Tab system
    local TabContainer = Instance.new("Frame")
    TabContainer.Size = UDim2.new(0, 120, 1, -35)
    TabContainer.Position = UDim2.new(0, 0, 0, 35)
    TabContainer.BackgroundColor3 = Colors.CurrentTheme.Surface
    TabContainer.BackgroundTransparency = 0.5
    TabContainer.BorderSizePixel = 0
    TabContainer.Parent = MainFrame
    
    local TabList = Instance.new("ScrollingFrame")
    TabList.Size = UDim2.new(1, 0, 1, -5)
    TabList.Position = UDim2.new(0, 0, 0, 5)
    TabList.BackgroundTransparency = 1
    TabList.BorderSizePixel = 0
    TabList.ScrollBarThickness = 0
    TabList.CanvasSize = UDim2.new(0, 0, 0, 0)
    TabList.Parent = TabContainer
    
    local TabListLayout = Instance.new("UIListLayout")
    TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabListLayout.Padding = UDim.new(0, 2)
    TabListLayout.Parent = TabList
    
    -- Content area
    local ContentFrame = Instance.new("Frame")
    ContentFrame.Size = UDim2.new(1, -120, 1, -35)
    ContentFrame.Position = UDim2.new(0, 120, 0, 35)
    ContentFrame.BackgroundColor3 = Colors.CurrentTheme.Background
    ContentFrame.BackgroundTransparency = 0.8
    ContentFrame.BorderSizePixel = 0
    ContentFrame.Parent = MainFrame
    
    -- Scroll system for content
    local ContentScroll = Instance.new("ScrollingFrame")
    ContentScroll.Size = UDim2.new(1, -5, 1, -5)
    ContentScroll.Position = UDim2.new(0, 2, 0, 2)
    ContentScroll.BackgroundTransparency = 1
    ContentScroll.BorderSizePixel = 0
    ContentScroll.ScrollBarThickness = 4
    ContentScroll.ScrollBarImageColor3 = Colors.CurrentTheme.Primary
    ContentScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    ContentScroll.Parent = ContentFrame
    
    local ContentList = Instance.new("UIListLayout")
    ContentList.SortOrder = Enum.SortOrder.LayoutOrder
    ContentList.Padding = UDim.new(0, 5)
    ContentList.Parent = ContentScroll
    
    ContentList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        ContentScroll.CanvasSize = UDim2.new(0, 0, 0, ContentList.AbsoluteContentSize.Y + 10)
    end)
    
    -- Window Methods
    function Window:AddTab(tabName, icon)
        local Tab = {}
        Tab.Name = tabName
        Tab.Elements = {}
        Tab.Content = ContentScroll
        
        local tabButton = Instance.new("TextButton")
        tabButton.Size = UDim2.new(1, -10, 0, 30)
        tabButton.Position = UDim2.new(0, 5, 0, 0)
        tabButton.BackgroundColor3 = Colors.CurrentTheme.Secondary
        tabButton.BackgroundTransparency = 0.5
        tabButton.BorderSizePixel = 0
        tabButton.Text = "  " .. tabName
        tabButton.TextColor3 = Colors.CurrentTheme.SubText
        tabButton.Font = Enum.Font.Gotham
        tabButton.TextSize = 13
        tabButton.TextXAlignment = Enum.TextXAlignment.Left
        tabButton.Parent = TabList
        
        local tabCorner = Instance.new("UICorner")
        tabCorner.CornerRadius = UDim.new(0, 6)
        tabCorner.Parent = tabButton
        
        local tabListFrame = Instance.new("Frame")
        tabListFrame.Size = UDim2.new(1, 0, 0, 0)
        tabListFrame.BackgroundTransparency = 1
        tabListFrame.Visible = false
        tabListFrame.Parent = ContentScroll
        
        local tabListLayout = Instance.new("UIListLayout")
        tabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
        tabListLayout.Padding = UDim.new(0, 5)
        tabListLayout.Parent = tabListFrame
        
        tabListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            tabListFrame.Size = UDim2.new(1, 0, 0, tabListLayout.AbsoluteContentSize.Y + 10)
        end)
        
        tabButton.MouseButton1Click:Connect(function()
            -- Deactivate all tabs
            for _, t in pairs(Window.Tabs) do
                if t.TabButton then
                    t.TabButton.BackgroundTransparency = 0.5
                    t.TabButton.TextColor3 = Colors.CurrentTheme.SubText
                end
                if t.TabFrame then
                    t.TabFrame.Visible = false
                end
            end
            
            -- Activate selected tab
            tabButton.BackgroundTransparency = 0.2
            tabButton.TextColor3 = Colors.CurrentTheme.Text
            tabListFrame.Visible = true
            
            -- Update scroll size
            ContentScroll.CanvasSize = UDim2.new(0, 0, 0, tabListLayout.AbsoluteContentSize.Y + 10)
        end)
        
        Tab.TabButton = tabButton
        Tab.TabFrame = tabListFrame
        
        -- Element creation methods
        function Tab:AddButton(text, callback)
            local element = {
                Type = "Button",
                Id = text .. "_" .. #Tab.Elements
            }
            
            local button = Instance.new("TextButton")
            button.Size = UDim2.new(1, -20, 0, 35)
            button.Position = UDim2.new(0, 10, 0, 0)
            button.BackgroundColor3 = Colors.CurrentTheme.Primary
            button.BackgroundTransparency = 0.3
            button.BorderSizePixel = 0
            button.Text = text
            button.TextColor3 = Colors.CurrentTheme.Text
            button.Font = Enum.Font.GothamBold
            button.TextSize = 14
            button.Parent = tabListFrame
            
            local buttonCorner = Instance.new("UICorner")
            buttonCorner.CornerRadius = UDim.new(0, 6)
            buttonCorner.Parent = button
            
            -- Hover effects
            button.MouseEnter:Connect(function()
                button.BackgroundTransparency = 0.1
            end)
            
            button.MouseLeave:Connect(function()
                button.BackgroundTransparency = 0.3
            end)
            
            button.MouseButton1Click:Connect(function()
                -- Click animation
                button:TweenSize(UDim2.new(1, -20, 0, 32), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.1, true)
                delay(0.1, function()
                    button:TweenSize(UDim2.new(1, -20, 0, 35), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.1, true)
                end)
                
                if callback then
                    callback()
                end
            end)
            
            element.SetValue = function(self, val) end
            element.GetValue = function(self) return nil end
            
            table.insert(Tab.Elements, element)
            Silence.Elements[element.Id] = element
            return element
        end
        
        function Tab:AddToggle(text, default, callback)
            local element = {
                Type = "Toggle",
                Id = text .. "_" .. #Tab.Elements,
                Value = default or false
            }
            
            local toggleFrame = Instance.new("Frame")
            toggleFrame.Size = UDim2.new(1, -20, 0, 30)
            toggleFrame.Position = UDim2.new(0, 10, 0, 0)
            toggleFrame.BackgroundColor3 = Colors.CurrentTheme.Secondary
            toggleFrame.BackgroundTransparency = 0.5
            toggleFrame.BorderSizePixel = 0
            toggleFrame.Parent = tabListFrame
            
            local toggleCorner = Instance.new("UICorner")
            toggleCorner.CornerRadius = UDim.new(0, 6)
            toggleCorner.Parent = toggleFrame
            
            local toggleLabel = Instance.new("TextLabel")
            toggleLabel.Size = UDim2.new(1, -50, 1, 0)
            toggleLabel.Position = UDim2.new(0, 10, 0, 0)
            toggleLabel.Text = text
            toggleLabel.TextColor3 = Colors.CurrentTheme.Text
            toggleLabel.BackgroundTransparency = 1
            toggleLabel.Font = Enum.Font.Gotham
            toggleLabel.TextSize = 13
            toggleLabel.TextXAlignment = Enum.TextXAlignment.Left
            toggleLabel.Parent = toggleFrame
            
            local toggleButton = Instance.new("Frame")
            toggleButton.Size = UDim2.new(0, 36, 0, 18)
            toggleButton.Position = UDim2.new(1, -46, 0.5, -9)
            toggleButton.BackgroundColor3 = element.Value and Colors.CurrentTheme.Accent or Colors.CurrentTheme.Secondary
            toggleButton.BorderSizePixel = 0
            toggleButton.Parent = toggleFrame
            
            local toggleButtonCorner = Instance.new("UICorner")
            toggleButtonCorner.CornerRadius = UDim.new(1, 0)
            toggleButtonCorner.Parent = toggleButton
            
            local toggleDot = Instance.new("Frame")
            toggleDot.Size = UDim2.new(0, 14, 0, 14)
            toggleDot.Position = element.Value and UDim2.new(0, 18, 0, 2) or UDim2.new(0, 2, 0, 2)
            toggleDot.BackgroundColor3 = Colors.CurrentTheme.Text
            toggleDot.BorderSizePixel = 0
            toggleDot.Parent = toggleButton
            
            local toggleDotCorner = Instance.new("UICorner")
            toggleDotCorner.CornerRadius = UDim.new(1, 0)
            toggleDotCorner.Parent = toggleDot
            
            local function updateToggle()
                local targetPos = element.Value and UDim2.new(0, 18, 0, 2) or UDim2.new(0, 2, 0, 2)
                local targetColor = element.Value and Colors.CurrentTheme.Accent or Colors.CurrentTheme.Secondary
                
                toggleDot:TweenPosition(targetPos, Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.2, true)
                toggleButton:TweenSize(UDim2.new(0, 36, 0, 18), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.1, true)
                
                spawn(function()
                    toggleButton.BackgroundColor3 = targetColor
                end)
            end
            
            toggleFrame.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    element.Value = not element.Value
                    updateToggle()
                    if callback then
                        callback(element.Value)
                    end
                end
            end)
            
            element.SetValue = function(self, val)
                self.Value = val
                updateToggle()
            end
            
            element.GetValue = function(self)
                return self.Value
            end
            
            table.insert(Tab.Elements, element)
            Silence.Elements[element.Id] = element
            return element
        end
        
        function Tab:AddSlider(text, min, max, default, decimal, callback)
            local element = {
                Type = "Slider",
                Id = text .. "_" .. #Tab.Elements,
                Value = default or min,
                Min = min,
                Max = max,
                Decimal = decimal or 0
            }
            
            local sliderFrame = Instance.new("Frame")
            sliderFrame.Size = UDim2.new(1, -20, 0, 50)
            sliderFrame.Position = UDim2.new(0, 10, 0, 0)
            sliderFrame.BackgroundColor3 = Colors.CurrentTheme.Secondary
            sliderFrame.BackgroundTransparency = 0.5
            sliderFrame.BorderSizePixel = 0
            sliderFrame.Parent = tabListFrame
            
            local sliderCorner = Instance.new("UICorner")
            sliderCorner.CornerRadius = UDim.new(0, 6)
            sliderCorner.Parent = sliderFrame
            
            local sliderLabel = Instance.new("TextLabel")
            sliderLabel.Size = UDim2.new(1, -20, 0, 20)
            sliderLabel.Position = UDim2.new(0, 10, 0, 3)
            sliderLabel.Text = text .. ": " .. Utility.Round(element.Value, element.Decimal)
            sliderLabel.TextColor3 = Colors.CurrentTheme.Text
            sliderLabel.BackgroundTransparency = 1
            sliderLabel.Font = Enum.Font.Gotham
            sliderLabel.TextSize = 13
            sliderLabel.TextXAlignment = Enum.TextXAlignment.Left
            sliderLabel.Parent = sliderFrame
            
            local sliderBar = Instance.new("Frame")
            sliderBar.Size = UDim2.new(1, -20, 0, 6)
            sliderBar.Position = UDim2.new(0, 10, 0, 28)
            sliderBar.BackgroundColor3 = Colors.CurrentTheme.Secondary
            sliderBar.BorderSizePixel = 0
            sliderBar.Parent = sliderFrame
            
            local sliderBarCorner = Instance.new("UICorner")
            sliderBarCorner.CornerRadius = UDim.new(0, 3)
            sliderBarCorner.Parent = sliderBar
            
            local sliderFill = Instance.new("Frame")
            sliderFill.Size = UDim2.new((element.Value - min) / (max - min), 0, 1, 0)
            sliderFill.BackgroundColor3 = Colors.CurrentTheme.Accent
            sliderFill.BorderSizePixel = 0
            sliderFill.Parent = sliderBar
            
            local sliderFillCorner = Instance.new("UICorner")
            sliderFillCorner.CornerRadius = UDim.new(0, 3)
            sliderFillCorner.Parent = sliderFill
            
            local sliderDot = Instance.new("Frame")
            sliderDot.Size = UDim2.new(0, 14, 0, 14)
            sliderDot.Position = UDim2.new((element.Value - min) / (max - min), -7, 0.5, -7)
            sliderDot.BackgroundColor3 = Colors.CurrentTheme.Text
            sliderDot.BorderSizePixel = 0
            sliderDot.Parent = sliderBar
            
            local sliderDotCorner = Instance.new("UICorner")
            sliderDotCorner.CornerRadius = UDim.new(1, 0)
            sliderDotCorner.Parent = sliderDot
            
            local isDragging = false
            
            local function updateSlider(inputX)
                local barSize = sliderBar.AbsoluteSize.X
                local relativeX = math.clamp((inputX - sliderBar.AbsolutePosition.X) / barSize, 0, 1)
                local value = min + (max - min) * relativeX
                element.Value = Utility.Round(value, element.Decimal)
                sliderFill.Size = UDim2.new(relativeX, 0, 1, 0)
                sliderDot.Position = UDim2.new(relativeX, -7, 0.5, -7)
                sliderLabel.Text = text .. ": " .. Utility.Round(element.Value, element.Decimal)
                
                if callback then
                    callback(element.Value)
                end
            end
            
            sliderBar.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    isDragging = true
                    updateSlider(input.Position.X)
                end
            end)
            
            UserInputService.InputChanged:Connect(function(input)
                if isDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                    updateSlider(input.Position.X)
                end
            end)
            
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    isDragging = false
                end
            end)
            
            element.SetValue = function(self, val)
                self.Value = Utility.Round(math.clamp(val, self.Min, self.Max), self.Decimal)
                local relativeX = (self.Value - self.Min) / (self.Max - self.Min)
                sliderFill.Size = UDim2.new(relativeX, 0, 1, 0)
                sliderDot.Position = UDim2.new(relativeX, -7, 0.5, -7)
                sliderLabel.Text = text .. ": " .. Utility.Round(self.Value, self.Decimal)
            end
            
            element.GetValue = function(self)
                return self.Value
            end
            
            table.insert(Tab.Elements, element)
            Silence.Elements[element.Id] = element
            return element
        end
        
        function Tab:AddDropdown(text, options, default, callback)
            local element = {
                Type = "Dropdown",
                Id = text .. "_" .. #Tab.Elements,
                Value = default or (options[1] or ""),
                Options = options,
                Expanded = false
            }
            
            local dropdownFrame = Instance.new("Frame")
            dropdownFrame.Size = UDim2.new(1, -20, 0, 30)
            dropdownFrame.Position = UDim2.new(0, 10, 0, 0)
            dropdownFrame.BackgroundColor3 = Colors.CurrentTheme.Secondary
            dropdownFrame.BackgroundTransparency = 0.5
            dropdownFrame.BorderSizePixel = 0
            dropdownFrame.ClipsDescendants = true
            dropdownFrame.Parent = tabListFrame
            
            local dropdownCorner = Instance.new("UICorner")
            dropdownCorner.CornerRadius = UDim.new(0, 6)
            dropdownCorner.Parent = dropdownFrame
            
            local dropdownLabel = Instance.new("TextLabel")
            dropdownLabel.Size = UDim2.new(1, -30, 1, 0)
            dropdownLabel.Position = UDim2.new(0, 10, 0, 0)
            dropdownLabel.Text = text .. ": " .. element.Value
            dropdownLabel.TextColor3 = Colors.CurrentTheme.Text
            dropdownLabel.BackgroundTransparency = 1
            dropdownLabel.Font = Enum.Font.Gotham
            dropdownLabel.TextSize = 13
            dropdownLabel.TextXAlignment = Enum.TextXAlignment.Left
            dropdownLabel.Parent = dropdownFrame
            
            local dropdownArrow = Instance.new("TextLabel")
            dropdownArrow.Size = UDim2.new(0, 20, 1, 0)
            dropdownArrow.Position = UDim2.new(1, -25, 0, 0)
            dropdownArrow.Text = "▼"
            dropdownArrow.TextColor3 = Colors.CurrentTheme.Text
            dropdownArrow.BackgroundTransparency = 1
            dropdownArrow.Font = Enum.Font.Gotham
            dropdownArrow.TextSize = 12
            dropdownArrow.Parent = dropdownFrame
            
            local optionList = Instance.new("Frame")
            optionList.Size = UDim2.new(1, 0, 0, 0)
            optionList.Position = UDim2.new(0, 0, 1, 0)
            optionList.BackgroundColor3 = Colors.CurrentTheme.Secondary
            optionList.BackgroundTransparency = 0.3
            optionList.BorderSizePixel = 0
            optionList.Visible = false
            optionList.Parent = dropdownFrame
            
            local optionListLayout = Instance.new("UIListLayout")
            optionListLayout.SortOrder = Enum.SortOrder.LayoutOrder
            optionListLayout.Parent = optionList
            
            local optionButtons = {}
            
            local function buildOptions()
                for _, button in pairs(optionButtons) do
                    button:Destroy()
                end
                optionButtons = {}
                
                for i, option in ipairs(element.Options) do
                    local optionButton = Instance.new("TextButton")
                    optionButton.Size = UDim2.new(1, 0, 0, 25)
                    optionButton.BackgroundColor3 = option == element.Value and Colors.CurrentTheme.Accent or Colors.CurrentTheme.Secondary
                    optionButton.BackgroundTransparency = 0.3
                    optionButton.BorderSizePixel = 0
                    optionButton.Text = option
                    optionButton.TextColor3 = Colors.CurrentTheme.Text
                    optionButton.Font = Enum.Font.Gotham
                    optionButton.TextSize = 12
                    optionButton.Parent = optionList
                    
                    optionButton.MouseButton1Click:Connect(function()
                        element.Value = option
                        dropdownLabel.Text = text .. ": " .. option
                        element.Expanded = false
                        optionList.Visible = false
                        dropdownFrame:TweenSize(UDim2.new(1, -20, 0, 30), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.2, true)
                        
                        -- Update option colors
                        for _, btn in pairs(optionButtons) do
                            btn.BackgroundColor3 = btn.Text == option and Colors.CurrentTheme.Accent or Colors.CurrentTheme.Secondary
                        end
                        
                        if callback then
                            callback(option)
                        end
                    end)
                    
                    table.insert(optionButtons, optionButton)
                end
                
                optionList.Size = UDim2.new(1, 0, 0, #element.Options * 25)
            end
            
            buildOptions()
            
            dropdownFrame.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    element.Expanded = not element.Expanded
                    optionList.Visible = element.Expanded
                    
                    if element.Expanded then
                        dropdownFrame:TweenSize(UDim2.new(1, -20, 0, 30 + #element.Options * 25), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.2, true)
                    else
                        dropdownFrame:TweenSize(UDim2.new(1, -20, 0, 30), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.2, true)
                    end
                end
            end)
            
            element.SetValue = function(self, val)
                self.Value = val
                dropdownLabel.Text = text .. ": " .. val
                buildOptions()
            end
            
            element.GetValue = function(self)
                return self.Value
            end
            
            table.insert(Tab.Elements, element)
            Silence.Elements[element.Id] = element
            return element
        end
        
        function Tab:AddKeybind(text, defaultKey, callback)
            local element = {
                Type = "Keybind",
                Id = text .. "_" .. #Tab.Elements,
                Value = defaultKey or "None",
                IsBinding = false
            }
            
            local keybindFrame = Instance.new("Frame")
            keybindFrame.Size = UDim2.new(1, -20, 0, 30)
            keybindFrame.Position = UDim2.new(0, 10, 0, 0)
            keybindFrame.BackgroundColor3 = Colors.CurrentTheme.Secondary
            keybindFrame.BackgroundTransparency = 0.5
            keybindFrame.BorderSizePixel = 0
            keybindFrame.Parent = tabListFrame
            
            local keybindCorner = Instance.new("UICorner")
            keybindCorner.CornerRadius = UDim.new(0, 6)
            keybindCorner.Parent = keybindFrame
            
            local keybindLabel = Instance.new("TextLabel")
            keybindLabel.Size = UDim2.new(1, -100, 1, 0)
            keybindLabel.Position = UDim2.new(0, 10, 0, 0)
            keybindLabel.Text = text
            keybindLabel.TextColor3 = Colors.CurrentTheme.Text
            keybindLabel.BackgroundTransparency = 1
            keybindLabel.Font = Enum.Font.Gotham
            keybindLabel.TextSize = 13
            keybindLabel.TextXAlignment = Enum.TextXAlignment.Left
            keybindLabel.Parent = keybindFrame
            
            local keybindButton = Instance.new("TextButton")
            keybindButton.Size = UDim2.new(0, 80, 1, -6)
            keybindButton.Position = UDim2.new(1, -85, 0, 3)
            keybindButton.BackgroundColor3 = Colors.CurrentTheme.Primary
            keybindButton.BackgroundTransparency = 0.3
            keybindButton.BorderSizePixel = 0
            keybindButton.Text = "[" .. element.Value .. "]"
            keybindButton.TextColor3 = Colors.CurrentTheme.Text
            keybindButton.Font = Enum.Font.GothamBold
            keybindButton.TextSize = 11
            keybindButton.Parent = keybindFrame
            
            local keybindButtonCorner = Instance.new("UICorner")
            keybindButtonCorner.CornerRadius = UDim.new(0, 4)
            keybindButtonCorner.Parent = keybindButton
            
            keybindButton.MouseButton1Click:Connect(function()
                element.IsBinding = true
                keybindButton.Text = "[...]"
                
                local connection
                connection = UserInputService.InputBegan:Connect(function(input)
                    if element.IsBinding then
                        if input.UserInputType == Enum.UserInputType.Keyboard then
                            element.Value = input.KeyCode.Name
                        elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
                            element.Value = "MB1"
                        elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
                            element.Value = "MB2"
                        end
                        
                        keybindButton.Text = "[" .. element.Value .. "]"
                        element.IsBinding = false
                        connection:Disconnect()
                        
                        if callback then
                            callback(element.Value)
                        end
                    end
                end)
            end)
            
            element.SetValue = function(self, val)
                self.Value = val
                keybindButton.Text = "[" .. val .. "]"
            end
            
            element.GetValue = function(self)
                return self.Value
            end
            
            table.insert(Tab.Elements, element)
            Silence.Elements[element.Id] = element
            return element
        end
        
        function Tab:AddColorPicker(text, default, callback)
            local element = {
                Type = "ColorPicker",
                Id = text .. "_" .. #Tab.Elements,
                Value = default or Color3.fromRGB(255, 255, 255)
            }
            
            local colorFrame = Instance.new("Frame")
            colorFrame.Size = UDim2.new(1, -20, 0, 30)
            colorFrame.Position = UDim2.new(0, 10, 0, 0)
            colorFrame.BackgroundColor3 = Colors.CurrentTheme.Secondary
            colorFrame.BackgroundTransparency = 0.5
            colorFrame.BorderSizePixel = 0
            colorFrame.Parent = tabListFrame
            
            local colorCorner = Instance.new("UICorner")
            colorCorner.CornerRadius = UDim.new(0, 6)
            colorCorner.Parent = colorFrame
            
            local colorLabel = Instance.new("TextLabel")
            colorLabel.Size = UDim2.new(1, -50, 1, 0)
            colorLabel.Position = UDim2.new(0, 10, 0, 0)
            colorLabel.Text = text
            colorLabel.TextColor3 = Colors.CurrentTheme.Text
            colorLabel.BackgroundTransparency = 1
            colorLabel.Font = Enum.Font.Gotham
            colorLabel.TextSize = 13
            colorLabel.TextXAlignment = Enum.TextXAlignment.Left
            colorLabel.Parent = colorFrame
            
            local colorPreview = Instance.new("Frame")
            colorPreview.Size = UDim2.new(0, 30, 0, 20)
            colorPreview.Position = UDim2.new(1, -38, 0.5, -10)
            colorPreview.BackgroundColor3 = element.Value
            colorPreview.BorderSizePixel = 0
            colorPreview.Parent = colorFrame
            
            local colorPreviewCorner = Instance.new("UICorner")
            colorPreviewCorner.CornerRadius = UDim.new(0, 4)
            colorPreviewCorner.Parent = colorPreview
            
            colorFrame.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    -- Open color picker UI
                    local pickerFrame = Instance.new("Frame")
                    pickerFrame.Size = UDim2.new(0, 200, 0, 200)
                    pickerFrame.Position = UDim2.new(0.5, -100, 0.5, -100)
                    pickerFrame.BackgroundColor3 = Colors.CurrentTheme.Background
                    pickerFrame.BorderSizePixel = 0
                    pickerFrame.ZIndex = 10
                    pickerFrame.Parent = Silence.Parent
                    
                    local pickerCorner = Instance.new("UICorner")
                    pickerCorner.CornerRadius = UDim.new(0, 8)
                    pickerCorner.Parent = pickerFrame
                    
                    -- Simple gradient picker
                    local hueSlider = Instance.new("Frame")
                    hueSlider.Size = UDim2.new(1, -20, 0, 20)
                    hueSlider.Position = UDim2.new(0, 10, 0, 170)
                    hueSlider.BorderSizePixel = 0
                    hueSlider.Parent = pickerFrame
                    
                    local closeButton = Instance.new("TextButton")
                    closeButton.Size = UDim2.new(0, 60, 0, 20)
                    closeButton.Position = UDim2.new(0.5, -30, 1, -25)
                    closeButton.Text = "Close"
                    closeButton.TextColor3 = Colors.CurrentTheme.Text
                    closeButton.BackgroundColor3 = Colors.CurrentTheme.Primary
                    closeButton.BorderSizePixel = 0
                    closeButton.Font = Enum.Font.Gotham
                    closeButton.TextSize = 12
                    closeButton.Parent = pickerFrame
                    
                    closeButton.MouseButton1Click:Connect(function()
                        pickerFrame:Destroy()
                    end)
                    
                    -- Simple color selection (simplified for demo)
                    for r = 0, 255, 85 do
                        for g = 0, 255, 85 do
                            for b = 0, 255, 85 do
                                local colorBox = Instance.new("TextButton")
                                colorBox.Size = UDim2.new(0, 20, 0, 20)
                                colorBox.Position = UDim2.new(r/255 * 0.8 + 0.05, 0, g/255 * 0.5 + 0.1, 0)
                                colorBox.BackgroundColor3 = Color3.fromRGB(r, g, b)
                                colorBox.BorderSizePixel = 0
                                colorBox.Text = ""
                                colorBox.Parent = pickerFrame
                                
                                colorBox.MouseButton1Click:Connect(function()
                                    element.Value = Color3.fromRGB(r, g, b)
                                    colorPreview.BackgroundColor3 = element.Value
                                    pickerFrame:Destroy()
                                    if callback then
                                        callback(element.Value)
                                    end
                                end)
                            end
                        end
                    end
                end
            end)
            
            element.SetValue = function(self, val)
                self.Value = val
                colorPreview.BackgroundColor3 = val
            end
            
            element.GetValue = function(self)
                return self.Value
            end
            
            table.insert(Tab.Elements, element)
            Silence.Elements[element.Id] = element
            return element
        end
        
        -- Add more element types here (Labels, Separators, etc.)
        
        Window.Tabs[tabName] = Tab
        TabList.CanvasSize = UDim2.new(0, 0, 0, #Window.Tabs * 32)
        
        -- Auto-select first tab
        if #Window.Tabs == 1 then
            tabButton.BackgroundTransparency = 0.2
            tabButton.TextColor3 = Colors.CurrentTheme.Text
            tabListFrame.Visible = true
        end
        
        return Tab
    end
    
    -- Theme application
    function Window:ApplyTheme(theme)
        Colors.CurrentTheme = theme
        Colors.AccentColor = theme.Accent
        
        -- Update all UI elements recursively
        local function updateColors(object)
            if object:IsA("TextLabel") or object:IsA("TextButton") then
                -- Skip if it's a special element
            end
            
            for _, child in ipairs(object:GetChildren()) do
                updateColors(child)
            end
        end
        
        MainFrame.BackgroundColor3 = theme.Background
        TitleBar.BackgroundColor3 = theme.Surface
        TabContainer.BackgroundColor3 = theme.Surface
        ContentFrame.BackgroundColor3 = theme.Background
        
        Silence:UpdateTransparency()
    end
    
    function Window:UpdateTransparency()
        MainFrame.BackgroundTransparency = Colors.Transparency
    end
    
    -- Save reference to main objects
    Window.MainFrame = MainFrame
    Window.ScreenGui = ScreenGui
    
    -- Return the window object
    Silence.Windows = Silence.Windows or {}
    table.insert(Silence.Windows, Window)
    
    return Window
end

-- Manage the theme system
function Silence:ApplyTheme(theme)
    Colors.CurrentTheme = theme
    for _, window in pairs(self.Windows or {}) do
        if window.ApplyTheme then
            window:ApplyTheme(theme)
        end
    end
end

function Silence:UpdateTransparency()
    for _, window in pairs(self.Windows or {}) do
        if window.UpdateTransparency then
            window:UpdateTransparency()
        end
    end
end

-- Create the floating button system
function Silence:CreateFloatingButton(callback)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0, 50, 0, 50)
    button.Position = UDim2.new(0.01, 0, 0.5, 0)
    button.BackgroundColor3 = Colors.CurrentTheme.Primary
    button.BackgroundTransparency = 0.3
    button.BorderSizePixel = 0
    button.Text = "S"
    button.TextColor3 = Colors.CurrentTheme.Text
    button.Font = Enum.Font.GothamBold
    button.TextSize = 20
    button.ZIndex = 5
    button.Parent = game:GetService("CoreGui")
    
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(1, 0)
    buttonCorner.Parent = button
    
    -- Draggable
    local dragStart, startPos
    button.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragStart = input.Position
            startPos = button.Position
        end
    end)
    
    button.InputChanged:Connect(function(input)
        if dragStart and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            button.Position = UDim2.new(
                math.clamp(startPos.X.Scale + delta.X / game.Workspace.CurrentCamera.ViewportSize.X, 0, 0.95),
                0,
                math.clamp(startPos.Y.Scale + delta.Y / game.Workspace.CurrentCamera.ViewportSize.Y, 0, 0.95),
                0
            )
        end
    end)
    
    button.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 and not dragStart then
            -- Click (not drag) - toggle UI
            if callback then callback() end
        end
        dragStart = nil
    end)
    
    Silence.FloatingButton = button
    return button
end

-- Initialize managers
Silence.SaveManager = SaveManager
Silence.Notifications = Notifications
Silence.Dialog = Dialog
Silence.Colors = Colors
Silence.Elements = {}

-- Theme management functions
function Silence:GetThemes()
    local themeList = {}
    for name, _ in pairs(Colors.Themes) do
        table.insert(themeList, name)
    end
    table.sort(themeList)
    return themeList
end

function Silence:SetTheme(themeName)
    local theme = Colors.Themes[themeName]
    if theme then
        self:ApplyTheme(theme)
        return true
    end
    return false
end

function Silence:GetCurrentTheme()
    return Colors.CurrentTheme
end

-- Export the library
return Silence
