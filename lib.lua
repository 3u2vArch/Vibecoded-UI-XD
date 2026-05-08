--[[
	UI Library - Production Ready Roblox UI Framework
	Version: 1.0.0
	Compatible with all major executors
	Features: Multiple windows, tabs, animations, themes, config system
--]]

local Library = {}
Library.__index = Library

-- Services
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

-- Theme definitions
Library.Themes = {
	Dark = {
		Background = Color3.fromRGB(20, 20, 25),
		Secondary = Color3.fromRGB(30, 30, 35),
		Tertiary = Color3.fromRGB(40, 40, 45),
		Text = Color3.fromRGB(220, 220, 220),
		TextSecondary = Color3.fromRGB(160, 160, 160),
		Accent = Color3.fromRGB(80, 130, 255),
		AccentHover = Color3.fromRGB(100, 150, 255),
		Border = Color3.fromRGB(50, 50, 55),
		Shadow = Color3.fromRGB(0, 0, 0),
		WindowBar = Color3.fromRGB(25, 25, 30),
		Glass = Color3.fromRGB(255, 255, 255)
	},
	Light = {
		Background = Color3.fromRGB(235, 235, 240),
		Secondary = Color3.fromRGB(245, 245, 250),
		Tertiary = Color3.fromRGB(225, 225, 230),
		Text = Color3.fromRGB(30, 30, 35),
		TextSecondary = Color3.fromRGB(100, 100, 105),
		Accent = Color3.fromRGB(60, 110, 240),
		AccentHover = Color3.fromRGB(80, 130, 255),
		Border = Color3.fromRGB(200, 200, 205),
		Shadow = Color3.fromRGB(150, 150, 155),
		WindowBar = Color3.fromRGB(225, 225, 230),
		Glass = Color3.fromRGB(255, 255, 255)
	},
	Glass = {
		Background = Color3.fromRGB(30, 30, 35),
		Secondary = Color3.fromRGB(255, 255, 255),
		Tertiary = Color3.fromRGB(255, 255, 255),
		Text = Color3.fromRGB(255, 255, 255),
		TextSecondary = Color3.fromRGB(200, 200, 200),
		Accent = Color3.fromRGB(100, 180, 255),
		AccentHover = Color3.fromRGB(130, 200, 255),
		Border = Color3.fromRGB(255, 255, 255),
		Shadow = Color3.fromRGB(0, 0, 0),
		WindowBar = Color3.fromRGB(255, 255, 255),
		Glass = Color3.fromRGB(255, 255, 255)
	},
	Midnight = {
		Background = Color3.fromRGB(10, 10, 20),
		Secondary = Color3.fromRGB(15, 15, 30),
		Tertiary = Color3.fromRGB(25, 25, 45),
		Text = Color3.fromRGB(200, 200, 220),
		TextSecondary = Color3.fromRGB(120, 120, 140),
		Accent = Color3.fromRGB(120, 80, 255),
		AccentHover = Color3.fromRGB(140, 100, 255),
		Border = Color3.fromRGB(40, 40, 60),
		Shadow = Color3.fromRGB(0, 0, 0),
		WindowBar = Color3.fromRGB(15, 15, 25),
		Glass = Color3.fromRGB(100, 100, 255)
	},
	Vibrant = {
		Background = Color3.fromRGB(15, 15, 25),
		Secondary = Color3.fromRGB(25, 25, 40),
		Tertiary = Color3.fromRGB(35, 35, 55),
		Text = Color3.fromRGB(240, 240, 255),
		TextSecondary = Color3.fromRGB(180, 180, 200),
		Accent = Color3.fromRGB(255, 80, 130),
		AccentHover = Color3.fromRGB(255, 110, 150),
		Border = Color3.fromRGB(60, 60, 80),
		Shadow = Color3.fromRGB(0, 0, 0),
		WindowBar = Color3.fromRGB(20, 20, 30),
		Glass = Color3.fromRGB(255, 80, 130)
	}
}

Library.CurrentTheme = "Dark"

-- Utility functions
local function CreateInstance(className, properties)
	local instance = Instance.new(className)
	for prop, value in pairs(properties or {}) do
		if prop == "Children" then
			for _, child in ipairs(value) do
				child.Parent = instance
			end
		else
			instance[prop] = value
		end
	end
	return instance
end

local function ApplyTheme(object, property)
	local theme = Library.Themes[Library.CurrentTheme]
	return theme[property] or theme.Accent
end

local function Tween(instance, tweenInfo, properties)
	local tween = TweenService:Create(instance, TweenInfo.new(
		tweenInfo.Time or 0.3,
		tweenInfo.Style or Enum.EasingStyle.Quad,
		tweenInfo.Direction or Enum.EasingDirection.Out
	), properties)
	tween:Play()
	return tween
end

