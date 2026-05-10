--[[
    Silence UI Library v3.0.0
    Ultimate Combined Library - Fluent + Obsidian Patterns
    Features: 90+ Themes, Acrylic/Glass, SaveManager, InterfaceManager,
    FloatingButtonManager, Notifications, Dialogs, ColorPickers,
    Keybinds, Search, Icons, Mobile Support, and more.
    
    Credits: Fluent by dawid, Obsidian by deividcomsono, and original code
]]

-- ============================================
-- SERVICES & COMPATIBILITY
-- ============================================
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui") or game:GetService("StarterGui")
local HttpService = game:GetService("HttpService")
local TextService = game:GetService("TextService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local SoundService = game:GetService("SoundService")
local Teams = game:GetService("Teams")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = Workspace.CurrentCamera

-- Executor compatibility
local protectgui = protectgui or (syn and syn.protect_gui) or function() end
local cloneref = cloneref or clonereference or function(inst) return inst end
local gethui = gethui or function() return CoreGui end
local request = request or http_request or (http and http.request) or (syn and syn.request)
local getcustomasset = getcustomasset or function(path) return "" end
local isfile = isfile or function() return false end
local readfile = readfile or function() return "" end
local writefile = writefile or function() end
local makefolder = makefolder or function() end
local isfolder = isfolder or function() return false end
local listfiles = listfiles or function() return {} end
local setclipboard = setclipboard or function() end
local getclipboard = getclipboard or function() return "" end
local getexecutorname = getexecutorname or identifyexecutor or function() return "Unknown" end

-- ============================================
-- UTILITY FUNCTIONS
-- ============================================
local Utility = {}

function Utility.DeepCopy(original)
    local copy = {}
    for k, v in pairs(original) do
        if type(v) == "table" then v = Utility.DeepCopy(v) end
        copy[k] = v
    end
    return copy
end

function Utility.Round(num, decimals)
    decimals = decimals or 0
    local mult = 10 ^ decimals
    return math.floor(num * mult + 0.5) / mult
end

function Utility.IsMouseInput(input, includeM2)
    includeM2 = includeM2 or false
    return input.UserInputType == Enum.UserInputType.MouseButton1
        or (includeM2 and input.UserInputType == Enum.UserInputType.MouseButton2)
        or input.UserInputType == Enum.UserInputType.Touch
end

function Utility.IsClickInput(input, includeM2)
    return Utility.IsMouseInput(input, includeM2)
        and input.UserInputState == Enum.UserInputState.Begin
end

function Utility.IsHoverInput(input)
    return (input.UserInputType == Enum.UserInputType.MouseMovement 
        or input.UserInputType == Enum.UserInputType.Touch)
        and input.UserInputState == Enum.UserInputState.Change
end

function Utility.IsDragInput(input, includeM2)
    return Utility.IsMouseInput(input, includeM2)
        and (input.UserInputState == Enum.UserInputState.Begin 
        or input.UserInputState == Enum.UserInputState.Change)
end

function Utility.GetTextBounds(text, font, size, width)
    local params = Instance.new("GetTextBoundsParams")
    params.Text = text or ""
    params.RichText = true
    params.Font = font or Font.new("rbxasset://fonts/families/GothamSSm.json")
    params.Size = size or 14
    params.Width = width or Camera.ViewportSize.X - 32
    local bounds = TextService:GetTextBoundsAsync(params)
    return bounds.X, bounds.Y
end

function Utility.GetTableSize(tbl)
    local size = 0
    for _ in pairs(tbl) do size = size + 1 end
    return size
end

function Utility.StopTween(tween)
    if tween and tween.PlaybackState == Enum.PlaybackState.Playing then
        tween:Cancel()
    end
end

function Utility.Trim(text)
    return (text or ""):match("^%s*(.-)%s*$")
end

function Utility.GetPlayers(excludeLocalPlayer)
    local playerList = Players:GetPlayers()
    if excludeLocalPlayer then
        local idx = table.find(playerList, LocalPlayer)
        if idx then table.remove(playerList, idx) end
    end
    table.sort(playerList, function(a, b) return a.Name:lower() < b.Name:lower() end)
    return playerList
end

function Utility.GetTeams()
    local teamList = Teams:GetTeams()
    table.sort(teamList, function(a, b) return a.Name:lower() < b.Name:lower() end)
    return teamList
end

function Utility.MouseIsOverFrame(frame, mousePos)
    if not frame then return false end
    local pos = frame.AbsolutePosition
    local size = frame.AbsoluteSize
    return mousePos.X >= pos.X
        and mousePos.X <= pos.X + size.X
        and mousePos.Y >= pos.Y
        and mousePos.Y <= pos.Y + size.Y
end

-- ============================================
-- FLIPPER ANIMATION LIBRARY (from Fluent)
-- ============================================
local Flipper = {}

local Signal = {}
Signal.__index = Signal

function Signal.new()
    return setmetatable({
        _connections = {},
        _threads = {}
    }, Signal)
end

function Signal:fire(...)
    for _, conn in pairs(self._connections) do
        conn._handler(...)
    end
    for _, thread in pairs(self._threads) do
        coroutine.resume(thread, ...)
    end
    self._threads = {}
end

function Signal:connect(handler)
    local connection = {
        signal = self,
        connected = true,
        _handler = handler
    }
    table.insert(self._connections, connection)
    return connection
end

function Signal:wait()
    table.insert(self._threads, coroutine.running())
    return coroutine.yield()
end

local Connection = {}
Connection.__index = Connection

function Connection.new(signal, handler)
    return setmetatable({
        signal = signal,
        connected = true,
        _handler = handler
    }, Connection)
end

function Connection:disconnect()
    if self.connected then
        self.connected = false
        for idx, conn in pairs(self.signal._connections) do
            if conn == self then
                table.remove(self.signal._connections, idx)
                return
            end
        end
    end
end

local BaseMotor = {}
BaseMotor.__index = BaseMotor

function BaseMotor.new()
    return setmetatable({
        _onStep = Signal.new(),
        _onStart = Signal.new(),
        _onComplete = Signal.new()
    }, BaseMotor)
end

function BaseMotor:onStep(callback)
    return self._onStep:connect(callback)
end

function BaseMotor:onStart(callback)
    return self._onStart:connect(callback)
end

function BaseMotor:onComplete(callback)
    return self._onComplete:connect(callback)
end

function BaseMotor:start()
    if not self._connection then
        self._connection = RunService.RenderStepped:Connect(function(dt)
            self:step(dt)
        end)
    end
end

function BaseMotor:stop()
    if self._connection then
        self._connection:Disconnect()
        self._connection = nil
    end
end

BaseMotor.destroy = BaseMotor.stop
BaseMotor.step = function() end
BaseMotor.getValue = function() return nil end
BaseMotor.setGoal = function() end

local SingleMotor = setmetatable({}, BaseMotor)
SingleMotor.__index = SingleMotor

function SingleMotor.new(initialValue, useImplicitConnections)
    local self = setmetatable(BaseMotor.new(), SingleMotor)
    self._useImplicitConnections = useImplicitConnections ~= false
    self._goal = nil
    self._state = {
        complete = true,
        value = initialValue,
        velocity = 0
    }
    return self
end

function SingleMotor:step(dt)
    if self._state.complete then
        return true
    end
    local newState = self._goal:step(self._state, dt)
    self._state = newState
    self._onStep:fire(newState.value)
    if newState.complete then
        if self._useImplicitConnections then
            self:stop()
        end
        self._onComplete:fire()
    end
    return newState.complete
end

function SingleMotor:getValue()
    return self._state.value
end

function SingleMotor:setGoal(goal)
    self._state.complete = false
    self._goal = goal
    self._onStart:fire()
    if self._useImplicitConnections then
        self:start()
    end
end

local GroupMotor = setmetatable({}, BaseMotor)
GroupMotor.__index = GroupMotor

function GroupMotor.new(initialValues, useImplicitConnections)
    local self = setmetatable(BaseMotor.new(), GroupMotor)
    self._useImplicitConnections = useImplicitConnections ~= false
    self._complete = true
    self._motors = {}
    for key, value in pairs(initialValues) do
        self._motors[key] = SingleMotor.new(value, false)
    end
    return self
end

function GroupMotor:step(dt)
    if self._complete then
        return true
    end
    local allComplete = true
    for _, motor in pairs(self._motors) do
        if not motor:step(dt) then
            allComplete = false
        end
    end
    self._onStep:fire(self:getValue())
    if allComplete then
        if self._useImplicitConnections then
            self:stop()
        end
        self._complete = true
        self._onComplete:fire()
    end
    return allComplete
end

function GroupMotor:setGoal(goals)
    self._complete = false
    self._onStart:fire()
    for key, goal in pairs(goals) do
        local motor = self._motors[key]
        if motor then
            motor:setGoal(goal)
        end
    end
    if self._useImplicitConnections then
        self:start()
    end
end

function GroupMotor:getValue()
    local values = {}
    for key, motor in pairs(self._motors) do
        values[key] = motor:getValue()
    end
    return values
end

local Instant = {}
Instant.__index = Instant

function Instant.new(targetValue)
    return setmetatable({
        _targetValue = targetValue
    }, Instant)
end

function Instant:step(state, dt)
    return {
        complete = true,
        value = self._targetValue,
        velocity = 0
    }
end

local Linear = {}
Linear.__index = Linear

function Linear.new(targetValue, options)
    options = options or {}
    return setmetatable({
        _targetValue = targetValue,
        _velocity = options.velocity or 1
    }, Linear)
end

function Linear:step(state, dt)
    local currentValue = state.value
    local velocity = self._velocity
    local target = self._targetValue
    local step = dt * velocity
    local complete = step >= math.abs(target - currentValue)
    
    if complete then
        return {
            complete = true,
            value = target,
            velocity = 0
        }
    end
    
    currentValue = currentValue + step * (target > currentValue and 1 or -1)
    return {
        complete = false,
        value = currentValue,
        velocity = velocity
    }
end

local Spring = {}
Spring.__index = Spring

function Spring.new(targetValue, options)
    options = options or {}
    return setmetatable({
        _targetValue = targetValue,
        _frequency = options.frequency or 4,
        _dampingRatio = options.dampingRatio or 1
    }, Spring)
end

function Spring:step(state, dt)
    local damping = self._dampingRatio
    local angularFrequency = self._frequency * 2 * math.pi
    local target = self._targetValue
    local currentValue = state.value
    local currentVelocity = state.velocity or 0
    local diff = target - currentValue
    local decay = math.exp(-damping * angularFrequency * dt)
    local newValue, newVelocity
    
    if damping == 1 then
        newValue = (diff * (1 + angularFrequency * dt) + currentVelocity * dt) * decay + target
        newVelocity = (currentVelocity * (1 - angularFrequency * dt) - diff * (angularFrequency * angularFrequency * dt)) * decay
    elseif damping < 1 then
        local dampedFreq = angularFrequency * math.sqrt(1 - damping * damping)
        local cos = math.cos(dampedFreq * dt)
        local sin = math.sin(dampedFreq * dt)
        local dampTerm = damping * angularFrequency
        newValue = (diff * (cos + dampTerm * sin / dampedFreq) + currentVelocity * sin / dampedFreq) * decay + target
        newVelocity = (currentVelocity * (cos - dampTerm * sin / dampedFreq) - diff * angularFrequency * sin / dampedFreq) * decay
    else
        local root1 = -angularFrequency * (damping - math.sqrt(damping * damping - 1))
        local root2 = -angularFrequency * (damping + math.sqrt(damping * damping - 1))
        local c1 = (currentVelocity - diff * root2) / (root1 - root2)
        local c2 = diff - c1
        newValue = c1 * math.exp(root1 * dt) + c2 * math.exp(root2 * dt) + target
        newVelocity = c1 * root1 * math.exp(root1 * dt) + c2 * root2 * math.exp(root2 * dt)
    end
    
    local complete = math.abs(newVelocity) < 0.001 and math.abs(newValue - target) < 0.001
    return {
        complete = complete,
        value = complete and target or newValue,
        velocity = complete and 0 or newVelocity
    }
end

local function isMotor(motor)
    local mt = tostring(motor):match("^Motor%((.+)%)$")
    if mt then
        return true, mt
    end
    return false
end

Flipper.Signal = Signal
Flipper.SingleMotor = SingleMotor
Flipper.GroupMotor = GroupMotor
Flipper.Instant = Instant
Flipper.Linear = Linear
Flipper.Spring = Spring
Flipper.isMotor = isMotor

-- ============================================
-- CREATOR / THEME SYSTEM (from Fluent)
-- ============================================
local Creator = {}
Creator.Registry = {}
Creator.Signals = {}
Creator.TransparencyMotors = {}
Creator.DefaultProperties = {
    ScreenGui = {
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    },
    Frame = {
        BackgroundColor3 = Color3.new(1, 1, 1),
        BorderColor3 = Color3.new(0, 0, 0),
        BorderSizePixel = 0
    },
    ScrollingFrame = {
        BackgroundColor3 = Color3.new(1, 1, 1),
        BorderColor3 = Color3.new(0, 0, 0),
        ScrollBarImageColor3 = Color3.new(0, 0, 0)
    },
    TextLabel = {
        BackgroundColor3 = Color3.new(1, 1, 1),
        BorderColor3 = Color3.new(0, 0, 0),
        Font = Enum.Font.SourceSans,
        Text = "",
        TextColor3 = Color3.new(0, 0, 0),
        BackgroundTransparency = 1,
        TextSize = 14
    },
    TextButton = {
        BackgroundColor3 = Color3.new(1, 1, 1),
        BorderColor3 = Color3.new(0, 0, 0),
        AutoButtonColor = false,
        Font = Enum.Font.SourceSans,
        Text = "",
        TextColor3 = Color3.new(0, 0, 0),
        TextSize = 14
    },
    TextBox = {
        BackgroundColor3 = Color3.new(1, 1, 1),
        BorderColor3 = Color3.new(0, 0, 0),
        ClearTextOnFocus = false,
        Font = Enum.Font.SourceSans,
        Text = "",
        TextColor3 = Color3.new(0, 0, 0),
        TextSize = 14
    },
    ImageLabel = {
        BackgroundTransparency = 1,
        BackgroundColor3 = Color3.new(1, 1, 1),
        BorderColor3 = Color3.new(0, 0, 0),
        BorderSizePixel = 0
    },
    ImageButton = {
        BackgroundColor3 = Color3.new(1, 1, 1),
        BorderColor3 = Color3.new(0, 0, 0),
        AutoButtonColor = false
    },
    CanvasGroup = {
        BackgroundColor3 = Color3.new(1, 1, 1),
        BorderColor3 = Color3.new(0, 0, 0),
        BorderSizePixel = 0
    },
    UIListLayout = {
        SortOrder = Enum.SortOrder.LayoutOrder
    },
    UIStroke = {
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    },
    UICorner = {},
    UIPadding = {},
    UIScale = {},
    UIGradient = {},
    UISizeConstraint = {}
}

function Creator.AddSignal(connection)
    if connection then
        table.insert(Creator.Signals, connection)
    end
end

function Creator.Disconnect()
    for i = #Creator.Signals, 1, -1 do
        local conn = table.remove(Creator.Signals, i)
        pcall(function() conn:Disconnect() end)
    end
end

function Creator.GetThemeProperty(name)
    if not name then return nil end
    local themeName = Silence and Silence.Theme
    if not themeName then return nil end
    local theme = Themes[themeName]
    if not theme then return nil end
    if theme[name] ~= nil then return theme[name] end
    return nil
end

function Creator.UpdateTheme()
    for instance, data in pairs(Creator.Registry) do
        for prop, tag in pairs(data.Properties) do
            local value = Creator.GetThemeProperty(tag)
            if value ~= nil then
                pcall(function() instance[prop] = value end)
            end
        end
    end
    local transparencyValue = Creator.GetThemeProperty("ElementTransparency") or 0.87
    for _, motor in pairs(Creator.TransparencyMotors) do
        motor:setGoal(Flipper.Instant.new(transparencyValue))
    end
end

function Creator.AddThemeObject(instance, properties)
    if not instance or not properties then return instance end
    Creator.Registry[instance] = {
        Object = instance,
        Properties = properties
    }
    Creator.UpdateTheme()
    return instance
end

function Creator.OverrideTag(instance, properties)
    if Creator.Registry[instance] then
        Creator.Registry[instance].Properties = properties
        Creator.UpdateTheme()
    end
end

function Creator.New(className, properties, children)
    local instance = Instance.new(className)
    
    local defaults = Creator.DefaultProperties[className] or {}
    for prop, value in pairs(defaults) do
        pcall(function() instance[prop] = value end)
    end
    
    if properties then
        for prop, value in pairs(properties) do
            if prop ~= "ThemeTag" then
                pcall(function() instance[prop] = value end)
            end
        end
    end
    
    if children then
        for _, child in ipairs(children) do
            child.Parent = instance
        end
    end
    
    if properties and properties.ThemeTag then
        Creator.AddThemeObject(instance, properties.ThemeTag)
    end
    
    if properties and properties.Parent and not properties.ZIndex then
        pcall(function() 
            instance.ZIndex = properties.Parent.ZIndex 
        end)
    end
    
    return instance
end

function Creator.SpringMotor(initialValue, instance, property, allowDuringDialog, isTransparencyMotor)
    local motor = Flipper.SingleMotor.new(initialValue)
    motor:onStep(function(value)
        pcall(function() instance[property] = value end)
    end)
    
    if isTransparencyMotor then
        table.insert(Creator.TransparencyMotors, motor)
    end
    
    local setGoal = function(goal, force)
        if not allowDuringDialog and not force then
            if Silence and Silence.DialogOpen and property == "BackgroundTransparency" then
                return
            end
        end
        motor:setGoal(Flipper.Spring.new(goal, {frequency = 8}))
    end
    
    return motor, setGoal
end

-- ============================================
-- THEMES DATABASE (90+ themes from Fluent modded)
-- ============================================
local Themes = {}

-- Base themes from Fluent
Themes["Dark"] = {
    Name = "Dark",
    Accent = Color3.fromRGB(100, 130, 255),
    AcrylicMain = Color3.fromRGB(20, 20, 30),
    AcrylicBorder = Color3.fromRGB(70, 70, 90),
    AcrylicGradient = Color3.fromRGB(30, 30, 45),
    AcrylicNoise = 0.92,
    TitleBarLine = Color3.fromRGB(60, 60, 75),
    Tab = Color3.fromRGB(100, 130, 255),
    Element = Color3.fromRGB(35, 35, 48),
    ElementBorder = Color3.fromRGB(25, 25, 35),
    InElementBorder = Color3.fromRGB(55, 55, 70),
    ElementTransparency = 0.87,
    ToggleSlider = Color3.fromRGB(60, 60, 80),
    ToggleToggled = Color3.fromRGB(255, 255, 255),
    SliderRail = Color3.fromRGB(40, 40, 55),
    DropdownFrame = Color3.fromRGB(100, 130, 255),
    DropdownHolder = Color3.fromRGB(20, 20, 28),
    DropdownBorder = Color3.fromRGB(25, 25, 35),
    DropdownOption = Color3.fromRGB(100, 130, 255),
    Keybind = Color3.fromRGB(35, 35, 48),
    Input = Color3.fromRGB(25, 25, 35),
    InputFocused = Color3.fromRGB(15, 15, 22),
    InputIndicator = Color3.fromRGB(100, 130, 255),
    Dialog = Color3.fromRGB(20, 20, 28),
    DialogHolder = Color3.fromRGB(15, 15, 20),
    DialogHolderLine = Color3.fromRGB(10, 10, 15),
    DialogButton = Color3.fromRGB(20, 20, 28),
    DialogButtonBorder = Color3.fromRGB(55, 55, 70),
    DialogBorder = Color3.fromRGB(40, 40, 55),
    DialogInput = Color3.fromRGB(30, 30, 40),
    DialogInputLine = Color3.fromRGB(100, 130, 255),
    Text = Color3.fromRGB(240, 240, 250),
    SubText = Color3.fromRGB(170, 170, 185),
    Hover = Color3.fromRGB(100, 130, 255),
    HoverChange = 0.05,
    ButtonGradient = {
        Background = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(7, 42, 82)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(12, 76, 142)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(21, 97, 181))
        }),
        Stroke = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(40, 120, 200)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 40, 80))
        })
    }
}

