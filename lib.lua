--// Custom UI Library
--// Modern dark Roblox UI

local Library = {}
Library.__index = Library

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local Player = Players.LocalPlayer

local Theme = {
    Background = Color3.fromRGB(15, 15, 20),
    Secondary = Color3.fromRGB(21, 21, 28),
    Tertiary = Color3.fromRGB(28, 28, 36),
    Accent = Color3.fromRGB(145, 90, 255),
    AccentDark = Color3.fromRGB(105, 60, 200),
    Text = Color3.fromRGB(240, 240, 245),
    SubText = Color3.fromRGB(150, 150, 165),
    Border = Color3.fromRGB(40, 40, 50)
}

local function Create(class, properties, parent)
    local object = Instance.new(class)

    for property, value in pairs(properties or {}) do
        object[property] = value
    end

    if parent then
        object.Parent = parent
    end

    return object
end

local function Tween(object, properties, duration)
    TweenService:Create(
        object,
        TweenInfo.new(duration or 0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
        properties
    ):Play()
end

function Library:CreateWindow(options)
    options = options or {}

    local Window = {}
    Window.Tabs = {}

    local ScreenGui = Create("ScreenGui", {
        Name = "CustomUILibrary",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    }, Player:WaitForChild("PlayerGui"))

    local Main = Create("Frame", {
        Name = "Main",
        Size = UDim2.fromOffset(options.Width or 650, options.Height or 430),
        Position = UDim2.fromScale(0.5, 0.5),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Theme.Background,
        BorderSizePixel = 0
    }, ScreenGui)

    Create("UICorner", {
        CornerRadius = UDim.new(0, 10)
    }, Main)

    Create("UIStroke", {
        Color = Theme.Border,
        Thickness = 1
    }, Main)

    --// Top bar
    local TopBar = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 55),
        BackgroundColor3 = Theme.Secondary,
        BorderSizePixel = 0
    }, Main)

    Create("UICorner", {
        CornerRadius = UDim.new(0, 10)
    }, TopBar)

    local Title = Create("TextLabel", {
        Size = UDim2.new(1, -70, 1, 0),
        Position = UDim2.fromOffset(20, 0),
        BackgroundTransparency = 1,
        Text = options.Title or "Custom UI",
        TextColor3 = Theme.Text,
        Font = Enum.Font.GothamBold,
        TextSize = 18,
        TextXAlignment = Enum.TextXAlignment.Left
    }, TopBar)

    local Close = Create("TextButton", {
        Size = UDim2.fromOffset(40, 40),
        Position = UDim2.new(1, -48, 0, 8),
        BackgroundTransparency = 1,
        Text = "×",
        TextColor3 = Theme.SubText,
        Font = Enum.Font.GothamBold,
        TextSize = 25
    }, TopBar)

    Close.MouseEnter:Connect(function()
        Tween(Close, {TextColor3 = Color3.fromRGB(255, 80, 80)})
    end)

    Close.MouseLeave:Connect(function()
        Tween(Close, {TextColor3 = Theme.SubText})
    end)

    Close.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
    end)

    --// Dragging
    local dragging = false
    local dragStart
    local startPosition

    TopBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPosition = Main.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart

            Main.Position = UDim2.new(
                startPosition.X.Scale,
                startPosition.X.Offset + delta.X,
                startPosition.Y.Scale,
                startPosition.Y.Offset + delta.Y
            )
        end
    end)

    --// Sidebar
    local Sidebar = Create("Frame", {
        Size = UDim2.new(0, 155, 1, -65),
        Position = UDim2.fromOffset(10, 60),
        BackgroundColor3 = Theme.Secondary,
        BorderSizePixel = 0
    }, Main)

    Create("UICorner", {
        CornerRadius = UDim.new(0, 8)
    }, Sidebar)

    local TabList = Create("ScrollingFrame", {
        Size = UDim2.new(1, -10, 1, -10),
        Position = UDim2.fromOffset(5, 5),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 2,
        CanvasSize = UDim2.new()
    }, Sidebar)

    local TabLayout = Create("UIListLayout", {
        Padding = UDim.new(0, 6),
        SortOrder = Enum.SortOrder.LayoutOrder
    }, TabList)

    --// Content
    local Content = Create("Frame", {
        Size = UDim2.new(1, -180, 1, -65),
        Position = UDim2.fromOffset(170, 60),
        BackgroundTransparency = 1
    }, Main)

    function Window:CreateTab(name, icon)
        local Tab = {}
        local TabButton = Create("TextButton", {
            Size = UDim2.new(1, -4, 0, 40),
            BackgroundColor3 = Theme.Tertiary,
            BackgroundTransparency = 1,
            Text = "",
            AutoButtonColor = false
        }, TabList)

        Create("UICorner", {
            CornerRadius = UDim.new(0, 6)
        }, TabButton)

        local TabText = Create("TextLabel", {
            Size = UDim2.new(1, -15, 1, 0),
            Position = UDim2.fromOffset(12, 0),
            BackgroundTransparency = 1,
            Text = (icon and icon .. "  " or "") .. name,
            TextColor3 = Theme.SubText,
            Font = Enum.Font.GothamMedium,
            TextSize = 13,
            TextXAlignment = Enum.TextXAlignment.Left
        }, TabButton)

        local Page = Create("ScrollingFrame", {
            Size = UDim2.fromScale(1, 1),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ScrollBarThickness = 3,
            CanvasSize = UDim2.new()
        }, Content)

        local Layout = Create("UIListLayout", {
            Padding = UDim.new(0, 8),
            SortOrder = Enum.SortOrder.LayoutOrder
        }, Page)

        Create("UIPadding", {
            PaddingTop = UDim.new(0, 5),
            PaddingBottom = UDim.new(0, 5),
            PaddingLeft = UDim.new(0, 5),
            PaddingRight = UDim.new(0, 5)
        }, Page)

        Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            Page.CanvasSize = UDim2.fromOffset(0, Layout.AbsoluteContentSize.Y + 10)
        end)

        function Tab:Show()
            for _, other in pairs(Window.Tabs) do
                other.Page.Visible = false
                other.Button.BackgroundTransparency = 1
                other.Text.TextColor3 = Theme.SubText
            end

            Page.Visible = true
            TabButton.BackgroundTransparency = 0
            TabText.TextColor3 = Theme.Text
        end

        function Tab:CreateSection(text)
            local Section = Create("TextLabel", {
                Size = UDim2.new(1, -10, 0, 25),
                BackgroundTransparency = 1,
                Text = text,
                TextColor3 = Theme.Text,
                Font = Enum.Font.GothamBold,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left
            }, Page)

            return Section
        end

        function Tab:CreateButton(options)
            options = options or {}

            local Button = Create("TextButton", {
                Size = UDim2.new(1, -10, 0, 42),
                BackgroundColor3 = Theme.Tertiary,
                Text = options.Name or "Button",
                TextColor3 = Theme.Text,
                Font = Enum.Font.GothamMedium,
                TextSize = 13,
                AutoButtonColor = false
            }, Page)

            Create("UICorner", {
                CornerRadius = UDim.new(0, 7)
            }, Button)

            Button.MouseEnter:Connect(function()
                Tween(Button, {BackgroundColor3 = Theme.AccentDark})
            end)

            Button.MouseLeave:Connect(function()
                Tween(Button, {BackgroundColor3 = Theme.Tertiary})
            end)

            Button.MouseButton1Click:Connect(function()
                if options.Callback then
                    options.Callback()
                end
            end)

            return Button
        end

        function Tab:CreateToggle(options)
            options = options or {}

            local Enabled = options.CurrentValue or false

            local Toggle = Create("TextButton", {
                Size = UDim2.new(1, -10, 0, 42),
                BackgroundColor3 = Theme.Tertiary,
                Text = "",
                AutoButtonColor = false
            }, Page)

            Create("UICorner", {
                CornerRadius = UDim.new(0, 7)
            }, Toggle)

            local Text = Create("TextLabel", {
                Size = UDim2.new(1, -70, 1, 0),
                Position = UDim2.fromOffset(12, 0),
                BackgroundTransparency = 1,
                Text = options.Name or "Toggle",
                TextColor3 = Theme.Text,
                Font = Enum.Font.GothamMedium,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left
            }, Toggle)

            local Switch = Create("Frame", {
                Size = UDim2.fromOffset(42, 22),
                Position = UDim2.new(1, -55, 0.5, -11),
                BackgroundColor3 = Color3.fromRGB(50, 50, 60)
            }, Toggle)

            Create("UICorner", {
                CornerRadius = UDim.new(1, 0)
            }, Switch)

            local Circle = Create("Frame", {
                Size = UDim2.fromOffset(16, 16),
                Position = UDim2.fromOffset(3, 3),
                BackgroundColor3 = Color3.fromRGB(220, 220, 225)
            }, Switch)

            Create("UICorner", {
                CornerRadius = UDim.new(1, 0)
            }, Circle)

            local function Update()
                if Enabled then
                    Tween(Switch, {BackgroundColor3 = Theme.Accent})
                    Tween(Circle, {Position = UDim2.new(1, -19, 0, 3)})
                else
                    Tween(Switch, {BackgroundColor3 = Color3.fromRGB(50, 50, 60)})
                    Tween(Circle, {Position = UDim2.fromOffset(3, 3)})
                end
            end

            Toggle.MouseButton1Click:Connect(function()
                Enabled = not Enabled
                Update()

                if options.Callback then
                    options.Callback(Enabled)
                end
            end)

            Update()

            return {
                Set = function(_, value)
                    Enabled = value
                    Update()
                end,

                Get = function()
                    return Enabled
                end
            }
        end

        function Tab:CreateSlider(options)
            options = options or {}

            local Min = options.Min or 0
            local Max = options.Max or 100
            local Value = options.CurrentValue or Min

            local Holder = Create("Frame", {
                Size = UDim2.new(1, -10, 0, 58),
                BackgroundColor3 = Theme.Tertiary
            }, Page)

            Create("UICorner", {
                CornerRadius = UDim.new(0, 7)
            }, Holder)

            local Label = Create("TextLabel", {
                Size = UDim2.new(1, -20, 0, 25),
                Position = UDim2.fromOffset(10, 5),
                BackgroundTransparency = 1,
                Text = (options.Name or "Slider") .. ": " .. tostring(Value),
                TextColor3 = Theme.Text,
                Font = Enum.Font.GothamMedium,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left
            }, Holder)

            local Bar = Create("Frame", {
                Size = UDim2.new(1, -20, 0, 5),
                Position = UDim2.fromOffset(10, 40),
                BackgroundColor3 = Color3.fromRGB(45, 45, 55)
            }, Holder)

            Create("UICorner", {
                CornerRadius = UDim.new(1, 0)
            }, Bar)

            local Fill = Create("Frame", {
                Size = UDim2.fromScale((Value - Min) / (Max - Min), 1),
                BackgroundColor3 = Theme.Accent
            }, Bar)

            Create("UICorner", {
                CornerRadius = UDim.new(1, 0)
            }, Fill)

            local function SetValue(value)
                Value = math.clamp(value, Min, Max)

                local Percent = (Value - Min) / (Max - Min)

                Fill.Size = UDim2.fromScale(Percent, 1)
                Label.Text = (options.Name or "Slider") .. ": " .. tostring(Value)

                if options.Callback then
                    options.Callback(Value)
                end
            end

            Bar.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    local connection

                    local function Update(input)
                        local Percent = math.clamp(
                            (input.Position.X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X,
                            0,
                            1
                        )

                        SetValue(math.floor(Min + ((Max - Min) * Percent)))
                    end

                    Update(input)

                    connection = UserInputService.InputChanged:Connect(function(changed)
                        if changed.UserInputType == Enum.UserInputType.MouseMovement then
                            Update(changed)
                        end
                    end)

                    UserInputService.InputEnded:Connect(function(ended)
                        if ended.UserInputType == Enum.UserInputType.MouseButton1 then
                            if connection then
                                connection:Disconnect()
                            end
                        end
                    end)
                end
            end)

            return {
                Set = function(_, value)
                    SetValue(value)
                end,

                Get = function()
                    return Value
                end
            }
        end

        function Tab:CreateDropdown(options)
            options = options or {}

            local Values = options.Values or {}
            local Selected = options.CurrentOption or Values[1]

            local Holder = Create("Frame", {
                Size = UDim2.new(1, -10, 0, 42),
                BackgroundColor3 = Theme.Tertiary,
                ClipsDescendants = true
            }, Page)

            Create("UICorner", {
                CornerRadius = UDim.new(0, 7)
            }, Holder)

            local Button = Create("TextButton", {
                Size = UDim2.new(1, 0, 0, 42),
                BackgroundTransparency = 1,
                Text = "",
                AutoButtonColor = false
            }, Holder)

            local Label = Create("TextLabel", {
                Size = UDim2.new(1, -45, 1, 0),
                Position = UDim2.fromOffset(12, 0),
                BackgroundTransparency = 1,
                Text = (options.Name or "Dropdown") .. ": " .. tostring(Selected),
                TextColor3 = Theme.Text,
                Font = Enum.Font.GothamMedium,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left
            }, Button)

            local Arrow = Create("TextLabel", {
                Size = UDim2.fromOffset(30, 42),
                Position = UDim2.new(1, -35, 0, 0),
                BackgroundTransparency = 1,
                Text = "▼",
                TextColor3 = Theme.SubText,
                Font = Enum.Font.GothamBold,
                TextSize = 11
            }, Button)

            local List = Create("Frame", {
                Size = UDim2.new(1, -10, 0, 0),
                Position = UDim2.fromOffset(5, 47),
                BackgroundTransparency = 1
            }, Holder)

            local Layout = Create("UIListLayout", {
                Padding = UDim.new(0, 4)
            }, List)

            for _, Value in ipairs(Values) do
                local Option = Create("TextButton", {
                    Size = UDim2.new(1, 0, 0, 30),
                    BackgroundColor3 = Theme.Secondary,
                    Text = tostring(Value),
                    TextColor3 = Theme.SubText,
                    Font = Enum.Font.Gotham,
                    TextSize = 12,
                    AutoButtonColor = false
                }, List)

                Create("UICorner", {
                    CornerRadius = UDim.new(0, 5)
                }, Option)

                Option.MouseButton1Click:Connect(function()
                    Selected = Value
                    Label.Text = (options.Name or "Dropdown") .. ": " .. tostring(Value)

                    if options.Callback then
                        options.Callback(Value)
                    end

                    Holder.Size = UDim2.new(1, -10, 0, 42)
                    List.Size = UDim2.new(1, -10, 0, 0)
                    Arrow.Text = "▼"
                end)
            end

            Button.MouseButton1Click:Connect(function()
                local Open = Holder.AbsoluteSize.Y > 50

                if Open then
                    Holder.Size = UDim2.new(1, -10, 0, 42)
                    Arrow.Text = "▼"
                else
                    local Height = math.min(#Values * 34 + 10, 170)

                    Holder.Size = UDim2.new(1, -10, 0, 47 + Height)
                    List.Size = UDim2.new(1, -10, 0, Height)
                    Arrow.Text = "▲"
                end
            end)

            return {
                Set = function(_, value)
                    Selected = value
                    Label.Text = (options.Name or "Dropdown") .. ": " .. tostring(value)

                    if options.Callback then
                        options.Callback(value)
                    end
                end,

                Get = function()
                    return Selected
                end
            }
        end

        table.insert(Window.Tabs, {
            Page = Page,
            Button = TabButton,
            Text = TabText
        })

        TabButton.MouseButton1Click:Connect(function()
            Tab:Show()
        end)

        if #Window.Tabs == 1 then
            Tab:Show()
        end

        return Tab
    end

    --// Notification system
    function Window:Notify(options)
        options = options or {}

        local Holder = Create("Frame", {
            Size = UDim2.fromOffset(280, 70),
            Position = UDim2.new(1, -20, 1, -20),
            AnchorPoint = Vector2.new(1, 1),
            BackgroundColor3 = Theme.Secondary
        }, ScreenGui)

        Create("UICorner", {
            CornerRadius = UDim.new(0, 8)
        }, Holder)

        Create("UIStroke", {
            Color = Theme.Border
        }, Holder)

        local Title = Create("TextLabel", {
            Size = UDim2.new(1, -20, 0, 25),
            Position = UDim2.fromOffset(10, 7),
            BackgroundTransparency = 1,
            Text = options.Title or "Notification",
            TextColor3 = Theme.Text,
            Font = Enum.Font.GothamBold,
            TextSize = 13,
            TextXAlignment = Enum.TextXAlignment.Left
        }, Holder)

        local Message = Create("TextLabel", {
            Size = UDim2.new(1, -20, 0, 30),
            Position = UDim2.fromOffset(10, 32),
            BackgroundTransparency = 1,
            Text = options.Content or "",
            TextColor3 = Theme.SubText,
            Font = Enum.Font.Gotham,
            TextSize = 11,
            TextWrapped = true,
            TextXAlignment = Enum.TextXAlignment.Left
        }, Holder)

        Holder.Position = UDim2.new(1, 300, 1, -20)

        Tween(
            Holder,
            {Position = UDim2.new(1, -20, 1, -20)},
            0.4
        )

        task.delay(options.Duration or 3, function()
            Tween(
                Holder,
                {Position = UDim2.new(1, 300, 1, -20)},
                0.4
            )

            task.wait(0.4)
            Holder:Destroy()
        end)
    end

    return Window
end

return Library
