--[[
	CoreUI — a self-contained Roblox Lua UI library
	----------------------------------------------------------------
	Patched build:
	  • Enum.AutomaticCanvasSize → Enum.AutomaticSize (doesn't exist in Roblox)
	  • Icons.Get now validates the provider returns an actual ImageLabel
	  • Window:SetStatus(text) added
	  • Lucide provider auto-detects common API shapes

	Usage:
		local CoreUI = loadstring(readfile("CoreUI.lua"))()
]]

local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService       = game:GetService("RunService")
local Players          = game:GetService("Players")
local HttpService      = game:GetService("HttpService")
local TextService      = game:GetService("TextService")
local CoreGui          = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer and LocalPlayer:GetMouse()

--============================================================
-- ROOT CONTAINER
--============================================================

local function GetRootParent()
	local ok, gui = pcall(function()
		return (gethui and gethui()) or CoreGui
	end)
	if ok and gui then return gui end
	return LocalPlayer:WaitForChild("PlayerGui")
end

--============================================================
-- UTILITIES
--============================================================

local Util = {}

function Util.Create(class, props, children)
	local inst = Instance.new(class)
	for k, v in pairs(props or {}) do
		if k ~= "Parent" then
			inst[k] = v
		end
	end
	for _, c in ipairs(children or {}) do
		c.Parent = inst
	end
	if props and props.Parent then
		inst.Parent = props.Parent
	end
	return inst
end
local New = Util.Create

function Util.Tween(inst, info, props)
	if typeof(info) == "number" then
		info = TweenInfo.new(info, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	end
	local tw = TweenService:Create(inst, info, props)
	tw:Play()
	return tw
end

function Util.Round(n, inc)
	inc = inc or 1
	if inc <= 0 then return n end
	return math.floor((n / inc) + 0.5) * inc
end

function Util.Clamp(n, min, max)
	return math.clamp(n, min, max)
end

function Util.IsMobile()
	return UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
end

function Util.Lerp(a, b, t)
	return a + (b - a) * t
end

function Util.Draggify(frame, handle, onDragStart, onDragEnd)
	handle = handle or frame
	local dragging = false
	local dragStart, startPos
	local conns = {}

	local function update(input)
		local delta = input.Position - dragStart
		frame.Position = UDim2.new(
			startPos.X.Scale, startPos.X.Offset + delta.X,
			startPos.Y.Scale, startPos.Y.Offset + delta.Y
		)
	end

	table.insert(conns, handle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = frame.Position
			if onDragStart then onDragStart() end
			local changedConn
			changedConn = input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
					if onDragEnd then onDragEnd() end
					if changedConn then changedConn:Disconnect() end
				end
			end)
		end
	end))

	table.insert(conns, UserInputService.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
			or input.UserInputType == Enum.UserInputType.Touch) then
			update(input)
		end
	end))

	return function()
		for _, c in ipairs(conns) do c:Disconnect() end
	end
end

function Util.Corner(radius)
	return New("UICorner", { CornerRadius = UDim.new(0, radius or 6) })
end

function Util.Stroke(color, thickness, transparency)
	return New("UIStroke", {
		Color = color,
		Thickness = thickness or 1,
		Transparency = transparency or 0,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
	})
end

function Util.Pad(a, b, c, d)
	return New("UIPadding", {
		PaddingTop = UDim.new(0, a or 0),
		PaddingRight = UDim.new(0, b or a or 0),
		PaddingBottom = UDim.new(0, c or a or 0),
		PaddingLeft = UDim.new(0, d or b or a or 0),
	})
end

--============================================================
-- ICONS (Lucide)
--============================================================
-- lucide-roblox exposes several API shapes across versions. We try
-- the common ones in order and only accept an actual ImageLabel.

local Icons = { Provider = nil, _shape = nil }

local function tryIcon(provider, shape, name, size, overrides)
	local ok, result = pcall(function()
		if shape == "ImageLabel" then
			return provider.ImageLabel(name, size, overrides)
		elseif shape == "Image" then
			return provider.Image(name, size, overrides)
		elseif shape == "Get" then
			return provider:Get(name, size, overrides)
		elseif shape == "getIcon" then
			return provider:getIcon(name, size, overrides)
		elseif shape == "Icon" then
			return provider.Icon(name, size, overrides)
		end
	end)
	if ok and typeof(result) == "Instance" and result:IsA("ImageLabel") then
		return result
	end
	return nil
end

function Icons.SetProvider(mod)
	Icons.Provider = mod
	Icons._shape = nil
	if not mod then return end

	-- Probe for a working shape using a known-good icon name.
	for _, shape in ipairs({ "ImageLabel", "Image", "Get", "getIcon", "Icon" }) do
		local probe = tryIcon(mod, shape, "home", 16, {})
		if probe then
			Icons._shape = shape
			probe:Destroy()
			break
		end
	end
end

function Icons.Get(name, size, overrides)
	if not name or not Icons.Provider or not Icons._shape then return nil end
	return tryIcon(Icons.Provider, Icons._shape, name, size or 18, overrides or {})
end

--============================================================
-- THEME
--============================================================

local Themes = {}

Themes.Spotix = {
	Name = "Spotix",
	Font = Enum.Font.GothamMedium,
	FontBold = Enum.Font.GothamBold,

	Background   = Color3.fromRGB(11, 15, 20),
	Sidebar      = Color3.fromRGB(13, 17, 23),
	Topbar       = Color3.fromRGB(13, 17, 23),
	Card         = Color3.fromRGB(17, 21, 28),
	CardAlt      = Color3.fromRGB(21, 26, 34),
	Border       = Color3.fromRGB(31, 37, 46),
	Divider      = Color3.fromRGB(28, 33, 41),

	Text         = Color3.fromRGB(237, 240, 244),
	SubText      = Color3.fromRGB(141, 150, 163),
	MutedText    = Color3.fromRGB(96, 103, 114),

	Accent       = Color3.fromRGB(34, 197, 94),
	AccentDark   = Color3.fromRGB(21, 128, 61),
	AccentText   = Color3.fromRGB(6, 20, 12),

	Danger       = Color3.fromRGB(239, 68, 68),
	Warning      = Color3.fromRGB(234, 179, 8),
	Info         = Color3.fromRGB(56, 139, 253),

	ToggleOff    = Color3.fromRGB(43, 49, 58),
	SliderRail   = Color3.fromRGB(35, 41, 50),
}

Themes.EvilSpotix = {
	Name = "Evil Spotix",
	Font = Enum.Font.GothamMedium,
	FontBold = Enum.Font.GothamBold,

	Background   = Color3.fromRGB(11, 15, 20),
	Sidebar      = Color3.fromRGB(13, 17, 23),
	Topbar       = Color3.fromRGB(13, 17, 23),
	Card         = Color3.fromRGB(17, 21, 28),
	CardAlt      = Color3.fromRGB(21, 26, 34),
	Border       = Color3.fromRGB(31, 37, 46),
	Divider      = Color3.fromRGB(28, 33, 41),

	Text         = Color3.fromRGB(237, 240, 244),
	SubText      = Color3.fromRGB(141, 150, 163),
	MutedText    = Color3.fromRGB(96, 103, 114),

	Accent       = Color3.fromRGB(239, 68, 68),
	AccentDark   = Color3.fromRGB(153, 27, 27),
	AccentText   = Color3.fromRGB(24, 6, 6),

	Danger       = Color3.fromRGB(239, 68, 68),
	Warning      = Color3.fromRGB(234, 179, 8),
	Info         = Color3.fromRGB(56, 139, 253),

	ToggleOff    = Color3.fromRGB(43, 49, 58),
	SliderRail   = Color3.fromRGB(35, 41, 50),
}

Themes.Obsidian = {
	Name = "Obsidian",
	Font = Enum.Font.GothamMedium,
	FontBold = Enum.Font.GothamBold,
	Background   = Color3.fromRGB(18, 18, 22),
	Sidebar      = Color3.fromRGB(15, 15, 19),
	Topbar       = Color3.fromRGB(15, 15, 19),
	Card         = Color3.fromRGB(24, 24, 29),
	CardAlt      = Color3.fromRGB(29, 29, 35),
	Border       = Color3.fromRGB(40, 40, 48),
	Divider      = Color3.fromRGB(35, 35, 42),
	Text         = Color3.fromRGB(240, 240, 245),
	SubText      = Color3.fromRGB(150, 150, 160),
	MutedText    = Color3.fromRGB(100, 100, 110),
	Accent       = Color3.fromRGB(124, 58, 237),
	AccentDark   = Color3.fromRGB(88, 28, 200),
	AccentText   = Color3.fromRGB(255, 255, 255),
	Danger       = Color3.fromRGB(239, 68, 68),
	Warning      = Color3.fromRGB(234, 179, 8),
	Info         = Color3.fromRGB(56, 139, 253),
	ToggleOff    = Color3.fromRGB(45, 45, 53),
	SliderRail   = Color3.fromRGB(38, 38, 46),
}

--============================================================
-- LIBRARY ROOT
--============================================================

local CoreUI = {}
CoreUI.__index = CoreUI