Themes["Light"] = {
    Name = "Light",
    Accent = Color3.fromRGB(80, 120, 240),
    AcrylicMain = Color3.fromRGB(240, 240, 245),
    AcrylicBorder = Color3.fromRGB(200, 200, 210),
    AcrylicGradient = Color3.fromRGB(255, 255, 255),
    AcrylicNoise = 0.95,
    TitleBarLine = Color3.fromRGB(210, 210, 215),
    Tab = Color3.fromRGB(80, 120, 240),
    Element = Color3.fromRGB(220, 220, 225),
    ElementBorder = Color3.fromRGB(180, 180, 190),
    InElementBorder = Color3.fromRGB(200, 200, 210),
    ElementTransparency = 0.70,
    ToggleSlider = Color3.fromRGB(180, 180, 190),
    ToggleToggled = Color3.fromRGB(255, 255, 255),
    SliderRail = Color3.fromRGB(200, 200, 210),
    DropdownFrame = Color3.fromRGB(80, 120, 240),
    DropdownHolder = Color3.fromRGB(245, 245, 248),
    DropdownBorder = Color3.fromRGB(180, 180, 190),
    DropdownOption = Color3.fromRGB(80, 120, 240),
    Keybind = Color3.fromRGB(220, 220, 225),
    Input = Color3.fromRGB(230, 230, 235),
    InputFocused = Color3.fromRGB(255, 255, 255),
    InputIndicator = Color3.fromRGB(80, 120, 240),
    Dialog = Color3.fromRGB(245, 245, 248),
    DialogHolder = Color3.fromRGB(238, 238, 242),
    DialogHolderLine = Color3.fromRGB(220, 220, 225),
    DialogButton = Color3.fromRGB(245, 245, 248),
    DialogButtonBorder = Color3.fromRGB(200, 200, 210),
    DialogBorder = Color3.fromRGB(200, 200, 210),
    DialogInput = Color3.fromRGB(240, 240, 245),
    DialogInputLine = Color3.fromRGB(80, 120, 240),
    Text = Color3.fromRGB(20, 20, 30),
    SubText = Color3.fromRGB(100, 100, 115),
    Hover = Color3.fromRGB(80, 120, 240),
    HoverChange = 0.04
}

Themes["Midnight"] = {
    Name = "Midnight",
    Accent = Color3.fromRGB(80, 80, 200),
    AcrylicMain = Color3.fromRGB(10, 10, 25),
    AcrylicBorder = Color3.fromRGB(60, 60, 120),
    AcrylicGradient = Color3.fromRGB(15, 15, 40),
    AcrylicNoise = 0.90,
    TitleBarLine = Color3.fromRGB(50, 50, 100),
    Tab = Color3.fromRGB(80, 80, 200),
    Element = Color3.fromRGB(20, 20, 45),
    ElementBorder = Color3.fromRGB(15, 15, 30),
    InElementBorder = Color3.fromRGB(50, 50, 100),
    ElementTransparency = 0.85,
    ToggleSlider = Color3.fromRGB(40, 40, 80),
    ToggleToggled = Color3.fromRGB(200, 200, 255),
    SliderRail = Color3.fromRGB(30, 30, 60),
    DropdownFrame = Color3.fromRGB(80, 80, 200),
    DropdownHolder = Color3.fromRGB(10, 10, 25),
    DropdownBorder = Color3.fromRGB(20, 20, 40),
    DropdownOption = Color3.fromRGB(80, 80, 200),
    Keybind = Color3.fromRGB(20, 20, 45),
    Input = Color3.fromRGB(15, 15, 35),
    InputFocused = Color3.fromRGB(8, 8, 20),
    InputIndicator = Color3.fromRGB(100, 100, 220),
    Dialog = Color3.fromRGB(10, 10, 25),
    DialogHolder = Color3.fromRGB(8, 8, 18),
    DialogHolderLine = Color3.fromRGB(5, 5, 12),
    DialogButton = Color3.fromRGB(12, 12, 28),
    DialogButtonBorder = Color3.fromRGB(50, 50, 100),
    DialogBorder = Color3.fromRGB(30, 30, 60),
    DialogInput = Color3.fromRGB(18, 18, 38),
    DialogInputLine = Color3.fromRGB(100, 100, 220),
    Text = Color3.fromRGB(220, 220, 255),
    SubText = Color3.fromRGB(150, 150, 200),
    Hover = Color3.fromRGB(80, 80, 200),
    HoverChange = 0.05
}

Themes["Blood Red"] = {
    Name = "Blood Red",
    Accent = Color3.fromRGB(180, 10, 20),
    AcrylicMain = Color3.fromRGB(35, 8, 10),
    AcrylicBorder = Color3.fromRGB(140, 15, 25),
    AcrylicGradient = Color3.fromRGB(130, 12, 20),
    AcrylicNoise = 0.90,
    TitleBarLine = Color3.fromRGB(155, 18, 28),
    Tab = Color3.fromRGB(180, 10, 20),
    Element = Color3.fromRGB(130, 12, 22),
    ElementBorder = Color3.fromRGB(85, 8, 14),
    InElementBorder = Color3.fromRGB(150, 18, 28),
    ElementTransparency = 0.90,
    ToggleSlider = Color3.fromRGB(180, 10, 20),
    ToggleToggled = Color3.fromRGB(255, 230, 230),
    SliderRail = Color3.fromRGB(145, 15, 25),
    DropdownFrame = Color3.fromRGB(180, 10, 20),
    DropdownHolder = Color3.fromRGB(28, 5, 8),
    DropdownBorder = Color3.fromRGB(80, 7, 13),
    DropdownOption = Color3.fromRGB(180, 10, 20),
    Keybind = Color3.fromRGB(130, 12, 22),
    Input = Color3.fromRGB(115, 10, 18),
    InputFocused = Color3.fromRGB(18, 3, 5),
    InputIndicator = Color3.fromRGB(220, 50, 70),
    Dialog = Color3.fromRGB(28, 5, 8),
    DialogHolder = Color3.fromRGB(18, 3, 5),
    DialogHolderLine = Color3.fromRGB(12, 2, 3),
    DialogButton = Color3.fromRGB(28, 5, 8),
    DialogButtonBorder = Color3.fromRGB(145, 15, 25),
    DialogBorder = Color3.fromRGB(85, 8, 14),
    DialogInput = Color3.fromRGB(50, 10, 14),
    DialogInputLine = Color3.fromRGB(220, 50, 70),
    Text = Color3.fromRGB(255, 230, 230),
    SubText = Color3.fromRGB(210, 175, 178),
    Hover = Color3.fromRGB(180, 10, 20),
    HoverChange = 0.05
}

