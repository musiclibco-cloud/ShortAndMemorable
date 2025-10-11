-- Tetolib (Roblox UI Library)
local Tetolib = {}

-- Services
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

-- Utilities
local function Tween(obj, props, duration, style, direction)
    style = style or Enum.EasingStyle.Quad
    direction = direction or Enum.EasingDirection.Out
    local tween = TweenService:Create(obj, TweenInfo.new(duration, style, direction), props)
    tween:Play()
    return tween
end

local function CreateInstance(class, props)
    local obj = Instance.new(class)
    for k, v in pairs(props) do
        obj[k] = v
    end
    if props.Parent then obj.Parent = props.Parent end
    return obj
end

-- Main Tetolib Window Constructor
function Tetolib:CreateWindow(config)
    config = config or {}
    local windowTitle = config.Title or "Tetolib UI"
    local windowSize = UDim2.new(0, 460, 0, 520)

    local Window = {Tabs = {}, CurrentTab = nil}

    -- ScreenGui & Main Frame
    local ScreenGui = CreateInstance("ScreenGui", {Name = "TetolibUI", Parent = CoreGui, ZIndexBehavior = Enum.ZIndexBehavior.Sibling, ResetOnSpawn = false})

    local MainFrame = CreateInstance("Frame", {
        Name = "MainFrame", Parent = ScreenGui,
        AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 0, 0.5, 0), Size = windowSize,
        BackgroundColor3 = Color3.fromRGB(30, 30, 30),
        BorderSizePixel = 0
    })
    CreateInstance("UICorner", {Parent = MainFrame, CornerRadius = UDim.new(0, 13)})

    -- Shadow Effect
    CreateInstance("ImageLabel", {
        Name = "Shadow", Parent = MainFrame, AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0), Size = UDim2.new(1, 40, 1, 40),
        BackgroundTransparency = 1, ImageTransparency = 0.87, ZIndex = 0,
        Image = "rbxassetid://3570695787", ImageColor3 = Color3.fromRGB(0,0,0)
    })

    -- Header
    local HeaderBar = CreateInstance("Frame", {
        Name = "HeaderBar", Parent = MainFrame, Size = UDim2.new(1, 0, 0, 50),
        BackgroundColor3 = Color3.fromRGB(40, 40, 40), BorderSizePixel = 0
    })
    CreateInstance("UICorner", {Parent = HeaderBar, CornerRadius = UDim.new(0, 13)})
    CreateInstance("Frame", {Parent = HeaderBar, Position = UDim2.new(0, 0, 1, -1), Size = UDim2.new(1, 0, 0, 1), BackgroundColor3 = Color3.fromRGB(66,135,245), BorderSizePixel = 0})

    local TitleLabel = CreateInstance("TextLabel", {
        Name = "Title", Parent = HeaderBar, Position = UDim2.new(0, 18, 0, 0), Size = UDim2.new(0.8, 0, 1, 0),
        BackgroundTransparency = 1, Text = windowTitle, TextColor3 = Color3.fromRGB(255,255,255),
        TextSize = 18, TextXAlignment = Enum.TextXAlignment.Left, Font = Enum.Font.GothamBold
    })

    -- Close Button
    local CloseBtn = CreateInstance("TextButton", {
        Name = "CloseButton", Parent = HeaderBar, AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -16, 0.5, 0), Size = UDim2.new(0, 34, 0, 34),
        BackgroundColor3 = Color3.fromRGB(66,135,245), Text = "×", TextColor3 = Color3.fromRGB(255,255,255),
        TextSize = 21, Font = Enum.Font.GothamBold, BorderSizePixel = 0
    })
    CreateInstance("UICorner", {Parent = CloseBtn, CornerRadius = UDim.new(1, 0)})
    CloseBtn.MouseButton1Click:Connect(function()
        Tween(MainFrame, {Size = UDim2.new(0, 0, 0, 0)}, 0.34, Enum.EasingStyle.Back, Enum.EasingDirection.In)
        wait(0.3)
        ScreenGui:Destroy()
    end)

    -- Tab Bar
    local TabContainer = CreateInstance("ScrollingFrame", {
        Name = "TabContainer", Parent = MainFrame, Position = UDim2.new(0, 10, 0, 55), Size = UDim2.new(1, -20, 0, 45),
        BackgroundColor3 = Color3.fromRGB(36, 36, 36), BorderSizePixel = 0,
        ScrollBarThickness = 0, CanvasSize = UDim2.new(0, 0, 0, 0), AutomaticCanvasSize = Enum.AutomaticSize.X
    })
    CreateInstance("UICorner", {Parent = TabContainer, CornerRadius = UDim.new(0, 8)})
    local TabList = CreateInstance("UIListLayout", {Parent = TabContainer, FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 8)})
    CreateInstance("UIPadding", {Parent = TabContainer, PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0,8), PaddingTop = UDim.new(0,6), PaddingBottom=UDim.new(0,6)})

    -- Main Content Container
    local ContentContainer = CreateInstance("Frame", {
        Name = "ContentContainer", Parent = MainFrame, Position = UDim2.new(0, 10, 0, 104), Size = UDim2.new(1, -20, 1, -114),
        BackgroundColor3 = Color3.fromRGB(40, 40, 40), BorderSizePixel = 0
    })
    CreateInstance("UICorner", {Parent = ContentContainer, CornerRadius = UDim.new(0, 8)})

    -- Drag logic
    local dragging, dragInput, dragStart, startPos
    local function setupDragging(frame)
        frame.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                dragStart = input.Position
                startPos = MainFrame.Position
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        dragging = false
                    end
                end)
            end
        end)
        frame.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                dragInput = input
            end
        end)
    end
    setupDragging(HeaderBar)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    -- Tab creation
    function Window:CreateTab(tabName)
        local Tab = {Elements = {}}
        local TabButton = CreateInstance("TextButton", {
            Name = tabName, Parent = TabContainer, Size = UDim2.new(0, 104, 1, -11), BackgroundColor3 = Color3.fromRGB(66, 135, 245),
            Text = tabName, TextColor3 = Color3.fromRGB(255, 255, 255), TextSize = 14, Font = Enum.Font.GothamBold, BorderSizePixel = 0, AutoButtonColor = false
        })
        CreateInstance("UICorner", {Parent = TabButton, CornerRadius = UDim.new(0, 6)})
        local TabContent = CreateInstance("ScrollingFrame", {
            Name = tabName .. "Content", Parent = ContentContainer, Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1,
            BorderSizePixel = 0, ScrollBarThickness = 0, CanvasSize = UDim2.new(0, 0, 0, 0), AutomaticCanvasSize = Enum.AutomaticSize.Y, Visible = false
        })
        local ContentList = CreateInstance("UIListLayout", {Parent = TabContent, Padding = UDim.new(0, 12), SortOrder = Enum.SortOrder.LayoutOrder})
        CreateInstance("UIPadding", {Parent = TabContent, PaddingLeft = UDim.new(0, 14), PaddingRight = UDim.new(0, 14), PaddingTop = UDim.new(0, 14), PaddingBottom = UDim.new(0, 14)})
        Tab.Button = TabButton
        Tab.Content = TabContent

        TabButton.MouseButton1Click:Connect(function()
            for _, tab in pairs(Window.Tabs) do
                tab.Button.BackgroundColor3 = Color3.fromRGB(36, 36, 36)
                tab.Button.TextColor3 = Color3.fromRGB(200, 200, 200)
                tab.Content.Visible = false
            end
            TabButton.BackgroundColor3 = Color3.fromRGB(66,135,245)
            TabButton.TextColor3 = Color3.fromRGB(255,255,255)
            TabContent.Visible = true
            Window.CurrentTab = Tab
        end)
        if #Window.Tabs == 0 then
            TabButton.BackgroundColor3 = Color3.fromRGB(66,135,245)
            TabButton.TextColor3 = Color3.fromRGB(255,255,255)
            TabContent.Visible = true
            Window.CurrentTab = Tab
        end
        table.insert(Window.Tabs, Tab)
        return Tab
    end

    -- Button
    function Tab:AddButton(config)
        config = config or {}
        local Button = CreateInstance("TextButton", {
            Parent = Tab.Content, Size = UDim2.new(1, 0, 0, 38), BackgroundColor3 = Color3.fromRGB(66,135,245),
            Text = config.Name or "Button", TextColor3 = Color3.fromRGB(255,255,255), TextSize = 14, Font = Enum.Font.GothamBold, BorderSizePixel = 0
        })
        CreateInstance("UICorner", {Parent = Button, CornerRadius = UDim.new(0, 8)})
        Button.MouseButton1Click:Connect(function()
            Tween(Button, {BackgroundColor3 = Color3.fromRGB(36,36,36)}, 0.13)
            wait(0.13)
            Tween(Button, {BackgroundColor3 = Color3.fromRGB(66,135,245)}, 0.14)
            if typeof(config.Callback) == "function" then config.Callback() end
        end)
    end

    -- Toggle
    function Tab:AddToggle(config)
        config = config or {}
        local toggleState = config.Default or false
        local ToggleFrame = CreateInstance("Frame", {
            Parent = Tab.Content, Size = UDim2.new(1, 0, 0, 44), BackgroundColor3 = Color3.fromRGB(36,36,36), BorderSizePixel=0
        })
        CreateInstance("UICorner", {Parent = ToggleFrame, CornerRadius = UDim.new(0, 8)})
        local Label = CreateInstance("TextLabel", {
            Parent = ToggleFrame, Position = UDim2.new(0, 12, 0, 0), Size = UDim2.new(1, -64, 1, 0), BackgroundTransparency=1,
            Text = config.Name or "Toggle", TextColor3 = Color3.fromRGB(255,255,255), TextSize=14, TextXAlignment = Enum.TextXAlignment.Left, Font = Enum.Font.GothamBold
        })
        local ToggleButton = CreateInstance("TextButton", {
            Parent = ToggleFrame, AnchorPoint = Vector2.new(1,0.5), Position = UDim2.new(1, -12, 0.5, 0), Size = UDim2.new(0, 46, 0, 26),
            BackgroundColor3 = toggleState and Color3.fromRGB(66,135,245) or Color3.fromRGB(200,200,200), Text="", BorderSizePixel=0
        })
        CreateInstance("UICorner", {Parent = ToggleButton, CornerRadius = UDim.new(1,0)})
        local Indicator = CreateInstance("Frame", {
            Parent = ToggleButton, Position = toggleState and UDim2.new(1, -22, 0.5, 0) or UDim2.new(0, 4, 0.5, 0), AnchorPoint = Vector2.new(0,0.5),
            Size = UDim2.new(0, 18, 0, 18), BackgroundColor3 = Color3.fromRGB(255,255,255), BorderSizePixel = 0
        })
        CreateInstance("UICorner", {Parent = Indicator, CornerRadius = UDim.new(1,0)})
        ToggleButton.MouseButton1Click:Connect(function()
            toggleState = not toggleState
            Tween(ToggleButton, {BackgroundColor3 = toggleState and Color3.fromRGB(66,135,245) or Color3.fromRGB(200,200,200)}, 0.15)
            Tween(Indicator, {Position = toggleState and UDim2.new(1, -22, 0.5, 0) or UDim2.new(0, 4, 0.5, 0)}, 0.17)
            if typeof(config.Callback) == "function" then config.Callback(toggleState) end
        end)
    end

    -- Input Box
    function Tab:AddInput(config)
        config = config or {}
        local InputFrame = CreateInstance("Frame", {Parent = Tab.Content, Size = UDim2.new(1,0,0,54), BackgroundColor3 = Color3.fromRGB(36,36,36), BorderSizePixel=0})
        CreateInstance("UICorner", {Parent = InputFrame, CornerRadius = UDim.new(0,8)})
        local Label = CreateInstance("TextLabel", {Parent = InputFrame, Position = UDim2.new(0,10,0,0), Size=UDim2.new(1,-20,0,20), BackgroundTransparency=1,
            Text = config.Name or "Input", TextColor3=Color3.fromRGB(255,255,255), TextSize=13, Font=Enum.Font.GothamBold, TextXAlignment=Enum.TextXAlignment.Left})
        local InputBox = CreateInstance("TextBox", {Parent = InputFrame, Position=UDim2.new(0,10,0,24), Size=UDim2.new(1,-20,0,24), BackgroundColor3=Color3.fromRGB(255,255,255),
            Text="", PlaceholderText=config.Placeholder or "Enter text...", TextColor3=Color3.fromRGB(40,40,40), PlaceholderColor3=Color3.fromRGB(180,180,180), TextSize=13, Font=Enum.Font.Gotham, BorderSizePixel=0})
        CreateInstance("UICorner", {Parent=InputBox, CornerRadius=UDim.new(0,6)})
        InputBox.Focused:Connect(function()
            Tween(InputBox, {BackgroundColor3=Color3.fromRGB(240,240,255)}, 0.16)
        end)
        InputBox.FocusLost:Connect(function(enterPressed)
            Tween(InputBox, {BackgroundColor3=Color3.fromRGB(255,255,255)}, 0.16)
            if enterPressed then
                if typeof(config.Callback) == "function" then config.Callback(InputBox.Text) end
            end
        end)
    end

    -- Dropdown
    function Tab:AddDropdown(config)
        config = config or {}
        local options = config.Options or {"Option 1", "Option 2"}
        local selected = options[1]
        local DropdownFrame = CreateInstance("Frame", {Parent=Tab.Content, Size=UDim2.new(1,0, 0,54), BackgroundColor3=Color3.fromRGB(36,36,36), BorderSizePixel=0})
        CreateInstance("UICorner", {Parent=DropdownFrame, CornerRadius=UDim.new(0,8)})
        local Label = CreateInstance("TextLabel", {Parent=DropdownFrame, Position=UDim2.new(0,10,0,0), Size=UDim2.new(1,-54,0,20), BackgroundTransparency=1,
            Text=config.Name or "Dropdown", TextColor3=Color3.fromRGB(255,255,255), TextSize=13, Font=Enum.Font.GothamBold, TextXAlignment=Enum.TextXAlignment.Left})
        local DropdownBtn = CreateInstance("TextButton", {Parent=DropdownFrame, AnchorPoint=Vector2.new(1,0.5), Position=UDim2.new(1,-10,0.5,0), Size=UDim2.new(0, 40, 0, 28),
            BackgroundColor3=Color3.fromRGB(66,135,245), Text=selected, TextColor3=Color3.fromRGB(255,255,255), TextSize=12, Font=Enum.Font.GothamBold, BorderSizePixel=0})
        CreateInstance("UICorner", {Parent=DropdownBtn, CornerRadius=UDim.new(1,0)})
        DropdownBtn.MouseButton1Click:Connect(function()
            -- Simple dropdown: cycles options on click (expand as needed)
            local idx = table.find(options, selected) or 1
            selected = options[(idx % #options) + 1]
            DropdownBtn.Text = selected
            if typeof(config.Callback) == "function" then config.Callback(selected) end
        end)
    end

    return Window
end

return Tetolib