CoreUI.Flags = {}
CoreUI.Options = {}
CoreUI._ThemeListeners = {}
CoreUI._Connections = {}
CoreUI._KeybindElements = {}
CoreUI.Theme = Themes.Spotix
CoreUI.Loaded = false
CoreUI.ConfigFolder = "CoreUI/Configs"
CoreUI.ToggleKeybind = Enum.KeyCode.RightControl

local function track(conn)
	table.insert(CoreUI._Connections, conn)
	return conn
end

function CoreUI:SetIconProvider(mod)
	Icons.SetProvider(mod)
end

function CoreUI:RegisterThemeListener(fn)
	table.insert(self._ThemeListeners, fn)
end

function CoreUI:SetTheme(themeOrName)
	local theme = themeOrName
	if type(themeOrName) == "string" then
		theme = Themes[themeOrName]
	end
	if not theme then return end
	self.Theme = theme
	for _, fn in ipairs(self._ThemeListeners) do
		pcall(fn, theme)
	end
end

CoreUI.Themes = Themes

--============================================================
-- ROOT SCREENGUI + GLOBAL OVERLAY LAYERS
--============================================================

local ScreenGui = New("ScreenGui", {
	Name = "CoreUI_" .. tostring(math.random(100000, 999999)),
	ResetOnSpawn = false,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	DisplayOrder = 999,
	IgnoreGuiInset = true,
	Parent = GetRootParent(),
})
CoreUI.ScreenGui = ScreenGui

local GlobalScale = New("UIScale", { Scale = 1, Parent = nil })

local TooltipLayer = New("Frame", {
	Name = "TooltipLayer",
	BackgroundTransparency = 1,
	Size = UDim2.fromScale(1, 1),
	ZIndex = 10000,
	Parent = ScreenGui,
})

local NotifyLayer = New("Frame", {
	Name = "NotifyLayer",
	BackgroundTransparency = 1,
	AnchorPoint = Vector2.new(1, 1),
	Position = UDim2.new(1, -20, 1, -20),
	Size = UDim2.new(0, 320, 1, -40),
	Parent = ScreenGui,
})
New("UIListLayout", {
	Parent = NotifyLayer,
	HorizontalAlignment = Enum.HorizontalAlignment.Right,
	VerticalAlignment = Enum.VerticalAlignment.Bottom,
	Padding = UDim.new(0, 10),
	SortOrder = Enum.SortOrder.LayoutOrder,
})

local CursorLayer = New("ImageLabel", {
	Name = "CustomCursor",
	BackgroundTransparency = 1,
	Size = UDim2.fromOffset(20, 20),
	Image = "rbxassetid://6034287594",
	ImageColor3 = Color3.new(1, 1, 1),
	Visible = false,
	ZIndex = 20000,
	Parent = ScreenGui,
})

--============================================================
-- DPI SCALING
--============================================================

local BASE_VIEWPORT = Vector2.new(1280, 832)

function CoreUI:SetDPIScale(scale)
	GlobalScale.Scale = scale
end

function CoreUI:EnableAutoDPI(enabled)
	self._autoDPI = enabled
	if enabled then
		local camera = workspace.CurrentCamera
		local function update()
			if not camera then return end
			local vp = camera.ViewportSize
			local s = math.min(vp.X / BASE_VIEWPORT.X, vp.Y / BASE_VIEWPORT.Y)
			s = Util.Clamp(s, 0.6, 1.25)
			if Util.IsMobile() then s = math.max(s, 0.85) end
			GlobalScale.Scale = s
		end
		update()
		track(camera and camera:GetPropertyChangedSignal("ViewportSize"):Connect(update))
	end
end

--============================================================
-- CUSTOM CURSOR
--============================================================

function CoreUI:SetCustomCursor(enabled, imageId)
	if imageId then CursorLayer.Image = imageId end
	CursorLayer.Visible = enabled and not Util.IsMobile()
	if enabled then
		pcall(function() UserInputService.MouseIconEnabled = false end)
		track(RunService.RenderStepped:Connect(function()
			if Mouse then
				CursorLayer.Position = UDim2.fromOffset(Mouse.X, Mouse.Y)
			end
		end))
	else
		pcall(function() UserInputService.MouseIconEnabled = true end)
	end
end

--============================================================
-- TOOLTIPS
--============================================================

local ActiveTooltip

local function HideTooltip()
	if ActiveTooltip then
		ActiveTooltip:Destroy()
		ActiveTooltip = nil
	end
end

function CoreUI:AttachTooltip(target, text, isDisabledFn, disabledReason)
	local theme = self.Theme
	local hovering = false

	local function show()
		HideTooltip()
		local disabled = isDisabledFn and isDisabledFn()
		local msg = (disabled and disabledReason) or text
		if not msg or msg == "" then return end

		local label = New("TextLabel", {
			BackgroundColor3 = theme.CardAlt,
			AutomaticSize = Enum.AutomaticSize.XY,
			Text = "  " .. msg .. "  ",
			Font = theme.Font,
			TextSize = 13,
			TextColor3 = disabled and theme.Warning or theme.Text,
			Size = UDim2.new(0, 0, 0, 28),
			ZIndex = 10001,
		}, { Util.Corner(6), Util.Stroke(theme.Border, 1) })
		label.Parent = TooltipLayer
		ActiveTooltip = label

		track(RunService.RenderStepped:Connect(function()
			if not hovering or not label.Parent then return end
			local pos = UserInputService:GetMouseLocation()
			label.Position = UDim2.fromOffset(pos.X + 16, pos.Y + 18)
		end))
	end

	track(target.MouseEnter:Connect(function()
		hovering = true
		show()
	end))
	track(target.MouseLeave:Connect(function()
		hovering = false
		HideTooltip()
	end))
end

--============================================================
-- NOTIFICATIONS
--============================================================