Themes["Neon"] = {
    Name = "Neon",
    Accent = Color3.fromRGB(0, 255, 200),
    AcrylicMain = Color3.fromRGB(5, 10, 18),
    AcrylicBorder = Color3.fromRGB(0, 200, 160),
    AcrylicGradient = Color3.fromRGB(0, 80, 60),
    AcrylicNoise = 0.92,
    TitleBarLine = Color3.fromRGB(0, 220, 175),
    Tab = Color3.fromRGB(0, 255, 200),
    Element = Color3.fromRGB(0, 160, 125),
    ElementBorder = Color3.fromRGB(0, 60, 45),
    InElementBorder = Color3.fromRGB(0, 200, 160),
    ElementTransparency = 0.88,
    ToggleSlider = Color3.fromRGB(0, 255, 200),
    ToggleToggled = Color3.fromRGB(5, 25, 30),
    SliderRail = Color3.fromRGB(0, 180, 140),
    DropdownFrame = Color3.fromRGB(0, 255, 200),
    DropdownHolder = Color3.fromRGB(5, 10, 18),
    DropdownBorder = Color3.fromRGB(0, 200, 160),
    DropdownOption = Color3.fromRGB(0, 255, 200),
    Keybind = Color3.fromRGB(0, 180, 140),
    Input = Color3.fromRGB(8, 15, 22),
    InputFocused = Color3.fromRGB(3, 5, 10),
    InputIndicator = Color3.fromRGB(0, 255, 200),
    Dialog = Color3.fromRGB(5, 10, 18),
    DialogHolder = Color3.fromRGB(3, 5, 10),
    DialogHolderLine = Color3.fromRGB(0, 200, 160),
    DialogButton = Color3.fromRGB(8, 15, 22),
    DialogButtonBorder = Color3.fromRGB(0, 200, 160),
    DialogBorder = Color3.fromRGB(0, 180, 140),
    DialogInput = Color3.fromRGB(12, 20, 28),
    DialogInputLine = Color3.fromRGB(0, 255, 200),
    Text = Color3.fromRGB(220, 255, 245),
    SubText = Color3.fromRGB(100, 220, 190),
    Hover = Color3.fromRGB(0, 255, 200),
    HoverChange = 0.05
}

Themes["Ocean"] = {
    Name = "Ocean",
    Accent = Color3.fromRGB(0, 150, 220),
    AcrylicMain = Color3.fromRGB(10, 25, 40),
    AcrylicBorder = Color3.fromRGB(0, 120, 180),
    AcrylicGradient = Color3.fromRGB(0, 80, 140),
    AcrylicNoise = 0.91,
    TitleBarLine = Color3.fromRGB(0, 130, 190),
    Tab = Color3.fromRGB(0, 150, 220),
    Element = Color3.fromRGB(0, 90, 140),
    ElementBorder = Color3.fromRGB(0, 60, 95),
    InElementBorder = Color3.fromRGB(0, 110, 165),
    ElementTransparency = 0.87,
    ToggleSlider = Color3.fromRGB(0, 150, 220),
    ToggleToggled = Color3.fromRGB(230, 250, 255),
    SliderRail = Color3.fromRGB(0, 100, 155),
    DropdownFrame = Color3.fromRGB(0, 150, 220),
    DropdownHolder = Color3.fromRGB(5, 18, 32),
    DropdownBorder = Color3.fromRGB(0, 90, 135),
    DropdownOption = Color3.fromRGB(0, 150, 220),
    Keybind = Color3.fromRGB(0, 90, 140),
    Input = Color3.fromRGB(6, 20, 35),
    InputFocused = Color3.fromRGB(2, 10, 18),
    InputIndicator = Color3.fromRGB(50, 190, 255),
    Dialog = Color3.fromRGB(5, 18, 32),
    DialogHolder = Color3.fromRGB(3, 10, 20),
    DialogHolderLine = Color3.fromRGB(0, 110, 165),
    DialogButton = Color3.fromRGB(8, 22, 38),
    DialogButtonBorder = Color3.fromRGB(0, 110, 165),
    DialogBorder = Color3.fromRGB(0, 90, 135),
    DialogInput = Color3.fromRGB(12, 28, 45),
    DialogInputLine = Color3.fromRGB(50, 190, 255),
    Text = Color3.fromRGB(220, 240, 255),
    SubText = Color3.fromRGB(150, 200, 230),
    Hover = Color3.fromRGB(0, 150, 220),
    HoverChange = 0.05
}

Themes["Galaxy"] = {
    Name = "Galaxy",
    Accent = Color3.fromRGB(160, 60, 220),
    AcrylicMain = Color3.fromRGB(12, 5, 25),
    AcrylicBorder = Color3.fromRGB(120, 40, 185),
    AcrylicGradient = Color3.fromRGB(40, 10, 80),
    AcrylicNoise = 0.93,
    TitleBarLine = Color3.fromRGB(130, 50, 195),
    Tab = Color3.fromRGB(160, 60, 220),
    Element = Color3.fromRGB(112, 40, 170),
    ElementBorder = Color3.fromRGB(75, 25, 115),
    InElementBorder = Color3.fromRGB(130, 50, 195),
    ElementTransparency = 0.88,
    ToggleSlider = Color3.fromRGB(160, 60, 220),
    ToggleToggled = Color3.fromRGB(20, 8, 40),
    SliderRail = Color3.fromRGB(125, 45, 190),
    DropdownFrame = Color3.fromRGB(160, 60, 220),
    DropdownHolder = Color3.fromRGB(8, 3, 20),
    DropdownBorder = Color3.fromRGB(100, 30, 160),
    DropdownOption = Color3.fromRGB(160, 60, 220),
    Keybind = Color3.fromRGB(112, 40, 170),
    Input = Color3.fromRGB(14, 6, 28),
    InputFocused = Color3.fromRGB(5, 2, 14),
    InputIndicator = Color3.fromRGB(195, 100, 255),
    Dialog = Color3.fromRGB(8, 3, 20),
    DialogHolder = Color3.fromRGB(5, 2, 14),
    DialogHolderLine = Color3.fromRGB(120, 40, 185),
    DialogButton = Color3.fromRGB(10, 4, 25),
    DialogButtonBorder = Color3.fromRGB(120, 40, 185),
    DialogBorder = Color3.fromRGB(100, 30, 160),
    DialogInput = Color3.fromRGB(18, 8, 38),
    DialogInputLine = Color3.fromRGB(195, 100, 255),
    Text = Color3.fromRGB(242, 232, 255),
    SubText = Color3.fromRGB(200, 178, 228),
    Hover = Color3.fromRGB(160, 60, 220),
    HoverChange = 0.05
}

Themes["Forest"] = {
    Name = "Forest",
    Accent = Color3.fromRGB(60, 180, 80),
    AcrylicMain = Color3.fromRGB(10, 30, 15),
    AcrylicBorder = Color3.fromRGB(40, 130, 55),
    AcrylicGradient = Color3.fromRGB(20, 80, 30),
    AcrylicNoise = 0.90,
    TitleBarLine = Color3.fromRGB(50, 150, 65),
    Tab = Color3.fromRGB(60, 180, 80),
    Element = Color3.fromRGB(35, 115, 45),
    ElementBorder = Color3.fromRGB(25, 75, 30),
    InElementBorder = Color3.fromRGB(50, 145, 60),
    ElementTransparency = 0.87,
    ToggleSlider = Color3.fromRGB(60, 180, 80),
    ToggleToggled = Color3.fromRGB(220, 255, 220),
    SliderRail = Color3.fromRGB(40, 130, 50),
    DropdownFrame = Color3.fromRGB(60, 180, 80),
    DropdownHolder = Color3.fromRGB(8, 22, 12),
    DropdownBorder = Color3.fromRGB(30, 90, 35),
    DropdownOption = Color3.fromRGB(60, 180, 80),
    Keybind = Color3.fromRGB(35, 115, 45),
    Input = Color3.fromRGB(8, 22, 12),
    InputFocused = Color3.fromRGB(5, 15, 8),
    InputIndicator = Color3.fromRGB(100, 220, 120),
    Dialog = Color3.fromRGB(8, 22, 12),
    DialogHolder = Color3.fromRGB(5, 15, 8),
    DialogHolderLine = Color3.fromRGB(40, 130, 55),
    DialogButton = Color3.fromRGB(12, 28, 16),
    DialogButtonBorder = Color3.fromRGB(40, 130, 55),
    DialogBorder = Color3.fromRGB(30, 90, 35),
    DialogInput = Color3.fromRGB(16, 35, 22),
    DialogInputLine = Color3.fromRGB(100, 220, 120),
    Text = Color3.fromRGB(220, 255, 225),
    SubText = Color3.fromRGB(160, 210, 170),
    Hover = Color3.fromRGB(60, 180, 80),
    HoverChange = 0.05
}

Themes["Sunset"] = {
    Name = "Sunset",
    Accent = Color3.fromRGB(255, 100, 80),
    AcrylicMain = Color3.fromRGB(35, 20, 25),
    AcrylicBorder = Color3.fromRGB(200, 70, 50),
    AcrylicGradient = Color3.fromRGB(180, 60, 45),
    AcrylicNoise = 0.90,
    TitleBarLine = Color3.fromRGB(220, 80, 60),
    Tab = Color3.fromRGB(255, 100, 80),
    Element = Color3.fromRGB(180, 62, 45),
    ElementBorder = Color3.fromRGB(120, 40, 30),
    InElementBorder = Color3.fromRGB(220, 80, 60),
    ElementTransparency = 0.87,
    ToggleSlider = Color3.fromRGB(255, 100, 80),
    ToggleToggled = Color3.fromRGB(255, 240, 235),
    SliderRail = Color3.fromRGB(200, 70, 50),
    DropdownFrame = Color3.fromRGB(255, 100, 80),
    DropdownHolder = Color3.fromRGB(30, 15, 20),
    DropdownBorder = Color3.fromRGB(160, 55, 40),
    DropdownOption = Color3.fromRGB(255, 100, 80),
    Keybind = Color3.fromRGB(180, 62, 45),
    Input = Color3.fromRGB(32, 16, 22),
    InputFocused = Color3.fromRGB(20, 8, 12),
    InputIndicator = Color3.fromRGB(255, 150, 130),
    Dialog = Color3.fromRGB(30, 15, 20),
    DialogHolder = Color3.fromRGB(20, 8, 12),
    DialogHolderLine = Color3.fromRGB(200, 70, 50),
    DialogButton = Color3.fromRGB(35, 18, 24),
    DialogButtonBorder = Color3.fromRGB(200, 70, 50),
    DialogBorder = Color3.fromRGB(160, 55, 40),
    DialogInput = Color3.fromRGB(42, 22, 28),
    DialogInputLine = Color3.fromRGB(255, 150, 130),
    Text = Color3.fromRGB(255, 240, 235),
    SubText = Color3.fromRGB(220, 195, 185),
    Hover = Color3.fromRGB(255, 100, 80),
    HoverChange = 0.05
}
Themes["Cyberpunk"] = {
    Name = "Cyberpunk",
    Accent = Color3.fromRGB(255, 0, 150),
    AcrylicMain = Color3.fromRGB(15, 5, 25),
    AcrylicBorder = Color3.fromRGB(200, 0, 120),
    AcrylicGradient = Color3.fromRGB(60, 0, 40),
    AcrylicNoise = 0.90,
    TitleBarLine = Color3.fromRGB(220, 10, 130),
    Tab = Color3.fromRGB(255, 0, 150),
    Element = Color3.fromRGB(180, 0, 108),
    ElementBorder = Color3.fromRGB(80, 0, 50),
    InElementBorder = Color3.fromRGB(220, 10, 130),
    ElementTransparency = 0.88,
    ToggleSlider = Color3.fromRGB(255, 0, 150),
    ToggleToggled = Color3.fromRGB(30, 5, 45),
    SliderRail = Color3.fromRGB(200, 0, 120),
    DropdownFrame = Color3.fromRGB(255, 0, 150),
    DropdownHolder = Color3.fromRGB(10, 0, 15),
    DropdownBorder = Color3.fromRGB(180, 0, 108),
    DropdownOption = Color3.fromRGB(255, 0, 150),
    Keybind = Color3.fromRGB(180, 0, 108),
    Input = Color3.fromRGB(18, 4, 30),
    InputFocused = Color3.fromRGB(8, 0, 12),
    InputIndicator = Color3.fromRGB(255, 50, 180),
    Dialog = Color3.fromRGB(10, 0, 15),
    DialogHolder = Color3.fromRGB(6, 0, 10),
    DialogHolderLine = Color3.fromRGB(200, 0, 120),
    DialogButton = Color3.fromRGB(12, 2, 20),
    DialogButtonBorder = Color3.fromRGB(200, 0, 120),
    DialogBorder = Color3.fromRGB(180, 0, 108),
    DialogInput = Color3.fromRGB(22, 6, 35),
    DialogInputLine = Color3.fromRGB(255, 50, 180),
    Text = Color3.fromRGB(255, 220, 240),
    SubText = Color3.fromRGB(220, 150, 200),
    Hover = Color3.fromRGB(255, 0, 150),
    HoverChange = 0.05
}

Themes["Emerald"] = {
    Name = "Emerald",
    Accent = Color3.fromRGB(80, 200, 120),
    AcrylicMain = Color3.fromRGB(10, 30, 20),
    AcrylicBorder = Color3.fromRGB(55, 160, 90),
    AcrylicGradient = Color3.fromRGB(40, 140, 80),
    AcrylicNoise = 0.90,
    TitleBarLine = Color3.fromRGB(65, 180, 100),
    Tab = Color3.fromRGB(80, 200, 120),
    Element = Color3.fromRGB(48, 140, 78),
    ElementBorder = Color3.fromRGB(30, 90, 50),
    InElementBorder = Color3.fromRGB(65, 180, 100),
    ElementTransparency = 0.87,
    ToggleSlider = Color3.fromRGB(80, 200, 120),
    ToggleToggled = Color3.fromRGB(220, 255, 230),
    SliderRail = Color3.fromRGB(55, 160, 90),
    DropdownFrame = Color3.fromRGB(80, 200, 120),
    DropdownHolder = Color3.fromRGB(5, 22, 12),
    DropdownBorder = Color3.fromRGB(40, 120, 68),
    DropdownOption = Color3.fromRGB(80, 200, 120),
    Keybind = Color3.fromRGB(48, 140, 78),
    Input = Color3.fromRGB(6, 25, 14),
    InputFocused = Color3.fromRGB(3, 15, 8),
    InputIndicator = Color3.fromRGB(130, 240, 170),
    Dialog = Color3.fromRGB(5, 22, 12),
    DialogHolder = Color3.fromRGB(3, 15, 8),
    DialogHolderLine = Color3.fromRGB(55, 160, 90),
    DialogButton = Color3.fromRGB(8, 28, 16),
    DialogButtonBorder = Color3.fromRGB(55, 160, 90),
    DialogBorder = Color3.fromRGB(40, 120, 68),
    DialogInput = Color3.fromRGB(12, 35, 22),
    DialogInputLine = Color3.fromRGB(130, 240, 170),
    Text = Color3.fromRGB(230, 255, 240),
    SubText = Color3.fromRGB(170, 220, 190),
    Hover = Color3.fromRGB(80, 200, 120),
    HoverChange = 0.05
}

