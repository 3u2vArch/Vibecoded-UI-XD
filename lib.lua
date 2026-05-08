-- UILibrary.lua
-- A modern, full-featured Roblox UI Library
-- Compatible with LocalScript and executor environments

local Library = {}
Library.__index = Library

-------------------------------------------------
-- SERVICES
-------------------------------------------------
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-------------------------------------------------
-- UTILITY
-------------------------------------------------
local function Tween(obj, props, duration, style, direction)
    style = style or Enum.EasingStyle.Quart
    direction = direction or Enum.EasingDirection.Out
    local info = TweenInfo.new(duration or 0.25, style, direction)
    local t = TweenService:Create(obj, info, props)
    t:Play()
    return t
end

local function Create(class, props, children)
    local obj = Instance.new(class)
    for k, v in pairs(props or {}) do
        if k ~= "Parent" then
            obj[k] = v
        end
    end
    for _, child in ipairs(children or {}) do
        child.Parent = obj
    end
    if props and props.Parent then
        obj.Parent = props.Parent
    end
    return obj
end

local function MakeDraggable(frame, handle)
    handle = handle or frame
    local dragging, dragInput, dragStart, startPos
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or
           input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    handle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or
           input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            local newPos = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
            frame.Position = newPos
        end
    end)
end

-------------------------------------------------
-- THEMES (30+)
-------------------------------------------------
Library.Themes = {
    Dark = {
        Background       = Color3.fromRGB(18, 18, 24),
        SecondaryBg      = Color3.fromRGB(26, 26, 34),
        TertiaryBg       = Color3.fromRGB(34, 34, 44),
        Accent           = Color3.fromRGB(99, 102, 241),
        AccentDark       = Color3.fromRGB(67, 70, 189),
        Text             = Color3.fromRGB(240, 240, 255),
        SubText          = Color3.fromRGB(160, 160, 185),
        Border           = Color3.fromRGB(50, 50, 65),
        Success          = Color3.fromRGB(52, 211, 153),
        Warning          = Color3.fromRGB(251, 191, 36),
        Error            = Color3.fromRGB(239, 68, 68),
        WindowBg         = Color3.fromRGB(15, 15, 20),
    },
    Light = {
        Background       = Color3.fromRGB(245, 245, 250),
        SecondaryBg      = Color3.fromRGB(235, 235, 242),
        TertiaryBg       = Color3.fromRGB(220, 220, 230),
        Accent           = Color3.fromRGB(99, 102, 241),
        AccentDark       = Color3.fromRGB(67, 70, 189),
        Text             = Color3.fromRGB(20, 20, 30),
        SubText          = Color3.fromRGB(90, 90, 110),
        Border           = Color3.fromRGB(200, 200, 215),
        Success          = Color3.fromRGB(16, 185, 129),
        Warning          = Color3.fromRGB(245, 158, 11),
        Error            = Color3.fromRGB(220, 38, 38),
        WindowBg         = Color3.fromRGB(250, 250, 255),
    },
    Midnight = {
        Background       = Color3.fromRGB(10, 10, 20),
        SecondaryBg      = Color3.fromRGB(15, 15, 30),
        TertiaryBg       = Color3.fromRGB(20, 20, 40),
        Accent           = Color3.fromRGB(139, 92, 246),
        AccentDark       = Color3.fromRGB(109, 62, 216),
        Text             = Color3.fromRGB(230, 225, 255),
        SubText          = Color3.fromRGB(140, 130, 180),
        Border           = Color3.fromRGB(40, 35, 70),
        Success          = Color3.fromRGB(52, 211, 153),
        Warning          = Color3.fromRGB(251, 191, 36),
        Error            = Color3.fromRGB(239, 68, 68),
        WindowBg         = Color3.fromRGB(8, 8, 18),
    },
    Ocean = {
        Background       = Color3.fromRGB(8, 25, 45),
        SecondaryBg      = Color3.fromRGB(12, 35, 60),
        TertiaryBg       = Color3.fromRGB(16, 45, 75),
        Accent           = Color3.fromRGB(56, 189, 248),
        AccentDark       = Color3.fromRGB(14, 165, 233),
        Text             = Color3.fromRGB(224, 242, 254),
        SubText          = Color3.fromRGB(125, 185, 220),
        Border           = Color3.fromRGB(30, 65, 100),
        Success          = Color3.fromRGB(52, 211, 153),
        Warning          = Color3.fromRGB(251, 191, 36),
        Error            = Color3.fromRGB(239, 68, 68),
        WindowBg         = Color3.fromRGB(5, 18, 35),
    },
    Forest = {
        Background       = Color3.fromRGB(12, 28, 18),
        SecondaryBg      = Color3.fromRGB(18, 38, 24),
        TertiaryBg       = Color3.fromRGB(24, 50, 32),
        Accent           = Color3.fromRGB(74, 222, 128),
        AccentDark       = Color3.fromRGB(34, 197, 94),
        Text             = Color3.fromRGB(220, 252, 231),
        SubText          = Color3.fromRGB(134, 190, 150),
        Border           = Color3.fromRGB(40, 80, 52),
        Success          = Color3.fromRGB(74, 222, 128),
        Warning          = Color3.fromRGB(251, 191, 36),
        Error            = Color3.fromRGB(239, 68, 68),
        WindowBg         = Color3.fromRGB(8, 20, 14),
    },
    Sunset = {
        Background       = Color3.fromRGB(30, 15, 20),
        SecondaryBg      = Color3.fromRGB(45, 20, 28),
        TertiaryBg       = Color3.fromRGB(60, 25, 35),
        Accent           = Color3.fromRGB(251, 113, 94),
        AccentDark       = Color3.fromRGB(239, 68, 68),
        Text             = Color3.fromRGB(255, 237, 235),
        SubText          = Color3.fromRGB(210, 155, 145),
        Border           = Color3.fromRGB(90, 40, 50),
        Success          = Color3.fromRGB(52, 211, 153),
        Warning          = Color3.fromRGB(251, 191, 36),
        Error            = Color3.fromRGB(239, 68, 68),
        WindowBg         = Color3.fromRGB(22, 10, 14),
    },
    Cyberpunk = {
        Background       = Color3.fromRGB(8, 8, 18),
        SecondaryBg      = Color3.fromRGB(12, 12, 28),
        TertiaryBg       = Color3.fromRGB(16, 16, 38),
        Accent           = Color3.fromRGB(234, 255, 0),
        AccentDark       = Color3.fromRGB(190, 210, 0),
        Text             = Color3.fromRGB(240, 255, 200),
        SubText          = Color3.fromRGB(160, 180, 100),
        Border           = Color3.fromRGB(60, 60, 20),
        Success          = Color3.fromRGB(0, 255, 170),
        Warning          = Color3.fromRGB(255, 160, 0),
        Error            = Color3.fromRGB(255, 50, 100),
        WindowBg         = Color3.fromRGB(5, 5, 14),
    },
    Neon = {
        Background       = Color3.fromRGB(5, 5, 10),
        SecondaryBg      = Color3.fromRGB(10, 8, 18),
        TertiaryBg       = Color3.fromRGB(15, 10, 26),
        Accent           = Color3.fromRGB(255, 0, 200),
        AccentDark       = Color3.fromRGB(200, 0, 160),
        Text             = Color3.fromRGB(255, 220, 255),
        SubText          = Color3.fromRGB(180, 140, 200),
        Border           = Color3.fromRGB(60, 20, 70),
        Success          = Color3.fromRGB(0, 255, 170),
        Warning          = Color3.fromRGB(255, 210, 0),
        Error            = Color3.fromRGB(255, 50, 80),
        WindowBg         = Color3.fromRGB(3, 3, 8),
    },
    Matrix = {
        Background       = Color3.fromRGB(0, 10, 0),
        SecondaryBg      = Color3.fromRGB(0, 16, 0),
        TertiaryBg       = Color3.fromRGB(0, 22, 0),
        Accent           = Color3.fromRGB(0, 255, 70),
        AccentDark       = Color3.fromRGB(0, 190, 50),
        Text             = Color3.fromRGB(180, 255, 180),
        SubText          = Color3.fromRGB(80, 180, 80),
        Border           = Color3.fromRGB(0, 60, 0),
        Success          = Color3.fromRGB(0, 255, 70),
        Warning          = Color3.fromRGB(200, 255, 0),
        Error            = Color3.fromRGB(255, 50, 50),
        WindowBg         = Color3.fromRGB(0, 6, 0),
    },
    Galaxy = {
        Background       = Color3.fromRGB(12, 8, 22),
        SecondaryBg      = Color3.fromRGB(18, 12, 35),
        TertiaryBg       = Color3.fromRGB(24, 16, 48),
        Accent           = Color3.fromRGB(180, 120, 255),
        AccentDark       = Color3.fromRGB(140, 80, 220),
        Text             = Color3.fromRGB(235, 225, 255),
        SubText          = Color3.fromRGB(160, 140, 210),
        Border           = Color3.fromRGB(55, 35, 90),
        Success          = Color3.fromRGB(100, 255, 200),
        Warning          = Color3.fromRGB(255, 210, 100),
        Error            = Color3.fromRGB(255, 80, 100),
        WindowBg         = Color3.fromRGB(8, 5, 16),
    },
    Pastel = {
        Background       = Color3.fromRGB(255, 248, 252),
        SecondaryBg      = Color3.fromRGB(248, 235, 248),
        TertiaryBg       = Color3.fromRGB(240, 222, 245),
        Accent           = Color3.fromRGB(218, 165, 230),
        AccentDark       = Color3.fromRGB(190, 130, 210),
        Text             = Color3.fromRGB(80, 50, 90),
        SubText          = Color3.fromRGB(160, 120, 170),
        Border           = Color3.fromRGB(220, 190, 230),
        Success          = Color3.fromRGB(160, 230, 180),
        Warning          = Color3.fromRGB(255, 220, 150),
        Error            = Color3.fromRGB(255, 160, 170),
        WindowBg         = Color3.fromRGB(255, 252, 255),
    },
    Halloween = {
        Background       = Color3.fromRGB(15, 8, 2),
        SecondaryBg      = Color3.fromRGB(25, 12, 3),
        TertiaryBg       = Color3.fromRGB(35, 16, 4),
        Accent           = Color3.fromRGB(255, 120, 0),
        AccentDark       = Color3.fromRGB(200, 80, 0),
        Text             = Color3.fromRGB(255, 230, 200),
        SubText          = Color3.fromRGB(180, 140, 100),
        Border           = Color3.fromRGB(80, 35, 5),
        Success          = Color3.fromRGB(100, 200, 80),
        Warning          = Color3.fromRGB(255, 200, 0),
        Error            = Color3.fromRGB(200, 30, 30),
        WindowBg         = Color3.fromRGB(10, 5, 1),
    },
    Christmas = {
        Background       = Color3.fromRGB(8, 22, 8),
        SecondaryBg      = Color3.fromRGB(12, 32, 12),
        TertiaryBg       = Color3.fromRGB(16, 42, 16),
        Accent           = Color3.fromRGB(220, 40, 40),
        AccentDark       = Color3.fromRGB(180, 20, 20),
        Text             = Color3.fromRGB(240, 255, 240),
        SubText          = Color3.fromRGB(160, 210, 160),
        Border           = Color3.fromRGB(40, 80, 40),
        Success          = Color3.fromRGB(100, 220, 100),
        Warning          = Color3.fromRGB(255, 215, 0),
        Error            = Color3.fromRGB(220, 40, 40),
        WindowBg         = Color3.fromRGB(5, 16, 5),
    },
    Lava = {
        Background       = Color3.fromRGB(20, 5, 2),
        SecondaryBg      = Color3.fromRGB(32, 8, 3),
        TertiaryBg       = Color3.fromRGB(44, 12, 4),
        Accent           = Color3.fromRGB(255, 80, 20),
        AccentDark       = Color3.fromRGB(200, 50, 10),
        Text             = Color3.fromRGB(255, 230, 220),
        SubText          = Color3.fromRGB(210, 140, 120),
        Border           = Color3.fromRGB(90, 25, 10),
        Success          = Color3.fromRGB(80, 220, 120),
        Warning          = Color3.fromRGB(255, 180, 0),
        Error            = Color3.fromRGB(255, 50, 30),
        WindowBg         = Color3.fromRGB(14, 3, 1),
    },
    Ice = {
        Background       = Color3.fromRGB(225, 240, 255),
        SecondaryBg      = Color3.fromRGB(210, 230, 250),
        TertiaryBg       = Color3.fromRGB(195, 218, 245),
        Accent           = Color3.fromRGB(100, 180, 240),
        AccentDark       = Color3.fromRGB(60, 150, 220),
        Text             = Color3.fromRGB(20, 50, 90),
        SubText          = Color3.fromRGB(80, 130, 180),
        Border           = Color3.fromRGB(170, 210, 240),
        Success          = Color3.fromRGB(60, 200, 160),
        Warning          = Color3.fromRGB(240, 180, 60),
        Error            = Color3.fromRGB(220, 60, 60),
        WindowBg         = Color3.fromRGB(235, 248, 255),
    },
    RoyalPurple = {
        Background       = Color3.fromRGB(18, 8, 28),
        SecondaryBg      = Color3.fromRGB(28, 12, 44),
        TertiaryBg       = Color3.fromRGB(38, 16, 60),
        Accent           = Color3.fromRGB(160, 60, 220),
        AccentDark       = Color3.fromRGB(120, 30, 180),
        Text             = Color3.fromRGB(240, 220, 255),
        SubText          = Color3.fromRGB(170, 130, 210),
        Border           = Color3.fromRGB(70, 30, 110),
        Success          = Color3.fromRGB(100, 220, 160),
        Warning          = Color3.fromRGB(255, 200, 80),
        Error            = Color3.fromRGB(240, 60, 80),
        WindowBg         = Color3.fromRGB(12, 5, 20),
    },
    Emerald = {
        Background       = Color3.fromRGB(5, 20, 15),
        SecondaryBg      = Color3.fromRGB(8, 32, 24),
        TertiaryBg       = Color3.fromRGB(10, 44, 32),
        Accent           = Color3.fromRGB(52, 211, 153),
        AccentDark       = Color3.fromRGB(16, 185, 129),
        Text             = Color3.fromRGB(210, 255, 240),
        SubText          = Color3.fromRGB(120, 210, 175),
        Border           = Color3.fromRGB(20, 80, 60),
        Success          = Color3.fromRGB(52, 211, 153),
        Warning          = Color3.fromRGB(251, 191, 36),
        Error            = Color3.fromRGB(239, 68, 68),
        WindowBg         = Color3.fromRGB(3, 14, 10),
    },
    Ruby = {
        Background       = Color3.fromRGB(22, 5, 8),
        SecondaryBg      = Color3.fromRGB(35, 8, 12),
        TertiaryBg       = Color3.fromRGB(48, 10, 16),
        Accent           = Color3.fromRGB(220, 50, 80),
        AccentDark       = Color3.fromRGB(180, 20, 50),
        Text             = Color3.fromRGB(255, 230, 235),
        SubText          = Color3.fromRGB(210, 140, 155),
        Border           = Color3.fromRGB(90, 20, 35),
        Success          = Color3.fromRGB(80, 220, 130),
        Warning          = Color3.fromRGB(255, 190, 60),
        Error            = Color3.fromRGB(220, 50, 80),
        WindowBg         = Color3.fromRGB(15, 3, 6),
    },
    Sapphire = {
        Background       = Color3.fromRGB(5, 10, 28),
        SecondaryBg      = Color3.fromRGB(8, 16, 44),
        TertiaryBg       = Color3.fromRGB(10, 22, 60),
        Accent           = Color3.fromRGB(60, 130, 240),
        AccentDark       = Color3.fromRGB(30, 100, 210),
        Text             = Color3.fromRGB(215, 230, 255),
        SubText          = Color3.fromRGB(120, 160, 225),
        Border           = Color3.fromRGB(20, 45, 100),
        Success          = Color3.fromRGB(80, 220, 160),
        Warning          = Color3.fromRGB(255, 200, 60),
        Error            = Color3.fromRGB(240, 60, 80),
        WindowBg         = Color3.fromRGB(3, 7, 20),
    },
    Amber = {
        Background       = Color3.fromRGB(22, 14, 2),
        SecondaryBg      = Color3.fromRGB(35, 22, 4),
        TertiaryBg       = Color3.fromRGB(48, 30, 6),
        Accent           = Color3.fromRGB(245, 158, 11),
        AccentDark       = Color3.fromRGB(217, 119, 6),
        Text             = Color3.fromRGB(255, 245, 220),
        SubText          = Color3.fromRGB(210, 170, 100),
        Border           = Color3.fromRGB(100, 60, 10),
        Success          = Color3.fromRGB(80, 210, 130),
        Warning          = Color3.fromRGB(245, 158, 11),
        Error            = Color3.fromRGB(239, 68, 68),
        WindowBg         = Color3.fromRGB(15, 9, 1),
    },
    RoseGold = {
        Background       = Color3.fromRGB(28, 16, 18),
        SecondaryBg      = Color3.fromRGB(44, 24, 28),
        TertiaryBg       = Color3.fromRGB(60, 32, 38),
        Accent           = Color3.fromRGB(225, 150, 150),
        AccentDark       = Color3.fromRGB(195, 110, 110),
        Text             = Color3.fromRGB(255, 235, 235),
        SubText          = Color3.fromRGB(210, 165, 165),
        Border           = Color3.fromRGB(110, 60, 65),
        Success          = Color3.fromRGB(100, 210, 150),
        Warning          = Color3.fromRGB(255, 200, 100),
        Error            = Color3.fromRGB(240, 80, 90),
        WindowBg         = Color3.fromRGB(20, 10, 12),
    },
    Mint = {
        Background       = Color3.fromRGB(240, 255, 250),
        SecondaryBg      = Color3.fromRGB(220, 248, 240),
        TertiaryBg       = Color3.fromRGB(200, 240, 230),
        Accent           = Color3.fromRGB(60, 200, 170),
        AccentDark       = Color3.fromRGB(30, 170, 140),
        Text             = Color3.fromRGB(20, 70, 60),
        SubText          = Color3.fromRGB(80, 160, 140),
        Border           = Color3.fromRGB(160, 220, 210),
        Success          = Color3.fromRGB(60, 200, 130),
        Warning          = Color3.fromRGB(245, 190, 50),
        Error            = Color3.fromRGB(220, 60, 60),
        WindowBg         = Color3.fromRGB(248, 255, 252),
    },
    Lavender = {
        Background       = Color3.fromRGB(248, 245, 255),
        SecondaryBg      = Color3.fromRGB(238, 232, 252),
        TertiaryBg       = Color3.fromRGB(226, 218, 248),
        Accent           = Color3.fromRGB(155, 135, 220),
        AccentDark       = Color3.fromRGB(120, 100, 190),
        Text             = Color3.fromRGB(55, 40, 90),
        SubText          = Color3.fromRGB(130, 110, 175),
        Border           = Color3.fromRGB(200, 185, 235),
        Success          = Color3.fromRGB(100, 210, 155),
        Warning          = Color3.fromRGB(245, 185, 60),
        Error            = Color3.fromRGB(220, 65, 80),
        WindowBg         = Color3.fromRGB(252, 250, 255),
    },
    Coffee = {
        Background       = Color3.fromRGB(22, 14, 8),
        SecondaryBg      = Color3.fromRGB(36, 22, 12),
        TertiaryBg       = Color3.fromRGB(50, 32, 18),
        Accent           = Color3.fromRGB(180, 120, 70),
        AccentDark       = Color3.fromRGB(140, 90, 50),
        Text             = Color3.fromRGB(250, 235, 220),
        SubText          = Color3.fromRGB(195, 160, 130),
        Border           = Color3.fromRGB(85, 55, 30),
        Success          = Color3.fromRGB(90, 200, 120),
        Warning          = Color3.fromRGB(255, 190, 60),
        Error            = Color3.fromRGB(230, 60, 60),
        WindowBg         = Color3.fromRGB(14, 9, 5),
    },
    Charcoal = {
        Background       = Color3.fromRGB(28, 28, 30),
        SecondaryBg      = Color3.fromRGB(38, 38, 40),
        TertiaryBg       = Color3.fromRGB(50, 50, 52),
        Accent           = Color3.fromRGB(160, 160, 170),
        AccentDark       = Color3.fromRGB(120, 120, 130),
        Text             = Color3.fromRGB(240, 240, 245),
        SubText          = Color3.fromRGB(165, 165, 175),
        Border           = Color3.fromRGB(65, 65, 70),
        Success          = Color3.fromRGB(100, 215, 150),
        Warning          = Color3.fromRGB(245, 185, 55),
        Error            = Color3.fromRGB(230, 65, 65),
        WindowBg         = Color3.fromRGB(20, 20, 22),
    },
    Valentine = {
        Background       = Color3.fromRGB(28, 8, 16),
        SecondaryBg      = Color3.fromRGB(45, 12, 25),
        TertiaryBg       = Color3.fromRGB(62, 16, 34),
        Accent           = Color3.fromRGB(255, 100, 150),
        AccentDark       = Color3.fromRGB(220, 60, 110),
        Text             = Color3.fromRGB(255, 230, 240),
        SubText          = Color3.fromRGB(215, 155, 180),
        Border           = Color3.fromRGB(110, 35, 65),
        Success          = Color3.fromRGB(100, 210, 150),
        Warning          = Color3.fromRGB(255, 200, 100),
        Error            = Color3.fromRGB(240, 60, 80),
        WindowBg         = Color3.fromRGB(20, 5, 12),
    },
    Monochrome = {
        Background       = Color3.fromRGB(10, 10, 10),
        SecondaryBg      = Color3.fromRGB(20, 20, 20),
        TertiaryBg       = Color3.fromRGB(30, 30, 30),
        Accent           = Color3.fromRGB(200, 200, 200),
        AccentDark       = Color3.fromRGB(150, 150, 150),
        Text             = Color3.fromRGB(245, 245, 245),
        SubText          = Color3.fromRGB(150, 150, 150),
        Border           = Color3.fromRGB(55, 55, 55),
        Success          = Color3.fromRGB(180, 230, 180),
        Warning          = Color3.fromRGB(230, 200, 130),
        Error            = Color3.fromRGB(230, 130, 130),
        WindowBg         = Color3.fromRGB(6, 6, 6),
    },
    RetroTerminal = {
        Background       = Color3.fromRGB(0, 12, 0),
        SecondaryBg      = Color3.fromRGB(0, 20, 0),
        TertiaryBg       = Color3.fromRGB(0, 28, 0),
        Accent           = Color3.fromRGB(0, 200, 80),
        AccentDark       = Color3.fromRGB(0, 150, 60),
        Text             = Color3.fromRGB(80, 230, 80),
        SubText          = Color3.fromRGB(40, 150, 40),
        Border           = Color3.fromRGB(0, 55, 10),
        Success          = Color3.fromRGB(0, 255, 100),
        Warning          = Color3.fromRGB(180, 220, 0),
        Error            = Color3.fromRGB(200, 30, 30),
        WindowBg         = Color3.fromRGB(0, 8, 0),
    },
    AquaGlass = {
        Background       = Color3.fromRGB(10, 30, 45),
        SecondaryBg      = Color3.fromRGB(15, 42, 62),
        TertiaryBg       = Color3.fromRGB(20, 54, 80),
        Accent           = Color3.fromRGB(80, 220, 210),
        AccentDark       = Color3.fromRGB(40, 180, 170),
        Text             = Color3.fromRGB(210, 250, 250),
        SubText          = Color3.fromRGB(120, 195, 200),
        Border           = Color3.fromRGB(30, 80, 100),
        Success          = Color3.fromRGB(80, 220, 160),
        Warning          = Color3.fromRGB(255, 200, 80),
        Error            = Color3.fromRGB(240, 70, 80),
        WindowBg         = Color3.fromRGB(7, 22, 34),
    },
    Sand = {
        Background       = Color3.fromRGB(38, 32, 22),
        SecondaryBg      = Color3.fromRGB(56, 48, 32),
        TertiaryBg       = Color3.fromRGB(74, 62, 42),
        Accent           = Color3.fromRGB(210, 180, 120),
        AccentDark       = Color3.fromRGB(180, 150, 90),
        Text             = Color3.fromRGB(250, 240, 215),
        SubText          = Color3.fromRGB(190, 170, 130),
        Border           = Color3.fromRGB(100, 84, 56),
        Success          = Color3.fromRGB(110, 200, 130),
        Warning          = Color3.fromRGB(230, 185, 60),
        Error            = Color3.fromRGB(220, 70, 60),
        WindowBg         = Color3.fromRGB(28, 22, 14),
    },
    Vibrant = {
        Background       = Color3.fromRGB(12, 8, 20),
        SecondaryBg      = Color3.fromRGB(18, 12, 32),
        TertiaryBg       = Color3.fromRGB(25, 16, 44),
        Accent           = Color3.fromRGB(255, 60, 200),
        AccentDark       = Color3.fromRGB(210, 30, 160),
        Text             = Color3.fromRGB(255, 230, 255),
        SubText          = Color3.fromRGB(190, 145, 210),
        Border           = Color3.fromRGB(70, 30, 85),
        Success          = Color3.fromRGB(60, 255, 180),
        Warning          = Color3.fromRGB(255, 220, 0),
        Error            = Color3.fromRGB(255, 60, 60),
        WindowBg         = Color3.fromRGB(8, 5, 15),
    },
    Sepia = {
        Background       = Color3.fromRGB(30, 22, 12),
        SecondaryBg      = Color3.fromRGB(45, 34, 18),
        TertiaryBg       = Color3.fromRGB(60, 46, 24),
        Accent           = Color3.fromRGB(190, 155, 100),
        AccentDark       = Color3.fromRGB(155, 120, 70),
        Text             = Color3.fromRGB(250, 235, 205),
        SubText          = Color3.fromRGB(190, 165, 125),
        Border           = Color3.fromRGB(100, 75, 38),
        Success          = Color3.fromRGB(100, 190, 120),
        Warning          = Color3.fromRGB(230, 180, 70),
        Error            = Color3.fromRGB(210, 70, 60),
        WindowBg         = Color3.fromRGB(22, 16, 8),
    },
    FrostedMetal = {
        Background       = Color3.fromRGB(38, 42, 48),
        SecondaryBg      = Color3.fromRGB(50, 55, 63),
        TertiaryBg       = Color3.fromRGB(62, 68, 78),
        Accent           = Color3.fromRGB(160, 200, 220),
        AccentDark       = Color3.fromRGB(120, 165, 190),
        Text             = Color3.fromRGB(235, 242, 248),
        SubText          = Color3.fromRGB(160, 175, 190),
        Border           = Color3.fromRGB(80, 90, 105),
        Success          = Color3.fromRGB(100, 210, 155),
        Warning          = Color3.fromRGB(245, 190, 70),
        Error            = Color3.fromRGB(225, 75, 75),
        WindowBg         = Color3.fromRGB(28, 32, 38),
    },
}