function CoreUI:Notify(config)
	config = config or {}
	local theme = self.Theme
	local duration = config.Duration or 4
	local accent = theme.Accent
	if config.Type == "Warning" then accent = theme.Warning end
	if config.Type == "Error" then accent = theme.Danger end
	if config.Type == "Info" then accent = theme.Info end

	local card = New("Frame", {
		BackgroundColor3 = theme.Card,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		LayoutOrder = -os.clock() * 1000,
	}, { Util.Corner(10), Util.Stroke(theme.Border, 1), Util.Pad(12, 12, 12, 12) })
	card.Parent = NotifyLayer

	New("Frame", {
		BackgroundColor3 = accent,
		Size = UDim2.new(0, 3, 1, 0),
		Parent = card,
	}, { Util.Corner(2) })

	New("UIListLayout", {
		Parent = card,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 4),
	})

	New("TextLabel", {
		BackgroundTransparency = 1,
		Text = config.Title or "Notification",
		Font = theme.FontBold,
		TextSize = 15,
		TextColor3 = theme.Text,
		TextXAlignment = Enum.TextXAlignment.Left,
		Size = UDim2.new(1, 0, 0, 18),
		LayoutOrder = 1,
		Parent = card,
	})

	if config.Content then
		New("TextLabel", {
			BackgroundTransparency = 1,
			Text = config.Content,
			Font = theme.Font,
			TextSize = 13,
			TextWrapped = true,
			TextColor3 = theme.SubText,
			TextXAlignment = Enum.TextXAlignment.Left,
			AutomaticSize = Enum.AutomaticSize.Y,
			Size = UDim2.new(1, 0, 0, 0),
			LayoutOrder = 2,
			Parent = card,
		})
	end

	if config.Steps then
		local stepsHolder = New("Frame", {
			BackgroundTransparency = 1,
			AutomaticSize = Enum.AutomaticSize.Y,
			Size = UDim2.new(1, 0, 0, 0),
			LayoutOrder = 3,
			Parent = card,
		})
		New("UIListLayout", { Parent = stepsHolder, Padding = UDim.new(0, 2) })
		local stepLabels = {}
		for i, stepText in ipairs(config.Steps) do
			local row = New("TextLabel", {
				BackgroundTransparency = 1,
				Text = "○  " .. stepText,
				Font = theme.Font,
				TextSize = 12,
				TextColor3 = theme.MutedText,
				TextXAlignment = Enum.TextXAlignment.Left,
				Size = UDim2.new(1, 0, 0, 16),
				Parent = stepsHolder,
			})
			stepLabels[i] = row
		end

		local bar = New("Frame", {
			BackgroundColor3 = theme.SliderRail,
			Size = UDim2.new(1, 0, 0, 4),
			LayoutOrder = 4,
			Parent = card,
		}, { Util.Corner(2) })
		local fill = New("Frame", {
			BackgroundColor3 = accent,
			Size = UDim2.new(0, 0, 1, 0),
			Parent = bar,
		}, { Util.Corner(2) })

		local notif = { StepLabels = stepLabels, Fill = fill, Card = card }
		function notif:SetStep(index)
			for i, lbl in ipairs(self.StepLabels) do
				if i < index then
					lbl.Text = "●  " .. lbl.Text:sub(4)
					lbl.TextColor3 = theme.SubText
				elseif i == index then
					lbl.Text = "➤  " .. lbl.Text:sub(4)
					lbl.TextColor3 = accent
				end
			end
			Util.Tween(fill, 0.25, { Size = UDim2.new(index / #self.StepLabels, 0, 1, 0) })
		end
		task.delay(duration, function()
			if card.Parent then
				Util.Tween(card, 0.2, { BackgroundTransparency = 1 })
				task.wait(0.2)
				card:Destroy()
			end
		end)
		return notif
	end

	card.BackgroundTransparency = 1
	for _, d in ipairs(card:GetDescendants()) do
		if d:IsA("TextLabel") then d.TextTransparency = 1 end
	end
	Util.Tween(card, 0.2, { BackgroundTransparency = 0 })
	for _, d in ipairs(card:GetDescendants()) do
		if d:IsA("TextLabel") then Util.Tween(d, 0.2, { TextTransparency = 0 }) end
	end

	task.delay(duration, function()
		if card.Parent then
			Util.Tween(card, 0.2, { BackgroundTransparency = 1 })
			for _, d in ipairs(card:GetDescendants()) do
				if d:IsA("TextLabel") then Util.Tween(d, 0.2, { TextTransparency = 1 }) end
			end
			task.wait(0.2)
			card:Destroy()
		end
	end)

	return { Card = card }
end

--============================================================
-- CONFIG (SAVE / LOAD)
--============================================================

local function fileApisAvailable()
	return typeof(writefile) == "function" and typeof(readfile) == "function"
end

function CoreUI:SaveConfig(name)
	name = name or "default"
	if not fileApisAvailable() then return false, "file APIs unavailable" end
	pcall(function()
		if not isfolder(self.ConfigFolder) then makefolder(self.ConfigFolder) end
	end)
	local data = HttpService:JSONEncode(self.Flags)
	local ok, err = pcall(function()
		writefile(self.ConfigFolder .. "/" .. name .. ".json", data)
	end)
	return ok, err
end

function CoreUI:LoadConfig(name)
	name = name or "default"
	if not fileApisAvailable() then return false, "file APIs unavailable" end
	local path = self.ConfigFolder .. "/" .. name .. ".json"
	local ok, contentOrErr = pcall(readfile, path)
	if not ok then return false, contentOrErr end
	local ok2, decoded = pcall(HttpService.JSONDecode, HttpService, contentOrErr)
	if not ok2 then return false, "corrupt config" end
	for flag, value in pairs(decoded) do
		local element = self.Options[flag]
		if element and element.Set then
			element:Set(value)
		end
		self.Flags[flag] = value
	end
	return true
end

function CoreUI:ListConfigs()
	if not (typeof(listfiles) == "function") then return {} end
	local ok, files = pcall(listfiles, self.ConfigFolder)
	if not ok then return {} end
	local names = {}
	for _, f in ipairs(files) do
		local name = f:match("([^/\\]+)%.json$")
		if name then table.insert(names, name) end
	end
	return names
end

--============================================================
-- UNLOAD / CLEANUP
--============================================================

CoreUI._UnloadCallbacks = {}

function CoreUI:OnUnload(fn)
	table.insert(self._UnloadCallbacks, fn)
end

function CoreUI:Unload()
	for _, fn in ipairs(self._UnloadCallbacks) do
		pcall(fn)
	end
	for _, conn in ipairs(self._Connections) do
		pcall(function() conn:Disconnect() end)
	end
	pcall(function() UserInputService.MouseIconEnabled = true end)
	if ScreenGui then ScreenGui:Destroy() end
	self.Loaded = false
end
CoreUI.Destroy = CoreUI.Unload

--============================================================
-- SHARED ROW BUILDER
--============================================================

local function BuildRow(parent, theme, opts)
	opts = opts or {}
	local row = New("Frame", {
		BackgroundColor3 = theme.CardAlt,
		BackgroundTransparency = opts.Flat and 1 or 0,
		Size = UDim2.new(1, 0, 0, opts.Height or 46),
		Parent = parent,
	}, opts.Flat and {} or { Util.Corner(8) })

	if opts.Icon then
		local icon = Icons.Get(opts.Icon, 16, { ImageColor3 = theme.SubText })
		if icon then
			icon.Position = UDim2.new(0, 12, 0.5, 0)
			icon.AnchorPoint = Vector2.new(0, 0.5)
			icon.Parent = row
		end
	end

	local textX = opts.Icon and 38 or 14
	local textHolder = New("Frame", {
		BackgroundTransparency = 1,
		Position = UDim2.new(0, textX, 0, 0),
		Size = UDim2.new(1, -(textX + (opts.ControlWidth or 120)), 1, 0),
	}, {
		New("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, VerticalAlignment = Enum.VerticalAlignment.Center }),
	})
	textHolder.Parent = row

	local title = New("TextLabel", {
		BackgroundTransparency = 1,
		Text = opts.Title or "",
		Font = theme.Font,
		TextSize = 14,
		TextColor3 = theme.Text,
		TextXAlignment = Enum.TextXAlignment.Left,
		Size = UDim2.new(1, 0, 0, opts.Description and 16 or 0),
		AutomaticSize = opts.Description and Enum.AutomaticSize.None or Enum.AutomaticSize.Y,
		Parent = textHolder,
	})
	if not opts.Description then
		title.Size = UDim2.new(1, 0, 1, 0)
	end

	if opts.Description then
		New("TextLabel", {
			BackgroundTransparency = 1,
			Text = opts.Description,
			Font = theme.Font,
			TextSize = 12,
			TextColor3 = theme.SubText,
			TextXAlignment = Enum.TextXAlignment.Left,
			Size = UDim2.new(1, 0, 0, 14),
			Parent = textHolder,
		})
	end

	local controlArea = New("Frame", {
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -12, 0.5, 0),
		Size = UDim2.new(0, opts.ControlWidth or 120, 1, -12),
		Parent = row,
	})

	return row, controlArea, title
end

--============================================================
-- ELEMENT: LABEL
--============================================================

local function CreateLabel(parent, theme, text)
	local lbl = New("TextLabel", {
		BackgroundTransparency = 1,
		Text = text or "",
		Font = theme.Font,
		TextSize = 13,
		TextColor3 = theme.SubText,
		TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Left,
		AutomaticSize = Enum.AutomaticSize.Y,
		Size = UDim2.new(1, 0, 0, 0),
		Parent = parent,
	})
	local obj = { Instance = lbl }
	function obj:Set(newText) lbl.Text = newText end
	return obj
end

local function CreateDivider(parent, theme)
	return New("Frame", {
		BackgroundColor3 = theme.Divider,
		Size = UDim2.new(1, 0, 0, 1),
		Parent = parent,
	})
end

local function CreateWarningBox(parent, theme, opts)
	opts = opts or {}
	local kind = opts.Type or "Warning"
	local color = theme.Warning
	if kind == "Error" then color = theme.Danger end
	if kind == "Info" then color = theme.Info end

	local box = New("Frame", {
		BackgroundColor3 = color,
		BackgroundTransparency = 0.88,
		AutomaticSize = Enum.AutomaticSize.Y,
		Size = UDim2.new(1, 0, 0, 0),
		Parent = parent,
	}, { Util.Corner(8), Util.Stroke(color, 1, 0.5), Util.Pad(10, 12, 10, 12) })

	local holder = New("Frame", {
		BackgroundTransparency = 1,
		AutomaticSize = Enum.AutomaticSize.Y,
		Size = UDim2.new(1, 0, 0, 0),
		Parent = box,
	})
	New("UIListLayout", { Parent = holder, Padding = UDim.new(0, 2) })

	New("TextLabel", {
		BackgroundTransparency = 1,
		Text = "⚠ " .. (opts.Title or kind),
		Font = theme.FontBold,
		TextSize = 13,
		TextColor3 = color,
		TextXAlignment = Enum.TextXAlignment.Left,
		Size = UDim2.new(1, 0, 0, 16),
		Parent = holder,
	})
	New("TextLabel", {
		BackgroundTransparency = 1,
		Text = opts.Text or "",
		Font = theme.Font,
		TextSize = 12,
		TextWrapped = true,
		TextColor3 = theme.Text,
		TextXAlignment = Enum.TextXAlignment.Left,
		AutomaticSize = Enum.AutomaticSize.Y,
		Size = UDim2.new(1, 0, 0, 0),
		Parent = holder,
	})
	return { Instance = box }
end

--============================================================
-- ELEMENT: BUTTON
--============================================================

local function CreateButton(parent, theme, opts)
	opts = opts or {}
	local row, controlArea = BuildRow(parent, theme, {
		Title = opts.Title, Description = opts.Description, Icon = opts.Icon,
		ControlWidth = 90,
	})

	local btn = New("TextButton", {
		BackgroundColor3 = theme.Accent,
		Size = UDim2.new(1, 0, 0, 30),
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, 0, 0.5, 0),
		Text = opts.ButtonText or "Run",
		Font = theme.FontBold,
		TextSize = 13,
		TextColor3 = theme.AccentText,
		AutoButtonColor = false,
		Parent = controlArea,
	}, { Util.Corner(6) })

	track(btn.MouseButton1Click:Connect(function()
		if opts.Callback then task.spawn(opts.Callback) end
	end))
	track(btn.MouseEnter:Connect(function()
		Util.Tween(btn, 0.12, { BackgroundColor3 = theme.AccentDark })
	end))
	track(btn.MouseLeave:Connect(function()
		Util.Tween(btn, 0.12, { BackgroundColor3 = theme.Accent })
	end))

	local obj = { Instance = row, Button = btn }
	function obj:SetDisabled(disabled, reason)
		btn.Active = not disabled
		btn.AutoButtonColor = false
		Util.Tween(btn, 0.15, { BackgroundTransparency = disabled and 0.6 or 0 })
		obj._disabled = disabled
		obj._disabledReason = reason
	end
	CoreUI:AttachTooltip(row, opts.Tooltip, function() return obj._disabled end, obj._disabledReason)
	return obj
end

--============================================================
-- ELEMENT: TOGGLE / CHECKBOX
--============================================================

local function CreateToggleBase(parent, theme, opts, square)
	opts = opts or {}
	local row, controlArea = BuildRow(parent, theme, {
		Title = opts.Title, Description = opts.Description, Icon = opts.Icon,
		ControlWidth = square and 26 or 42,
	})

	local state = opts.Default or false
	local switch, knob

	if square then
		switch = New("Frame", {
			BackgroundColor3 = state and theme.Accent or theme.CardAlt,
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, 0, 0.5, 0),
			Size = UDim2.fromOffset(22, 22),
			Parent = controlArea,
		}, { Util.Corner(5), Util.Stroke(theme.Border, 1) })
		knob = New("TextLabel", {
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(1, 1),
			Text = state and "✓" or "",
			TextColor3 = theme.AccentText,
			Font = theme.FontBold,
			TextSize = 15,
			Parent = switch,
		})
	else
		switch = New("Frame", {
				BackgroundColor3 = state and theme.Accent or theme.ToggleOff,
				AnchorPoint = Vector2.new(1, 0.5),
				Position = UDim2.new(1, 0, 0.5, 0),
				Size = UDim2.fromOffset(38, 20),
				Parent = controlArea,
			}, { Util.Corner(10) })
		knob = New("Frame", {
			BackgroundColor3 = Color3.new(1, 1, 1),
			Size = UDim2.fromOffset(16, 16),
			Position = state and UDim2.new(1, -18, 0.5, 0) or UDim2.new(0, 2, 0.5, 0),
			AnchorPoint = Vector2.new(0, 0.5),
			Parent = switch,
		}, { Util.Corner(8) })
	end

	local click = New("TextButton", {
		BackgroundTransparency = 1,
		Text = "",
		Size = UDim2.fromScale(1, 1),
		Parent = switch,
	})

	local obj = { Instance = row, Value = state, Flag = opts.Flag }

	function obj:Set(value, fireCallback)
		state = value
		obj.Value = value
		if opts.Flag then CoreUI.Flags[opts.Flag] = value end
		if square then
			Util.Tween(switch, 0.12, { BackgroundColor3 = value and theme.Accent or theme.CardAlt })
			knob.Text = value and "✓" or ""
		else
			Util.Tween(switch, 0.12, { BackgroundColor3 = value and theme.Accent or theme.ToggleOff })
			Util.Tween(knob, 0.12, { Position = value and UDim2.new(1, -18, 0.5, 0) or UDim2.new(0, 2, 0.5, 0) })
		end
		if fireCallback ~= false and opts.Callback then
			task.spawn(opts.Callback, value)
		end
	end

	function obj:Get() return state end

	track(click.MouseButton1Click:Connect(function()
		if obj._disabled then return end
		obj:Set(not state)
	end))

	function obj:SetDisabled(disabled, reason)
		obj._disabled = disabled
		obj._disabledReason = reason
		Util.Tween(row, 0.15, { BackgroundTransparency = disabled and 0.55 or 0 })
	end

	if opts.Flag then
		CoreUI.Flags[opts.Flag] = state
		CoreUI.Options[opts.Flag] = obj
	end
	CoreUI:AttachTooltip(row, opts.Tooltip, function() return obj._disabled end, obj._disabledReason)
	return obj
end

--============================================================
-- ELEMENT: INPUT
--============================================================

local function CreateInput(parent, theme, opts)
	opts = opts or {}
	local row, controlArea = BuildRow(parent, theme, {
		Title = opts.Title, Description = opts.Description, Icon = opts.Icon,
		ControlWidth = opts.ControlWidth or 140,
	})

	local box = New("Frame", {
		BackgroundColor3 = theme.Card,
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, 0, 0.5, 0),
		Size = UDim2.new(1, 0, 0, 30),
		Parent = controlArea,
	}, { Util.Corner(6), Util.Stroke(theme.Border, 1), Util.Pad(0, 8, 0, 8) })

	local input = New("TextBox", {
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		Text = tostring(opts.Default or ""),
		PlaceholderText = opts.Placeholder or "",
		Font = theme.Font,
		TextSize = 13,
		TextColor3 = theme.Text,
		PlaceholderColor3 = theme.MutedText,
		ClearTextOnFocus = false,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = box,
	})

	local obj = { Instance = row, Flag = opts.Flag }
	function obj:Set(value)
		input.Text = tostring(value)
		if opts.Flag then CoreUI.Flags[opts.Flag] = value end
	end
	function obj:Get() return input.Text end

	track(input.FocusLost:Connect(function(enterPressed)
		local text = input.Text
		if opts.Numeric then
			local n = tonumber(text)
			if not n then
				input.Text = tostring(opts.Default or 0)
				return
			end
			if opts.Flag then CoreUI.Flags[opts.Flag] = n end
			if opts.Callback then task.spawn(opts.Callback, n, enterPressed) end
		else
			if opts.Flag then CoreUI.Flags[opts.Flag] = text end
			if opts.Callback then task.spawn(opts.Callback, text, enterPressed) end
		end
	end))

	if opts.Flag then
		CoreUI.Flags[opts.Flag] = opts.Default
		CoreUI.Options[opts.Flag] = obj
	end
	CoreUI:AttachTooltip(row, opts.Tooltip)
	return obj