Themes["Ruby"] = {
    Name = "Ruby",
    Accent = Color3.fromRGB(224, 17, 95),
    AcrylicMain = Color3.fromRGB(40, 10, 20),
    AcrylicBorder = Color3.fromRGB(190, 12, 80),
    AcrylicGradient = Color3.fromRGB(170, 10, 70),
    AcrylicNoise = 0.90,
    TitleBarLine = Color3.fromRGB(200, 14, 85),
    Tab = Color3.fromRGB(224, 17, 95),
    Element = Color3.fromRGB(160, 10, 65),
    ElementBorder = Color3.fromRGB(110, 7, 45),
    InElementBorder = Color3.fromRGB(185, 13, 80),
    ElementTransparency = 0.87,
    ToggleSlider = Color3.fromRGB(224, 17, 95),
    ToggleToggled = Color3.fromRGB(255, 230, 240),
    SliderRail = Color3.fromRGB(180, 12, 75),
    DropdownFrame = Color3.fromRGB(224, 17, 95),
    DropdownHolder = Color3.fromRGB(30, 5, 15),
    DropdownBorder = Color3.fromRGB(105, 7, 45),
    DropdownOption = Color3.fromRGB(224, 17, 95),
    Keybind = Color3.fromRGB(160, 10, 65),
    Input = Color3.fromRGB(145, 9, 60),
    InputFocused = Color3.fromRGB(22, 3, 10),
    InputIndicator = Color3.fromRGB(255, 60, 130),
    Dialog = Color3.fromRGB(30, 5, 15),
    DialogHolder = Color3.fromRGB(20, 3, 10),
    DialogHolderLine = Color3.fromRGB(180, 12, 75),
    DialogButton = Color3.fromRGB(35, 7, 18),
    DialogButtonBorder = Color3.fromRGB(180, 12, 75),
    DialogBorder = Color3.fromRGB(110, 7, 45),
    DialogInput = Color3.fromRGB(50, 10, 25),
    DialogInputLine = Color3.fromRGB(255, 60, 130),
    Text = Color3.fromRGB(255, 235, 245),
    SubText = Color3.fromRGB(220, 180, 200),
    Hover = Color3.fromRGB(224, 17, 95),
    HoverChange = 0.05
}

Themes["Sapphire"] = {
    Name = "Sapphire",
    Accent = Color3.fromRGB(50, 100, 240),
    AcrylicMain = Color3.fromRGB(10, 15, 40),
    AcrylicBorder = Color3.fromRGB(35, 75, 200),
    AcrylicGradient = Color3.fromRGB(30, 60, 180),
    AcrylicNoise = 0.90,
    TitleBarLine = Color3.fromRGB(40, 85, 210),
    Tab = Color3.fromRGB(50, 100, 240),
    Element = Color3.fromRGB(30, 70, 170),
    ElementBorder = Color3.fromRGB(20, 45, 110),
    InElementBorder = Color3.fromRGB(40, 85, 210),
    ElementTransparency = 0.87,
    ToggleSlider = Color3.fromRGB(50, 100, 240),
    ToggleToggled = Color3.fromRGB(210, 220, 255),
    SliderRail = Color3.fromRGB(35, 75, 190),
    DropdownFrame = Color3.fromRGB(50, 100, 240),
    DropdownHolder = Color3.fromRGB(8, 12, 30),
    DropdownBorder = Color3.fromRGB(25, 55, 130),
    DropdownOption = Color3.fromRGB(50, 100, 240),
    Keybind = Color3.fromRGB(30, 70, 170),
    Input = Color3.fromRGB(12, 20, 50),
    InputFocused = Color3.fromRGB(6, 10, 28),
    InputIndicator = Color3.fromRGB(80, 130, 255),
    Dialog = Color3.fromRGB(8, 12, 30),
    DialogHolder = Color3.fromRGB(5, 8, 20),
    DialogHolderLine = Color3.fromRGB(35, 75, 200),
    DialogButton = Color3.fromRGB(10, 16, 35),
    DialogButtonBorder = Color3.fromRGB(35, 75, 200),
    DialogBorder = Color3.fromRGB(25, 55, 130),
    DialogInput = Color3.fromRGB(16, 25, 55),
    DialogInputLine = Color3.fromRGB(80, 130, 255),
    Text = Color3.fromRGB(220, 230, 255),
    SubText = Color3.fromRGB(170, 185, 225),
    Hover = Color3.fromRGB(50, 100, 240),
    HoverChange = 0.05
}

Themes["Amber"] = {
    Name = "Amber",
    Accent = Color3.fromRGB(255, 180, 80),
    AcrylicMain = Color3.fromRGB(40, 30, 15),
    AcrylicBorder = Color3.fromRGB(220, 150, 55),
    AcrylicGradient = Color3.fromRGB(200, 135, 50),
    AcrylicNoise = 0.90,
    TitleBarLine = Color3.fromRGB(235, 160, 65),
    Tab = Color3.fromRGB(255, 180, 80),
    Element = Color3.fromRGB(180, 125, 50),
    ElementBorder = Color3.fromRGB(130, 90, 35),
    InElementBorder = Color3.fromRGB(215, 150, 60),
    ElementTransparency = 0.87,
    ToggleSlider = Color3.fromRGB(255, 180, 80),
    ToggleToggled = Color3.fromRGB(0, 0, 0),
    SliderRail = Color3.fromRGB(200, 140, 55),
    DropdownFrame = Color3.fromRGB(255, 180, 80),
    DropdownHolder = Color3.fromRGB(35, 25, 15),
    DropdownBorder = Color3.fromRGB(120, 85, 30),
    DropdownOption = Color3.fromRGB(255, 180, 80),
    Keybind = Color3.fromRGB(180, 125, 50),
    Input = Color3.fromRGB(165, 115, 45),
    InputFocused = Color3.fromRGB(25, 18, 10),
    InputIndicator = Color3.fromRGB(255, 210, 130),
    Dialog = Color3.fromRGB(35, 25, 15),
    DialogHolder = Color3.fromRGB(25, 18, 10),
    DialogHolderLine = Color3.fromRGB(200, 140, 55),
    DialogButton = Color3.fromRGB(40, 30, 18),
    DialogButtonBorder = Color3.fromRGB(200, 140, 55),
    DialogBorder = Color3.fromRGB(130, 90, 35),
    DialogInput = Color3.fromRGB(55, 40, 22),
    DialogInputLine = Color3.fromRGB(255, 210, 130),
    Text = Color3.fromRGB(255, 248, 235),
    SubText = Color3.fromRGB(220, 200, 180),
    Hover = Color3.fromRGB(255, 180, 80),
    HoverChange = 0.05
}

Themes["Rose Gold"] = {
    Name = "Rose Gold",
    Accent = Color3.fromRGB(230, 140, 150),
    AcrylicMain = Color3.fromRGB(40, 25, 30),
    AcrylicBorder = Color3.fromRGB(190, 110, 120),
    AcrylicGradient = Color3.fromRGB(170, 100, 110),
    AcrylicNoise = 0.91,
    TitleBarLine = Color3.fromRGB(200, 120, 130),
    Tab = Color3.fromRGB(230, 140, 150),
    Element = Color3.fromRGB(170, 100, 108),
    ElementBorder = Color3.fromRGB(110, 65, 72),
    InElementBorder = Color3.fromRGB(200, 120, 130),
    ElementTransparency = 0.87,
    ToggleSlider = Color3.fromRGB(230, 140, 150),
    ToggleToggled = Color3.fromRGB(255, 235, 240),
    SliderRail = Color3.fromRGB(190, 110, 120),
    DropdownFrame = Color3.fromRGB(230, 140, 150),
    DropdownHolder = Color3.fromRGB(30, 18, 22),
    DropdownBorder = Color3.fromRGB(160, 90, 100),
    DropdownOption = Color3.fromRGB(230, 140, 150),
    Keybind = Color3.fromRGB(170, 100, 108),
    Input = Color3.fromRGB(35, 20, 25),
    InputFocused = Color3.fromRGB(22, 12, 16),
    InputIndicator = Color3.fromRGB(255, 180, 190),
    Dialog = Color3.fromRGB(30, 18, 22),
    DialogHolder = Color3.fromRGB(20, 12, 15),
    DialogHolderLine = Color3.fromRGB(190, 110, 120),
    DialogButton = Color3.fromRGB(35, 22, 26),
    DialogButtonBorder = Color3.fromRGB(190, 110, 120),
    DialogBorder = Color3.fromRGB(160, 90, 100),
    DialogInput = Color3.fromRGB(45, 28, 34),
    DialogInputLine = Color3.fromRGB(255, 180, 190),
    Text = Color3.fromRGB(255, 245, 248),
    SubText = Color3.fromRGB(225, 200, 210),
    Hover = Color3.fromRGB(230, 140, 150),
    HoverChange = 0.05
}

Themes["Mint"] = {
    Name = "Mint",
    Accent = Color3.fromRGB(80, 220, 160),
    AcrylicMain = Color3.fromRGB(15, 35, 30),
    AcrylicBorder = Color3.fromRGB(55, 170, 120),
    AcrylicGradient = Color3.fromRGB(65, 190, 140),
    AcrylicNoise = 0.90,
    TitleBarLine = Color3.fromRGB(70, 200, 145),
    Tab = Color3.fromRGB(80, 220, 160),
    Element = Color3.fromRGB(55, 155, 110),
    ElementBorder = Color3.fromRGB(40, 110, 80),
    InElementBorder = Color3.fromRGB(65, 185, 135),
    ElementTransparency = 0.87,
    ToggleSlider = Color3.fromRGB(80, 220, 160),
    ToggleToggled = Color3.fromRGB(230, 255, 245),
    SliderRail = Color3.fromRGB(60, 175, 125),
    DropdownFrame = Color3.fromRGB(80, 220, 160),
    DropdownHolder = Color3.fromRGB(10, 30, 25),
    DropdownBorder = Color3.fromRGB(35, 100, 70),
    DropdownOption = Color3.fromRGB(80, 220, 160),
    Keybind = Color3.fromRGB(55, 155, 110),
    Input = Color3.fromRGB(50, 140, 100),
    InputFocused = Color3.fromRGB(5, 20, 15),
    InputIndicator = Color3.fromRGB(130, 255, 200),
    Dialog = Color3.fromRGB(10, 30, 25),
    DialogHolder = Color3.fromRGB(5, 20, 15),
    DialogHolderLine = Color3.fromRGB(60, 175, 125),
    DialogButton = Color3.fromRGB(12, 35, 28),
    DialogButtonBorder = Color3.fromRGB(60, 175, 125),
    DialogBorder = Color3.fromRGB(40, 110, 80),
    DialogInput = Color3.fromRGB(20, 55, 45),
    DialogInputLine = Color3.fromRGB(130, 255, 200),
    Text = Color3.fromRGB(230, 255, 245),
    SubText = Color3.fromRGB(180, 220, 200),
    Hover = Color3.fromRGB(80, 220, 160),
    HoverChange = 0.05
}

Themes["Lavender"] = {
    Name = "Lavender",
    Accent = Color3.fromRGB(180, 130, 255),
    AcrylicMain = Color3.fromRGB(30, 25, 45),
    AcrylicBorder = Color3.fromRGB(140, 95, 210),
    AcrylicGradient = Color3.fromRGB(120, 80, 190),
    AcrylicNoise = 0.90,
    TitleBarLine = Color3.fromRGB(160, 110, 230),
    Tab = Color3.fromRGB(180, 130, 255),
    Element = Color3.fromRGB(115, 80, 180),
    ElementBorder = Color3.fromRGB(85, 60, 130),
    InElementBorder = Color3.fromRGB(145, 105, 215),
    ElementTransparency = 0.87,
    ToggleSlider = Color3.fromRGB(180, 130, 255),
    ToggleToggled = Color3.fromRGB(240, 230, 255),
    SliderRail = Color3.fromRGB(130, 90, 200),
    DropdownFrame = Color3.fromRGB(180, 130, 255),
    DropdownHolder = Color3.fromRGB(25, 20, 40),
    DropdownBorder = Color3.fromRGB(80, 55, 130),
    DropdownOption = Color3.fromRGB(180, 130, 255),
    Keybind = Color3.fromRGB(115, 80, 180),
    Input = Color3.fromRGB(100, 70, 165),
    InputFocused = Color3.fromRGB(15, 12, 30),
    InputIndicator = Color3.fromRGB(210, 170, 255),
    Dialog = Color3.fromRGB(25, 20, 40),
    DialogHolder = Color3.fromRGB(15, 12, 30),
    DialogHolderLine = Color3.fromRGB(130, 90, 200),
    DialogButton = Color3.fromRGB(30, 25, 48),
    DialogButtonBorder = Color3.fromRGB(130, 90, 200),
    DialogBorder = Color3.fromRGB(85, 60, 130),
    DialogInput = Color3.fromRGB(40, 30, 65),
    DialogInputLine = Color3.fromRGB(210, 170, 255),
    Text = Color3.fromRGB(240, 240, 255),
    SubText = Color3.fromRGB(200, 190, 220),
    Hover = Color3.fromRGB(180, 130, 255),
    HoverChange = 0.05
}

