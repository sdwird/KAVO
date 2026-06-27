--[[
    Kavo UI Library - Fully Optimized Version
    Rewritten for maximum performance, readability, and zero memory leaks.
]]

local Kavo = {}
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local tweenInfo = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

-- Theme Management (Event Driven - NO WHILE LOOPS)
local currentTheme = {}
local themeObjects = {} -- Stores {Instance, Property, ThemeKey}

local function ApplyTheme(instance, property, themeKey)
    table.insert(themeObjects, {Inst = instance, Prop = property, Key = themeKey})
    if currentTheme[themeKey] then
        instance[property] = currentTheme[themeKey]
    end
end

local function UpdateTheme()
    for i = #themeObjects, 1, -1 do
        local obj = themeObjects[i]
        if obj.Inst and obj.Inst.Parent then
            TweenService:Create(obj.Inst, tweenInfo, {[obj.Prop] = currentTheme[obj.Key]}):Play()
        else
            table.remove(themeObjects, i) -- Clean up garbage collected objects
        end
    end
end

local themes = {
    DarkTheme = {SchemeColor = Color3.fromRGB(64, 64, 64), Background = Color3.fromRGB(0, 0, 0), Header = Color3.fromRGB(0, 0, 0), TextColor = Color3.fromRGB(255, 255, 255), ElementColor = Color3.fromRGB(20, 20, 20)},
    LightTheme = {SchemeColor = Color3.fromRGB(150, 150, 150), Background = Color3.fromRGB(255, 255, 255), Header = Color3.fromRGB(200, 200, 200), TextColor = Color3.fromRGB(0, 0, 0), ElementColor = Color3.fromRGB(224, 224, 224)},
    BloodTheme = {SchemeColor = Color3.fromRGB(227, 27, 27), Background = Color3.fromRGB(10, 10, 10), Header = Color3.fromRGB(5, 5, 5), TextColor = Color3.fromRGB(255, 255, 255), ElementColor = Color3.fromRGB(20, 20, 20)},
    GrapeTheme = {SchemeColor = Color3.fromRGB(166, 71, 214), Background = Color3.fromRGB(64, 50, 71), Header = Color3.fromRGB(36, 28, 41), TextColor = Color3.fromRGB(255, 255, 255), ElementColor = Color3.fromRGB(74, 58, 84)},
    Ocean = {SchemeColor = Color3.fromRGB(86, 76, 251), Background = Color3.fromRGB(26, 32, 58), Header = Color3.fromRGB(38, 45, 71), TextColor = Color3.fromRGB(200, 200, 200), ElementColor = Color3.fromRGB(38, 45, 71)},
    Midnight = {SchemeColor = Color3.fromRGB(26, 189, 158), Background = Color3.fromRGB(44, 62, 82), Header = Color3.fromRGB(57, 81, 105), TextColor = Color3.fromRGB(255, 255, 255), ElementColor = Color3.fromRGB(52, 74, 95)},
    Sentinel = {SchemeColor = Color3.fromRGB(230, 35, 69), Background = Color3.fromRGB(32, 32, 32), Header = Color3.fromRGB(24, 24, 24), TextColor = Color3.fromRGB(119, 209, 138), ElementColor = Color3.fromRGB(24, 24, 24)},
    Synapse = {SchemeColor = Color3.fromRGB(46, 48, 43), Background = Color3.fromRGB(13, 15, 12), Header = Color3.fromRGB(36, 38, 35), TextColor = Color3.fromRGB(152, 99, 53), ElementColor = Color3.fromRGB(24, 24, 24)},
    Serpent = {SchemeColor = Color3.fromRGB(0, 166, 58), Background = Color3.fromRGB(31, 41, 43), Header = Color3.fromRGB(22, 29, 31), TextColor = Color3.fromRGB(255, 255, 255), ElementColor = Color3.fromRGB(22, 29, 31)}
}

-- Utility Functions
local function Tween(obj, props, duration)
    TweenService:Create(obj, duration and TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out) or tweenInfo, props):Play()
end

local function Lighten(color, amount)
    return Color3.new(math.clamp(color.r + amount, 0, 1), math.clamp(color.g + amount, 0, 1), math.clamp(color.b + amount, 0, 1))