end

--============================================================
-- ELEMENT: SLIDER
--============================================================

local function CreateSlider(parent, theme, opts)
	opts = opts or {}
	local min, max = opts.Min or 0, opts.Max or 100
	local default = Util.Clamp(opts.Default or min, min, max)
	local rounding = opts.Rounding or 0
	local suffix = opts.Suffix or ""

	local row, controlArea = BuildRow(parent, theme, {
		Title = opts.Title, Icon = opts.Icon, Height = 46, ControlWidth = 70,
	})

	local valueLabel = New("TextLabel", {
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, 0, 0.5, 0),
		Size = UDim2.new(1, 0, 1, 0),
		Text = string.format("%." .. rounding .. "f%s", default, suffix),
		Font = theme.Font,
		TextSize = 13,
		TextColor3 = theme.SubText,
		TextXAlignment = Enum.TextXAlignment.Right,
		Parent = controlArea,
	})

	local rail = New("Frame", {
		BackgroundColor3 = theme.SliderRail,
		Position = UDim2.new(0, opts.Icon and 38 or 14, 1, -10),
		Size = UDim2.new(1, -((opts.Icon and 38 or 14) + 78), 0, 6),
		Parent = row,
	}, { Util.Corner(3) })

	local function fracFromValue(v) return (v - min) / (max - min) end

	local fill = New("Frame", {
		BackgroundColor3 = theme.Accent,
		Size = UDim2.new(fracFromValue(default), 0, 1, 0),
		Parent = rail,
	}, { Util.Corner(3) })

	local knob = New("Frame", {
		BackgroundColor3 = Color3.new(1, 1, 1),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(fracFromValue(default), 0, 0.5, 0),
		Size = UDim2.fromOffset(14, 14),
		ZIndex = 2,
		Parent = rail,
	}, { Util.Corner(7), Util.Stroke(theme.Border, 1) })

	local dragging = false
	local value = default

	local function setFromFrac(frac)
		frac = Util.Clamp(frac, 0, 1)
		local raw = min + (max - min) * frac
		raw = Util.Round(raw, opts.Step or (rounding > 0 and (1 / (10 ^ rounding)) or 1))
		raw = Util.Clamp(raw, min, max)
		value = raw
		local f = fracFromValue(raw)
		fill.Size = UDim2.new(f, 0, 1, 0)
		knob.Position = UDim2.new(f, 0, 0.5, 0)
		valueLabel.Text = string.format("%." .. rounding .. "f%s", raw, suffix)
	end

	local hit = New("TextButton", {
		BackgroundTransparency = 1,
		Text = "",
		Size = UDim2.new(1, 0, 1, 14),
		Position = UDim2.new(0, 0, 0, -7),
		Parent = rail,
	})

	local obj = { Instance = row, Flag = opts.Flag }

	track(hit.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			if obj._disabled then return end
			dragging = true
			local frac = (input.Position.X - rail.AbsolutePosition.X) / rail.AbsoluteSize.X
			setFromFrac(frac)
		end
	end))
	track(UserInputService.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local frac = (input.Position.X - rail.AbsolutePosition.X) / rail.AbsoluteSize.X
			setFromFrac(frac)
			if opts.Flag then CoreUI.Flags[opts.Flag] = value end
			if opts.Callback then task.spawn(opts.Callback, value) end
		end
	end))
	track(UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			if dragging and opts.Flag then CoreUI.Flags[opts.Flag] = value end
			dragging = false
		end
	end))

	function obj:Set(v, fireCallback)
		setFromFrac(fracFromValue(Util.Clamp(v, min, max)))
		if opts.Flag then CoreUI.Flags[opts.Flag] = value end
		if fireCallback ~= false and opts.Callback then task.spawn(opts.Callback, value) end
	end
	function obj:Get() return value end
	function obj:SetDisabled(disabled, reason)
		obj._disabled = disabled
		obj._disabledReason = reason
		Util.Tween(row, 0.15, { BackgroundTransparency = disabled and 0.55 or 0 })
	end

	if opts.Flag then
		CoreUI.Flags[opts.Flag] = default
		CoreUI.Options[opts.Flag] = obj
	end
	CoreUI:AttachTooltip(row, opts.Tooltip, function() return obj._disabled end, obj._disabledReason)
	return obj