-------------------------------------------------
-- LIBRARY STATE
-------------------------------------------------
Library.ActiveTheme = Library.Themes.Dark
Library.ActiveThemeName = "Dark"
Library.Windows = {}
Library.Connections = {}
Library.Config = {
    Transparency = 0.95,
    Font = Enum.Font.GothamMedium,
    ShowShine = false,
    SearchEnabled = true,
    SavePath = "UILibrary_Config",
}

-------------------------------------------------
-- SAVE MANAGER
-------------------------------------------------
Library.SaveManager = {}
Library.SaveManager._data = {}

function Library.SaveManager:Save(slot)
    slot = slot or "default"
    local serialized = HttpService:JSONEncode(self._data)
    -- In executor environments, use writefile if available
    local ok, err = pcall(function()
        if writefile then
            writefile("UILib_" .. slot .. ".json", serialized)
        end
    end)
    return ok
end

function Library.SaveManager:Load(slot)
    slot = slot or "default"
    local ok, data = pcall(function()
        if readfile then
            local raw = readfile("UILib_" .. slot .. ".json")
            return HttpService:JSONDecode(raw)
        end
    end)
    if ok and data then
        self._data = data
    end
    return self._data
end

function Library.SaveManager:Set(key, value)
    self._data[key] = value
end