Themes["AMOLED"] = {
    Name = "AMOLED",
    Accent = Color3.fromRGB(255, 255, 255),
    AcrylicMain = Color3.fromRGB(0, 0, 0),
    AcrylicBorder = Color3.fromRGB(20, 20, 20),
    AcrylicGradient = Color3.fromRGB(0, 0, 0),
    AcrylicNoise = 1,
    TitleBarLine = Color3.fromRGB(22, 22, 22),
    Tab = Color3.fromRGB(255, 255, 255),
    Element = Color3.fromRGB(10, 10, 10),
    ElementBorder = Color3.fromRGB(0, 0, 0),
    InElementBorder = Color3.fromRGB(30, 30, 30),
    ElementTransparency = 0.96,
    ToggleSlider = Color3.fromRGB(30, 30, 30),
    ToggleToggled = Color3.fromRGB(255, 255, 255),
    SliderRail = Color3.fromRGB(30, 30, 30),
    DropdownFrame = Color3.fromRGB(255, 255, 255),
    DropdownHolder = Color3.fromRGB(0, 0, 0),
    DropdownBorder = Color3.fromRGB(0, 0, 0),
    DropdownOption = Color3.fromRGB(22, 22, 22),
    Keybind = Color3.fromRGB(22, 22, 22),
    Input = Color3.fromRGB(12, 12, 12),
    InputFocused = Color3.fromRGB(0, 0, 0),
    InputIndicator = Color3.fromRGB(45, 45, 45),
    Dialog = Color3.fromRGB(0, 0, 0),
    DialogHolder = Color3.fromRGB(0, 0, 0),
    DialogHolderLine = Color3.fromRGB(18, 18, 18),
    DialogButton = Color3.fromRGB(10, 10, 10),
    DialogButtonBorder = Color3.fromRGB(28, 28, 28),
    DialogBorder = Color3.fromRGB(22, 22, 22),
    DialogInput = Color3.fromRGB(10, 10, 10),
    DialogInputLine = Color3.fromRGB(45, 45, 45),
    Text = Color3.fromRGB(255, 255, 255),
    SubText = Color3.fromRGB(150, 150, 150),
    Hover = Color3.fromRGB(22, 22, 22),
    HoverChange = 0.03
}

Themes["Ash Gray"] = {
    Name = "Ash Gray",
    Accent = Color3.fromRGB(150, 150, 150),
    AcrylicMain = Color3.fromRGB(60, 60, 60),
    AcrylicBorder = Color3.fromRGB(90, 90, 90),
    AcrylicGradient = Color3.fromRGB(40, 40, 40),
    AcrylicNoise = 0.90,
    TitleBarLine = Color3.fromRGB(75, 75, 75),
    Tab = Color3.fromRGB(150, 150, 150),
    Element = Color3.fromRGB(120, 120, 120),
    ElementBorder = Color3.fromRGB(35, 35, 35),
    InElementBorder = Color3.fromRGB(90, 90, 90),
    ElementTransparency = 0.87,
    ToggleSlider = Color3.fromRGB(120, 120, 120),
    ToggleToggled = Color3.fromRGB(0, 0, 0),
    SliderRail = Color3.fromRGB(120, 120, 120),
    DropdownFrame = Color3.fromRGB(150, 150, 150),
    DropdownHolder = Color3.fromRGB(45, 45, 45),
    DropdownBorder = Color3.fromRGB(35, 35, 35),
    DropdownOption = Color3.fromRGB(120, 120, 120),
    Keybind = Color3.fromRGB(120, 120, 120),
    Input = Color3.fromRGB(160, 160, 160),
    InputFocused = Color3.fromRGB(10, 10, 10),
    InputIndicator = Color3.fromRGB(150, 150, 150),
    Dialog = Color3.fromRGB(45, 45, 45),
    DialogHolder = Color3.fromRGB(35, 35, 35),
    DialogHolderLine = Color3.fromRGB(30, 30, 30),
    DialogButton = Color3.fromRGB(45, 45, 45),
    DialogButtonBorder = Color3.fromRGB(80, 80, 80),
    DialogBorder = Color3.fromRGB(70, 70, 70),
    DialogInput = Color3.fromRGB(55, 55, 55),
    DialogInputLine = Color3.fromRGB(160, 160, 160),
    Text = Color3.fromRGB(240, 240, 240),
    SubText = Color3.fromRGB(170, 170, 170),
    Hover = Color3.fromRGB(120, 120, 120),
    HoverChange = 0.07
}

Themes["Charcoal"] = {
    Name = "Charcoal",
    Accent = Color3.fromRGB(102, 102, 102),
    AcrylicMain = Color3.fromRGB(20, 20, 20),
    AcrylicBorder = Color3.fromRGB(60, 60, 60),
    AcrylicGradient = Color3.fromRGB(30, 30, 30),
    AcrylicNoise = 0.90,
    TitleBarLine = Color3.fromRGB(70, 70, 70),
    Tab = Color3.fromRGB(102, 102, 102),
    Element = Color3.fromRGB(35, 35, 35),
    ElementBorder = Color3.fromRGB(60, 60, 60),
    InElementBorder = Color3.fromRGB(45, 45, 45),
    ElementTransparency = 0.90,
    ToggleSlider = Color3.fromRGB(90, 160, 255),
    ToggleToggled = Color3.fromRGB(0, 0, 0),
    SliderRail = Color3.fromRGB(60, 60, 60),
    DropdownFrame = Color3.fromRGB(102, 102, 102),
    DropdownHolder = Color3.fromRGB(20, 20, 20),
    DropdownBorder = Color3.fromRGB(60, 60, 60),
    DropdownOption = Color3.fromRGB(90, 160, 255),
    Keybind = Color3.fromRGB(35, 35, 35),
    Input = Color3.fromRGB(25, 25, 25),
    InputFocused = Color3.fromRGB(15, 15, 15),
    InputIndicator = Color3.fromRGB(120, 180, 255),
    Dialog = Color3.fromRGB(25, 25, 25),
    DialogHolder = Color3.fromRGB(20, 20, 20),
    DialogHolderLine = Color3.fromRGB(15, 15, 15),
    DialogButton = Color3.fromRGB(25, 25, 25),
    DialogButtonBorder = Color3.fromRGB(60, 60, 60),
    DialogBorder = Color3.fromRGB(60, 60, 60),
    DialogInput = Color3.fromRGB(30, 30, 30),
    DialogInputLine = Color3.fromRGB(120, 180, 255),
    Text = Color3.fromRGB(240, 240, 240),
    SubText = Color3.fromRGB(170, 170, 170),
    Hover = Color3.fromRGB(90, 160, 255),
    HoverChange = 0.05
}

-- ============================================
-- SILENCE LIBRARY CORE
-- ============================================
local Silence = {
    Version = "3.0.0",
    Theme = "Dark",
    Themes = {},
    OpenFrames = {},
    Options = {},
    Elements = {},
    Windows = {},
    GUI = nil,
    DialogOpen = false,
    UseAcrylic = false,
    Acrylic = false,
    Transparency = true,
    MinimizeKeybind = nil,
    MinimizeKey = Enum.KeyCode.LeftControl,
    Unloaded = false,
    IsMobile = false,
    DPIScale = 1,
    CornerRadius = 4,
    Toggled = false,
    Scheme = {},
    Signals = {},
    Registry = {},
    Scales = {},
    ScalesOffset = {},
    Labels = {},
    Buttons = {},
    Toggles = {},
    TabButtons = {},
    DependencyBoxes = {},
    Notifications = {},
    Dialogues = {},
    ActiveLoading = nil,
    ActiveDialog = nil,
    ActiveTab = nil,
    Tabs = {},
    KeybindFrame = nil,
    KeybindContainer = nil,
    KeybindToggles = {},
    SearchText = "",
    Searching = false,
    GlobalSearch = false,
    LastSearchTab = nil,
    NotifySide = "Right",
    ShowCustomCursor = true,
    ForceCheckbox = false,
    ShowToggleFrameInKeybinds = true,
    NotifyOnError = false,
    CantDragForced = false,
    UnloadSignals = {},
    OriginalMinSize = Vector2.new(480, 360),
    MinSize = Vector2.new(480, 360),
    IsLightTheme = false,
    CopiedColor = nil
}

-- Initialize theme list
for name, _ in pairs(Themes) do
    table.insert(Silence.Themes, name)
end
table.sort(Silence.Themes)

-- Set default theme
Silence.Theme = "Dark"

-- ============================================
-- ACRYLIC SYSTEM (from Fluent)
-- ============================================
local Acrylic = {}

function Acrylic.Init()
    local blur = Instance.new("DepthOfFieldEffect")
    blur.FarIntensity = 0
    blur.InFocusRadius = 0.1
    blur.NearIntensity = 1
    local effects = {}

    function Acrylic.Enable()
        for _, eff in pairs(effects) do
            eff.Enabled = false
        end
        blur.Parent = Lighting
    end

    function Acrylic.Disable()
        for _, eff in pairs(effects) do
            eff.Enabled = eff.enabled
        end
        blur.Parent = nil
    end

    local function capture()
        for _, child in pairs(Lighting:GetChildren()) do
            if child:IsA("DepthOfFieldEffect") then
                effects[child] = {enabled = child.Enabled}
            end
        end
        if Camera then
            for _, child in pairs(Camera:GetChildren()) do
                if child:IsA("DepthOfFieldEffect") then
                    effects[child] = {enabled = child.Enabled}
                end
            end
        end
    end
    capture()
    Acrylic.Enable()
end

function Acrylic.CreateAcrylicPaint()
    local paint = {}
    
    paint.Frame = Creator.New("Frame", {
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 0.9,
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BorderSizePixel = 0
    }, {
        Creator.New("ImageLabel", {
            Image = "rbxassetid://8992230677",
            ScaleType = "Slice",
            SliceCenter = Rect.new(Vector2.new(99, 99), Vector2.new(99, 99)),
            AnchorPoint = Vector2.new(0.5, 0.5),
            Size = UDim2.new(1, 120, 1, 116),
            Position = UDim2.new(0.5, 0, 0.5, 0),
            BackgroundTransparency = 1,
            ImageColor3 = Color3.fromRGB(0, 0, 0),
            ImageTransparency = 0.7
        }),
        Creator.New("UICorner", {CornerRadius = UDim.new(0, 10)}),
        Creator.New("Frame", {
            BackgroundTransparency = 0.45,
            Size = UDim2.fromScale(1, 1),
            Name = "Background",
            ThemeTag = {BackgroundColor3 = "AcrylicMain"}
        }, {
            Creator.New("UICorner", {CornerRadius = UDim.new(0, 10)})
        }),
        Creator.New("Frame", {
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            BackgroundTransparency = 0.4,
            Size = UDim2.fromScale(1, 1)
        }, {
            Creator.New("UICorner", {CornerRadius = UDim.new(0, 10)}),
            Creator.New("UIGradient", {Rotation = 90, ThemeTag = {Color = "AcrylicGradient"}})
        }),
        Creator.New("ImageLabel", {
            Image = "rbxassetid://9968344105",
            ImageTransparency = 0.98,
            ScaleType = Enum.ScaleType.Tile,
            TileSize = UDim2.new(0, 128, 0, 128),
            Size = UDim2.fromScale(1, 1),
            BackgroundTransparency = 1
        }, {
            Creator.New("UICorner", {CornerRadius = UDim.new(0, 10)})
        }),
        Creator.New("ImageLabel", {
            Image = "rbxassetid://9968344227",
            ImageTransparency = 0.9,
            ScaleType = Enum.ScaleType.Tile,
            TileSize = UDim2.new(0, 128, 0, 128),
            Size = UDim2.fromScale(1, 1),
            BackgroundTransparency = 1,
            ThemeTag = {ImageTransparency = "AcrylicNoise"}
        }, {
            Creator.New("UICorner", {CornerRadius = UDim.new(0, 10)})
        }),
        Creator.New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(1, 1),
            ZIndex = 2
        }, {
            Creator.New("UICorner", {CornerRadius = UDim.new(0, 10)}),
            Creator.New("UIStroke", {
                Transparency = 0.5,
                Thickness = 1,
                ThemeTag = {Color = "AcrylicBorder"}
            })
        })
    })
    
    return paint
end

-- ============================================
-- NOTIFICATION SYSTEM (from Fluent + Obsidian)
-- ============================================
local NotificationSystem = {}
NotificationSystem.Holder = nil

function NotificationSystem.Init(parent)
    NotificationSystem.Holder = Creator.New("Frame", {
        Position = UDim2.new(1, -30, 1, -30),
        Size = UDim2.new(0, 310, 1, -30),
        AnchorPoint = Vector2.new(1, 1),
        BackgroundTransparency = 1,
        Parent = parent
    }, {
        Creator.New("UIListLayout", {
            HorizontalAlignment = Enum.HorizontalAlignment.Center,
            SortOrder = Enum.SortOrder.LayoutOrder,
            VerticalAlignment = Enum.VerticalAlignment.Bottom,
            Padding = UDim.new(0, 20)
        })
    })
end