end

--============================================================
-- ELEMENT: DROPDOWN
--============================================================

local function CreateDropdownBase(parent, theme, opts, multi)
	opts = opts or {}
	local options = opts.Options or {}
	local selected = multi and (opts.Default or {}) or opts.Default

	local row, controlArea = BuildRow(parent, theme, {
		Title = opts.Title, Description = opts.Description, Icon = opts.Icon,
		ControlWidth = opts.ControlWidth or 150,
	})

	local box = New("TextButton", {
		BackgroundColor3 = theme.Card,
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, 0, 0.5, 0),
		Size = UDim2.new(1, 0, 0, 30),
		Text = "",
		AutoButtonColor = false,
		Parent = controlArea,
	}, { Util.Corner(6), Util.Stroke(theme.Border, 1) })

	local function summaryText()
		if multi then
			if #selected == 0 then return opts.Placeholder or "None" end
			return table.concat(selected, ", ")
		else
			return selected and tostring(selected) or (opts.Placeholder or "Select...")
		end
	end

	local label = New("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 10, 0, 0),
		Size = UDim2.new(1, -30, 1, 0),
		Text = summaryText(),
		Font = theme.Font,
		TextSize = 13,
		TextColor3 = theme.Text,
		TextTruncate = Enum.TextTruncate.AtEnd,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = box,
	})
	New("TextLabel", {
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -8, 0.5, 0),
		Size = UDim2.fromOffset(14, 14),
		Text = "▾",
		TextColor3 = theme.SubText,
		Font = theme.Font,
		TextSize = 13,
		Parent = box,
	})

	local popup = New("Frame", {
		BackgroundColor3 = theme.Card,
		Visible = false,
		ZIndex = 500,
		Size = UDim2.new(0, 0, 0, 0),
		Parent = ScreenGui,
	}, { Util.Corner(6), Util.Stroke(theme.Border, 1), Util.Pad(4, 4, 4, 4) })

	local list = New("ScrollingFrame", {
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollBarThickness = 3,
		ZIndex = 500,
		Parent = popup,
	})
	New("UIListLayout", { Parent = list, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 2) })

	local optionButtons = {}

	local function isSelected(name)
		if multi then
			return table.find(selected, name) ~= nil
		else
			return selected == name
		end
	end

	local function refreshButtons()
		for name, btn in pairs(optionButtons) do
			btn.BackgroundColor3 = isSelected(name) and theme.Accent or theme.Card
			btn.TextColor3 = isSelected(name) and theme.AccentText or theme.Text
		end
		label.Text = summaryText()
	end

	local obj = { Instance = row, Flag = opts.Flag }
	local closePopup, openPopup

	local function choose(name)
		if multi then
			local idx = table.find(selected, name)
			if idx then
				table.remove(selected, idx)
			else
				table.insert(selected, name)
			end
		else
			selected = name
		end
		refreshButtons()
		if opts.Flag then CoreUI.Flags[opts.Flag] = selected end
		if opts.Callback then task.spawn(opts.Callback, selected) end
		if not multi then closePopup() end
	end

	function obj:Refresh(newOptions)
		options = newOptions
		for _, b in pairs(optionButtons) do b:Destroy() end
		optionButtons = {}
		for i, name in ipairs(options) do
			local optBtn = New("TextButton", {
				BackgroundColor3 = isSelected(name) and theme.Accent or theme.Card,
				Size = UDim2.new(1, 0, 0, 28),
				Text = "  " .. tostring(name),
				TextXAlignment = Enum.TextXAlignment.Left,
				Font = theme.Font,
				TextSize = 13,
				TextColor3 = isSelected(name) and theme.AccentText or theme.Text,
				AutoButtonColor = false,
				ZIndex = 500,
				LayoutOrder = i,
				Parent = list,
			}, { Util.Corner(4) })
			track(optBtn.MouseButton1Click:Connect(function() choose(name) end))
			optionButtons[name] = optBtn
		end
	end
	obj:Refresh(options)

	local open = false
	closePopup = function()
		open = false
		popup.Visible = false
	end
	openPopup = function()
		if obj._disabled then return end
		open = true
		local abs = box.AbsolutePosition
		local size = box.AbsoluteSize
		popup.Size = UDim2.fromOffset(size.X, math.min(#options * 30 + 8, 180))
		popup.Position = UDim2.fromOffset(abs.X, abs.Y + size.Y + 4)
		popup.Visible = true
	end

	track(box.MouseButton1Click:Connect(function()
		if open then closePopup() else openPopup() end
	end))
	track(UserInputService.InputBegan:Connect(function(input)
		if open and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
			local pos = UserInputService:GetMouseLocation()
			local pAbs, pSize = popup.AbsolutePosition, popup.AbsoluteSize
			local bAbs, bSize = box.AbsolutePosition, box.AbsoluteSize
			local inPopup = pos.X >= pAbs.X and pos.X <= pAbs.X + pSize.X and pos.Y >= pAbs.Y and pos.Y <= pAbs.Y + pSize.Y
			local inBox = pos.X >= bAbs.X and pos.X <= bAbs.X + bSize.X and pos.Y >= bAbs.Y and pos.Y <= bAbs.Y + bSize.Y
			if not inPopup and not inBox then closePopup() end
		end
	end))

	function obj:Set(value, fireCallback)
		selected = value
		refreshButtons()
		if opts.Flag then CoreUI.Flags[opts.Flag] = selected end
		if fireCallback ~= false and opts.Callback then task.spawn(opts.Callback, selected) end
	end
	function obj:Get() return selected end
	function obj:SetDisabled(disabled, reason)
		obj._disabled = disabled
		obj._disabledReason = reason
		Util.Tween(row, 0.15, { BackgroundTransparency = disabled and 0.55 or 0 })
	end

	if opts.Flag then
		CoreUI.Flags[opts.Flag] = selected
		CoreUI.Options[opts.Flag] = obj
	end
	CoreUI:AttachTooltip(row, opts.Tooltip, function() return obj._disabled end, obj._disabledReason)
	return obj
end

--============================================================
-- ELEMENT: KEYBIND
--============================================================

local function CreateKeybind(parent, theme, opts)
	opts = opts or {}
	local currentKey = opts.Default
	local mode = opts.Mode or "Toggle"
	local boundState = false

	local row, controlArea = BuildRow(parent, theme, {
		Title = opts.Title, Description = opts.Description, Icon = opts.Icon,
		ControlWidth = 90,
	})

	local btn = New("TextButton", {
		BackgroundColor3 = theme.Card,
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, 0, 0.5, 0),
		Size = UDim2.new(1, 0, 0, 28),
		Text = currentKey and currentKey.Name or "None",
		Font = theme.Font,
		TextSize = 12,
		TextColor3 = theme.SubText,
		AutoButtonColor = false,
		Parent = controlArea,
	}, { Util.Corner(6), Util.Stroke(theme.Border, 1) })

	local listening = false
	local obj = { Instance = row, Flag = opts.Flag }

	track(btn.MouseButton1Click:Connect(function()
		listening = true
		btn.Text = "..."
		btn.TextColor3 = theme.Accent
	end))

	track(UserInputService.InputBegan:Connect(function(input, gpe)
		if listening then
			if input.UserInputType == Enum.UserInputType.Keyboard then
				currentKey = input.KeyCode
				btn.Text = currentKey.Name
				btn.TextColor3 = theme.SubText
				listening = false
				if opts.Flag then CoreUI.Flags[opts.Flag .. "_Key"] = currentKey.Name end
				if opts.ChangedCallback then task.spawn(opts.ChangedCallback, currentKey) end
			end
			return
		end
		if gpe then return end
		if currentKey and input.KeyCode == currentKey then
			if mode == "Toggle" then
				boundState = not boundState
				if opts.Flag then CoreUI.Flags[opts.Flag] = boundState end
				if opts.Callback then task.spawn(opts.Callback, boundState) end
			elseif mode == "Hold" or mode == "Always" then
				if opts.Callback then task.spawn(opts.Callback, true) end
			end
		end
	end))
	track(UserInputService.InputEnded:Connect(function(input)
		if currentKey and input.KeyCode == currentKey and mode == "Hold" then
			if opts.Callback then task.spawn(opts.Callback, false) end
		end
	end))

	function obj:Set(keyCode)
		currentKey = keyCode
		btn.Text = keyCode and keyCode.Name or "None"
	end
	function obj:Get() return currentKey, boundState end

	table.insert(CoreUI._KeybindElements, { Title = opts.Title, Object = obj })
	if opts.Flag then CoreUI.Options[opts.Flag] = obj end
	CoreUI:AttachTooltip(row, opts.Tooltip)
	return obj
end

--============================================================
-- ELEMENT: COLOR PICKER
--============================================================

local function CreateColorPicker(parent, theme, opts)
	opts = opts or {}
	local color = opts.Default or Color3.fromRGB(255, 255, 255)
	local h, s, v = Color3.toHSV(color)

	local row, controlArea = BuildRow(parent, theme, {
		Title = opts.Title, Description = opts.Description, Icon = opts.Icon,
		ControlWidth = 44,
	})

	local swatch = New("TextButton", {
		BackgroundColor3 = color,
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, 0, 0.5, 0),
		Size = UDim2.fromOffset(36, 28),
		Text = "",
		AutoButtonColor = false,
		Parent = controlArea,
	}, { Util.Corner(6), Util.Stroke(theme.Border, 1) })

	local popup = New("Frame", {
		BackgroundColor3 = theme.Card,
		Visible = false,
		ZIndex = 500,
		Size = UDim2.fromOffset(220, 190),
		Parent = ScreenGui,
	}, { Util.Corner(8), Util.Stroke(theme.Border, 1), Util.Pad(10, 10, 10, 10) })

	local svBox = New("Frame", {
		BackgroundColor3 = Color3.fromHSV(h, 1, 1),
		Size = UDim2.new(1, 0, 0, 110),
		ZIndex = 500,
		Parent = popup,
	}, { Util.Corner(6) })
	local whiteGrad = New("Frame", {
		BackgroundColor3 = Color3.new(1, 1, 1),
		Size = UDim2.fromScale(1, 1),
		ZIndex = 500,
		Parent = svBox,
	}, {
		Util.Corner(6),
		New("UIGradient", { Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 1),
		}) }),
	})
	New("Frame", {
		BackgroundColor3 = Color3.new(0, 0, 0),
		Size = UDim2.fromScale(1, 1),
		ZIndex = 500,
		Parent = whiteGrad,
	}, {
		Util.Corner(6),
		New("UIGradient", {
			Rotation = 90,
			Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, 0),
			}),
		}),
	})
	local svCursor = New("Frame", {
		BackgroundColor3 = Color3.new(1, 1, 1),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Size = UDim2.fromOffset(10, 10),
		Position = UDim2.new(s, 0, 1 - v, 0),
		ZIndex = 501,
		Parent = svBox,
	}, { Util.Corner(5), Util.Stroke(Color3.new(0, 0, 0), 1) })

	local hueBar = New("Frame", {
		Size = UDim2.new(1, 0, 0, 14),
		Position = UDim2.new(0, 0, 0, 118),
		ZIndex = 500,
		Parent = popup,
	}, {
		Util.Corner(6),
		New("UIGradient", { Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0.000, Color3.fromRGB(255,0,0)),
			ColorSequenceKeypoint.new(0.167, Color3.fromRGB(255,255,0)),
			ColorSequenceKeypoint.new(0.333, Color3.fromRGB(0,255,0)),
			ColorSequenceKeypoint.new(0.500, Color3.fromRGB(0,255,255)),
			ColorSequenceKeypoint.new(0.667, Color3.fromRGB(0,0,255)),
			ColorSequenceKeypoint.new(0.833, Color3.fromRGB(255,0,255)),
			ColorSequenceKeypoint.new(1.000, Color3.fromRGB(255,0,0)),
		}) }),
	})
	local hueCursor = New("Frame", {
		BackgroundColor3 = Color3.new(1, 1, 1),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Size = UDim2.fromOffset(6, 18),
		Position = UDim2.new(h, 0, 0.5, 0),
		ZIndex = 501,
		Parent = hueBar,
	}, { Util.Corner(3), Util.Stroke(Color3.new(0, 0, 0), 1) })

	local hexBox = New("TextBox", {
		BackgroundColor3 = theme.CardAlt,
		Position = UDim2.new(0, 0, 0, 142),
		Size = UDim2.new(1, 0, 0, 28),
		Text = string.format("#%02X%02X%02X", color.R * 255, color.G * 255, color.B * 255),
		Font = theme.Font,
		TextSize = 13,
		TextColor3 = theme.Text,
		ClearTextOnFocus = false,
		ZIndex = 500,
		Parent = popup,
	}, { Util.Corner(6), Util.Stroke(theme.Border, 1) })

	local obj = { Instance = row, Flag = opts.Flag }

	local function apply(fireCallback)
		color = Color3.fromHSV(h, s, v)
		swatch.BackgroundColor3 = color
		svBox.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
		hexBox.Text = string.format("#%02X%02X%02X", color.R * 255, color.G * 255, color.B * 255)
		if opts.Flag then CoreUI.Flags[opts.Flag] = color end
		if fireCallback ~= false and opts.Callback then task.spawn(opts.Callback, color) end
	end

	local draggingSV, draggingHue = false, false
	track(svBox.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			draggingSV = true
		end
	end))
	track(hueBar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			draggingHue = true
		end
	end))
	track(UserInputService.InputEnded:Connect(function() draggingSV, draggingHue = false, false end))
	track(UserInputService.InputChanged:Connect(function(input)
		if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then return end
		if draggingSV then
			local rel = (input.Position - svBox.AbsolutePosition)
			s = Util.Clamp(rel.X / svBox.AbsoluteSize.X, 0, 1)
			v = Util.Clamp(1 - rel.Y / svBox.AbsoluteSize.Y, 0, 1)
			svCursor.Position = UDim2.new(s, 0, 1 - v, 0)
			apply()
		elseif draggingHue then
			local rel = (input.Position - hueBar.AbsolutePosition)
			h = Util.Clamp(rel.X / hueBar.AbsoluteSize.X, 0, 1)
			hueCursor.Position = UDim2.new(h, 0, 0.5, 0)
			apply()
		end
	end))

	track(hexBox.FocusLost:Connect(function()
		local hex = hexBox.Text:gsub("#", "")
		if #hex == 6 and hex:match("^%x+$") then
			local r = tonumber(hex:sub(1, 2), 16) / 255
			local g = tonumber(hex:sub(3, 4), 16) / 255
			local b = tonumber(hex:sub(5, 6), 16) / 255
			h, s, v = Color3.toHSV(Color3.new(r, g, b))
			svCursor.Position = UDim2.new(s, 0, 1 - v, 0)
			hueCursor.Position = UDim2.new(h, 0, 0.5, 0)
			apply()
		else
			apply(false)
		end
	end))

	local open = false
	track(swatch.MouseButton1Click:Connect(function()
		open = not open
		if open then
			local abs, size = swatch.AbsolutePosition, swatch.AbsoluteSize
			popup.Position = UDim2.fromOffset(abs.X - 220 + size.X, abs.Y + size.Y + 4)
		end
		popup.Visible = open
	end))
	track(UserInputService.InputBegan:Connect(function(input)
		if open and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
			local pos = UserInputService:GetMouseLocation()
			local pAbs, pSize = popup.AbsolutePosition, popup.AbsoluteSize
			local inPopup = pos.X >= pAbs.X and pos.X <= pAbs.X + pSize.X and pos.Y >= pAbs.Y and pos.Y <= pAbs.Y + pSize.Y
			local sAbs, sSize = swatch.AbsolutePosition, swatch.AbsoluteSize
			local inSwatch = pos.X >= sAbs.X and pos.X <= sAbs.X + sSize.X and pos.Y >= sAbs.Y and pos.Y <= sAbs.Y + sSize.Y
			if not inPopup and not inSwatch then
				open = false
				popup.Visible = false
			end
		end
	end))

	function obj:Set(newColor, fireCallback)
		h, s, v = Color3.toHSV(newColor)
		svCursor.Position = UDim2.new(s, 0, 1 - v, 0)
		hueCursor.Position = UDim2.new(h, 0, 0.5, 0)
		apply(fireCallback)
	end
	function obj:Get() return color end

	if opts.Flag then
		CoreUI.Flags[opts.Flag] = color
		CoreUI.Options[opts.Flag] = obj
	end
	CoreUI:AttachTooltip(row, opts.Tooltip)
	return obj