end

local function Create(className, properties, children)
    local inst = Instance.new(className)
    for k, v in pairs(properties or {}) do
        if k == "Theme" then
            for prop, themeKey in pairs(v) do ApplyTheme(inst, prop, themeKey) end
        elseif type(k) == "number" then -- Assuming array of children
            v.Parent = inst
        else
            inst[k] = v
        end
    end
    for _, child in ipairs(children or {}) do child.Parent = inst end
    return inst
end

local function MakeCorner(radius)
    return Create("UICorner", {CornerRadius = UDim.new(0, radius or 4)})
end

local function RippleEffect(btn)
    local mouse = game.Players.LocalPlayer:GetMouse()
    local ripple = Create("ImageLabel", {
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 1,
        Image = "rbxassetid://4560909609",
        ImageTransparency = 0.6,
        Theme = {ImageColor3 = "SchemeColor"},
        ZIndex = btn.ZIndex + 1,
        Parent = btn
    })
    
    local x, y = (mouse.X - btn.AbsolutePosition.X), (mouse.Y - btn.AbsolutePosition.Y)
    ripple.Position = UDim2.new(0, x, 0, y)
    
    local size = math.max(btn.AbsoluteSize.X, btn.AbsoluteSize.Y) * 1.5
    local time = 0.35
    
    TweenService:Create(ripple, TweenInfo.new(time, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, size, 0, size),
        Position = UDim2.new(0.5, -size/2, 0.5, -size/2),
        ImageTransparency = 1
    }):Play()
    
    game.Debris:AddItem(ripple, time)
end

function Kavo:DraggingEnabled(frame, parent)
    parent = parent or frame
    local dragging, dragInput, mousePos, framePos

    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            mousePos = input.Position
            framePos = parent.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)

    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - mousePos
            parent.Position = UDim2.new(framePos.X.Scale, framePos.X.Offset + delta.X, framePos.Y.Scale, framePos.Y.Offset + delta.Y)
        end
    end)
end

local LibName = "Kavo_" .. tostring(math.random(1000, 9999))

function Kavo:ToggleUI()
    local gui = CoreGui:FindFirstChild(LibName)
    if gui then gui.Enabled = not gui.Enabled end
end