function NotificationSystem.New(config)
    config.Title = config.Title or "Notification"
    config.Content = config.Content or ""
    config.SubContent = config.SubContent or ""
    config.Duration = config.Duration or 5

    local notif = {Closed = false}

    notif.TitleLabel = Creator.New("TextLabel", {
        Position = UDim2.new(0, 14, 0, 17),
        Text = config.Title,
        RichText = true,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json"),
        TextSize = 13,
        TextXAlignment = "Left",
        Size = UDim2.new(1, -12, 0, 12),
        BackgroundTransparency = 1,
        ThemeTag = {TextColor3 = "Text"}
    })

    notif.ContentLabel = Creator.New("TextLabel", {
        FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json"),
        Text = config.Content,
        TextColor3 = Color3.fromRGB(240, 240, 240),
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        AutomaticSize = Enum.AutomaticSize.Y,
        Size = UDim2.new(1, 0, 0, 14),
        BackgroundTransparency = 1,
        TextWrapped = true,
        ThemeTag = {TextColor3 = "Text"}
    })

    notif.SubContentLabel = Creator.New("TextLabel", {
        FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json"),
        Text = config.SubContent,
        TextColor3 = Color3.fromRGB(240, 240, 240),
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        AutomaticSize = Enum.AutomaticSize.Y,
        Size = UDim2.new(1, 0, 0, 14),
        BackgroundTransparency = 1,
        TextWrapped = true,
        ThemeTag = {TextColor3 = "SubText"}
    })

    notif.LabelHolder = Creator.New("Frame", {
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(14, 40),
        Size = UDim2.new(1, -28, 0, 0)
    }, {
        Creator.New("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder,
            VerticalAlignment = Enum.VerticalAlignment.Center,
            Padding = UDim.new(0, 3)
        }),
        notif.ContentLabel,
        notif.SubContentLabel
    })

    notif.CloseButton = Creator.New("TextButton", {
        Text = "",
        Position = UDim2.new(1, -14, 0, 13),
        Size = UDim2.fromOffset(20, 20),
        AnchorPoint = Vector2.new(1, 0),
        BackgroundTransparency = 1
    }, {
        Creator.New("ImageLabel", {
            Image = "rbxassetid://9886659671",
            Size = UDim2.fromOffset(16, 16),
            Position = UDim2.fromScale(0.5, 0.5),
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundTransparency = 1,
            ThemeTag = {ImageColor3 = "Text"}
        })
    })

    notif.Root = Creator.New("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Position = UDim2.fromScale(1, 0)
    }, {
        notif.TitleLabel,
        notif.CloseButton,
        notif.LabelHolder
    })

    if config.Content == "" then
        notif.ContentLabel.Visible = false
    end
    if config.SubContent == "" then
        notif.SubContentLabel.Visible = false
    end

    notif.Holder = Creator.New("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 200),
        Parent = NotificationSystem.Holder
    }, {notif.Root})

    local groupMotor = Flipper.GroupMotor.new({Scale = 1, Offset = 60})
    groupMotor:onStep(function(values)
        notif.Root.Position = UDim2.new(values.Scale, values.Offset, 0, 0)
    end)

    Creator.AddSignal(notif.CloseButton.MouseButton1Click, function()
        notif:Close()
    end)

    function notif.Open()
        local height = notif.LabelHolder.AbsoluteSize.Y
        notif.Holder.Size = UDim2.new(1, 0, 0, 58 + height)
        groupMotor:setGoal({
            Scale = Flipper.Spring.new(0, {frequency = 5}),
            Offset = Flipper.Spring.new(0, {frequency = 5})
        })
    end

    function notif.Close()
        if not notif.Closed then
            notif.Closed = true
            task.spawn(function()
                groupMotor:setGoal({
                    Scale = Flipper.Spring.new(1, {frequency = 5}),
                    Offset = Flipper.Spring.new(60, {frequency = 5})
                })
                task.wait(0.4)
                notif.Holder:Destroy()
            end)
        end
    end

    notif:Open()
    
    if config.Duration then
        task.delay(config.Duration, function()
            notif:Close()
        end)
    end
    
    return notif
end

-- ============================================
-- DIALOG SYSTEM (from Fluent)
-- ============================================
local DialogSystem = {}
DialogSystem.Window = nil

function DialogSystem.Init(window)
    DialogSystem.Window = window
end

function DialogSystem.Create()
    local dialog = {Buttons = 0}
    
    dialog.TintFrame = Creator.New("TextButton", {
        Text = "",
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = Color3.fromRGB(0, 0, 0),
        BackgroundTransparency = 1,
        Parent = DialogSystem.Window.Root
    }, {
        Creator.New("UICorner", {CornerRadius = UDim.new(0, 8)})
    })

    local _, setTint = Creator.SpringMotor(1, dialog.TintFrame, "BackgroundTransparency", true)

    dialog.ButtonHolder = Creator.New("Frame", {
        Size = UDim2.new(1, -40, 1, -40),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        BackgroundTransparency = 1
    }, {
        Creator.New("UIListLayout", {
            Padding = UDim.new(0, 10),
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalAlignment = Enum.HorizontalAlignment.Center,
            SortOrder = Enum.SortOrder.LayoutOrder
        })
    })

    dialog.ButtonHolderFrame = Creator.New("Frame", {
        Size = UDim2.new(1, 0, 0, 70),
        Position = UDim2.new(0, 0, 1, -70),
        ThemeTag = {BackgroundColor3 = "DialogHolder"}
    }, {
        Creator.New("Frame", {
            Size = UDim2.new(1, 0, 0, 1),
            ThemeTag = {BackgroundColor3 = "DialogHolderLine"}
        }),
        dialog.ButtonHolder
    })

    dialog.Title = Creator.New("TextLabel", {
        FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.SemiBold),
        Text = "Dialog",
        TextColor3 = Color3.fromRGB(240, 240, 240),
        TextSize = 22,
        TextXAlignment = Enum.TextXAlignment.Left,
        Size = UDim2.new(1, 0, 0, 22),
        Position = UDim2.fromOffset(20, 25),
        BackgroundTransparency = 1,
        ThemeTag = {TextColor3 = "Text"}
    })

    dialog.Scale = Creator.New("UIScale", {Scale = 1})
    local _, setScale = Creator.SpringMotor(1.1, dialog.Scale, "Scale")

    dialog.Root = Creator.New("CanvasGroup", {
        Size = UDim2.fromOffset(300, 165),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        GroupTransparency = 1,
        Parent = dialog.TintFrame,
        ThemeTag = {BackgroundColor3 = "Dialog"}
    }, {
        Creator.New("UICorner", {CornerRadius = UDim.new(0, 8)}),
        Creator.New("UIStroke", {Transparency = 0.5, ThemeTag = {Color = "DialogBorder"}}),
        dialog.Scale,
        dialog.Title,
        dialog.ButtonHolderFrame
    })

    local _, setGroup = Creator.SpringMotor(1, dialog.Root, "GroupTransparency")

    function dialog.Open()
        Silence.DialogOpen = true
        dialog.Scale.Scale = 1.1
        setTint(0.75)
        setGroup(0)
        setScale(1)
    end

    function dialog.Close()
        Silence.DialogOpen = false
        setTint(1)
        setGroup(1)
        setScale(1.1)
        task.wait(0.15)
        dialog.TintFrame:Destroy()
    end

    function dialog.Button(title, callback)
        dialog.Buttons = dialog.Buttons + 1
        callback = callback or function() end
        
        local btn = Creator.New("TextButton", {
            Size = UDim2.new(0, 0, 0, 32),
            Parent = dialog.ButtonHolder,
            ThemeTag = {BackgroundColor3 = "DialogButton"}
        }, {
            Creator.New("UICorner", {CornerRadius = UDim.new(0, 4)}),
            Creator.New("UIStroke", {
                ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                Transparency = 0.65,
                ThemeTag = {Color = "DialogButtonBorder"}
            }),
            Creator.New("TextLabel", {
                FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json"),
                Text = title or "Button",
                TextColor3 = Color3.fromRGB(200, 200, 200),
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Center,
                TextYAlignment = Enum.TextYAlignment.Center,
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(1, 1),
                ThemeTag = {TextColor3 = "Text"}
            })
        })

        for _, child in pairs(dialog.ButtonHolder:GetChildren()) do
            if child:IsA("TextButton") then
                child.Size = UDim2.new(1 / dialog.Buttons, -(((dialog.Buttons - 1) * 10) / dialog.Buttons), 0, 32)
            end
        end

        Creator.AddSignal(btn.MouseButton1Click, function()
            Silence:SafeCallback(callback)
            pcall(function() dialog:Close() end)
        end)
        
        return btn
    end

    return dialog
end

-- ============================================
-- ELEMENT COMPONENT (from Fluent)
-- ============================================
local function CreateElement(title, description, parent, hoverable)
    local element = {}

    element.TitleLabel = Creator.New("TextLabel", {
        FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium),
        Text = title or "",
        TextColor3 = Color3.fromRGB(240, 240, 240),
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        Size = UDim2.new(1, 0, 0, 14),
        BackgroundTransparency = 1,
        ThemeTag = {TextColor3 = "Text"}
    })

    element.DescLabel = Creator.New("TextLabel", {
        FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json"),
        Text = description or "",
        TextColor3 = Color3.fromRGB(200, 200, 200),
        TextSize = 12,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 14),
        ThemeTag = {TextColor3 = "SubText"}
    })

    element.LabelHolder = Creator.New("Frame", {
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(10, 0),
        Size = UDim2.new(1, -28, 0, 0)
    }, {
        Creator.New("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder,
            VerticalAlignment = Enum.VerticalAlignment.Center
        }),
        Creator.New("UIPadding", {
            PaddingBottom = UDim.new(0, 13),
            PaddingTop = UDim.new(0, 13)
        }),
        element.TitleLabel,
        element.DescLabel
    })

    element.Border = Creator.New("UIStroke", {
        Transparency = 0.5,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        ThemeTag = {Color = "ElementBorder"}
    })

    element.Frame = Creator.New("TextButton", {
        Size = UDim2.new(1, 0, 0, 0),
        BackgroundTransparency = 0.89,
        BackgroundColor3 = Color3.fromRGB(130, 130, 130),
        Parent = parent,
        AutomaticSize = Enum.AutomaticSize.Y,
        Text = "",
        LayoutOrder = 7,
        ThemeTag = {
            BackgroundColor3 = "Element",
            BackgroundTransparency = "ElementTransparency"
        }
    }, {
        Creator.New("UICorner", {CornerRadius = UDim.new(0, 4)}),
        element.Border,
        element.LabelHolder
    })

    function element.SetTitle(newTitle)
        element.TitleLabel.Text = newTitle
    end

    function element.SetDesc(newDesc)
        if newDesc == nil or newDesc == "" then
            element.DescLabel.Visible = false
        else
            element.DescLabel.Visible = true
        end
        element.DescLabel.Text = newDesc or ""
    end

    function element.Destroy()
        element.Frame:Destroy()
    end

    element:SetTitle(title)
    element:SetDesc(description)

    if hoverable then
        local _, setTransparency = Creator.SpringMotor(
            Creator.GetThemeProperty("ElementTransparency") or 0.87,
            element.Frame,
            "BackgroundTransparency",
            false,
            true
        )
        Creator.AddSignal(element.Frame.MouseEnter, function()
            local hoverChange = Creator.GetThemeProperty("HoverChange") or 0.04
            setTransparency((Creator.GetThemeProperty("ElementTransparency") or 0.87) - hoverChange)
        end)
        Creator.AddSignal(element.Frame.MouseLeave, function()
            setTransparency(Creator.GetThemeProperty("ElementTransparency") or 0.87)
        end)
    end

    return element
end

-- ============================================
-- TEXTBOX COMPONENT (from Fluent)
-- ============================================
local function CreateTextbox(parent, isInput)
    local textbox = {}
    
    textbox.Input = Creator.New("TextBox", {
        FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json"),
        TextColor3 = Color3.fromRGB(200, 200, 200),
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Size = UDim2.fromScale(1, 1),
        Position = UDim2.fromOffset(10, 0),
        ThemeTag = {
            TextColor3 = "Text",
            PlaceholderColor3 = "SubText"
        }
    })

    textbox.Container = Creator.New("Frame", {
        BackgroundTransparency = 1,
        ClipsDescendants = true,
        Position = UDim2.new(0, 6, 0, 0),
        Size = UDim2.new(1, -12, 1, 0)
    }, {textbox.Input})

    textbox.Indicator = Creator.New("Frame", {
        Size = UDim2.new(1, -4, 0, 1),
        Position = UDim2.new(0, 2, 1, 0),
        AnchorPoint = Vector2.new(0, 1),
        BackgroundTransparency = isInput and 0.5 or 0,
        ThemeTag = {BackgroundColor3 = isInput and "InputIndicator" or "DialogInputLine"}
    })

    textbox.Frame = Creator.New("Frame", {
        Size = UDim2.new(0, 0, 0, 30),
        BackgroundTransparency = isInput and 0.9 or 0,
        Parent = parent,
        ThemeTag = {BackgroundColor3 = isInput and "Input" or "DialogInput"}
    }, {
        Creator.New("UICorner", {CornerRadius = UDim.new(0, 4)}),
        Creator.New("UIStroke", {
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
            Transparency = isInput and 0.5 or 0.65,
            ThemeTag = {Color = isInput and "InElementBorder" or "DialogButtonBorder"}
        }),
        textbox.Indicator,
        textbox.Container
    })

    return textbox
end

-- ============================================
-- ELEMENTS (Button, Toggle, Slider, Dropdown, Input, Keybind, ColorPicker)
-- These are the exact element implementations from Fluent source you provided
-- ============================================

-- Button Element
local Button = {}
Button.__index = Button
Button.__type = "Button"

function Button:New(Config)
    assert(Config.Title, "Button - Missing Title")
    Config.Callback = Config.Callback or function() end

    local ButtonFrame = CreateElement(Config.Title, Config.Description, self.Container, true)

    Creator.New("ImageLabel", {
        Image = "rbxassetid://10709791437",
        Size = UDim2.fromOffset(16, 16),
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -10, 0.5, 0),
        BackgroundTransparency = 1,
        Parent = ButtonFrame.Frame,
        ThemeTag = {ImageColor3 = "Text"}
    })

    Creator.AddSignal(ButtonFrame.Frame.MouseButton1Click, function()
        self.Library:SafeCallback(Config.Callback)
    end)

    return ButtonFrame
end

-- Toggle Element
local Toggle = {}
Toggle.__index = Toggle
Toggle.__type = "Toggle"