end

--============================================================
-- GROUPBOX
--============================================================

local Groupbox = {}
Groupbox.__index = Groupbox

local function NewGroupbox(parent, theme, title, description)
	local frame = New("Frame", {
		BackgroundColor3 = theme.Card,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		Parent = parent,
	}, { Util.Corner(10), Util.Stroke(theme.Border, 1), Util.Pad(14, 14, 14, 14) })

	New("UIListLayout", {
		Parent = frame,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 8),
	})

	if title then
		local header = New("Frame", {
			BackgroundTransparency = 1,
			AutomaticSize = Enum.AutomaticSize.Y,
			Size = UDim2.new(1, 0, 0, 0),
			LayoutOrder = 0,
			Parent = frame,
		})
		New("UIListLayout", { Parent = header, Padding = UDim.new(0, 2) })
		New("TextLabel", {
			BackgroundTransparency = 1,
			Text = title,
			Font = theme.FontBold,
			TextSize = 17,
			TextColor3 = theme.Text,
			TextXAlignment = Enum.TextXAlignment.Left,
			Size = UDim2.new(1, 0, 0, 22),
			Parent = header,
		})
		if description then
			New("TextLabel", {
				BackgroundTransparency = 1,
				Text = description,
				Font = theme.Font,
				TextSize = 13,
				TextWrapped = true,
				TextColor3 = theme.SubText,
				TextXAlignment = Enum.TextXAlignment.Left,
				AutomaticSize = Enum.AutomaticSize.Y,
				Size = UDim2.new(1, 0, 0, 0),
				Parent = header,
			})
		end
	end

	return setmetatable({ Instance = frame, Theme = theme, _order = 1 }, Groupbox)