function Library.SaveManager:Get(key)
    return self._data[key]
end

function Library.SaveManager:GetAll()
    return self._data
end

function Library.SaveManager:Reset()
    self._data = {}
end

-------------------------------------------------
-- NOTIFICATION SYSTEM
-------------------------------------------------
Library.NotificationHolder = nil

function Library:_ensureNotifHolder()
    if self.NotificationHolder then return end
    local pCore = LocalPlayer:FindFirstChild("PlayerGui")
        or game:GetService("CoreGui")
    local sg = Create("ScreenGui", {
        Name = "UILib_Notifications",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        Parent = pCore,
    })
    local holder = Create("Frame", {
        Name = "Holder",
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -320, 1, -20),
        Size = UDim2.new(0, 300, 0, 0),
        AnchorPoint = Vector2.new(0, 1),
        Parent = sg,
    })
    Create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        VerticalAlignment = Enum.VerticalAlignment.Bottom,
        Padding = UDim.new(0, 8),
        Parent = holder,
    })
    self.NotificationHolder = holder
end

function Library:Notify(opts)
    opts = opts or {}
    local title    = opts.Title or "Notification"
    local message  = opts.Message or ""
    local duration = opts.Duration or 3
    local theme    = self.ActiveTheme

    self:_ensureNotifHolder()

    local notif = Create("Frame", {
        Name = "Notification",
        BackgroundColor3 = theme.SecondaryBg,
        Size = UDim2.new(1, 0, 0, 70),
        BackgroundTransparency = 0.1,
        ClipsDescendants = true,
        Parent = self.NotificationHolder,
    })
    Create("UICorner", { CornerRadius = UDim.new(0, 10), Parent = notif })
    Create("UIStroke", { Color = theme.Border, Thickness = 1, Parent = notif })

    -- Accent bar
    Create("Frame", {
        BackgroundColor3 = theme.Accent,
        Size = UDim2.new(0, 3, 1, 0),
        BorderSizePixel = 0,
        Parent = notif,
    })

    Create("TextLabel", {
        Text = title,
        Font = self.Config.Font,
        TextSize = 14,
        TextColor3 = theme.Text,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 14, 0, 8),
        Size = UDim2.new(1, -20, 0, 20),
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = notif,
    })
    Create("TextLabel", {
        Text = message,
        Font = Enum.Font.Gotham,
        TextSize = 12,
        TextColor3 = theme.SubText,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 14, 0, 30),
        Size = UDim2.new(1, -20, 0, 32),
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true,
        Parent = notif,
    })

    -- Progress bar
    local progress = Create("Frame", {
        BackgroundColor3 = theme.Accent,
        Position = UDim2.new(0, 0, 1, -3),
        Size = UDim2.new(1, 0, 0, 3),
        BorderSizePixel = 0,
        Parent = notif,
    })

    notif.BackgroundTransparency = 1
    notif.Position = UDim2.new(1, 10, 0, 0)
    Tween(notif, { BackgroundTransparency = 0.1, Position = UDim2.new(0, 0, 0, 0) }, 0.3)
    Tween(progress, { Size = UDim2.new(0, 0, 0, 3) }, duration, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)

    task.delay(duration, function()
        Tween(notif, { BackgroundTransparency = 1, Position = UDim2.new(1, 10, 0, 0) }, 0.3)
        task.delay(0.35, function() notif:Destroy() end)
    end)

    notif.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
            Tween(notif, { BackgroundTransparency = 1 }, 0.2)
            task.delay(0.25, function() notif:Destroy() end)
        end
    end)