-- Notification system
function Library:Notify(title, message, duration)
	duration = duration or 3
	local theme = Library.Themes[Library.CurrentTheme]
	
	local notification = CreateInstance("Frame", {
		Parent = self.Gui,
		BackgroundColor3 = theme.Secondary,
		BorderSizePixel = 0,
		Position = UDim2.new(1, 20, 1, -20),
		Size = UDim2.new(0, 280, 0, 70),
		AnchorPoint = Vector2.new(1, 1),
		ZIndex = 100,
	})
	
	CreateInstance("UICorner", {
		CornerRadius = UDim.new(0, 8),
		Parent = notification
	})
	
	CreateInstance("UIStroke", {
		Thickness = 1,
		Color = theme.Border,
		Parent = notification
	})
	
	CreateInstance("TextLabel", {
		Parent = notification,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 15, 0, 10),
		Size = UDim2.new(1, -30, 0, 20),
		Font = Enum.Font.GothamBold,
		Text = title,
		TextColor3 = theme.Text,
		TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Left,
	})
	
	CreateInstance("TextLabel", {
		Parent = notification,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 15, 0, 30),
		Size = UDim2.new(1, -30, 0, 30),
		Font = Enum.Font.Gotham,
		Text = message or "",
		TextColor3 = theme.TextSecondary,
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextWrapped = true,
	})
	
	local progressBar = CreateInstance("Frame", {
		Parent = notification,
		BackgroundColor3 = theme.Accent,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 8, 1, -6),
		Size = UDim2.new(1, -16, 0, 3),
		ZIndex = 101,
	})
	
	CreateInstance("UICorner", {
		CornerRadius = UDim.new(1, 0),
		Parent = progressBar
	})
	
	notification.Position = UDim2.new(1, 300, 1, -20)
	Tween(notification, {Time = 0.4, Style = Enum.EasingStyle.Back}, {Position = UDim2.new(1, -20, 1, -20)})
	
	Tween(progressBar, {Time = duration}, {Size = UDim2.new(0, 0, 0, 3)})
	
	task.delay(duration, function()
		Tween(notification, {Time = 0.3}, {Position = UDim2.new(1, 300, 1, -20)})
		task.wait(0.3)
		notification:Destroy()
	end)
end

-- Dialog system
function Library:Dialog(title, message, buttons)
	local theme = Library.Themes[Library.CurrentTheme]
	
	local overlay = CreateInstance("Frame", {
		Parent = self.Gui,
		BackgroundColor3 = Color3.fromRGB(0, 0, 0),
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 1, 0),
		ZIndex = 200,
	})
	
	local dialog = CreateInstance("Frame", {
		Parent = overlay,
		BackgroundColor3 = theme.Secondary,
		BorderSizePixel = 0,
		Position = UDim2.new(0.5, 0, 0.5, 0),
		Size = UDim2.new(0, 300, 0, 150),
		AnchorPoint = Vector2.new(0.5, 0.5),
		ZIndex = 201,
	})
	
	CreateInstance("UICorner", {
		CornerRadius = UDim.new(0, 12),
		Parent = dialog
	})
	
	CreateInstance("UIStroke", {
		Thickness = 1,
		Color = theme.Border,
		Parent = dialog
	})
	
	CreateInstance("TextLabel", {
		Parent = dialog,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 20, 0, 20),
		Size = UDim2.new(1, -40, 0, 25),
		Font = Enum.Font.GothamBold,
		Text = title,
		TextColor3 = theme.Text,
		TextSize = 16,
	})
	
	CreateInstance("TextLabel", {
		Parent = dialog,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 20, 0, 50),
		Size = UDim2.new(1, -40, 0, 45),
		Font = Enum.Font.Gotham,
		Text = message,
		TextColor3 = theme.TextSecondary,
		TextSize = 13,
		TextWrapped = true,
	})
	
	buttons = buttons or {
		{Text = "OK", Callback = function() end}
	}
	
	for i, button in ipairs(buttons) do
		local btnFrame = CreateInstance("TextButton", {
			Parent = dialog,
			BackgroundColor3 = i == 1 and theme.Accent or theme.Tertiary,
			BorderSizePixel = 0,
			Position = UDim2.new(0, 20 + (i-1)*140, 1, -45),
			Size = UDim2.new(0, 120, 0, 35),
			Text = "",
			AutoButtonColor = false,
		})
		
		CreateInstance("UICorner", {
			CornerRadius = UDim.new(0, 6),
			Parent = btnFrame
		})
		
		CreateInstance("TextLabel", {
			Parent = btnFrame,
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 1, 0),
			Font = Enum.Font.GothamBold,
			Text = button.Text,
			TextColor3 = i == 1 and Color3.fromRGB(255, 255, 255) or theme.Text,
			TextSize = 13,
		})
		
		btnFrame.MouseButton1Click:Connect(function()
			if button.Callback then
				button.Callback()
			end
			overlay:Destroy()
		end)
	end
	
	Tween(dialog, {Time = 0.3, Style = Enum.EasingStyle.Back}, {Size = UDim2.new(0, 300, 0, 150)})
	dialog.Size = UDim2.new(0, 0, 0, 0)
	Tween(dialog, {Time = 0.3, Style = Enum.EasingStyle.Back}, {Size = UDim2.new(0, 300, 0, 150)})