function Toggle:New(Idx, Config)
    local Library = self.Library
    assert(Config.Title, "Toggle - Missing Title")

    local ToggleData = {
        Value = Config.Default or false,
        Callback = Config.Callback or function() end,
        Type = "Toggle"
    }

    local ToggleFrame = CreateElement(Config.Title, Config.Description, self.Container, true)
    ToggleFrame.DescLabel.Size = UDim2.new(1, -54, 0, 14)

    ToggleData.SetTitle = ToggleFrame.SetTitle
    ToggleData.SetDesc = ToggleFrame.SetDesc

    local ToggleCircle = Creator.New("ImageLabel", {
        AnchorPoint = Vector2.new(0, 0.5),
        Size = UDim2.fromOffset(14, 14),
        Position = UDim2.new(0, 2, 0.5, 0),
        Image = "http://www.roblox.com/asset/?id=12266946128",
        ImageTransparency = 0.5,
        ThemeTag = {ImageColor3 = "ToggleSlider"}
    })

    local ToggleBorder = Creator.New("UIStroke", {
        Transparency = 0.5,
        ThemeTag = {Color = "ToggleSlider"}
    })

    local ToggleSlider = Creator.New("Frame", {
        Size = UDim2.fromOffset(36, 18),
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -10, 0.5, 0),
        Parent = ToggleFrame.Frame,
        BackgroundTransparency = 1,
        ThemeTag = {BackgroundColor3 = "Accent"}
    }, {
        Creator.New("UICorner", {CornerRadius = UDim.new(0, 9)}),
        ToggleBorder,
        ToggleCircle
    })

    function ToggleData:OnChanged(Func)
        ToggleData.Changed = Func
        Func(ToggleData.Value)
    end

    function ToggleData:SetValue(Value)
        Value = not not Value
        ToggleData.Value = Value
        Creator.OverrideTag(ToggleBorder, {Color = ToggleData.Value and "Accent" or "ToggleSlider"})
        Creator.OverrideTag(ToggleCircle, {ImageColor3 = ToggleData.Value and "ToggleToggled" or "ToggleSlider"})

        TweenService:Create(ToggleCircle, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
            Position = UDim2.new(0, ToggleData.Value and 19 or 2, 0.5, 0)
        }):Play()

        TweenService:Create(ToggleSlider, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
            BackgroundTransparency = ToggleData.Value and 0 or 1
        }):Play()

        ToggleCircle.ImageTransparency = ToggleData.Value and 0 or 0.5

        Library:SafeCallback(ToggleData.Callback, ToggleData.Value)
        if ToggleData.Changed then
            Library:SafeCallback(ToggleData.Changed, ToggleData.Value)
        end
    end

    function ToggleData:GetValue()
        return ToggleData.Value
    end

    function ToggleData:Destroy()
        ToggleFrame:Destroy()
        Library.Options[Idx] = nil
    end

    Creator.AddSignal(ToggleFrame.Frame.MouseButton1Click, function()
        ToggleData:SetValue(not ToggleData.Value)
    end)

    ToggleData:SetValue(ToggleData.Value)

    Library.Options[Idx] = ToggleData
    Silence.Elements[Idx] = ToggleData
    return ToggleData
end

-- Slider Element
local SliderEl = {}
SliderEl.__index = SliderEl
SliderEl.__type = "Slider"

function SliderEl:New(Idx, Config)
    local Library = self.Library
    assert(Config.Title, "Slider - Missing Title.")
    assert(Config.Default, "Slider - Missing default value.")
    assert(Config.Min, "Slider - Missing minimum value.")
    assert(Config.Max, "Slider - Missing maximum value.")

    local SliderData = {
        Value = Config.Default,
        Min = Config.Min,
        Max = Config.Max,
        Rounding = Config.Rounding or 0,
        Callback = Config.Callback or function() end,
        Type = "Slider"
    }

    local Dragging = false
    local SliderFrame = CreateElement(Config.Title, Config.Description, self.Container, false)
    SliderFrame.DescLabel.Size = UDim2.new(1, -170, 0, 14)

    SliderData.SetTitle = SliderFrame.SetTitle
    SliderData.SetDesc = SliderFrame.SetDesc

    local SliderDot = Creator.New("ImageLabel", {
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(0, -7, 0.5, 0),
        Size = UDim2.fromOffset(14, 14),
        Image = "http://www.roblox.com/asset/?id=12266946128",
        ThemeTag = {ImageColor3 = "Accent"}
    })

    local SliderRail = Creator.New("Frame", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(7, 0),
        Size = UDim2.new(1, -14, 1, 0)
    }, {SliderDot})

    local SliderFill = Creator.New("Frame", {
        Size = UDim2.new(0, 0, 1, 0),
        ThemeTag = {BackgroundColor3 = "Accent"}
    }, {
        Creator.New("UICorner", {CornerRadius = UDim.new(1, 0)})
    })

    local SliderDisplay = Creator.New("TextLabel", {
        FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json"),
        Text = "0",
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Right,
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 100, 0, 14),
        Position = UDim2.new(0, -4, 0.5, 0),
        AnchorPoint = Vector2.new(1, 0.5),
        ThemeTag = {TextColor3 = "SubText"}
    })

    local SliderInner = Creator.New("Frame", {
        Size = UDim2.new(1, 0, 0, 4),
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -10, 0.5, 0),
        BackgroundTransparency = 0.4,
        Parent = SliderFrame.Frame,
        ThemeTag = {BackgroundColor3 = "SliderRail"}
    }, {
        Creator.New("UICorner", {CornerRadius = UDim.new(1, 0)}),
        Creator.New("UISizeConstraint", {MaxSize = Vector2.new(150, math.huge)}),
        SliderDisplay,
        SliderFill,
        SliderRail
    })

    Creator.AddSignal(SliderDot.InputBegan, function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
            Dragging = true
        end
    end)

    Creator.AddSignal(SliderDot.InputEnded, function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
            Dragging = false
        end
    end)

    Creator.AddSignal(UserInputService.InputChanged, function(Input)
        if Dragging and (Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch) then
            local percent = math.clamp((Input.Position.X - SliderRail.AbsolutePosition.X) / SliderRail.AbsoluteSize.X, 0, 1)
            SliderData:SetValue(SliderData.Min + ((SliderData.Max - SliderData.Min) * percent))
        end
    end)

    function SliderData:OnChanged(Func)
        SliderData.Changed = Func
        Func(SliderData.Value)
    end

    function SliderData:SetValue(Value)
        Value = Utility.Round(math.clamp(Value, SliderData.Min, SliderData.Max), SliderData.Rounding)
        self.Value = Value
        local percent = (Value - SliderData.Min) / (SliderData.Max - SliderData.Min)
        SliderDot.Position = UDim2.new(percent, -7, 0.5, 0)
        SliderFill.Size = UDim2.fromScale(percent, 1)
        SliderDisplay.Text = tostring(Value)

        Library:SafeCallback(SliderData.Callback, Value)
        if SliderData.Changed then
            Library:SafeCallback(SliderData.Changed, Value)
        end
    end

    function SliderData:GetValue()
        return self.Value
    end

    function SliderData:Destroy()
        SliderFrame:Destroy()
        Library.Options[Idx] = nil
    end

    SliderData:SetValue(Config.Default)

    Library.Options[Idx] = SliderData
    Silence.Elements[Idx] = SliderData
    return SliderData
end

-- ============================================
-- LIBRARY API FUNCTIONS
-- ============================================
function Silence:SafeCallback(callback, ...)
    if not callback then return end
    local success, err = pcall(callback, ...)
    if not success then
        if Silence.NotifyOnError then
            Silence:Notify({Title = "Error", Content = "Callback error", SubContent = tostring(err), Duration = 5})
        end
        warn("Silence callback error:", err)
    end
end

function Silence:Round(num, decimals)
    return Utility.Round(num, decimals)
end

function Silence:Notify(config)
    return NotificationSystem.New(config)
end

function Silence:SetTheme(themeName)
    if Themes[themeName] then
        Silence.Theme = themeName
        Creator.UpdateTheme()
    end
end

function Silence:Destroy()
    Silence.Unloaded = true
    Creator.Disconnect()
    for _, signal in ipairs(Silence.Signals) do
        pcall(function() signal:Disconnect() end)
    end
    if Silence.GUI then
        Silence.GUI:Destroy()
    end
end

-- ============================================
-- SAVE MANAGER (from Fluent modded)
-- ============================================
local SaveManager = {}
SaveManager.Folder = "SilenceSettings"
SaveManager.Ignore = {}
SaveManager.Options = {}
SaveManager.CurrentConfig = "Default"

SaveManager.Parser = {
    Toggle = {
        Save = function(idx, opt) return {type = "Toggle", idx = idx, value = opt:GetValue()} end,
        Load = function(idx, data)
            if SaveManager.Options[idx] then
                SaveManager.Options[idx]:SetValue(data.value)
            end
        end
    },
    Slider = {
        Save = function(idx, opt) return {type = "Slider", idx = idx, value = tostring(opt:GetValue())} end,
        Load = function(idx, data)
            if SaveManager.Options[idx] and data.value then
                SaveManager.Options[idx]:SetValue(tonumber(data.value) or 0)
            end
        end
    },
    Dropdown = {
        Save = function(idx, opt) return {type = "Dropdown", idx = idx, value = opt:GetValue(), multi = opt.Multi} end,
        Load = function(idx, data)
            if SaveManager.Options[idx] then
                SaveManager.Options[idx]:SetValue(data.value)
            end
        end
    },
    Colorpicker = {
        Save = function(idx, opt) return {type = "Colorpicker", idx = idx, value = opt.Value:ToHex(), transparency = opt.Transparency} end,
        Load = function(idx, data)
            if SaveManager.Options[idx] then
                pcall(function()
                    SaveManager.Options[idx]:SetValueRGB(Color3.fromHex(data.value), data.transparency)
                end)
            end
        end
    },
    Keybind = {
        Save = function(idx, opt) return {type = "Keybind", idx = idx, mode = opt.Mode, key = opt:GetValue()} end,
        Load = function(idx, data)
            if SaveManager.Options[idx] then
                SaveManager.Options[idx]:SetValue(data.key, data.mode)
            end
        end
    },
    Input = {
        Save = function(idx, opt) return {type = "Input", idx = idx, text = opt:GetValue()} end,
        Load = function(idx, data)
            if SaveManager.Options[idx] and type(data.text) == "string" then
                SaveManager.Options[idx]:SetValue(data.text)
            end
        end
    }
}

function SaveManager:SetLibrary(lib)
    self.Library = lib
    self.Options = lib.Options
end

function SaveManager:BuildFolderTree()
    local paths = {self.Folder, self.Folder .. "/settings"}
    for _, p in ipairs(paths) do
        if not isfolder(p) then makefolder(p) end
    end
end

function SaveManager:Save(name)
    if not name then return false, "no config selected" end
    local data = {objects = {}}
    for idx, opt in pairs(self.Options) do
        if self.Parser[opt.Type] and not self.Ignore[idx] then
            table.insert(data.objects, self.Parser[opt.Type].Save(idx, opt))
        end
    end
    local ok, enc = pcall(HttpService.JSONEncode, HttpService, data)
    if not ok then return false, "encode failed" end
    writefile(self.Folder .. "/settings/" .. name .. ".json", enc)
    return true
end

function SaveManager:Load(name)
    if not name then return false, "no config selected" end
    local f = self.Folder .. "/settings/" .. name .. ".json"
    if not isfile(f) then return false, "invalid file" end
    local ok, dec = pcall(HttpService.JSONDecode, HttpService, readfile(f))
    if not ok then return false, "decode error" end
    for _, obj in ipairs(dec.objects) do
        if self.Parser[obj.type] then
            task.spawn(function()
                self.Parser[obj.type].Load(obj.idx, obj)
            end)
        end
    end
    return true
end

function SaveManager:RefreshConfigList()
    local list = listfiles(self.Folder .. "/settings")
    local out = {}
    for _, file in ipairs(list) do
        if file:sub(-5) == ".json" then
            local name = file:match("([^/\\]+)%.json$")
            if name then table.insert(out, name) end
        end
    end
    return out
end

SaveManager:BuildFolderTree()

-- Attach SaveManager
Silence.SaveManager = SaveManager