end

-------------------------------------------------
-- DIALOG SYSTEM
-------------------------------------------------
function Library:Dialog(opts)
    opts = opts or {}
    local title   = opts.Title or "Dialog"
    local message = opts.Message or ""
    local buttons = opts.Buttons or { { Text = "OK", Callback = nil } }
    local theme   = self.ActiveTheme

    local pCore = LocalPlayer:FindFirstChild("PlayerGui") or game:GetService("CoreGui")
    local sg = Create("ScreenGui", {
        Name = "UILib_Dialog",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        Parent = pCore,
    })

    -- Backdrop
    local backdrop = Create("Frame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = Color3.fromRGB(0, 0, 0),
        BackgroundTransparency = 0.4,
        BorderSizePixel = 0,
        Parent = sg,
    })

    local box = Create("Frame", {
        Size = UDim2.new(0, 340, 0, 160 + #buttons * 44),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = theme.SecondaryBg,
        BorderSizePixel = 0,
        Parent = sg,
    })
    Create("UICorner", { CornerRadius = UDim.new(0, 12), Parent = box })
    Create("UIStroke", { Color = theme.Border, Thickness = 1, Parent = box })

    Create("TextLabel", {
        Text = title,
        Font = self.Config.Font,
        TextSize = 16,
        TextColor3 = theme.Text,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 20, 0, 18),
        Size = UDim2.new(1, -40, 0, 24),
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = box,
    })
    Create("TextLabel", {
        Text = message,
        Font = Enum.Font.Gotham,
        TextSize = 13,
        TextColor3 = theme.SubText,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 20, 0, 52),
        Size = UDim2.new(1, -40, 0, 80),
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true,
        Parent = box,
    })

    -- Divider
    Create("Frame", {
        BackgroundColor3 = theme.Border,
        Position = UDim2.new(0, 0, 0, 138),
        Size = UDim2.new(1, 0, 0, 1),
        BorderSizePixel = 0,
        Parent = box,
    })

    local btnW = 1 / #buttons
    for i, btnOpts in ipairs(buttons) do
        local btn = Create("TextButton", {
            Text = btnOpts.Text or "OK",
            Font = self.Config.Font,
            TextSize = 14,
            TextColor3 = (i == #buttons) and theme.Accent or theme.SubText,
            BackgroundTransparency = 1,
            Position = UDim2.new(btnW * (i - 1), 0, 0, 140),
            Size = UDim2.new(btnW, 0, 0, 40),
            Parent = box,
        })
        btn.MouseButton1Click:Connect(function()
            sg:Destroy()
            if btnOpts.Callback then btnOpts.Callback() end
        end)
    end

    -- Animate in
    box.Position = UDim2.new(0.5, 0, 0.6, 0)
    box.BackgroundTransparency = 1
    Tween(box, {
        Position = UDim2.new(0.5, 0, 0.5, 0),
        BackgroundTransparency = 0,
    }, 0.3)
end

-------------------------------------------------
-- WINDOW CONSTRUCTOR
-------------------------------------------------
function Library:CreateWindow(opts)
    opts = opts or {}
    local title      = opts.Title or "UILibrary"
    local size       = opts.Size or UDim2.new(0, 560, 0, 400)
    local position   = opts.Position or UDim2.new(0.5, -280, 0.5, -200)
    local theme      = self.ActiveTheme

    -- Root ScreenGui
    local pCore = LocalPlayer:FindFirstChild("PlayerGui") or game:GetService("CoreGui")
    local screenGui = Create("ScreenGui", {
        Name = "UILib_" .. title,
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        IgnoreGuiInset = true,
        Parent = pCore,
    })

    -- Main window frame
    local mainFrame = Create("Frame", {
        Name = "MainFrame",
        Size = size,
        Position = position,
        BackgroundColor3 = theme.WindowBg,
        BorderSizePixel = 0,
        ClipsDescendants = false,
        Parent = screenGui,
    })
    Create("UICorner", { CornerRadius = UDim.new(0, 12), Parent = mainFrame })
    Create("UIStroke", { Color = theme.Border, Thickness = 1, Parent = mainFrame })

    -- Drop shadow
    Create("ImageLabel", {
        Name = "Shadow",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, -15, 0, -15),
        Size = UDim2.new(1, 30, 1, 30),
        Image = "rbxassetid://6014261993",
        ImageColor3 = Color3.fromRGB(0, 0, 0),
        ImageTransparency = 0.6,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(49, 49, 450, 450),
        ZIndex = -1,
        Parent = mainFrame,
    })

    -- Titlebar
    local titleBar = Create("Frame", {
        Name = "TitleBar",
        Size = UDim2.new(1, 0, 0, 42),
        BackgroundColor3 = theme.SecondaryBg,
        BorderSizePixel = 0,
        Parent = mainFrame,
    })
    Create("UICorner", { CornerRadius = UDim.new(0, 12), Parent = titleBar })
    -- Square off bottom corners of titlebar
    Create("Frame", {
        BackgroundColor3 = theme.SecondaryBg,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0.5, 0),
        Size = UDim2.new(1, 0, 0.5, 0),
        Parent = titleBar,
    })

    -- Mac-style window controls
    local function makeControl(color, xOffset, action)
        local ctrl = Create("TextButton", {
            Name = "WinCtrl",
            Size = UDim2.new(0, 12, 0, 12),
            Position = UDim2.new(0, xOffset, 0.5, -6),
            BackgroundColor3 = color,
            Text = "",
            BorderSizePixel = 0,
            Parent = titleBar,
        })
        Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = ctrl })
        ctrl.MouseButton1Click:Connect(action)
        return ctrl
    end

    local winState = { minimized = false }

    makeControl(Color3.fromRGB(255, 95, 86), 14, function()
        -- Close
        Tween(mainFrame, { Size = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 1 }, 0.25)
        task.delay(0.3, function() screenGui:Destroy() end)
    end)
    makeControl(Color3.fromRGB(255, 189, 46), 30, function()
        -- Minimize
        if winState.minimized then
            Tween(mainFrame, { Size = size }, 0.3)
            winState.minimized = false
        else
            Tween(mainFrame, { Size = UDim2.new(size.X.Scale, size.X.Offset, 0, 42) }, 0.3)
            winState.minimized = true
        end
    end)
    makeControl(Color3.fromRGB(39, 201, 63), 46, function()
        -- Fullscreen toggle
        if winState.fullscreen then
            Tween(mainFrame, { Size = size, Position = position }, 0.3)
            winState.fullscreen = false
        else
            Tween(mainFrame, { Size = UDim2.new(1, 0, 1, 0), Position = UDim2.new(0,0,0,0) }, 0.3)
            winState.fullscreen = true
        end
    end)

    -- Title text
    Create("TextLabel", {
        Name = "Title",
        Text = title,
        Font = self.Config.Font,
        TextSize = 14,
        TextColor3 = theme.Text,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 70, 0, 0),
        Size = UDim2.new(1, -80, 1, 0),
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = titleBar,
    })

    -- Make draggable via titlebar
    MakeDraggable(mainFrame, titleBar)

    -- Tab bar
    local tabBar = Create("Frame", {
        Name = "TabBar",
        BackgroundColor3 = theme.SecondaryBg,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, 42),
        Size = UDim2.new(0, 140, 1, -42),
        ClipsDescendants = true,
        Parent = mainFrame,
    })
    -- Square off right side of tab bar
    Create("Frame", {
        BackgroundColor3 = theme.SecondaryBg,
        BorderSizePixel = 0,
        Position = UDim2.new(0.5, 0, 0, 0),
        Size = UDim2.new(0.5, 0, 1, 0),
        Parent = tabBar,
    })

    -- Search box in tab bar
    local searchBox = Create("TextBox", {
        Name = "Search",
        PlaceholderText = "Search tabs...",
        Text = "",
        Font = Enum.Font.Gotham,
        TextSize = 12,
        TextColor3 = theme.Text,
        PlaceholderColor3 = theme.SubText,
        BackgroundColor3 = theme.TertiaryBg,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 8, 0, 8),
        Size = UDim2.new(1, -16, 0, 28),
        ClearTextOnFocus = false,
        Parent = tabBar,
    })
    Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = searchBox })
    Create("UIPadding", { PaddingLeft = UDim.new(0, 8), Parent = searchBox })

    -- Tab list container
    local tabListFrame = Create("ScrollingFrame", {
        Name = "TabList",
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, 44),
        Size = UDim2.new(1, 0, 1, -44),
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = theme.Accent,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        Parent = tabBar,
    })
    Create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 2),
        Parent = tabListFrame,
    })
    Create("UIPadding", {
        PaddingTop = UDim.new(0, 4),
        PaddingLeft = UDim.new(0, 6),
        PaddingRight = UDim.new(0, 6),
        Parent = tabListFrame,
    })

    -- Content area
    local contentArea = Create("Frame", {
        Name = "ContentArea",
        BackgroundColor3 = theme.Background,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 140, 0, 42),
        Size = UDim2.new(1, -140, 1, -42),
        ClipsDescendants = true,
        Parent = mainFrame,
    })
    -- Round bottom-right corner
    Create("UICorner", { CornerRadius = UDim.new(0, 12), Parent = contentArea })
    Create("Frame", {
        BackgroundColor3 = theme.Background,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(0.5, 0, 0.3, 0),
        Parent = contentArea,
    })

    -- Animate window in
    mainFrame.Size = UDim2.new(0, 0, 0, 0)
    mainFrame.BackgroundTransparency = 1
    Tween(mainFrame, { Size = size, BackgroundTransparency = 0 }, 0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

    -----------------------------------------
    -- Window object
    -----------------------------------------
    local Window = {}
    Window._tabs = {}
    Window._activeTab = nil
    Window.MainFrame = mainFrame
    Window.ScreenGui = screenGui

    -- Search functionality
    searchBox:GetPropertyChangedSignal("Text"):Connect(function()
        local query = searchBox.Text:lower()
        for _, tabData in pairs(Window._tabs) do
            local visible = query == "" or tabData.Name:lower():find(query, 1, true)
            tabData.Button.Visible = visible
        end
    end)

    function Window:SetTheme(themeName)
        local newTheme = Library.Themes[themeName]
        if not newTheme then return end
        Library.ActiveTheme = newTheme
        Library.ActiveThemeName = themeName
        theme = newTheme
        -- Update main elements
        mainFrame.BackgroundColor3 = newTheme.WindowBg
        titleBar.BackgroundColor3 = newTheme.SecondaryBg
        tabBar.BackgroundColor3 = newTheme.SecondaryBg
        contentArea.BackgroundColor3 = newTheme.Background
        searchBox.BackgroundColor3 = newTheme.TertiaryBg
        searchBox.TextColor3 = newTheme.Text
        searchBox.PlaceholderColor3 = newTheme.SubText
        -- Notify
        Library:Notify({ Title = "Theme Changed", Message = "Applied: " .. themeName, Duration = 2 })
    end

    function Window:CreateTab(tabName, icon)
        local tabData = {}
        tabData.Name = tabName

        -- Tab button
        local tabBtn = Create("TextButton", {
            Name = tabName,
            Text = (icon and icon .. "  " or "") .. tabName,
            Font = Library.Config.Font,
            TextSize = 13,
            TextColor3 = theme.SubText,
            BackgroundColor3 = Color3.fromRGB(0,0,0),
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 34),
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = tabListFrame,
        })
        Create("UICorner", { CornerRadius = UDim.new(0, 7), Parent = tabBtn })
        Create("UIPadding", { PaddingLeft = UDim.new(0, 10), Parent = tabBtn })

        -- Accent bar indicator
        local indicator = Create("Frame", {
            BackgroundColor3 = theme.Accent,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 0, 0.15, 0),
            Size = UDim2.new(0, 3, 0.7, 0),
            BorderSizePixel = 0,
            Parent = tabBtn,
        })
        Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = indicator })

        -- Tab content (ScrollingFrame)
        local tabContent = Create("ScrollingFrame", {
            Name = tabName .. "_Content",
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Position = UDim2.new(0, 0, 0, 0),
            Size = UDim2.new(1, 0, 1, 0),
            ScrollBarThickness = 3,
            ScrollBarImageColor3 = theme.Accent,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            Visible = false,
            Parent = contentArea,
        })
        Create("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 6),
            Parent = tabContent,
        })
        Create("UIPadding", {
            PaddingTop = UDim.new(0, 10),
            PaddingLeft = UDim.new(0, 10),
            PaddingRight = UDim.new(0, 10),
            PaddingBottom = UDim.new(0, 10),
            Parent = tabContent,
        })

        -- Auto resize canvas
        local layout = tabContent:FindFirstChildOfClass("UIListLayout")
        layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            tabContent.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 20)
        end)
        tabListFrame.CanvasSize = UDim2.new(0, 0, 0, #Window._tabs * 38 + 10)

        tabData.Button = tabBtn
        tabData.Content = tabContent
        tabData.Indicator = indicator

        table.insert(Window._tabs, tabData)

        -- Activate tab
        local function activate()
            if Window._activeTab then
                Window._activeTab.Content.Visible = false
                Tween(Window._activeTab.Button, { TextColor3 = theme.SubText }, 0.15)
                Tween(Window._activeTab.Button, { BackgroundTransparency = 1 }, 0.15)
                Tween(Window._activeTab.Indicator, { BackgroundTransparency = 1 }, 0.15)
            end
            Window._activeTab = tabData
            tabContent.Visible = true
            Tween(tabBtn, { TextColor3 = theme.Text, BackgroundTransparency = 0.7 }, 0.15)
            Tween(indicator, { BackgroundTransparency = 0 }, 0.15)
        end

        tabBtn.MouseButton1Click:Connect(activate)
        tabBtn.MouseEnter:Connect(function()
            if Window._activeTab ~= tabData then
                Tween(tabBtn, { BackgroundTransparency = 0.85 }, 0.1)
            end
        end)
        tabBtn.MouseLeave:Connect(function()
            if Window._activeTab ~= tabData then
                Tween(tabBtn, { BackgroundTransparency = 1 }, 0.1)
            end
        end)

        if #Window._tabs == 1 then activate() end

        -----------------------------------------
        -- TAB ELEMENT BUILDERS
        -----------------------------------------
        local Tab = {}
        Tab._content = tabContent
        Tab._theme = theme

        -- Helper: section header
        local function makeSection(name)
            local sec = Create("Frame", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 22),
                LayoutOrder = 0,
                Parent = tabContent,
            })
            Create("TextLabel", {
                Text = name:upper(),
                Font = Library.Config.Font,
                TextSize = 10,
                TextColor3 = theme.SubText,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 1, 0),
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = sec,
            })
            Create("Frame", {
                BackgroundColor3 = theme.Border,
                BorderSizePixel = 0,
                Position = UDim2.new(0, 0, 1, -1),
                Size = UDim2.new(1, 0, 0, 1),
                Parent = sec,
            })
            return sec
        end

        function Tab:Section(name)
            makeSection(name)
        end

        function Tab:Separator()
            Create("Frame", {
                BackgroundColor3 = theme.Border,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 1),
                Parent = tabContent,
            })
        end

        function Tab:Label(text, opts)
            opts = opts or {}
            local lbl = Create("TextLabel", {
                Text = text,
                Font = opts.Font or Library.Config.Font,
                TextSize = opts.TextSize or 13,
                TextColor3 = opts.Color or theme.SubText,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 24),
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = tabContent,
            })
            return lbl
        end

        function Tab:Button(opts)
            opts = opts or {}
            local labelText = opts.Name or "Button"
            local callback = opts.Callback or function() end
            local cooldown = opts.Cooldown or 0
            local _onCooldown = false

            local btn = Create("TextButton", {
                Text = "",
                BackgroundColor3 = theme.TertiaryBg,
                Size = UDim2.new(1, 0, 0, 36),
                BorderSizePixel = 0,
                Parent = tabContent,
            })
            Create("UICorner", { CornerRadius = UDim.new(0, 8), Parent = btn })
            Create("UIStroke", { Color = theme.Border, Thickness = 1, Parent = btn })

            local lbl = Create("TextLabel", {
                Text = labelText,
                Font = Library.Config.Font,
                TextSize = 13,
                TextColor3 = theme.Text,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, -16, 1, 0),
                Position = UDim2.new(0, 12, 0, 0),
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = btn,
            })

            btn.MouseEnter:Connect(function()
                Tween(btn, { BackgroundColor3 = theme.Border }, 0.12)
            end)
            btn.MouseLeave:Connect(function()
                Tween(btn, { BackgroundColor3 = theme.TertiaryBg }, 0.12)
            end)
            btn.MouseButton1Down:Connect(function()
                Tween(btn, { Size = UDim2.new(1, -4, 0, 34) }, 0.08)
            end)
            btn.MouseButton1Up:Connect(function()
                Tween(btn, { Size = UDim2.new(1, 0, 0, 36) }, 0.08)
            end)
            btn.MouseButton1Click:Connect(function()
                if _onCooldown then return end
                if cooldown > 0 then
                    _onCooldown = true
                    lbl.TextColor3 = theme.SubText
                    task.delay(cooldown, function()
                        _onCooldown = false
                        lbl.TextColor3 = theme.Text
                    end)
                end
                callback()
            end)
            return btn
        end

        function Tab:Toggle(opts)
            opts = opts or {}
            local labelText = opts.Name or "Toggle"
            local default   = opts.Default or false
            local callback  = opts.Callback or function() end
            local saveKey   = opts.SaveKey

            -- Load saved value
            if saveKey and Library.SaveManager:Get(saveKey) ~= nil then
                default = Library.SaveManager:Get(saveKey)
            end

            local toggled = default
            local row = Create("Frame", {
                BackgroundColor3 = theme.TertiaryBg,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 36),
                Parent = tabContent,
            })
            Create("UICorner", { CornerRadius = UDim.new(0, 8), Parent = row })
            Create("UIStroke", { Color = theme.Border, Thickness = 1, Parent = row })

            Create("TextLabel", {
                Text = labelText,
                Font = Library.Config.Font,
                TextSize = 13,
                TextColor3 = theme.Text,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 12, 0, 0),
                Size = UDim2.new(1, -60, 1, 0),
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = row,
            })

            -- Toggle track
            local track = Create("Frame", {
                BackgroundColor3 = toggled and theme.Accent or theme.Border,
                BorderSizePixel = 0,
                Position = UDim2.new(1, -46, 0.5, -10),
                Size = UDim2.new(0, 36, 0, 20),
                Parent = row,
            })
            Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = track })

            local thumb = Create("Frame", {
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                BorderSizePixel = 0,
                Position = toggled and UDim2.new(0, 18, 0.5, -7) or UDim2.new(0, 2, 0.5, -7),
                Size = UDim2.new(0, 14, 0, 14),
                Parent = track,
            })
            Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = thumb })

            local btn = Create("TextButton", {
                Text = "",
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 1, 0),
                Parent = row,
            })

            local toggleObj = {}
            function toggleObj:Set(val)
                toggled = val
                Tween(track, { BackgroundColor3 = toggled and theme.Accent or theme.Border }, 0.2)
                Tween(thumb, { Position = toggled and UDim2.new(0, 18, 0.5, -7) or UDim2.new(0, 2, 0.5, -7) }, 0.2)
                if saveKey then Library.SaveManager:Set(saveKey, toggled) end
                callback(toggled)
            end
            function toggleObj:Get() return toggled end

            btn.MouseButton1Click:Connect(function()
                toggleObj:Set(not toggled)
            end)

            -- Hover
            btn.MouseEnter:Connect(function() Tween(row, { BackgroundColor3 = theme.Border }, 0.12) end)
            btn.MouseLeave:Connect(function() Tween(row, { BackgroundColor3 = theme.TertiaryBg }, 0.12) end)

            return toggleObj
        end

        function Tab:Slider(opts)
            opts = opts or {}
            local labelText = opts.Name or "Slider"
            local min       = opts.Min or 0
            local max       = opts.Max or 100
            local default   = opts.Default or min
            local decimals  = opts.Decimals or 0
            local suffix    = opts.Suffix or ""
            local callback  = opts.Callback or function() end
            local saveKey   = opts.SaveKey

            if saveKey and Library.SaveManager:Get(saveKey) ~= nil then
                default = Library.SaveManager:Get(saveKey)
            end

            local value = math.clamp(default, min, max)

            local container = Create("Frame", {
                BackgroundColor3 = theme.TertiaryBg,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 52),
                Parent = tabContent,
            })
            Create("UICorner", { CornerRadius = UDim.new(0, 8), Parent = container })
            Create("UIStroke", { Color = theme.Border, Thickness = 1, Parent = container })

            Create("TextLabel", {
                Text = labelText,
                Font = Library.Config.Font,
                TextSize = 13,
                TextColor3 = theme.Text,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 12, 0, 5),
                Size = UDim2.new(0.6, 0, 0, 20),
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = container,
            })

            local valLabel = Create("TextLabel", {
                Text = tostring(value) .. suffix,
                Font = Library.Config.Font,
                TextSize = 12,
                TextColor3 = theme.Accent,
                BackgroundTransparency = 1,
                Position = UDim2.new(0.6, 0, 0, 5),
                Size = UDim2.new(0.4, -12, 0, 20),
                TextXAlignment = Enum.TextXAlignment.Right,
                Parent = container,
            })

            -- Track
            local track = Create("Frame", {
                BackgroundColor3 = theme.Border,
                BorderSizePixel = 0,
                Position = UDim2.new(0, 12, 0, 34),
                Size = UDim2.new(1, -24, 0, 6),
                Parent = container,
            })
            Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = track })

            -- Fill
            local fill = Create("Frame", {
                BackgroundColor3 = theme.Accent,
                BorderSizePixel = 0,
                Size = UDim2.new((value - min) / (max - min), 0, 1, 0),
                Parent = track,
            })
            Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = fill })

            -- Thumb
            local thumb = Create("Frame", {
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                BorderSizePixel = 0,
                Size = UDim2.new(0, 14, 0, 14),
                Position = UDim2.new((value - min) / (max - min), -7, 0.5, -7),
                Parent = track,
            })
            Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = thumb })
            Create("UIStroke", { Color = theme.Accent, Thickness = 2, Parent = thumb })

            local draggingSlider = false
            local function updateSlider(input)
                local trackPos = track.AbsolutePosition.X
                local trackSize = track.AbsoluteSize.X
                local rel = math.clamp((input.Position.X - trackPos) / trackSize, 0, 1)
                local raw = min + (max - min) * rel
                if decimals == 0 then
                    value = math.round(raw)
                else
                    value = math.floor(raw * 10^decimals + 0.5) / 10^decimals
                end
                fill.Size = UDim2.new(rel, 0, 1, 0)
                thumb.Position = UDim2.new(rel, -7, 0.5, -7)
                valLabel.Text = tostring(value) .. suffix
                if saveKey then Library.SaveManager:Set(saveKey, value) end
                callback(value)
            end

            track.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or
                   input.UserInputType == Enum.UserInputType.Touch then
                    draggingSlider = true
                    updateSlider(input)
                end
            end)
            UserInputService.InputChanged:Connect(function(input)
                if draggingSlider and (input.UserInputType == Enum.UserInputType.MouseMovement or
                   input.UserInputType == Enum.UserInputType.Touch) then
                    updateSlider(input)
                end
            end)
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or
                   input.UserInputType == Enum.UserInputType.Touch then
                    draggingSlider = false
                end
            end)

            local sliderObj = {}
            function sliderObj:Set(v)
                value = math.clamp(v, min, max)
                local rel = (value - min) / (max - min)
                fill.Size = UDim2.new(rel, 0, 1, 0)
                thumb.Position = UDim2.new(rel, -7, 0.5, -7)
                valLabel.Text = tostring(value) .. suffix
                if saveKey then Library.SaveManager:Set(saveKey, value) end
                callback(value)
            end
            function sliderObj:Get() return value end
            return sliderObj
        end

        function Tab:Dropdown(opts)
            opts = opts or {}
            local labelText = opts.Name or "Dropdown"
            local options   = opts.Options or {}
            local default   = opts.Default or (options[1] or "")
            local callback  = opts.Callback or function() end
            local saveKey   = opts.SaveKey
            local searchable = opts.Searchable ~= false

            if saveKey and Library.SaveManager:Get(saveKey) ~= nil then
                default = Library.SaveManager:Get(saveKey)
            end

            local selected = default
            local expanded = false

            local container = Create("Frame", {
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 36),
                ClipsDescendants = false,
                Parent = tabContent,
            })

            local header = Create("TextButton", {
                Text = "",
                BackgroundColor3 = theme.TertiaryBg,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 36),
                Parent = container,
            })
            Create("UICorner", { CornerRadius = UDim.new(0, 8), Parent = header })
            Create("UIStroke", { Color = theme.Border, Thickness = 1, Parent = header })

            Create("TextLabel", {
                Text = labelText,
                Font = Library.Config.Font,
                TextSize = 13,
                TextColor3 = theme.SubText,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 12, 0, 0),
                Size = UDim2.new(0.5, 0, 1, 0),
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = header,
            })

            local selectedLbl = Create("TextLabel", {
                Text = selected,
                Font = Library.Config.Font,
                TextSize = 13,
                TextColor3 = theme.Text,
                BackgroundTransparency = 1,
                Position = UDim2.new(0.5, 0, 0, 0),
                Size = UDim2.new(0.5, -36, 1, 0),
                TextXAlignment = Enum.TextXAlignment.Right,
                Parent = header,
            })

            -- Arrow
            local arrow = Create("TextLabel", {
                Text = "▾",
                Font = Library.Config.Font,
                TextSize = 14,
                TextColor3 = theme.SubText,
                BackgroundTransparency = 1,
                Position = UDim2.new(1, -28, 0, 0),
                Size = UDim2.new(0, 22, 1, 0),
                TextXAlignment = Enum.TextXAlignment.Center,
                Parent = header,
            })

            -- Dropdown panel
            local panelHeight = math.min(#options * 32 + (searchable and 36 or 8), 180)
            local panel = Create("Frame", {
                BackgroundColor3 = theme.SecondaryBg,
                BorderSizePixel = 0,
                Position = UDim2.new(0, 0, 1, 4),
                Size = UDim2.new(1, 0, 0, panelHeight),
                Visible = false,
                ClipsDescendants = true,
                ZIndex = 10,
                Parent = container,
            })
            Create("UICorner", { CornerRadius = UDim.new(0, 8), Parent = panel })
            Create("UIStroke", { Color = theme.Border, Thickness = 1, Parent = panel })

            -- Search inside dropdown
            local ddSearch
            if searchable then
                ddSearch = Create("TextBox", {
                    PlaceholderText = "Search...",
                    Text = "",
                    Font = Enum.Font.Gotham,
                    TextSize = 12,
                    TextColor3 = theme.Text,
                    PlaceholderColor3 = theme.SubText,
                    BackgroundColor3 = theme.TertiaryBg,
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 8, 0, 4),
                    Size = UDim2.new(1, -16, 0, 26),
                    ClearTextOnFocus = false,
                    ZIndex = 11,
                    Parent = panel,
                })
                Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = ddSearch })
                Create("UIPadding", { PaddingLeft = UDim.new(0, 6), Parent = ddSearch })
            end

            local optScroll = Create("ScrollingFrame", {
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Position = UDim2.new(0, 0, 0, searchable and 34 or 4),
                Size = UDim2.new(1, 0, 1, searchable and -34 or -4),
                ScrollBarThickness = 2,
                ScrollBarImageColor3 = theme.Accent,
                CanvasSize = UDim2.new(0, 0, 0, #options * 32),
                ZIndex = 11,
                Parent = panel,
            })
            Create("UIListLayout", {
                SortOrder = Enum.SortOrder.LayoutOrder,
                Parent = optScroll,
            })
            Create("UIPadding", {
                PaddingLeft = UDim.new(0, 4),
                PaddingRight = UDim.new(0, 4),
                Parent = optScroll,
            })

            local optButtons = {}
            local function buildOptions(filter)
                -- Clear existing
                for _, ob in pairs(optButtons) do ob:Destroy() end
                optButtons = {}
                local count = 0
                for _, opt in ipairs(options) do
                    if filter == "" or opt:lower():find(filter:lower(), 1, true) then
                        count = count + 1
                        local ob = Create("TextButton", {
                            Text = opt,
                            Font = Library.Config.Font,
                            TextSize = 13,
                            TextColor3 = (opt == selected) and theme.Accent or theme.Text,
                            BackgroundColor3 = (opt == selected) and theme.TertiaryBg or Color3.fromRGB(0,0,0),
                            BackgroundTransparency = (opt == selected) and 0.5 or 1,
                            Size = UDim2.new(1, 0, 0, 30),
                            ZIndex = 12,
                            Parent = optScroll,
                        })
                        Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = ob })
                        table.insert(optButtons, ob)
                        ob.MouseButton1Click:Connect(function()
                            selected = opt
                            selectedLbl.Text = selected
                            if saveKey then Library.SaveManager:Set(saveKey, selected) end
                            callback(selected)
                            -- Close
                            expanded = false
                            Tween(arrow, { Rotation = 0 }, 0.15)
                            panel.Visible = false
                            container.Size = UDim2.new(1, 0, 0, 36)
                            buildOptions("")
                        end)
                        ob.MouseEnter:Connect(function()
                            Tween(ob, { BackgroundTransparency = 0.7 }, 0.1)
                        end)
                        ob.MouseLeave:Connect(function()
                            Tween(ob, { BackgroundTransparency = (opt == selected) and 0.5 or 1 }, 0.1)
                        end)
                    end
                end
                optScroll.CanvasSize = UDim2.new(0, 0, 0, count * 32)
            end
            buildOptions("")

            if ddSearch then
                ddSearch:GetPropertyChangedSignal("Text"):Connect(function()
                    buildOptions(ddSearch.Text)
                end)
            end

            header.MouseButton1Click:Connect(function()
                expanded = not expanded
                if expanded then
                    panel.Visible = true
                    container.Size = UDim2.new(1, 0, 0, 36 + panelHeight + 4)
                    Tween(arrow, { Rotation = 180 }, 0.2)
                else
                    Tween(arrow, { Rotation = 0 }, 0.15)
                    panel.Visible = false
                    container.Size = UDim2.new(1, 0, 0, 36)
                end
            end)

            header.MouseEnter:Connect(function() Tween(header, { BackgroundColor3 = theme.Border }, 0.12) end)
            header.MouseLeave:Connect(function() Tween(header, { BackgroundColor3 = theme.TertiaryBg }, 0.12) end)

            local ddObj = {}
            function ddObj:Set(v)
                selected = v
                selectedLbl.Text = v
                if saveKey then Library.SaveManager:Set(saveKey, v) end
                callback(v)
                buildOptions("")
            end
            function ddObj:Get() return selected end
            function ddObj:SetOptions(newOpts)
                options = newOpts
                buildOptions("")
            end
            return ddObj
        end

        function Tab:TextBox(opts)
            opts = opts or {}
            local labelText  = opts.Name or "TextBox"
            local placeholder = opts.Placeholder or "Enter text..."
            local default    = opts.Default or ""
            local callback   = opts.Callback or function() end
            local saveKey    = opts.SaveKey

            if saveKey and Library.SaveManager:Get(saveKey) ~= nil then
                default = Library.SaveManager:Get(saveKey)
            end

            local container = Create("Frame", {
                BackgroundColor3 = theme.TertiaryBg,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 58),
                Parent = tabContent,
            })
            Create("UICorner", { CornerRadius = UDim.new(0, 8), Parent = container })
            Create("UIStroke", { Color = theme.Border, Thickness = 1, Parent = container })

            Create("TextLabel", {
                Text = labelText,
                Font = Library.Config.Font,
                TextSize = 12,
                TextColor3 = theme.SubText,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 12, 0, 4),
                Size = UDim2.new(1, -24, 0, 18),
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = container,
            })

            local box = Create("TextBox", {
                Text = default,
                PlaceholderText = placeholder,
                Font = Library.Config.Font,
                TextSize = 13,
                TextColor3 = theme.Text,
                PlaceholderColor3 = theme.SubText,
                BackgroundColor3 = theme.Background,
                BorderSizePixel = 0,
                Position = UDim2.new(0, 12, 0, 26),
                Size = UDim2.new(1, -24, 0, 26),
                ClearTextOnFocus = false,
                Parent = container,
            })
            Create("UICorner", { CornerRadius = UDim.new(0, 5), Parent = box })
            Create("UIPadding", { PaddingLeft = UDim.new(0, 8), Parent = box })

            box.FocusLost:Connect(function(enter)
                if saveKey then Library.SaveManager:Set(saveKey, box.Text) end
                callback(box.Text, enter)
            end)

            local tbObj = {}
            function tbObj:Set(v) box.Text = v end
            function tbObj:Get() return box.Text end
            return tbObj
        end

        function Tab:Keybind(opts)
            opts = opts or {}
            local labelText = opts.Name or "Keybind"
            local default   = opts.Default or Enum.KeyCode.Unknown
            local callback  = opts.Callback or function() end
            local saveKey   = opts.SaveKey

            if saveKey and Library.SaveManager:Get(saveKey) ~= nil then
                local saved = Library.SaveManager:Get(saveKey)
                if saved then default = Enum.KeyCode[saved] or default end
            end

            local currentKey = default
            local listening  = false

            local row = Create("Frame", {
                BackgroundColor3 = theme.TertiaryBg,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 36),
                Parent = tabContent,
            })
            Create("UICorner", { CornerRadius = UDim.new(0, 8), Parent = row })
            Create("UIStroke", { Color = theme.Border, Thickness = 1, Parent = row })

            Create("TextLabel", {
                Text = labelText,
                Font = Library.Config.Font,
                TextSize = 13,
                TextColor3 = theme.Text,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 12, 0, 0),
                Size = UDim2.new(1, -120, 1, 0),
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = row,
            })

            local keyBtn = Create("TextButton", {
                Text = currentKey == Enum.KeyCode.Unknown and "None" or currentKey.Name,
                Font = Library.Config.Font,
                TextSize = 12,
                TextColor3 = theme.Accent,
                BackgroundColor3 = theme.Background,
                BorderSizePixel = 0,
                Position = UDim2.new(1, -108, 0.5, -13),
                Size = UDim2.new(0, 90, 0, 26),
                Parent = row,
            })
            Create("UICorner", { CornerRadius = UDim.new(0, 5), Parent = keyBtn })
            Create("UIStroke", { Color = theme.Accent, Thickness = 1, Parent = keyBtn })

            keyBtn.MouseButton1Click:Connect(function()
                listening = true
                keyBtn.Text = "..."
                keyBtn.TextColor3 = theme.Warning
            end)

            UserInputService.InputBegan:Connect(function(input, processed)
                if not listening then return end
                if input.UserInputType == Enum.UserInputType.Keyboard then
                    if input.KeyCode == Enum.KeyCode.Escape then
                        currentKey = Enum.KeyCode.Unknown
                        keyBtn.Text = "None"
                    else
                        currentKey = input.KeyCode
                        keyBtn.Text = input.KeyCode.Name
                    end
                    keyBtn.TextColor3 = theme.Accent
                    listening = false
                    if saveKey then Library.SaveManager:Set(saveKey, currentKey.Name) end
                    callback(currentKey)
                end
            end)

            local kbObj = {}
            function kbObj:Get() return currentKey end
            function kbObj:Set(key)
                currentKey = key
                keyBtn.Text = key == Enum.KeyCode.Unknown and "None" or key.Name
            end
            return kbObj
        end

        function Tab:ColorPicker(opts)
            opts = opts or {}
            local labelText = opts.Name or "Color"
            local default   = opts.Default or Color3.fromRGB(255, 100, 100)
            local callback  = opts.Callback or function() end

            local currentColor = default
            local expanded = false

            local container = Create("Frame", {
                BackgroundColor3 = theme.TertiaryBg,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 36),
                ClipsDescendants = false,
                Parent = tabContent,
            })
            Create("UICorner", { CornerRadius = UDim.new(0, 8), Parent = container })
            Create("UIStroke", { Color = theme.Border, Thickness = 1, Parent = container })

            Create("TextLabel", {
                Text = labelText,
                Font = Library.Config.Font,
                TextSize = 13,
                TextColor3 = theme.Text,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 12, 0, 0),
                Size = UDim2.new(1, -60, 1, 0),
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = container,
            })

            -- Color preview
            local preview = Create("TextButton", {
                Text = "",
                BackgroundColor3 = currentColor,
                BorderSizePixel = 0,
                Position = UDim2.new(1, -46, 0.5, -11),
                Size = UDim2.new(0, 34, 0, 22),
                Parent = container,
            })
            Create("UICorner", { CornerRadius = UDim.new(0, 5), Parent = preview })
            Create("UIStroke", { Color = theme.Border, Thickness = 1, Parent = preview })

            -- Color picker panel (simplified HSV picker)
            local pickerPanel = Create("Frame", {
                BackgroundColor3 = theme.SecondaryBg,
                BorderSizePixel = 0,
                Position = UDim2.new(0, 0, 1, 4),
                Size = UDim2.new(1, 0, 0, 200),
                Visible = false,
                ZIndex = 10,
                Parent = container,
            })
            Create("UICorner", { CornerRadius = UDim.new(0, 8), Parent = pickerPanel })
            Create("UIStroke", { Color = theme.Border, Thickness = 1, Parent = pickerPanel })

            -- Gradient SV square
            local svFrame = Create("ImageLabel", {
                Image = "rbxassetid://2615689005",
                BackgroundColor3 = Color3.fromHSV(0, 1, 1),
                BorderSizePixel = 0,
                Position = UDim2.new(0, 10, 0, 10),
                Size = UDim2.new(1, -20, 0, 130),
                ZIndex = 11,
                Parent = pickerPanel,
            })
            Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = svFrame })

            -- Hue bar
            local hueBar = Create("ImageLabel", {
                Image = "rbxassetid://2615689005",
                BackgroundColor3 = Color3.fromRGB(255,255,255),
                BorderSizePixel = 0,
                Position = UDim2.new(0, 10, 0, 148),
                Size = UDim2.new(1, -20, 0, 16),
                ZIndex = 11,
                Parent = pickerPanel,
            })
            -- Hue gradient
            local hueGrad = Create("UIGradient", {
                Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(255,0,0)),
                    ColorSequenceKeypoint.new(0.167, Color3.fromRGB(255,255,0)),
                    ColorSequenceKeypoint.new(0.333, Color3.fromRGB(0,255,0)),
                    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0,255,255)),
                    ColorSequenceKeypoint.new(0.667, Color3.fromRGB(0,0,255)),
                    ColorSequenceKeypoint.new(0.833, Color3.fromRGB(255,0,255)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(255,0,0)),
                }),
                Parent = hueBar,
            })
            Create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = hueBar })

            local hexBox = Create("TextBox", {
                Text = string.format("%02X%02X%02X", 
                    math.floor(currentColor.R*255),
                    math.floor(currentColor.G*255),
                    math.floor(currentColor.B*255)),
                Font = Enum.Font.Code,
                TextSize = 12,
                TextColor3 = theme.Text,
                PlaceholderText = "RRGGBB",
                BackgroundColor3 = theme.TertiaryBg,
                BorderSizePixel = 0,
                Position = UDim2.new(0, 10, 0, 172),
                Size = UDim2.new(1, -20, 0, 22),
                ClearTextOnFocus = false,
                ZIndex = 11,
                Parent = pickerPanel,
            })
            Create("UICorner", { CornerRadius = UDim.new(0, 5), Parent = hexBox })

            local h, s, v = Color3.toHSV(currentColor)

            local function applyColor()
                currentColor = Color3.fromHSV(h, s, v)
                preview.BackgroundColor3 = currentColor
                hexBox.Text = string.format("%02X%02X%02X",
                    math.floor(currentColor.R*255),
                    math.floor(currentColor.G*255),
                    math.floor(currentColor.B*255))
                svFrame.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
                callback(currentColor)
            end

            -- Hue dragging
            local hDragging = false
            hueBar.InputBegan:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                    hDragging = true
                    h = math.clamp((inp.Position.X - hueBar.AbsolutePosition.X) / hueBar.AbsoluteSize.X, 0, 1)
                    applyColor()
                end
            end)
            UserInputService.InputChanged:Connect(function(inp)
                if hDragging and inp.UserInputType == Enum.UserInputType.MouseMovement then
                    h = math.clamp((inp.Position.X - hueBar.AbsolutePosition.X) / hueBar.AbsoluteSize.X, 0, 1)
                    applyColor()
                end
            end)
            UserInputService.InputEnded:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1 then hDragging = false end
            end)

            -- SV dragging
            local svDragging = false
            svFrame.InputBegan:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                    svDragging = true
                    s = math.clamp((inp.Position.X - svFrame.AbsolutePosition.X) / svFrame.AbsoluteSize.X, 0, 1)
                    v = 1 - math.clamp((inp.Position.Y - svFrame.AbsolutePosition.Y) / svFrame.AbsoluteSize.Y, 0, 1)
                    applyColor()
                end
            end)
            UserInputService.InputChanged:Connect(function(inp)
                if svDragging and inp.UserInputType == Enum.UserInputType.MouseMovement then
                    s = math.clamp((inp.Position.X - svFrame.AbsolutePosition.X) / svFrame.AbsoluteSize.X, 0, 1)
                    v = 1 - math.clamp((inp.Position.Y - svFrame.AbsolutePosition.Y) / svFrame.AbsoluteSize.Y, 0, 1)
                    applyColor()
                end
            end)

            hexBox.FocusLost:Connect(function()
                local hex = hexBox.Text:gsub("#", "")
                if #hex == 6 then
                    local r = tonumber(hex:sub(1,2), 16)
                    local g = tonumber(hex:sub(3,4), 16)
                    local b = tonumber(hex:sub(5,6), 16)
                    if r and g and b then
                        currentColor = Color3.fromRGB(r, g, b)
                        h, s, v = Color3.toHSV(currentColor)
                        applyColor()
                    end
                end
            end)

            preview.MouseButton1Click:Connect(function()
                expanded = not expanded
                pickerPanel.Visible = expanded
                container.Size = expanded and UDim2.new(1, 0, 0, 36 + 204) or UDim2.new(1, 0, 0, 36)
            end)

            local cpObj = {}
            function cpObj:Get() return currentColor end
            function cpObj:Set(c)
                currentColor = c
                h, s, v = Color3.toHSV(c)
                applyColor()
            end
            return cpObj
        end

        function Tab:RadioGroup(opts)
            opts = opts or {}
            local labelText = opts.Name or "Radio Group"
            local options   = opts.Options or {}
            local default   = opts.Default or (options[1] or "")
            local callback  = opts.Callback or function() end

            local selected = default
            local buttons  = {}

            local section = Create("Frame", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 22 + #options * 32),
                Parent = tabContent,
            })
            Create("TextLabel", {
                Text = labelText,
                Font = Library.Config.Font,
                TextSize = 12,
                TextColor3 = theme.SubText,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 20),
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = section,
            })

            local function refresh()
                for opt, btn in pairs(buttons) do
                    local dot = btn:FindFirstChild("Dot")
                    if dot then
                        dot.BackgroundColor3 = (opt == selected) and theme.Accent or theme.Border
                    end
                    btn.TextColor3 = (opt == selected) and theme.Text or theme.SubText
                end
            end

            for i, opt in ipairs(options) do
                local btn = Create("TextButton", {
                    Text = "     " .. opt,
                    Font = Library.Config.Font,
                    TextSize = 13,
                    TextColor3 = (opt == selected) and theme.Text or theme.SubText,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 0, 0, 22 + (i-1)*30),
                    Size = UDim2.new(1, 0, 0, 28),
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = section,
                })
                local dot = Create("Frame", {
                    Name = "Dot",
                    BackgroundColor3 = (opt == selected) and theme.Accent or theme.Border,
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 0, 0.5, -7),
                    Size = UDim2.new(0, 14, 0, 14),
                    Parent = btn,
                })
                Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = dot })
                Create("UIStroke", { Color = theme.SubText, Thickness = 1.5, Parent = dot })

                buttons[opt] = btn
                btn.MouseButton1Click:Connect(function()
                    selected = opt
                    refresh()
                    callback(selected)
                end)
            end

            local rObj = {}
            function rObj:Get() return selected end
            function rObj:Set(v) selected = v; refresh(); callback(v) end
            return rObj
        end

        function Tab:ProgressBar(opts)
            opts = opts or {}
            local labelText = opts.Name or "Progress"
            local value     = opts.Value or 0
            local color     = opts.Color or theme.Accent

            local container = Create("Frame", {
                BackgroundColor3 = theme.TertiaryBg,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 48),
                Parent = tabContent,
            })
            Create("UICorner", { CornerRadius = UDim.new(0, 8), Parent = container })
            Create("UIStroke", { Color = theme.Border, Thickness = 1, Parent = container })

            local lbl = Create("TextLabel", {
                Text = labelText,
                Font = Library.Config.Font,
                TextSize = 13,
                TextColor3 = theme.Text,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 12, 0, 5),
                Size = UDim2.new(0.7, 0, 0, 18),
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = container,
            })
            local pct = Create("TextLabel", {
                Text = math.floor(value) .. "%",
                Font = Library.Config.Font,
                TextSize = 12,
                TextColor3 = theme.SubText,
                BackgroundTransparency = 1,
                Position = UDim2.new(0.7, 0, 0, 5),
                Size = UDim2.new(0.3, -12, 0, 18),
                TextXAlignment = Enum.TextXAlignment.Right,
                Parent = container,
            })

            local track = Create("Frame", {
                BackgroundColor3 = theme.Border,
                BorderSizePixel = 0,
                Position = UDim2.new(0, 12, 0, 30),
                Size = UDim2.new(1, -24, 0, 8),
                Parent = container,
            })
            Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = track })

            local fill = Create("Frame", {
                BackgroundColor3 = color,
                BorderSizePixel = 0,
                Size = UDim2.new(value / 100, 0, 1, 0),
                Parent = track,
            })
            Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = fill })

            local pbObj = {}
            function pbObj:Set(v)
                value = math.clamp(v, 0, 100)
                Tween(fill, { Size = UDim2.new(value / 100, 0, 1, 0) }, 0.3)
                pct.Text = math.floor(value) .. "%"
            end
            function pbObj:Get() return value end
            return pbObj
        end

        function Tab:ImageDisplay(opts)
            opts = opts or {}
            local labelText = opts.Name or "Image"
            local imageId   = opts.Image or "rbxassetid://0"
            local imgSize   = opts.Size or UDim2.new(0, 80, 0, 80)

            local container = Create("Frame", {
                BackgroundColor3 = theme.TertiaryBg,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 100),
                Parent = tabContent,
            })
            Create("UICorner", { CornerRadius = UDim.new(0, 8), Parent = container })
            Create("UIStroke", { Color = theme.Border, Thickness = 1, Parent = container })

            Create("ImageLabel", {
                Image = imageId,
                BackgroundColor3 = theme.Background,
                BorderSizePixel = 0,
                Position = UDim2.new(0.5, -40, 0, 10),
                Size = UDim2.new(0, 80, 0, 80),
                ScaleType = Enum.ScaleType.Fit,
                Parent = container,
            })

            if labelText ~= "" then
                Create("TextLabel", {
                    Text = labelText,
                    Font = Enum.Font.Gotham,
                    TextSize = 11,
                    TextColor3 = theme.SubText,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 0, 0, 82),
                    Size = UDim2.new(1, 0, 0, 14),
                    TextXAlignment = Enum.TextXAlignment.Center,
                    Parent = container,
                })
            end
        end

        return Tab
    end

    -----------------------------------------
    -- InterfaceManager on window
    -----------------------------------------
    function Window:GetInterfaceManager()
        local IM = {}

        function IM:SetTransparency(val)
            Library.Config.Transparency = val
            mainFrame.BackgroundTransparency = 1 - val
        end

        function IM:SetFont(font)
            Library.Config.Font = font
        end

        function IM:SetTheme(name)
            Window:SetTheme(name)
        end

        return IM
    end

    table.insert(Library.Windows, Window)
    return Window