end

local function nextOrder(self)
	self._order = self._order + 1
	return self._order
end

function Groupbox:AddLabel(text)
	local o = CreateLabel(self.Instance, self.Theme, text)
	o.Instance.LayoutOrder = nextOrder(self)
	return o
end
function Groupbox:AddDivider()
	local d = CreateDivider(self.Instance, self.Theme)
	d.LayoutOrder = nextOrder(self)
	return { Instance = d }
end
function Groupbox:AddWarningBox(opts)
	local o = CreateWarningBox(self.Instance, self.Theme, opts)
	o.Instance.LayoutOrder = nextOrder(self)
	return o
end
function Groupbox:AddButton(opts)
	local o = CreateButton(self.Instance, self.Theme, opts)
	o.Instance.LayoutOrder = nextOrder(self)
	return o
end
function Groupbox:AddToggle(opts)
	local o = CreateToggleBase(self.Instance, self.Theme, opts, false)
	o.Instance.LayoutOrder = nextOrder(self)
	return o
end
function Groupbox:AddCheckbox(opts)
	local o = CreateToggleBase(self.Instance, self.Theme, opts, true)
	o.Instance.LayoutOrder = nextOrder(self)
	return o
end
function Groupbox:AddInput(opts)
	local o = CreateInput(self.Instance, self.Theme, opts)
	o.Instance.LayoutOrder = nextOrder(self)
	return o
end
function Groupbox:AddSlider(opts)
	local o = CreateSlider(self.Instance, self.Theme, opts)
	o.Instance.LayoutOrder = nextOrder(self)
	return o
end
function Groupbox:AddDropdown(opts)
	local o = CreateDropdownBase(self.Instance, self.Theme, opts, false)
	o.Instance.LayoutOrder = nextOrder(self)
	return o
end
function Groupbox:AddMultiDropdown(opts)
	local o = CreateDropdownBase(self.Instance, self.Theme, opts, true)
	o.Instance.LayoutOrder = nextOrder(self)
	return o
end
function Groupbox:AddKeybind(opts)
	local o = CreateKeybind(self.Instance, self.Theme, opts)
	o.Instance.LayoutOrder = nextOrder(self)
	return o
end
function Groupbox:AddColorPicker(opts)
	local o = CreateColorPicker(self.Instance, self.Theme, opts)
	o.Instance.LayoutOrder = nextOrder(self)
	return o
end

--============================================================
-- TABBOX
--============================================================

local function NewTabbox(parent, theme)
	local outer = New("Frame", {
		BackgroundColor3 = theme.Card,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		Parent = parent,
	}, { Util.Corner(10), Util.Stroke(theme.Border, 1), Util.Pad(10, 10, 10, 10) })
	New("UIListLayout", { Parent = outer, Padding = UDim.new(0, 8) })

	local pillBar = New("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 28),
		LayoutOrder = 0,
		Parent = outer,
	})
	New("UIListLayout", { Parent = pillBar, FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 6) })

	local pages = New("Frame", {
		BackgroundTransparency = 1,
		AutomaticSize = Enum.AutomaticSize.Y,
		Size = UDim2.new(1, 0, 0, 0),
		LayoutOrder = 1,
		Parent = outer,
	})

	local tabbox = { Instance = outer, _tabs = {}, _active = nil }

	function tabbox:AddTab(name)
		local pill = New("TextButton", {
			BackgroundColor3 = theme.CardAlt,
			AutomaticSize = Enum.AutomaticSize.X,
			Size = UDim2.new(0, 0, 1, 0),
			Text = "  " .. name .. "  ",
			Font = theme.Font,
			TextSize = 13,
			TextColor3 = theme.SubText,
			AutoButtonColor = false,
			Parent = pillBar,
		}, { Util.Corner(6) })

		local page = New("Frame", {
			BackgroundTransparency = 1,
			AutomaticSize = Enum.AutomaticSize.Y,
			Size = UDim2.new(1, 0, 0, 0),
			Visible = false,
			Parent = pages,
		})
		New("UIListLayout", { Parent = page, Padding = UDim.new(0, 8) })

		local gb = setmetatable({ Instance = page, Theme = theme, _order = 1 }, Groupbox)

		local function activate()
			for _, t in pairs(tabbox._tabs) do
				t.Page.Visible = false
				t.Pill.BackgroundColor3 = theme.CardAlt
				t.Pill.TextColor3 = theme.SubText
			end
			page.Visible = true
			pill.BackgroundColor3 = theme.Accent
			pill.TextColor3 = theme.AccentText
			tabbox._active = name
		end

		track(pill.MouseButton1Click:Connect(activate))
		tabbox._tabs[name] = { Pill = pill, Page = page, Group = gb }
		if not tabbox._active then activate() end
		return gb
	end

	return tabbox
end

--============================================================
-- TAB (declaration only — methods added later)
--============================================================

local Tab = {}
Tab.__index = Tab

--============================================================
-- WINDOW
--============================================================

local Window = {}
Window.__index = Window