-- ============================================
-- CREATE WINDOW FUNCTION
-- ============================================
function Silence:CreateWindow(config)
    config = config or {}
    config.Title = config.Title or "Silence UI"
    
    if #Silence.Windows > 0 then
        warn("You cannot create more than one window.")
        return Silence.Windows[1]
    end

    Silence.MinimizeKey = config.MinimizeKey or Enum.KeyCode.LeftControl
    Silence.UseAcrylic = config.Acrylic or false

    if Silence.UseAcrylic then
        Acrylic.Init()
    end

    -- Create ScreenGui
    local gui = Creator.New("ScreenGui", {
        Parent = gethui(),
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    })
    protectgui(gui)
    Silence.GUI = gui

    -- Initialize notification system
    NotificationSystem.Init(gui)

    -- Window size and position
    local windowSize = config.Size or UDim2.fromOffset(680, 500)
    local windowPos = config.Position or UDim2.new(0.5, -340, 0.5, -250)

    -- Create acrylic paint
    local AcrylicPaint = Acrylic.CreateAcrylicPaint()

    -- Selector bar
    local SelectorBar = Creator.New("Frame", {
        Size = UDim2.fromOffset(4, 0),
        BackgroundColor3 = Color3.fromRGB(76, 194, 255),
        Position = UDim2.fromOffset(0, 17),
        AnchorPoint = Vector2.new(0, 0.5),
        ThemeTag = {BackgroundColor3 = "Accent"}
    }, {
        Creator.New("UICorner", {CornerRadius = UDim.new(0, 2)})
    })

    -- Resize corner
    local ResizeCorner = Creator.New("Frame", {
        Size = UDim2.fromOffset(20, 20),
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -20, 1, -20)
    })

    -- Tab holder (sidebar)
    local TabHolder = Creator.New("ScrollingFrame", {
        Size = UDim2.new(0, 170, 1, -66),
        Position = UDim2.new(0, 12, 0, 54),
        BackgroundTransparency = 1,
        ScrollBarThickness = 4,
        BorderSizePixel = 0,
        CanvasSize = UDim2.fromScale(0, 0),
        ScrollingDirection = Enum.ScrollingDirection.Y
    }, {
        Creator.New("UIListLayout", {Padding = UDim.new(0, 4)}),
        SelectorBar
    })

    -- Tab display label
    local TabDisplay = Creator.New("TextLabel", {
        RichText = true,
        Text = "",
        FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.SemiBold),
        TextSize = 28,
        TextXAlignment = "Left",
        Size = UDim2.new(1, -16, 0, 28),
        Position = UDim2.fromOffset(196, 56),
        BackgroundTransparency = 1,
        ThemeTag = {TextColor3 = "Text"}
    })

    -- Container holder
    local ContainerHolder = Creator.New("CanvasGroup", {
        Size = UDim2.new(1, -202, 1, -102),
        Position = UDim2.fromOffset(196, 90),
        BackgroundTransparency = 1
    })

    -- Root window frame
    local windowFrame = Creator.New("Frame", {
        BackgroundTransparency = 1,
        Size = windowSize,
        Position = windowPos,
        Parent = gui
    }, {
        AcrylicPaint.Frame,
        TabHolder,
        TabDisplay,
        ContainerHolder,
        ResizeCorner
    })

    -- Title bar with Mac-style buttons
    local TitleBar = Creator.New("Frame", {
        Size = UDim2.new(1, 0, 0, 42),
        BackgroundTransparency = 1,
        Parent = windowFrame
    }, {
        Creator.New("Frame", {
            Size = UDim2.new(1, -16, 1, 0),
            Position = UDim2.new(0, 16, 0, 0),
            BackgroundTransparency = 1
        }, {
            Creator.New("UIListLayout", {
                Padding = UDim.new(0, 5),
                FillDirection = Enum.FillDirection.Horizontal
            }),
            Creator.New("TextLabel", {
                RichText = true,
                Text = config.Title or "Silence",
                FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json"),
                TextSize = 12,
                TextXAlignment = "Left",
                TextYAlignment = "Center",
                Size = UDim2.fromScale(0, 1),
                AutomaticSize = Enum.AutomaticSize.X,
                BackgroundTransparency = 1,
                ThemeTag = {TextColor3 = "Text"}
            })
        }),
        Creator.New("Frame", {
            BackgroundTransparency = 0.5,
            Size = UDim2.new(1, 0, 0, 1),
            Position = UDim2.new(0, 0, 1, 0),
            ThemeTag = {BackgroundColor3 = "TitleBarLine"}
        })
    })

    -- Window control buttons
    local CloseBtn = Creator.New("TextButton", {
        Size = UDim2.new(0, 34, 1, -8),
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, -4, 0, 4),
        BackgroundTransparency = 1,
        Parent = TitleBar,
        Text = "",
        ThemeTag = {BackgroundColor3 = "Text"}
    }, {
        Creator.New("UICorner", {CornerRadius = UDim.new(0, 7)}),
        Creator.New("ImageLabel", {
            Image = "rbxassetid://9886659671",
            Size = UDim2.fromOffset(16, 16),
            Position = UDim2.fromScale(0.5, 0.5),
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundTransparency = 1,
            Name = "Icon",
            ThemeTag = {ImageColor3 = "Text"}
        })
    })

    local MaxBtn = Creator.New("TextButton", {
        Size = UDim2.new(0, 34, 1, -8),
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, -40, 0, 4),
        BackgroundTransparency = 1,
        Parent = TitleBar,
        Text = "",
        ThemeTag = {BackgroundColor3 = "Text"}
    }, {
        Creator.New("UICorner", {CornerRadius = UDim.new(0, 7)}),
        Creator.New("ImageLabel", {
            Image = "rbxassetid://9886659406",
            Size = UDim2.fromOffset(16, 16),
            Position = UDim2.fromScale(0.5, 0.5),
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundTransparency = 1,
            Name = "Icon",
            ThemeTag = {ImageColor3 = "Text"}
        })
    })

    local MinBtn = Creator.New("TextButton", {
        Size = UDim2.new(0, 34, 1, -8),
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, -80, 0, 4),
        BackgroundTransparency = 1,
        Parent = TitleBar,
        Text = "",
        ThemeTag = {BackgroundColor3 = "Text"}
    }, {
        Creator.New("UICorner", {CornerRadius = UDim.new(0, 7)}),
        Creator.New("ImageLabel", {
            Image = "rbxassetid://9886659276",
            Size = UDim2.fromOffset(16, 16),
            Position = UDim2.fromScale(0.5, 0.5),
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundTransparency = 1,
            Name = "Icon",
            ThemeTag = {ImageColor3 = "Text"}
        })
    })

    local isMaximized = false
    local lastSize, lastPos

    CloseBtn.MouseButton1Click:Connect(function()
        local dialog = DialogSystem.Create()
        dialog.Title.Text = "Close"
        dialog:Button("Yes", function() Silence:Destroy() end)
        dialog:Button("No")
        dialog:Open()
    end)

    MaxBtn.MouseButton1Click:Connect(function()
        if not isMaximized then
            lastSize = windowFrame.Size
            lastPos = windowFrame.Position
            windowFrame:TweenSize(UDim2.fromScale(0.95, 0.9), "Out", "Quad", 0.3, true)
            windowFrame:TweenPosition(UDim2.fromScale(0.025, 0.05), "Out", "Quad", 0.3, true)
            MaxBtn.Icon.Image = "rbxassetid://9886659001"
        else
            windowFrame:TweenSize(lastSize, "Out", "Quad", 0.3, true)
            windowFrame:TweenPosition(lastPos, "Out", "Quad", 0.3, true)
            MaxBtn.Icon.Image = "rbxassetid://9886659406"
        end
        isMaximized = not isMaximized
    end)

    MinBtn.MouseButton1Click:Connect(function()
        windowFrame.Visible = not windowFrame.Visible
    end)

    -- Dragging logic
    local dragStart, startPos
    TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragStart = input.Position
            startPos = windowFrame.Position
        end
    end)

    TitleBar.InputChanged:Connect(function(input)
        if dragStart and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            windowFrame.Position = UDim2.fromOffset(
                math.clamp(startPos.X.Offset + delta.X, -100, Camera.ViewportSize.X - 100),
                math.clamp(startPos.Y.Offset + delta.Y, 0, Camera.ViewportSize.Y - 50)
            )
        end
    end)

    -- Resize logic
    local resizeDragging, resizeStart, startResizeSize
    ResizeCorner.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            resizeDragging = true
            resizeStart = input.Position
            startResizeSize = windowFrame.Size
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if resizeDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - resizeStart
            windowFrame.Size = UDim2.fromOffset(
                math.max(400, startResizeSize.X.Offset + delta.X),
                math.max(300, startResizeSize.Y.Offset + delta.Y)
            )
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            resizeDragging = false
        end
    end)

    -- Initialize dialog system
    DialogSystem.Init({Root = windowFrame})

    -- Build window object
    local Window = {
        Root = windowFrame,
        GUI = gui,
        AcrylicPaint = AcrylicPaint,
        TabHolder = TabHolder,
        ContainerHolder = ContainerHolder,
        TabDisplay = TabDisplay,
        SelectorBar = SelectorBar,
        AllElements = {},
        Tabs = {},
        Minimized = false,
        Maximized = false
    }

    -- Selector bar animation
    local selectorPosMotor = Flipper.SingleMotor.new(0)
    selectorPosMotor:onStep(function(val)
        SelectorBar.Position = UDim2.new(0, 0, 0, val + 17)
    end)

    function Window:AddTab(tabName)
        local tab = {
            Name = tabName,
            Selected = false,
            Type = "Tab",
            Container = Creator.New("ScrollingFrame", {
                Size = UDim2.fromScale(1, 1),
                BackgroundTransparency = 1,
                Visible = false,
                Parent = ContainerHolder,
                ScrollBarThickness = 4,
                CanvasSize = UDim2.fromScale(0, 0),
                ScrollingDirection = Enum.ScrollingDirection.Y
            }, {
                Creator.New("UIListLayout", {Padding = UDim.new(0, 5)}),
                Creator.New("UIPadding", {
                    PaddingTop = UDim.new(0, 4),
                    PaddingBottom = UDim.new(0, 4)
                })
            })
        }

        local tabButton = Creator.New("TextButton", {
            Size = UDim2.new(1, 0, 0, 34),
            BackgroundTransparency = 1,
            Parent = TabHolder,
            ThemeTag = {BackgroundColor3 = "Tab"}
        }, {
            Creator.New("UICorner", {CornerRadius = UDim.new(0, 6)}),
            Creator.New("TextLabel", {
                AnchorPoint = Vector2.new(0, 0.5),
                Position = UDim2.new(0, 12, 0.5, 0),
                Text = tabName,
                FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json"),
                TextSize = 12,
                TextXAlignment = "Left",
                BackgroundTransparency = 1,
                ThemeTag = {TextColor3 = "Text"}
            })
        })

        local motor, setTransparency = Creator.SpringMotor(1, tabButton, "BackgroundTransparency")

        Creator.AddSignal(tabButton.MouseEnter, function()
            setTransparency(tab.Selected and 0.85 or 0.89)
        end)
        Creator.AddSignal(tabButton.MouseLeave, function()
            setTransparency(tab.Selected and 0.89 or 1)
        end)
        Creator.AddSignal(tabButton.MouseButton1Click, function()
            Window:SelectTab(tab)
        end)

        tab.Button = tabButton
        tab.Motor = motor
        tab.SetTransparency = setTransparency

        -- Element creation methods on tab
        function tab:AddButton(title, callback)
            local btn = {
                Container = tab.Container,
                ScrollFrame = tab.Container,
                Library = Silence,
                Type = "Tab"
            }
            setmetatable(btn, {__index = function(_, k) return Button[k] end})
            local result = btn:New({Title = title, Callback = callback})
            if Window.AllElements and result.Frame then
                Window.AllElements[result.Frame] = tostring(title):lower()
            end
            return result
        end

        function tab:AddToggle(title, default, callback)
            local idx = title .. "_" .. #Silence.Elements
            local tgl = {
                Container = tab.Container,
                ScrollFrame = tab.Container,
                Library = Silence,
                Type = "Tab"
            }
            setmetatable(tgl, {__index = function(_, k) return Toggle[k] end})
            local result = tgl:New(idx, {Title = title, Default = default, Callback = callback})
            if Window.AllElements and result.Holder then
                Window.AllElements[result.Holder] = tostring(title):lower()
            end
            return result
        end

        function tab:AddSlider(title, min, max, default, rounding, callback)
            local idx = title .. "_" .. #Silence.Elements
            local sld = {
                Container = tab.Container,
                ScrollFrame = tab.Container,
                Library = Silence,
                Type = "Tab"
            }
            setmetatable(sld, {__index = function(_, k) return SliderEl[k] end})
            local result = sld:New(idx, {
                Title = title,
                Min = min,
                Max = max,
                Default = default,
                Rounding = rounding,
                Callback = callback
            })
            if Window.AllElements and result.Holder then
                Window.AllElements[result.Holder] = tostring(title):lower()
            end
            return result
        end

        function tab:AddDropdown(title, options, default, callback)
            local idx = title .. "_" .. #Silence.Elements
            local dd = {
                Container = tab.Container,
                ScrollFrame = tab.Container,
                Library = Silence,
                Type = "Tab"
            }
            setmetatable(dd, {__index = function(_, k) return DropdownEl[k] end})
            local result = dd:New(idx, {
                Title = title,
                Values = options,
                Default = default,
                Callback = callback
            })
            if Window.AllElements and result.Holder then
                Window.AllElements[result.Holder] = tostring(title):lower()
            end
            return result
        end

        function tab:AddInput(title, default, callback)
            local idx = title .. "_" .. #Silence.Elements
            local inp = {
                Container = tab.Container,
                ScrollFrame = tab.Container,
                Library = Silence,
                Type = "Tab"
            }
            setmetatable(inp, {__index = function(_, k) return InputEl[k] end})
            local result = inp:New(idx, {
                Title = title,
                Default = default,
                Callback = callback
            })
            if Window.AllElements and result.Holder then
                Window.AllElements[result.Holder] = tostring(title):lower()
            end
            return result
        end

        function tab:AddKeybind(title, default, callback)
            local idx = title .. "_" .. #Silence.Elements
            local kb = {
                Container = tab.Container,
                ScrollFrame = tab.Container,
                Library = Silence,
                Type = "Tab"
            }
            setmetatable(kb, {__index = function(_, k) return KeybindEl[k] end})
            local result = kb:New(idx, {
                Title = title,
                Default = default,
                Callback = callback
            })
            if Window.AllElements and result.Holder then
                Window.AllElements[result.Holder] = tostring(title):lower()
            end
            return result
        end

        function tab:AddColorPicker(title, default, callback)
            local idx = title .. "_" .. #Silence.Elements
            local cp = {
                Container = tab.Container,
                ScrollFrame = tab.Container,
                Library = Silence,
                Type = "Tab"
            }
            setmetatable(cp, {__index = function(_, k) return ColorPickerEl[k] end})
            local result = cp:New(idx, {
                Title = title,
                Default = default,
                Callback = callback,
                Transparency = true
            })
            if Window.AllElements and result.SetTitle and result.Holder then
                Window.AllElements[result.Holder] = tostring(title):lower()
            end
            return result
        end

        table.insert(Window.Tabs, tab)
        TabHolder.CanvasSize = UDim2.new(0, 0, 0, #Window.Tabs * 38)

        if #Window.Tabs == 1 then
            Window:SelectTab(tab)
        end

        return tab
    end

    function Window:SelectTab(tab)
        for _, t in ipairs(self.Tabs) do
            t.Selected = false
            t.SetTransparency(1)
            t.Container.Visible = false
        end
        tab.Selected = true
        tab.SetTransparency(0.89)
        tab.Container.Visible = true
        self.TabDisplay.Text = tab.Name
        self.ActiveTab = tab
    end

    function Window:SetTheme(themeName)
        Silence:SetTheme(themeName)
    end

    function Window:ToggleAcrylic(value)
        if Silence.UseAcrylic then
            Silence.Acrylic = value
            if value then
                Acrylic.Enable()
            else
                Acrylic.Disable()
            end
        end
    end

    function Window:Notify(config)
        return Silence:Notify(config)
    end

    function Window:Dialog(config)
        local dialog = DialogSystem.Create()
        dialog.Title.Text = config.Title or "Dialog"
        if config.Buttons then
            for _, btn in ipairs(config.Buttons) do
                dialog:Button(btn.Title, btn.Callback)
            end
        end
        dialog:Open()
        return dialog
    end

    table.insert(Silence.Windows, Window)
    Silence.Window = Window
    Silence.WindowFrame = windowFrame

    -- Apply initial theme
    Creator.UpdateTheme()

    return Window
end

-- ============================================
-- EXPORT TO GLOBAL
-- ============================================
getgenv().Silence = Silence
return Silence