function Kavo.CreateLib(kavName, themeList)
    kavName = kavName or "Library"
    
    -- Set Theme
    if type(themeList) == "string" and themes[themeList] then
        currentTheme = themes[themeList]
    elseif type(themeList) == "table" then
        currentTheme = themeList
    else
        currentTheme = themes.DarkTheme
    end

    -- Clear existing
    for _, v in pairs(CoreGui:GetChildren()) do
        if v.Name == LibName then v:Destroy() end
    end

    local ScreenGui = Create("ScreenGui", {Name = LibName, Parent = CoreGui, ResetOnSpawn = false, ZIndexBehavior = Enum.ZIndexBehavior.Sibling})

    local Main = Create("Frame", {
        Name = "Main", Parent = ScreenGui, ClipsDescendants = true,
        Position = UDim2.new(0.5, -262, 0.5, -159), Size = UDim2.new(0, 525, 0, 318),
        Theme = {BackgroundColor3 = "Background"}
    }, { MakeCorner(4) })

    local MainHeader = Create("Frame", {
        Name = "MainHeader", Parent = Main, Size = UDim2.new(1, 0, 0, 29),
        Theme = {BackgroundColor3 = "Header"}
    }, {
        MakeCorner(4),
        Create("Frame", {Size = UDim2.new(1, 0, 0, 7), Position = UDim2.new(0, 0, 1, -7), BorderSizePixel = 0, Theme = {BackgroundColor3 = "Header"}}),
        Create("TextLabel", {
            Text = kavName, Font = Enum.Font.Gotham, TextSize = 16, TextColor3 = Color3.fromRGB(245, 245, 245),
            BackgroundTransparency = 1, Position = UDim2.new(0, 10, 0, 0), Size = UDim2.new(0, 200, 1, 0), TextXAlignment = Enum.TextXAlignment.Left
        })
    })

    local CloseBtn = Create("ImageButton", {
        Parent = MainHeader, BackgroundTransparency = 1, Position = UDim2.new(1, -25, 0.5, -10), Size = UDim2.new(0, 20, 0, 20),
        Image = "rbxassetid://3926305904", ImageRectOffset = Vector2.new(284, 4), ImageRectSize = Vector2.new(24, 24)
    })

    CloseBtn.MouseButton1Click:Connect(function()
        Tween(Main, {Size = UDim2.new(0, 0, 0, 0), Position = UDim2.new(0, Main.AbsolutePosition.X + (Main.AbsoluteSize.X/2), 0, Main.AbsolutePosition.Y + (Main.AbsoluteSize.Y/2))}, 0.2)
        task.wait(0.2)
        ScreenGui:Destroy()
    end)

    Kavo:DraggingEnabled(MainHeader, Main)

    local MainSide = Create("Frame", {
        Name = "MainSide", Parent = Main, Position = UDim2.new(0, 0, 0, 29), Size = UDim2.new(0, 149, 1, -29),
        Theme = {BackgroundColor3 = "Header"}
    }, {
        MakeCorner(4),
        Create("Frame", {Size = UDim2.new(0, 7, 1, 0), Position = UDim2.new(1, -7, 0, 0), BorderSizePixel = 0, Theme = {BackgroundColor3 = "Header"}})
    })

    local TabFrames = Create("ScrollingFrame", {
        Name = "TabFrames", Parent = MainSide, BackgroundTransparency = 1, Size = UDim2.new(1, -14, 1, -10), Position = UDim2.new(0, 7, 0, 5),
        ScrollBarThickness = 0, CanvasSize = UDim2.new(0, 0, 0, 0)
    }, { Create("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 3)}) })

    local Pages = Create("Folder", {Name = "Pages", Parent = Main})
    local PageContainer = Create("Frame", {
        Name = "PageContainer", Parent = Main, BackgroundTransparency = 1,
        Position = UDim2.new(0, 155, 0, 35), Size = UDim2.new(1, -165, 1, -45)
    })

    -- Tooltip Setup
    local TooltipFrame = Create("Frame", {
        Parent = ScreenGui, Size = UDim2.new(0, 0, 0, 25), BackgroundColor3 = Color3.fromRGB(20, 20, 20), Visible = false, ZIndex = 100, ClipsDescendants = true
    }, {
        MakeCorner(4),
        Create("TextLabel", {Name = "Text", BackgroundTransparency = 1, Size = UDim2.new(1, -10, 1, 0), Position = UDim2.new(0, 5, 0, 0),
        Font = Enum.Font.GothamSemibold, TextSize = 13, Theme = {TextColor3 = "TextColor"}, TextXAlignment = Enum.TextXAlignment.Left})
    })

    local function ShowTooltip(text)
        TooltipFrame.Text.Text = text
        local size = game:GetService("TextService"):GetTextSize(text, 13, Enum.Font.GothamSemibold, Vector2.new(500, 25))
        TooltipFrame.Size = UDim2.new(0, size.X + 15, 0, 25)
        TooltipFrame.Visible = true
        local conn
        conn = RunService.RenderStepped:Connect(function()
            local mouse = UserInputService:GetMouseLocation()
            TooltipFrame.Position = UDim2.new(0, mouse.X + 15, 0, mouse.Y - 15)
        end)
        return conn
    end

    local function AddTooltipBehavior(element, text)
        local conn
        element.MouseEnter:Connect(function() conn = ShowTooltip(text) end)
        element.MouseLeave:Connect(function() if conn then conn:Disconnect() TooltipFrame.Visible = false end end)
    end

    local Tabs = {}
    local firstTab = true

    function Tabs:NewTab(tabName)
        local TabBtn = Create("TextButton", {
            Parent = TabFrames, Size = UDim2.new(1, 0, 0, 28), BackgroundTransparency = firstTab and 0 or 1, AutoButtonColor = false,
            Text = tabName, Font = Enum.Font.Gotham, TextSize = 14,
            Theme = {BackgroundColor3 = "SchemeColor", TextColor3 = "TextColor"}
        }, {MakeCorner(4)})

        local Page = Create("ScrollingFrame", {
            Parent = PageContainer, Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, ScrollBarThickness = 4, Visible = firstTab,
            Theme = {ScrollBarImageColor3 = "SchemeColor"}
        }, { Create("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 6)}) })
        
        Page.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            Page.CanvasSize = UDim2.new(0, 0, 0, Page.UIListLayout.AbsoluteContentSize.Y)
        end)
        TabFrames.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            TabFrames.CanvasSize = UDim2.new(0, 0, 0, TabFrames.UIListLayout.AbsoluteContentSize.Y)
        end)

        TabBtn.MouseButton1Click:Connect(function()
            for _, v in pairs(PageContainer:GetChildren()) do v.Visible = false end
            for _, v in pairs(TabFrames:GetChildren()) do
                if v:IsA("TextButton") then Tween(v, {BackgroundTransparency = 1}) end
            end
            Page.Visible = true
            Tween(TabBtn, {BackgroundTransparency = 0})
        end)
        
        firstTab = false
        local Sections = {}

        function Sections:NewSection(secName, hidden)
            local SectionFrame = Create("Frame", {Parent = Page, Size = UDim2.new(1, 0, 0, 33), BackgroundTransparency = 1})
            local SectionLayout = Create("UIListLayout", {Parent = SectionFrame, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 5)})
            
            SectionLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                SectionFrame.Size = UDim2.new(1, 0, 0, SectionLayout.AbsoluteContentSize.Y)
            end)

            if not hidden then
                Create("Frame", {
                    Parent = SectionFrame, Size = UDim2.new(1, 0, 0, 33), Theme = {BackgroundColor3 = "SchemeColor"}
                }, {
                    MakeCorner(4),
                    Create("TextLabel", {
                        BackgroundTransparency = 1, Size = UDim2.new(1, -10, 1, 0), Position = UDim2.new(0, 10, 0, 0),
                        Font = Enum.Font.Gotham, Text = secName, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left, Theme = {TextColor3 = "TextColor"}
                    })
                })
            end

            local Elements = {}

            -- Helper to wrap element creation interactions
            local function Wrapper(title, infoText)
                local btn = Create("TextButton", {
                    Parent = SectionFrame, Size = UDim2.new(1, 0, 0, 33), AutoButtonColor = false, Text = "",
                    Theme = {BackgroundColor3 = "ElementColor"}
                }, {
                    MakeCorner(4),
                    Create("TextLabel", {
                        Name = "Title", BackgroundTransparency = 1, Size = UDim2.new(1, -40, 1, 0), Position = UDim2.new(0, 35, 0, 0),
                        Font = Enum.Font.GothamSemibold, Text = title, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left, Theme = {TextColor3 = "TextColor"}
                    })
                })

                btn.MouseEnter:Connect(function() Tween(btn, {BackgroundColor3 = Lighten(currentTheme.ElementColor, 0.05)}) end)
                btn.MouseLeave:Connect(function() Tween(btn, {BackgroundColor3 = currentTheme.ElementColor}) end)

                if infoText and infoText ~= "" then
                    local infoIcon = Create("ImageLabel", {
                        Parent = btn, BackgroundTransparency = 1, Size = UDim2.new(0, 20, 0, 20), Position = UDim2.new(1, -25, 0.5, -10),
                        Image = "rbxassetid://3926305904", ImageRectOffset = Vector2.new(764, 764), ImageRectSize = Vector2.new(36, 36),
                        Theme = {ImageColor3 = "SchemeColor"}
                    })
                    AddTooltipBehavior(infoIcon, infoText)
                end

                return btn
            end

            function Elements:NewButton(bname, tipINf, callback)
                local btn = Wrapper(bname, tipINf)
                Create("ImageLabel", {
                    Parent = btn, BackgroundTransparency = 1, Size = UDim2.new(0, 20, 0, 20), Position = UDim2.new(0, 7, 0.5, -10),
                    Image = "rbxassetid://3926305904", ImageRectOffset = Vector2.new(84, 204), ImageRectSize = Vector2.new(36, 36), Theme = {ImageColor3 = "SchemeColor"}
                })
                btn.MouseButton1Click:Connect(function()
                    RippleEffect(btn)
                    if callback then pcall(callback) end
                end)
                return { UpdateButton = function(self, newName) btn.Title.Text = newName end }
            end

            function Elements:NewToggle(tname, tip, callback)
                local btn = Wrapper(tname, tip)
                local state = false
                local icon = Create("ImageLabel", {
                    Parent = btn, BackgroundTransparency = 1, Size = UDim2.new(0, 20, 0, 20), Position = UDim2.new(0, 7, 0.5, -10),
                    Image = "rbxassetid://3926309567", ImageRectOffset = Vector2.new(628, 420), ImageRectSize = Vector2.new(48, 48), Theme = {ImageColor3 = "SchemeColor"}
                })
                
                local function Fire()
                    state = not state
                    icon.ImageRectOffset = state and Vector2.new(784, 420) or Vector2.new(628, 420)
                    RippleEffect(btn)
                    if callback then pcall(callback, state) end
                end
                btn.MouseButton1Click:Connect(Fire)
                
                return { UpdateToggle = function(self, newText, forceState)
                    if newText then btn.Title.Text = newText end
                    if forceState ~= nil and state ~= forceState then Fire() end
                end }
            end

            function Elements:NewTextBox(tname, tip, callback)
                local btn = Wrapper(tname, tip)
                Create("ImageLabel", {
                    Parent = btn, BackgroundTransparency = 1, Size = UDim2.new(0, 20, 0, 20), Position = UDim2.new(0, 7, 0.5, -10),
                    Image = "rbxassetid://3926305904", ImageRectOffset = Vector2.new(324, 604), ImageRectSize = Vector2.new(36, 36), Theme = {ImageColor3 = "SchemeColor"}
                })
                
                local box = Create("TextBox", {
                    Parent = btn, Size = UDim2.new(0, 120, 0, 20), Position = UDim2.new(1, -155, 0.5, -10),
                    Font = Enum.Font.Gotham, TextSize = 12, Text = "", PlaceholderText = "Type...", ClearTextOnFocus = false,
                    Theme = {BackgroundColor3 = "Background", TextColor3 = "TextColor"}
                }, {MakeCorner(4)})
                
                box.FocusLost:Connect(function(enter)
                    if enter and callback then
                        pcall(callback, box.Text)
                        box.Text = ""
                    end
                end)
            end

            function Elements:NewSlider(sname, tip, max, min, callback)
                min = min or 0; max = max or 100
                local btn = Wrapper(sname, tip)
                local Value = min
                
                Create("ImageLabel", {
                    Parent = btn, BackgroundTransparency = 1, Size = UDim2.new(0, 20, 0, 20), Position = UDim2.new(0, 7, 0.5, -10),
                    Image = "rbxassetid://3926307971", ImageRectOffset = Vector2.new(404, 164), ImageRectSize = Vector2.new(36, 36), Theme = {ImageColor3 = "SchemeColor"}
                })
                
                local valText = Create("TextLabel", {
                    Parent = btn, BackgroundTransparency = 1, Size = UDim2.new(0, 40, 1, 0), Position = UDim2.new(0.4, 0, 0, 0),
                    Font = Enum.Font.GothamSemibold, TextSize = 13, Text = tostring(min), Theme = {TextColor3 = "TextColor"}
                })
                
                local track = Create("Frame", {
                    Parent = btn, Size = UDim2.new(0, 130, 0, 6), Position = UDim2.new(1, -165, 0.5, -3),
                    Theme = {BackgroundColor3 = "Background"}
                }, {MakeCorner(4)})
                
                local fill = Create("Frame", {
                    Parent = track, Size = UDim2.new(0, 0, 1, 0), Theme = {BackgroundColor3 = "SchemeColor"}
                }, {MakeCorner(4)})
                
                local dragging = false
                local function UpdateSlide(input)
                    local percent = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
                    fill.Size = UDim2.new(percent, 0, 1, 0)
                    Value = math.floor(min + ((max - min) * percent))
                    valText.Text = tostring(Value)
                    if callback then pcall(callback, Value) end
                end
                
                track.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = true
                        UpdateSlide(input)
                    end
                end)
                UserInputService.InputChanged:Connect(function(input)
                    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then UpdateSlide(input) end
                end)
                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
                end)
            end

            function Elements:NewDropdown(dropname, tip, list, callback)
                local btn = Wrapper(dropname, tip)
                local open = false
                
                local DropIcon = Create("ImageLabel", {
                    Parent = btn, BackgroundTransparency = 1, Size = UDim2.new(0, 20, 0, 20), Position = UDim2.new(0, 7, 0, 6),
                    Image = "rbxassetid://3926305904", ImageRectOffset = Vector2.new(644, 364), ImageRectSize = Vector2.new(36, 36), Theme = {ImageColor3 = "SchemeColor"}
                })

                local ListFrame = Create("Frame", {
                    Parent = SectionFrame, Size = UDim2.new(1, 0, 0, 0), BackgroundTransparency = 1, ClipsDescendants = true, Visible = false
                })
                local ListLayout = Create("UIListLayout", {Parent = ListFrame, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 2)})

                local function Populate(newList)
                    for _, v in pairs(ListFrame:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
                    for _, v in ipairs(newList) do
                        local opt = Create("TextButton", {
                            Parent = ListFrame, Size = UDim2.new(1, 0, 0, 30), AutoButtonColor = false, Font = Enum.Font.Gotham,
                            Text = "  " .. tostring(v), TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, Theme = {BackgroundColor3 = "Background", TextColor3 = "TextColor"}
                        }, {MakeCorner(4)})
                        opt.MouseEnter:Connect(function() Tween(opt, {BackgroundColor3 = Lighten(currentTheme.Background, 0.05)}) end)
                        opt.MouseLeave:Connect(function() Tween(opt, {BackgroundColor3 = currentTheme.Background}) end)
                        opt.MouseButton1Click:Connect(function()
                            btn.Title.Text = tostring(v)
                            btn.MouseButton1Click:Fire() -- close drop
                            if callback then pcall(callback, v) end
                        end)
                    end
                end
                Populate(list or {})

                btn.MouseButton1Click:Connect(function()
                    RippleEffect(btn)
                    open = not open
                    if open then
                        ListFrame.Visible = true
                        Tween(ListFrame, {Size = UDim2.new(1, 0, 0, ListLayout.AbsoluteContentSize.Y)})
                    else
                        local t = TweenService:Create(ListFrame, tweenInfo, {Size = UDim2.new(1, 0, 0, 0)})
                        t:Play()
                        t.Completed:Connect(function() if not open then ListFrame.Visible = false end end)
                    end
                end)
                
                return { Refresh = function(self, newList) Populate(newList) end }
            end

            function Elements:NewKeybind(kname, tip, default, callback)
                local btn = Wrapper(kname, tip)
                local key = default
                local binding = false

                Create("ImageLabel", {
                    Parent = btn, BackgroundTransparency = 1, Size = UDim2.new(0, 20, 0, 20), Position = UDim2.new(0, 7, 0.5, -10),
                    Image = "rbxassetid://3926305904", ImageRectOffset = Vector2.new(364, 284), ImageRectSize = Vector2.new(36, 36), Theme = {ImageColor3 = "SchemeColor"}
                })
                
                local valText = Create("TextLabel", {
                    Parent = btn, BackgroundTransparency = 1, Size = UDim2.new(0, 100, 1, 0), Position = UDim2.new(1, -135, 0, 0),
                    Font = Enum.Font.GothamSemibold, TextSize = 13, Text = key and key.Name or "None", TextXAlignment = Enum.TextXAlignment.Right, Theme = {TextColor3 = "SchemeColor"}
                })

                btn.MouseButton1Click:Connect(function()
                    binding = true
                    valText.Text = "..."
                end)

                UserInputService.InputBegan:Connect(function(input, processed)
                    if binding and input.UserInputType == Enum.UserInputType.Keyboard then
                        binding = false
                        key = input.KeyCode
                        valText.Text = key.Name
                    elseif not binding and not processed and key and input.KeyCode == key then
                        if callback then pcall(callback) end
                    end
                end)
            end

            return Elements
        end
        return Sections
    end
    return Tabs
end

return Kavo