end

-------------------------------------------------
-- FLOATING BUTTON MANAGER
-------------------------------------------------
Library.FloatingButtonManager = {}

function Library.FloatingButtonManager:Create(opts)
    opts = opts or {}
    local icon     = opts.Icon or "☰"
    local callback = opts.Callback or function() end
    local label    = opts.Label or "Open"

    local pCore = LocalPlayer:FindFirstChild("PlayerGui") or game:GetService("CoreGui")
    local sg = Create("ScreenGui", {
        Name = "UILib_FloatingBtn",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        Parent = pCore,
    })

    local btn = Create("TextButton", {
        Text = icon .. "  " .. label,
        Font = Library.Config.Font,
        TextSize = 13,
        TextColor3 = Library.ActiveTheme.Text,
        BackgroundColor3 = Library.ActiveTheme.Accent,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 20, 0.5, 0),
        Size = UDim2.new(0, 110, 0, 38),
        Parent = sg,
    })
    Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = btn })

    -- Drop shadow
    Create("ImageLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, -8, 0, -8),
        Size = UDim2.new(1, 16, 1, 16),
        Image = "rbxassetid://6014261993",
        ImageColor3 = Color3.fromRGB(0,0,0),
        ImageTransparency = 0.5,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(49,49,450,450),
        ZIndex = 0,
        Parent = btn,
    })

    MakeDraggable(btn)

    btn.MouseButton1Click:Connect(callback)

    btn.MouseEnter:Connect(function()
        Tween(btn, { BackgroundColor3 = Library.ActiveTheme.AccentDark }, 0.12)
    end)
    btn.MouseLeave:Connect(function()
        Tween(btn, { BackgroundColor3 = Library.ActiveTheme.Accent }, 0.12)
    end)

    local fbObj = {}
    function fbObj:SetVisible(v) btn.Visible = v end
    function fbObj:Destroy() sg:Destroy() end
    return fbObj
end

-------------------------------------------------
-- RETURN
-------------------------------------------------
return Library