end

-- Loading spinner
function Library:ShowLoading(message)
	if self.LoadingFrame then
		self:HideLoading()
	end
	
	local theme = Library.Themes[Library.CurrentTheme]
	
	self.LoadingFrame = CreateInstance("Frame", {
		Parent = self.Gui,
		BackgroundColor3 = Color3.fromRGB(0, 0, 0),
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 1, 0),
		ZIndex = 300,
	})
	
	local spinner = CreateInstance("Frame", {
		Parent = self.LoadingFrame,
		BackgroundColor3 = theme.Secondary,
		BorderSizePixel = 0,
		Position = UDim2.new(0.5, 0, 0.5, 0),
		Size = UDim2.new(0, 150, 0, 100),
		AnchorPoint = Vector2.new(0.5, 0.5),
		ZIndex = 301,
	})
	
	CreateInstance("UICorner", {
		CornerRadius = UDim.new(0, 12),
		Parent = spinner
	})
	
	local spinnerIcon = CreateInstance("ImageLabel", {
		Parent = spinner,
		BackgroundTransparency = 1,
		Position = UDim2.new(0.5, 0, 0, 20),
		Size = UDim2.new(0, 30, 0, 30),
		AnchorPoint = Vector2.new(0.5, 0),
		Image = "rbxassetid://7072705936", -- Standard loading icon
	})
	
	CreateInstance("TextLabel", {
		Parent = spinner,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 10, 0, 60),
		Size = UDim2.new(1, -20, 0, 25),
		Font = Enum.Font.Gotham,
		Text = message or "Loading...",
		TextColor3 = theme.TextSecondary,
		TextSize = 13,
	})
	
	spawn(function()
		while self.LoadingFrame do
			spinnerIcon.Rotation += 5
			task.wait(0.016)
		end
	end)
end

function Library:HideLoading()
	if self.LoadingFrame then
		self.LoadingFrame:Destroy()
		self.LoadingFrame = nil
	end
end

-- Tooltip system
function Library:AddTooltip(guiObject, text)
	local theme = Library.Themes[Library.CurrentTheme]
	local tooltip
	
	guiObject.MouseEnter:Connect(function()
		tooltip = CreateInstance("Frame", {
			Parent = self.Gui,
			BackgroundColor3 = theme.Secondary,
			BorderSizePixel = 0,
			Position = UDim2.new(0, mouse.X + 10, 0, mouse.Y - 10),
			Size = UDim2.new(0, 0, 0, 0),
			ZIndex = 400,
			ClipsDescendants = true,
		})
		
		CreateInstance("UICorner", {
			CornerRadius = UDim.new(0, 6),
			Parent = tooltip
		})
		
		CreateInstance("UIStroke", {
			Thickness = 1,
			Color = theme.Border,
			Parent = tooltip
		})
		
		local label = CreateInstance("TextLabel", {
			Parent = tooltip,
			BackgroundTransparency = 1,
			Position = UDim2.new(0, 10, 0, 5),
			Size = UDim2.new(1, -20, 0, 20),
			Font = Enum.Font.Gotham,
			Text = text,
			TextColor3 = theme.Text,
			TextSize = 12,
			TextXAlignment = Enum.TextXAlignment.Left,
		})
		
		local textWidth = label.TextBounds.X + 20
		tooltip.Size = UDim2.new(0, textWidth, 0, 25)
		
		Tween(tooltip, {Time = 0.2}, {Size = UDim2.new(0, textWidth, 0, 25)})
	end)
	
	guiObject.MouseLeave:Connect(function()
		if tooltip then
			tooltip:Destroy()
			tooltip = nil
		end
	end)
end

-- Configuration system
function Library:SaveConfig(name)
	local config = {}
	
	for windowName, windowData in pairs(self.Windows) do
		config[windowName] = {}
		
		for tabName, tabData in pairs(windowData.Tabs) do
			config[windowName][tabName] = {}
			
			for _, element in ipairs(tabData.Elements) do
				if element.Type == "Toggle" then
					config[windowName][tabName][element.Name] = element.Value
				elseif element.Type == "Slider" then
					config[windowName][tabName][element.Name] = element.Value
				elseif element.Type == "Dropdown" then
					config[windowName][tabName][element.Name] = element.Value
				elseif element.Type == "ColorPicker" then
					config[windowName][tabName][element.Name] = element.Value
				end
			end
		end
	end
	
	return config
end