function CoreUI:CreateWindow(config)
	config = config or {}
	local theme = self.Theme
	local self_ = self

	local minSize = config.MinSize or Vector2.new(720, 460)
	local size = config.Size or Vector2.new(960, 600)

	local main = New("Frame", {
		Name = "Window",
		BackgroundColor3 = theme.Background,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(size.X, size.Y),
		ClipsDescendants = true,
		Parent = ScreenGui,
	}, { Util.Corner(12), Util.Stroke(theme.Border, 1), GlobalScale })

	local topbar = New("Frame", {
		BackgroundColor3 = theme.Topbar,
		Size = UDim2.new(1, 0, 0, 52),
		Parent = main,
	}, { Util.Pad(0, 16, 0, 16) })
	New("Frame", { BackgroundColor3 = theme.Border, Size = UDim2.new(1, 0, 0, 1), Position = UDim2.new(0, 0, 1, -1), Parent = topbar })

	if config.Icon then
		local logo = Icons.Get(config.Icon, 26, { ImageColor3 = theme.Accent })
		if logo then
			logo.Position = UDim2.new(0, 0, 0.5, 0)
			logo.AnchorPoint = Vector2.new(0, 0.5)
			logo.Parent = topbar
		end
	end

	local titleX = config.Icon and 36 or 0
	New("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.new(0, titleX, 0, 4),
		Size = UDim2.new(0, 300, 0, 20),
		Text = config.Title or "CoreUI",
		Font = theme.FontBold,
		TextSize = 17,
		TextColor3 = theme.Text,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = topbar,
	})
	New("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.new(0, titleX, 0, 24),
		Size = UDim2.new(0, 300, 0, 16),
		Text = config.Subtitle or "",
		Font = theme.Font,
		TextSize = 12,
		TextColor3 = theme.SubText,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = topbar,
	})

	local statusText = New("TextLabel", {
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -76, 0.5, 0),
		Size = UDim2.new(0, 160, 0, 20),
		Text = config.Status or "",
		Font = theme.Font,
		TextSize = 13,
		TextColor3 = theme.SubText,
		TextXAlignment = Enum.TextXAlignment.Right,
		Parent = topbar,
	})

	local closeBtn = New("TextButton", {
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, 0, 0.5, 0),
		Size = UDim2.fromOffset(28, 28),
		Text = "✕",
		TextColor3 = theme.SubText,
		Font = theme.FontBold,
		TextSize = 15,
		Parent = topbar,
	})
	local minimizeBtn = New("TextButton", {
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -32, 0.5, 0),
		Size = UDim2.fromOffset(28, 28),
		Text = "—",
		TextColor3 = theme.SubText,
		Font = theme.FontBold,
		TextSize = 15,
		Parent = topbar,
	})

	local body = New("Frame", {
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 0, 0, 52),
		Size = UDim2.new(1, 0, 1, -52),
		Parent = main,
	})

	local sidebar = New("ScrollingFrame", {
		BackgroundColor3 = theme.Sidebar,
		Size = UDim2.new(0, 190, 1, 0),
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollBarThickness = 3,
		BorderSizePixel = 0,
		Parent = body,
	}, { Util.Pad(10, 10, 10, 10) })
	New("Frame", { BackgroundColor3 = theme.Border, Size = UDim2.new(0, 1, 1, 0), Position = UDim2.new(1, 0, 0, 0), Parent = sidebar })
	New("UIListLayout", { Parent = sidebar, Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder })

	local contentHolder = New("Frame", {
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 190, 0, 0),
		Size = UDim2.new(1, -190, 1, 0),
		Parent = body,
	}, { Util.Pad(16, 16, 16, 16) })

	local grip = New("Frame", {
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(1, 1),
		Position = UDim2.new(1, 0, 1, 0),
		Size = UDim2.fromOffset(18, 18),
		ZIndex = 50,
		Parent = main,
	})
	New("TextLabel", {
		BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), Text = "◢",
		TextColor3 = theme.MutedText, Font = theme.Font, TextSize = 14, Parent = grip,
	})

	Util.Draggify(main, topbar)

	do
		local resizing = false
		track(grip.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				resizing = true
			end
		end))
		track(UserInputService.InputChanged:Connect(function(input)
			if resizing and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
				local newX = math.max(minSize.X, input.Position.X - main.AbsolutePosition.X)
				local newY = math.max(minSize.Y, input.Position.Y - main.AbsolutePosition.Y)
				main.Size = UDim2.fromOffset(newX, newY)
			end
		end))
		track(UserInputService.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				resizing = false
			end
		end))
	end

	local win = setmetatable({
		Instance = main,
		Theme = theme,
		Sidebar = sidebar,
		ContentHolder = contentHolder,
		_tabs = {},
		_activeTab = nil,
		Visible = true,
	}, Window)

	local minimized = false
	track(closeBtn.MouseButton1Click:Connect(function() win:SetVisible(false) end))
	track(minimizeBtn.MouseButton1Click:Connect(function()
		minimized = not minimized
		Util.Tween(main, 0.18, { Size = minimized and UDim2.fromOffset(size.X, 52) or UDim2.fromOffset(main.AbsoluteSize.X, size.Y) })
		body.Visible = not minimized
		grip.Visible = not minimized
	end))
	track(closeBtn.MouseEnter:Connect(function() closeBtn.TextColor3 = theme.Danger end))
	track(closeBtn.MouseLeave:Connect(function() closeBtn.TextColor3 = theme.SubText end))

	track(UserInputService.InputBegan:Connect(function(input, gpe)
		if gpe then return end
		if input.KeyCode == self_.ToggleKeybind then
			win:SetVisible(not win.Visible)
		end
	end))

	if Util.IsMobile() then
		local bubble = New("TextButton", {
			BackgroundColor3 = theme.Accent,
			Size = UDim2.fromOffset(48, 48),
			Position = UDim2.new(0, 20, 0, 120),
			Text = "☰",
			TextColor3 = theme.AccentText,
			Font = theme.FontBold,
			TextSize = 20,
			ZIndex = 9000,
			Parent = ScreenGui,
		}, { Util.Corner(24) })
		Util.Draggify(bubble, bubble)
		track(bubble.MouseButton1Click:Connect(function()
			win:SetVisible(not win.Visible)
		end))
	end

	function win:SetVisible(v)
		self.Visible = v
		main.Visible = v
	end

	function win:SetStatus(text)
		statusText.Text = text or ""
	end

	function win:CreateTab(name, iconName)
		local page = New("ScrollingFrame", {
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(1, 1),
			CanvasSize = UDim2.new(),
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			ScrollBarThickness = 3,
			Visible = false,
			Parent = contentHolder,
		})

		local columns = New("Frame", {
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			Parent = page,
		})
		New("UIListLayout", { Parent = columns, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 12) })

		local sideBtn = New("TextButton", {
			BackgroundColor3 = theme.Sidebar,
			Size = UDim2.new(1, 0, 0, 36),
			Text = "",
			AutoButtonColor = false,
			Parent = sidebar,
		}, { Util.Corner(6) })

		local icon = Icons.Get(iconName, 16, { ImageColor3 = theme.SubText })
		if icon then
			icon.Position = UDim2.new(0, 10, 0.5, 0)
			icon.AnchorPoint = Vector2.new(0, 0.5)
			icon.Parent = sideBtn
		end
		local sideLabel = New("TextLabel", {
			BackgroundTransparency = 1,
			Position = UDim2.new(0, icon and 34 or 12, 0, 0),
			Size = UDim2.new(1, -34, 1, 0),
			Text = name,
			Font = theme.Font,
			TextSize = 14,
			TextColor3 = theme.SubText,
			TextXAlignment = Enum.TextXAlignment.Left,
			Parent = sideBtn,
		})

		local tabObj = setmetatable({ Page = page, Columns = columns, Theme = theme, _leftCol = nil, _rightCol = nil }, Tab)

		local function activate()
			for _, t in pairs(win._tabs) do
				t.Page.Visible = false
				t.SideBtn.BackgroundColor3 = theme.Sidebar
				t.SideLabel.TextColor3 = theme.SubText
			end
			page.Visible = true
			sideBtn.BackgroundColor3 = theme.Accent
			sideLabel.TextColor3 = theme.AccentText
			win._activeTab = name
		end
		track(sideBtn.MouseButton1Click:Connect(activate))

		win._tabs[name] = { Page = page, SideBtn = sideBtn, SideLabel = sideLabel }
		if not win._activeTab then activate() end

		return tabObj
	end

	self._Windows = self._Windows or {}
	table.insert(self._Windows, win)
	self.Loaded = true
	return win
end

--============================================================
-- TAB METHODS
--============================================================

function Tab:CreateGroupbox(title, description)
	return NewGroupbox(self.Columns, self.Theme, title, description)
end

function Tab:_getSplit()
	if not self._split then
		self._split = New("Frame", {
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			Parent = self.Columns,
		})
		New("UIListLayout", {
			Parent = self._split, FillDirection = Enum.FillDirection.Horizontal,
			Padding = UDim.new(0, 12), SortOrder = Enum.SortOrder.LayoutOrder,
		})
		self._leftHolder = New("Frame", {
			BackgroundTransparency = 1, Size = UDim2.new(0.5, -6, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y, Parent = self._split,
		})
		New("UIListLayout", { Parent = self._leftHolder, Padding = UDim.new(0, 12) })
		self._rightHolder = New("Frame", {
			BackgroundTransparency = 1, Size = UDim2.new(0.5, -6, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y, Parent = self._split,
		})
		New("UIListLayout", { Parent = self._rightHolder, Padding = UDim.new(0, 12) })
	end
	return self._leftHolder, self._rightHolder
end

function Tab:CreateLeftGroupbox(title, description)
	local left = self:_getSplit()
	return NewGroupbox(left, self.Theme, title, description)
end

function Tab:CreateRightGroupbox(title, description)
	local _, right = self:_getSplit()
	return NewGroupbox(right, self.Theme, title, description)
end

function Tab:CreateTabbox()
	return NewTabbox(self.Columns, self.Theme)
end

function Tab:CreateWarningBox(opts)
	return CreateWarningBox(self.Columns, self.Theme, opts)
end

--============================================================
-- BUILT-IN KEYBIND MENU
--============================================================

function CoreUI:ShowKeybindMenu()
	local theme = self.Theme
	if self._keybindMenu then
		self._keybindMenu.Visible = not self._keybindMenu.Visible
		return
	end

	local menu = New("Frame", {
		BackgroundColor3 = theme.Card,
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -20, 0, 70),
		Size = UDim2.fromOffset(240, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		ZIndex = 400,
		Parent = ScreenGui,
	}, { Util.Corner(10), Util.Stroke(theme.Border, 1), Util.Pad(12, 12, 12, 12) })
	New("UIListLayout", { Parent = menu, Padding = UDim.new(0, 6) })
	New("TextLabel", {
		BackgroundTransparency = 1,
		Text = "Keybinds",
		Font = theme.FontBold,
		TextSize = 15,
		TextColor3 = theme.Text,
		TextXAlignment = Enum.TextXAlignment.Left,
		Size = UDim2.new(1, 0, 0, 20),
		Parent = menu,
	})
	for _, entry in ipairs(self._KeybindElements) do
		local row = New("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 20), Parent = menu })
		New("TextLabel", {
			BackgroundTransparency = 1, Text = entry.Title, Size = UDim2.new(0.6, 0, 1, 0),
			Font = theme.Font, TextSize = 13, TextColor3 = theme.SubText, TextXAlignment = Enum.TextXAlignment.Left, Parent = row,
		})
		local key = entry.Object:Get()
		New("TextLabel", {
			BackgroundTransparency = 1, Text = key and key.Name or "None",
			AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, 0, 0, 0), Size = UDim2.new(0.4, 0, 1, 0),
			Font = theme.FontBold, TextSize = 13, TextColor3 = theme.Accent, TextXAlignment = Enum.TextXAlignment.Right, Parent = row,
		})
	end
	self._keybindMenu = menu
end

--============================================================
-- RETURN
--============================================================

CoreUI:EnableAutoDPI(true)

return CoreUI