function Library:LoadConfig(config)
	for windowName, windowData in pairs(config) do
		if self.Windows[windowName] then
			for tabName, tabData in pairs(windowData) do
				if self.Windows[windowName].Tabs[tabName] then
					for elementName, value in pairs(tabData) do
						for _, element in ipairs(self.Windows[windowName].Tabs[tabName].Elements) do
							if element.Name == elementName then
								if element.Type == "Toggle" then
									element:Set(value)
								elseif element.Type == "Slider" then
									element:Set(value)
								elseif element.Type == "Dropdown" then
									element:Set(value)
								elseif element.Type == "ColorPicker" then
									element:Set(value)
								end
							end
						end
					end
				end
			end
		end
	end
end

function Library:ExportConfig()
	local config = self:SaveConfig("export")
	return game:GetService("HttpService"):JSONEncode(config)
end

function Library:ImportConfig(jsonString)
	local success, config = pcall(function()
		return game:GetService("HttpService"):JSONDecode(jsonString)
	end)
	
	if success then
		self:LoadConfig(config)
		self:Notify("Config", "Configuration imported successfully!", 3)
	else
		self:Notify("Error", "Failed to import configuration!", 3)
	end
end

-- Window creation
function Library:CreateWindow(config)
	config = config or {}
	local title = config.Title or "UI Library"
	local size = config.Size or UDim2.new(0, 550, 0, 400)
	
	local theme = Library.Themes[Library.CurrentTheme]
	
	self.Gui = self.Gui or CreateInstance("ScreenGui", {
		Parent = CoreGui,
		ResetOnSpawn = false,
	})
	
	-- Main window frame with glass effect
	local window = CreateInstance("Frame", {
		Parent = self.Gui,
		BackgroundColor3 = theme.Background,
		BackgroundTransparency = 0.15,
		BorderSizePixel = 0,
		Position = UDim2.new(0.5, -size.X.Offset/2, 0.5, -size.Y.Offset/2),
		Size = size,
		ZIndex = 1,
	})
	
	CreateInstance("UICorner", {
		CornerRadius = UDim.new(0, 12),
		Parent = window
	})
	
	CreateInstance("UIStroke", {
		Thickness = 1,
		Color = theme.Border,
		Transparency = 0.3,
		Parent = window
	})
	
	-- Glass effect overlay
	local glassEffect = CreateInstance("ImageLabel", {
		Parent = window,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 0, 0, 0),
		Size = UDim2.new(1, 0, 1, 0),
		Image = "rbxassetid://9968344105", -- Blur texture
		ImageTransparency = 0.9,
		ScaleType = Enum.ScaleType.Tile,
		TileSize = UDim2.new(0, 128, 0, 128),
		ZIndex = 2,
	})
	
	-- Title bar
	local titleBar = CreateInstance("Frame", {
		Parent = window,
		BackgroundColor3 = theme.WindowBar,
		BackgroundTransparency = 0.1,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 0, 0, 0),
		Size = UDim2.new(1, 0, 0, 35),
		ZIndex = 10,
	})
	
	CreateInstance("UICorner", {
		CornerRadius = UDim.new(0, 12),
		Parent = titleBar
	})
	
	-- Fix bottom corners
	CreateInstance("Frame", {
		Parent = titleBar,
		BackgroundColor3 = theme.WindowBar,
		BackgroundTransparency = 0.1,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 0, 0.5, 0),
		Size = UDim2.new(1, 0, 0.5, 0),
	})
	
	-- Window title
	CreateInstance("TextLabel", {
		Parent = titleBar,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 15, 0, 0),
		Size = UDim2.new(1, -90, 1, 0),
		Font = Enum.Font.GothamBold,
		Text = title,
		TextColor3 = theme.Text,
		TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 11,
	})
	
	-- Window controls (Mac OS style)
	local controls = {
		{Color = Color3.fromRGB(255, 95, 87), Action = "close"},
		{Color = Color3.fromRGB(255, 189, 46), Action = "minimize"},
		{Color = Color3.fromRGB(39, 201, 63), Action = "maximize"}
	}
	
	for i, control in ipairs(controls) do
		local button = CreateInstance("TextButton", {
			Parent = titleBar,
			BackgroundColor3 = control.Color,
			BorderSizePixel = 0,
			Position = UDim2.new(1, -65 + (i-1)*20, 0.5, -6),
			Size = UDim2.new(0, 12, 0, 12),
			Text = "",
			ZIndex = 11,
		})
		
		CreateInstance("UICorner", {
			CornerRadius = UDim.new(1, 0),
			Parent = button
		})
		
		button.MouseButton1Click:Connect(function()
			if control.Action == "close" then
				window.Visible = false
			elseif control.Action == "minimize" then
				Tween(window, {Time = 0.3}, {Size = UDim2.new(0, size.X.Offset, 0, 35)})
			elseif control.Action == "maximize" then
				Tween(window, {Time = 0.3}, {Size = size, Position = UDim2.new(0.5, -size.X.Offset/2, 0.5, -size.Y.Offset/2)})
			end
		end)
	end
	
	-- Tab container
	local tabContainer = CreateInstance("ScrollingFrame", {
		Parent = window,
		BackgroundColor3 = theme.Secondary,
		BackgroundTransparency = 0.3,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 0, 0, 35),
		Size = UDim2.new(0, 120, 1, -35),
		ScrollBarThickness = 0,
		CanvasSize = UDim2.new(0, 0, 0, 0),
		ZIndex = 5,
	})
	
	local tabList = CreateInstance("UIListLayout", {
		Parent = tabContainer,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 2),
	})
	
	local tabPadding = CreateInstance("UIPadding", {
		Parent = tabContainer,
		PaddingTop = UDim.new(0, 10),
		PaddingBottom = UDim.new(0, 10),
	})
	
	-- Content area
	local contentArea = CreateInstance("Frame", {
		Parent = window,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 125, 0, 40),
		Size = UDim2.new(1, -130, 1, -45),
		ZIndex = 3,
	})
	
	-- Dragging functionality
	local dragging = false
	local dragStart = nil
	local startPos = nil
	
	titleBar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			dragStart = input.Position
			startPos = window.Position
		end
	end)
	
	titleBar.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = false
		end
	end)
	
	UserInputService.InputChanged:Connect(function(input)
		if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			local delta = input.Position - dragStart
			window.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end)
	
	local windowObject = {
		Frame = window,
		ContentArea = contentArea,
		TabContainer = tabContainer,
		Tabs = {},
		Elements = {},
	}
	
	if not self.Windows then
		self.Windows = {}
	end
	
	self.Windows[title] = windowObject
	
	function windowObject:CreateTab(name)
		local tabButton = CreateInstance("TextButton", {
			Parent = tabContainer,
			BackgroundColor3 = theme.Tertiary,
			BackgroundTransparency = 0.5,
			BorderSizePixel = 0,
			Size = UDim2.new(1, -16, 0, 32),
			Position = UDim2.new(0, 8, 0, 0),
			Text = "",
			ZIndex = 6,
		})
		
		CreateInstance("UICorner", {
			CornerRadius = UDim.new(0, 8),
			Parent = tabButton
		})
		
		CreateInstance("TextLabel", {
			Parent = tabButton,
			BackgroundTransparency = 1,
			Size = UDim2.new(1, -10, 1, 0),
			Font = Enum.Font.Gotham,
			Text = name,
			TextColor3 = theme.Text,
			TextSize = 12,
			ZIndex = 7,
		})
		
		local tabContent = CreateInstance("ScrollingFrame", {
			Parent = contentArea,
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 1, 0),
			Visible = false,
			ScrollBarThickness = 0,
			CanvasSize = UDim2.new(0, 0, 0, 0),
			ZIndex = 4,
		})
		
		local contentList = CreateInstance("UIListLayout", {
			Parent = tabContent,
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0, 8),
		})
		
		local contentPadding = CreateInstance("UIPadding", {
			Parent = tabContent,
			PaddingLeft = UDim.new(0, 10),
			PaddingRight = UDim.new(0, 10),
			PaddingTop = UDim.new(0, 5),
			PaddingBottom = UDim.new(0, 5),
		})
		
		-- Custom scrollbar
		local scrollbar = CreateInstance("Frame", {
			Parent = window,
			BackgroundColor3 = theme.Tertiary,
			BackgroundTransparency = 0.7,
			BorderSizePixel = 0,
			Position = UDim2.new(1, -8, 0, 40),
			Size = UDim2.new(0, 4, 1, -45),
			Visible = false,
			ZIndex = 10,
		})
		
		CreateInstance("UICorner", {
			CornerRadius = UDim.new(0, 2),
			Parent = scrollbar
		})
		
		local scrollThumb = CreateInstance("TextButton", {
			Parent = scrollbar,
			BackgroundColor3 = theme.TextSecondary,
			BackgroundTransparency = 0.5,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, 30),
			Text = "",
			ZIndex = 11,
		})
		
		CreateInstance("UICorner", {
			CornerRadius = UDim.new(0, 2),
			Parent = scrollThumb
		})
		
		-- Scroll handling
		tabContent.ChildAdded:Connect(function()
			tabContent.CanvasSize = UDim2.new(0, 0, 0, contentList.AbsoluteContentSize.Y + 10)
			scrollbar.Visible = contentList.AbsoluteContentSize.Y > tabContent.AbsoluteSize.Y
		end)
		
		tabContent.ChildRemoved:Connect(function()
			tabContent.CanvasSize = UDim2.new(0, 0, 0, contentList.AbsoluteContentSize.Y + 10)
			scrollbar.Visible = contentList.AbsoluteContentSize.Y > tabContent.AbsoluteSize.Y
		end)
		
		tabContent:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
			local ratio = tabContent.CanvasPosition.Y / (tabContent.CanvasSize.Y.Offset - tabContent.AbsoluteSize.Y)
			local thumbHeight = math.max(30, (tabContent.AbsoluteSize.Y / tabContent.CanvasSize.Y.Offset) * tabContent.AbsoluteSize.Y)
			scrollThumb.Size = UDim2.new(1, 0, 0, thumbHeight)
			scrollThumb.Position = UDim2.new(0, 0, ratio, 0)
		end)
		
		-- Mouse wheel scrolling
		tabContent.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton2 then
				-- Right click handled elsewhere
			end
		end)
		
		-- Scrollbar thumb dragging
		local thumbDragging = false
		local thumbStartY = nil
		
		scrollThumb.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				thumbDragging = true
				thumbStartY = input.Position.Y - scrollThumb.Position.Y.Offset
			end
		end)
		
		UserInputService.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				thumbDragging = false
			end
		end)
		
		UserInputService.InputChanged:Connect(function(input)
			if thumbDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
				local delta = input.Position.Y - thumbStartY
				local ratio = delta / (scrollbar.AbsoluteSize.Y - scrollThumb.AbsoluteSize.Y)
				ratio = math.clamp(ratio, 0, 1)
				tabContent.CanvasPosition = Vector2.new(0, ratio * (tabContent.CanvasSize.Y.Offset - tabContent.AbsoluteSize.Y))
			end
		end)
		
		-- Tab switching
		local function switchToTab()
			for _, otherTab in pairs(windowObject.Tabs) do
				otherTab.Button.BackgroundColor3 = theme.Tertiary
				otherTab.Button.BackgroundTransparency = 0.5
				otherTab.Content.Visible = false
			end
			tabButton.BackgroundColor3 = theme.Accent
			tabButton.BackgroundTransparency = 0.2
			tabContent.Visible = true
		end
		
		tabButton.MouseButton1Click:Connect(switchToTab)
		
		local tabObject = {
			Name = name,
			Button = tabButton,
			Content = tabContent,
			Elements = {},
		}
		
		windowObject.Tabs[name] = tabObject
		
		if #windowObject.Tabs == 1 then
			switchToTab()
		end
		
		-- Element creation methods
		function tabObject:AddButton(name, callback)
			local button = CreateInstance("TextButton", {
				Parent = tabContent,
				BackgroundColor3 = theme.Accent,
				BorderSizePixel = 0,
				Size = UDim2.new(1, -5, 0, 35),
				Text = "",
				AutoButtonColor = false,
				ZIndex = 4,
			})
			
			CreateInstance("UICorner", {
				CornerRadius = UDim.new(0, 6),
				Parent = button
			})
			
			CreateInstance("TextLabel", {
				Parent = button,
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 1, 0),
				Font = Enum.Font.GothamBold,
				Text = name,
				TextColor3 = Color3.fromRGB(255, 255, 255),
				TextSize = 13,
				ZIndex = 5,
			})
			
			local cooldown = false
			
			button.MouseButton1Click:Connect(function()
				if cooldown then return end
				cooldown = true
				
				Tween(button, {Time = 0.15}, {BackgroundColor3 = theme.AccentHover})
				Tween(button, {Time = 0.15}, {BackgroundColor3 = theme.Accent})
				
				if callback then
					callback()
				end
				
				task.delay(0.5, function()
					cooldown = false
				end)
			end)
			
			local element = {
				Type = "Button",
				Name = name,
				Frame = button,
			}
			tabObject.Elements[#tabObject.Elements + 1] = element
			
			return element
		end
		
		function tabObject:AddToggle(name, default, callback)
			default = default or false
			
			local toggle = CreateInstance("Frame", {
				Parent = tabContent,
				BackgroundColor3 = theme.Tertiary,
				BackgroundTransparency = 0.5,
				BorderSizePixel = 0,
				Size = UDim2.new(1, -5, 0, 35),
				ZIndex = 4,
			})
			
			CreateInstance("UICorner", {
				CornerRadius = UDim.new(0, 6),
				Parent = toggle
			})
			
			CreateInstance("TextLabel", {
				Parent = toggle,
				BackgroundTransparency = 1,
				Position = UDim2.new(0, 12, 0, 0),
				Size = UDim2.new(0.7, 0, 1, 0),
				Font = Enum.Font.Gotham,
				Text = name,
				TextColor3 = theme.Text,
				TextSize = 13,
				TextXAlignment = Enum.TextXAlignment.Left,
				ZIndex = 5,
			})
			
			local switchFrame = CreateInstance("Frame", {
				Parent = toggle,
				BackgroundColor3 = default and theme.Accent or theme.Secondary,
				BorderSizePixel = 0,
				Position = UDim2.new(1, -40, 0.5, -10),
				Size = UDim2.new(0, 32, 0, 20),
				ZIndex = 5,
			})
			
			CreateInstance("UICorner", {
				CornerRadius = UDim.new(1, 0),
				Parent = switchFrame
			})
			
			local switchKnob = CreateInstance("Frame", {
				Parent = switchFrame,
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				BorderSizePixel = 0,
				Position = default and UDim2.new(1, -16, 0.5, -6) or UDim2.new(0, 4, 0.5, -6),
				Size = UDim2.new(0, 12, 0, 12),
				ZIndex = 6,
			})
			
			CreateInstance("UICorner", {
				CornerRadius = UDim.new(1, 0),
				Parent = switchKnob
			})
			
			local toggleButton = CreateInstance("TextButton", {
				Parent = toggle,
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 1, 0),
				Text = "",
				ZIndex = 7,
			})
			
			local value = default
			
			local function set(newValue)
				value = newValue
				Tween(switchFrame, {Time = 0.2}, {BackgroundColor3 = value and theme.Accent or theme.Secondary})
				Tween(switchKnob, {Time = 0.2}, {Position = value and UDim2.new(1, -16, 0.5, -6) or UDim2.new(0, 4, 0.5, -6)})
			end
			
			toggleButton.MouseButton1Click:Connect(function()
				value = not value
				set(value)
				if callback then
					callback(value)
				end
			end)
			
			local element = {
				Type = "Toggle",
				Name = name,
				Value = value,
				Frame = toggle,
				Set = function(self, val)
					set(val)
					value = val
				end,
			}
			tabObject.Elements[#tabObject.Elements + 1] = element
			
			return element
		end
		
		function tabObject:AddSlider(name, min, max, default, callback)
			min = min or 1
			max = max or 100
			default = default or min
			
			local slider = CreateInstance("Frame", {
				Parent = tabContent,
				BackgroundColor3 = theme.Tertiary,
				BackgroundTransparency = 0.5,
				BorderSizePixel = 0,
				Size = UDim2.new(1, -5, 0, 55),
				ZIndex = 4,
			})
			
			CreateInstance("UICorner", {
				CornerRadius = UDim.new(0, 6),
				Parent = slider
			})
			
			CreateInstance("TextLabel", {
				Parent = slider,
				BackgroundTransparency = 1,
				Position = UDim2.new(0, 12, 0, 8),
				Size = UDim2.new(1, -24, 0, 16),
				Font = Enum.Font.Gotham,
				Text = name,
				TextColor3 = theme.Text,
				TextSize = 12,
				TextXAlignment = Enum.TextXAlignment.Left,
				ZIndex = 5,
			})
			
			local valueLabel = CreateInstance("TextLabel", {
				Parent = slider,
				BackgroundTransparency = 1,
				Position = UDim2.new(1, -50, 0, 8),
				Size = UDim2.new(0, 40, 0, 16),
				Font = Enum.Font.GothamBold,
				Text = tostring(default),
				TextColor3 = theme.Accent,
				TextSize = 12,
				TextXAlignment = Enum.TextXAlignment.Right,
				ZIndex = 5,
			})
			
			local sliderTrack = CreateInstance("Frame", {
				Parent = slider,
				BackgroundColor3 = theme.Secondary,
				BorderSizePixel = 0,
				Position = UDim2.new(0, 12, 0, 32),
				Size = UDim2.new(1, -24, 0, 4),
				ZIndex = 5,
			})
			
			CreateInstance("UICorner", {
				CornerRadius = UDim.new(0, 2),
				Parent = sliderTrack
			})
			
			local sliderFill = CreateInstance("Frame", {
				Parent = sliderTrack,
				BackgroundColor3 = theme.Accent,
				BorderSizePixel = 0,
				Size = UDim2.new((default - min) / (max - min), 0, 1, 0),
				ZIndex = 6,
			})
			
			CreateInstance("UICorner", {
				CornerRadius = UDim.new(0, 2),
				Parent = sliderFill
			})
			
			local sliderButton = CreateInstance("TextButton", {
				Parent = sliderTrack,
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 20, 1, 20),
				Position = UDim2.new(0, -10, 0, -8),
				Text = "",
				ZIndex = 7,
			})
			
			local value = default
			local dragging = false
			
			local function set(newValue)
				value = math.clamp(newValue, min, max)
				local ratio = (value - min) / (max - min)
				sliderFill.Size = UDim2.new(ratio, 0, 1, 0)
				valueLabel.Text = tostring(math.floor(value * 100) / 100)
			end
			
			sliderButton.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					dragging = true
				end
			end)
			
			sliderButton.InputEnded:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					dragging = false
				end
			end)
			
			UserInputService.InputChanged:Connect(function(input)
				if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
					local relativeX = input.Position.X - sliderTrack.AbsolutePosition.X
					local ratio = math.clamp(relativeX / sliderTrack.AbsoluteSize.X, 0, 1)
					local newValue = min + (max - min) * ratio
					set(newValue)
					if callback then
						callback(value)
					end
				end
			end)
			
			local element = {
				Type = "Slider",
				Name = name,
				Value = value,
				Min = min,
				Max = max,
				Frame = slider,
				Set = function(self, val)
					set(val)
				end,
			}
			tabObject.Elements[#tabObject.Elements + 1] = element
			
			return element
		end
		
		function tabObject:AddDropdown(name, options, default, callback)
			options = options or {}
			default = default or options[1] or ""
			
			local dropdown = CreateInstance("Frame", {
				Parent = tabContent,
				BackgroundColor3 = theme.Tertiary,
				BackgroundTransparency = 0.5,
				BorderSizePixel = 0,
				Size = UDim2.new(1, -5, 0, 35),
				ZIndex = 4,
				ClipsDescendants = false,
			})
			
			CreateInstance("UICorner", {
				CornerRadius = UDim.new(0, 6),
				Parent = dropdown
			})
			
			local dropdownButton = CreateInstance("TextButton", {
				Parent = dropdown,
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 1, 0),
				Text = "",
				ZIndex = 7,
			})
			
			local label = CreateInstance("TextLabel", {
				Parent = dropdown,
				BackgroundTransparency = 1,
				Position = UDim2.new(0, 12, 0, 0),
				Size = UDim2.new(0.6, 0, 1, 0),
				Font = Enum.Font.Gotham,
				Text = name,
				TextColor3 = theme.Text,
				TextSize = 13,
				TextXAlignment = Enum.TextXAlignment.Left,
				ZIndex = 5,
			})
			
			local selectedLabel = CreateInstance("TextLabel", {
				Parent = dropdown,
				BackgroundTransparency = 1,
				Position = UDim2.new(0, 12, 0, 0),
				Size = UDim2.new(1, -24, 1, 0),
				Font = Enum.Font.GothamBold,
				Text = default,
				TextColor3 = theme.Accent,
				TextSize = 12,
				TextXAlignment = Enum.TextXAlignment.Right,
				ZIndex = 5,
			})
			
			local optionsList = CreateInstance("ScrollingFrame", {
				Parent = dropdown,
				BackgroundColor3 = theme.Secondary,
				BorderSizePixel = 0,
				Position = UDim2.new(0, 0, 1, 2),
				Size = UDim2.new(1, 0, 0, 0),
				CanvasSize = UDim2.new(0, 0, 0, #options * 30),
				ZIndex = 10,
				ScrollBarThickness = 3,
				ScrollBarImageColor3 = theme.Accent,
				Visible = false,
			})
			
			CreateInstance("UICorner", {
				CornerRadius = UDim.new(0, 6),
				Parent = optionsList
			})
			
			CreateInstance("UIStroke", {
				Thickness = 1,
				Color = theme.Border,
				Parent = optionsList
			})
			
			local optionsLayout = CreateInstance("UIListLayout", {
				Parent = optionsList,
				SortOrder = Enum.SortOrder.LayoutOrder,
			})
			
			local selectedOption = default
			
			for i, option in ipairs(options) do
				local optionButton = CreateInstance("TextButton", {
					Parent = optionsList,
					BackgroundColor3 = option == default and theme.Accent or Color3.fromRGB(255, 255, 255),
					BackgroundTransparency = option == default and 0.2 or 1,
					BorderSizePixel = 0,
					Size = UDim2.new(1, 0, 0, 28),
					Text = "",
					ZIndex = 11,
				})
				
				CreateInstance("TextLabel", {
					Parent = optionButton,
					BackgroundTransparency = 1,
					Size = UDim2.new(1, -10, 1, 0),
					Font = Enum.Font.Gotham,
					Text = option,
					TextColor3 = theme.Text,
					TextSize = 12,
					ZIndex = 12,
				})
				
				optionButton.MouseButton1Click:Connect(function()
					selectedOption = option
					selectedLabel.Text = option
					optionsList.Visible = false
					
					if callback then
						callback(option)
					end
					
					for _, btn in ipairs(optionsList:GetChildren()) do
						if btn:IsA("TextButton") then
							btn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
							btn.BackgroundTransparency = 1
						end
					end
					optionButton.BackgroundColor3 = theme.Accent
					optionButton.BackgroundTransparency = 0.2
				end)
			end
			
			local expanded = false
			dropdownButton.MouseButton1Click:Connect(function()
				expanded = not expanded
				optionsList.Visible = expanded
				if expanded then
					Tween(optionsList, {Time = 0.2}, {Size = UDim2.new(1, 0, 0, math.min(#options * 30, 150))})
				else
					Tween(optionsList, {Time = 0.2}, {Size = UDim2.new(1, 0, 0, 0)})
				end
			end)
			
			local element = {
				Type = "Dropdown",
				Name = name,
				Value = selectedOption,
				Frame = dropdown,
				Set = function(self, val)
					if table.find(options, val) then
						selectedOption = val
						selectedLabel.Text = val
					end
				end,
			}
			tabObject.Elements[#tabObject.Elements + 1] = element
			
			return element
		end
		
		return tabObject
	end
	
	return windowObject
end

-- Set theme
function Library:SetTheme(themeName)
	if Library.Themes[themeName] then
		Library.CurrentTheme = themeName
		self:Notify("Theme", "Theme changed to " .. themeName .. "!", 2)
	end
end

return Library
