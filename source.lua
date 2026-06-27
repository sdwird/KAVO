--[[
Kavo UI Library - The Ultimate Optimized Edition (v5)
Features: Event-driven architecture, Config System, Collapsible Sections,
Searchable Dropdowns, Slider Increments, Dynamic Element API, RichText,
Watermarks, Active Modules List, Player Dropdowns, Safe Unload,
Global Omni-Search, Window Resizability, Element Icons.
]]

-- /* STREAMING_CHUNK:Initializing Services, Constants, and Core Theme Manager... */
local Kavo = { Flags = {}, Elements = {} }
local TS = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local RS = game:GetService("RunService")
local CG = game:GetService("CoreGui")
local PLRS = game:GetService("Players")
local HTTP = game:GetService("HttpService")

local tweenInfo = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local easeQuadOut = Enum.EasingStyle.Quad
local easeDirOut = Enum.EasingDirection.Out

local currentTheme = {}
local themeObjects = {}
local activeConnections = {}

local function ApplyTheme(instance, property, themeKey)
table.insert(themeObjects, {Inst = instance, Prop = property, Key = themeKey})
if currentTheme[themeKey] then instance[property] = currentTheme[themeKey] end
end

local function UpdateTheme()
for i = #themeObjects, 1, -1 do
local obj = themeObjects[i]
if obj.Inst and obj.Inst.Parent then
TS:Create(obj.Inst, tweenInfo, {[obj.Prop] = currentTheme[obj.Key]}):Play()
else
table.remove(themeObjects, i)
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

-- /* STREAMING_CHUNK:Defining Builders, Utility Functions, and Visual Effects... */
local function Tween(obj, props, duration)
TS:Create(obj, duration and TweenInfo.new(duration, easeQuadOut, easeDirOut) or tweenInfo, props):Play()
end

local function Lighten(color, amount)
return Color3.new(math.clamp(color.r + amount, 0, 1), math.clamp(color.g + amount, 0, 1), math.clamp(color.b + amount, 0, 1))
end

local function Create(className, properties, children)
local inst = Instance.new(className)
for k, v in pairs(properties or {}) do
if k == "Theme" then
for prop, themeKey in pairs(v) do ApplyTheme(inst, prop, themeKey) end
elseif type(k) == "number" then v.Parent = inst
else inst[k] = v end
end
for _, child in ipairs(children or {}) do child.Parent = inst end
return inst
end

local function MakeCorner(radius) return Create("UICorner", {CornerRadius = UDim.new(0, radius or 4)}) end
local function MakeStroke(thickness, transparency)
return Create("UIStroke", { Thickness = thickness or 1, Transparency = transparency or 0.8, Theme = {Color = "SchemeColor"}, ApplyStrokeMode = Enum.ApplyStrokeMode.Border })
end

local function RippleEffect(btn)
local mouse = PLRS.LocalPlayer:GetMouse()
local ripple = Create("ImageLabel", {
BackgroundColor3 = Color3.fromRGB(255, 255, 255), BackgroundTransparency = 1, Image = "rbxassetid://4560909609",
ImageTransparency = 0.6, Theme = {ImageColor3 = "SchemeColor"}, ZIndex = btn.ZIndex + 1, Parent = btn
})
ripple.Position = UDim2.new(0, mouse.X - btn.AbsolutePosition.X, 0, mouse.Y - btn.AbsolutePosition.Y)
local size = math.max(btn.AbsoluteSize.X, btn.AbsoluteSize.Y) * 1.5
TS:Create(ripple, TweenInfo.new(0.4, easeQuadOut, easeDirOut), { Size = UDim2.new(0, size, 0, size), Position = UDim2.new(0.5, -size/2, 0.5, -size/2), ImageTransparency = 1 }):Play()
game.Debris:AddItem(ripple, 0.4)
end

function Kavo:DraggingEnabled(frame, parent)
parent = parent or frame
local dragging, dragInput, mousePos, framePos

frame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true; mousePos = input.Position; framePos = parent.Position
        input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
    end
end)
frame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end
end)
table.insert(activeConnections, UIS.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - mousePos
        parent.Position = UDim2.new(framePos.X.Scale, framePos.X.Offset + delta.X, framePos.Y.Scale, framePos.Y.Offset + delta.Y)
    end
end))


end

-- /* STREAMING_CHUNK:Constructing Main UI Window, Navigation, and Resizer... */
local LibName = "Kavo_" .. tostring(math.random(1000, 9999))

function Kavo:ToggleUI()
local gui = CG:FindFirstChild(LibName)
if gui then local main = gui:FindFirstChild("Main") if main then main.Visible = not main.Visible end end
end

function Kavo.CreateLib(kavName, themeList, toggleKey)
kavName = kavName or "Library"; local uiToggleKey = toggleKey or Enum.KeyCode.RightShift

table.clear(themeObjects); for _, conn in pairs(activeConnections) do conn:Disconnect() end; table.clear(activeConnections)
Kavo.Flags = {}; Kavo.Elements = {}
currentTheme = (type(themeList) == "string" and themes[themeList]) or (type(themeList) == "table" and themeList) or themes.DarkTheme

for _, v in pairs(CG:GetChildren()) do if v.Name == LibName then v:Destroy() end end

local ScreenGui = Create("ScreenGui", {Name = LibName, Parent = CG, ResetOnSpawn = false, ZIndexBehavior = Enum.ZIndexBehavior.Sibling})

local Main = Create("Frame", { Name = "Main", Parent = ScreenGui, ClipsDescendants = true, Position = UDim2.new(0.5, -262, 0.5, -159), Size = UDim2.new(0, 525, 0, 318), Theme = {BackgroundColor3 = "Background"} }, { MakeCorner(4), MakeStroke(1, 0.7) })
local MainHeader = Create("Frame", { Name = "MainHeader", Parent = Main, Size = UDim2.new(1, 0, 0, 29), Theme = {BackgroundColor3 = "Header"} }, { MakeCorner(4), Create("Frame", {Size = UDim2.new(1, 0, 0, 7), Position = UDim2.new(0, 0, 1, -7), BorderSizePixel = 0, Theme = {BackgroundColor3 = "Header"}}), Create("TextLabel", { Text = kavName, Font = Enum.Font.GothamBold, TextSize = 16, TextColor3 = Color3.fromRGB(245, 245, 245), BackgroundTransparency = 1, Position = UDim2.new(0, 10, 0, 0), Size = UDim2.new(0, 200, 1, 0), TextXAlignment = Enum.TextXAlignment.Left, RichText = true }) })

local CloseBtn = Create("ImageButton", { Parent = MainHeader, BackgroundTransparency = 1, Position = UDim2.new(1, -25, 0.5, -10), Size = UDim2.new(0, 20, 0, 20), Image = "rbxassetid://3926305904", ImageRectOffset = Vector2.new(284, 4), ImageRectSize = Vector2.new(24, 24) })
local MinBtn = Create("ImageButton", { Parent = MainHeader, BackgroundTransparency = 1, Position = UDim2.new(1, -50, 0.5, -10), Size = UDim2.new(0, 20, 0, 20), Image = "rbxassetid://3926307971", ImageRectOffset = Vector2.new(884, 284), ImageRectSize = Vector2.new(36, 36) })

local isMinimized = false
MinBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    Tween(Main, {Size = isMinimized and UDim2.new(0, 525, 0, 29) or UDim2.new(0, 525, 0, 318)}, 0.2)
end)
CloseBtn.MouseButton1Click:Connect(function()
    Tween(Main, {Size = UDim2.new(0, 0, 0, 0), Position = UDim2.new(0, Main.AbsolutePosition.X + (Main.AbsoluteSize.X/2), 0, Main.AbsolutePosition.Y + (Main.AbsoluteSize.Y/2))}, 0.2); task.wait(0.2); ScreenGui:Destroy()
end)
Kavo:DraggingEnabled(MainHeader, Main)

-- Window Resizer Handle
local ResizeHandle = Create("ImageButton", { Parent = Main, BackgroundTransparency = 1, Position = UDim2.new(1, -15, 1, -15), Size = UDim2.new(0, 15, 0, 15), Image = "rbxassetid://3926305904", ImageRectOffset = Vector2.new(284, 764), ImageRectSize = Vector2.new(36, 36), Theme = {ImageColor3 = "SchemeColor"}, ZIndex = 100 })
local draggingResize = false; local dragStart, startSize
ResizeHandle.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then draggingResize = true; dragStart = input.Position; startSize = Main.AbsoluteSize end
end)
table.insert(activeConnections, UIS.InputChanged:Connect(function(input)
    if draggingResize and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        Main.Size = UDim2.new(0, math.clamp(startSize.X + delta.X, 450, 900), 0, math.clamp(startSize.Y + delta.Y, 250, 700))
    end
end))
table.insert(activeConnections, UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then draggingResize = false end
end))

local MainSide = Create("Frame", { Name = "MainSide", Parent = Main, Position = UDim2.new(0, 0, 0, 29), Size = UDim2.new(0, 149, 1, -29), Theme = {BackgroundColor3 = "Header"} }, { MakeCorner(4), Create("Frame", {Size = UDim2.new(0, 7, 1, 0), Position = UDim2.new(1, -7, 0, 0), BorderSizePixel = 0, Theme = {BackgroundColor3 = "Header"}}) })

-- Global Search Container
local SearchContainer = Create("Frame", { Parent = MainSide, Size = UDim2.new(1, -14, 0, 26), Position = UDim2.new(0, 7, 0, 8), BackgroundTransparency = 1 })
local SearchBox = Create("TextBox", { Parent = SearchContainer, Size = UDim2.new(1, 0, 1, 0), Theme = {BackgroundColor3 = "Background", TextColor3 = "TextColor"}, Font = Enum.Font.Gotham, TextSize = 12, Text = "", PlaceholderText = "Search Elements...", ClearTextOnFocus = false }, {MakeCorner(4), MakeStroke(1, 0.5)})
Create("ImageLabel", { Parent = SearchBox, BackgroundTransparency = 1, Size = UDim2.new(0, 16, 0, 16), Position = UDim2.new(0, 5, 0.5, -8), Image = "rbxassetid://3926305904", ImageRectOffset = Vector2.new(964, 324), ImageRectSize = Vector2.new(36, 36), Theme = {ImageColor3 = "SchemeColor"} })
Create("UIPadding", {Parent = SearchBox, PaddingLeft = UDim.new(0, 25)})

local TabFrames = Create("ScrollingFrame", { Name = "TabFrames", Parent = MainSide, BackgroundTransparency = 1, Size = UDim2.new(1, -14, 1, -45), Position = UDim2.new(0, 7, 0, 42), ScrollBarThickness = 0, CanvasSize = UDim2.new(0, 0, 0, 0) }, { Create("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 4)}) })
local SearchResultsList = Create("ScrollingFrame", { Name = "SearchResultsList", Parent = MainSide, BackgroundTransparency = 1, Size = UDim2.new(1, -14, 1, -45), Position = UDim2.new(0, 7, 0, 42), ScrollBarThickness = 2, CanvasSize = UDim2.new(0, 0, 0, 0), Visible = false, Theme = {ScrollBarImageColor3 = "SchemeColor"} }, { Create("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 4)}) })

local PageContainer = Create("Frame", { Name = "PageContainer", Parent = Main, BackgroundTransparency = 1, Position = UDim2.new(0, 155, 0, 35), Size = UDim2.new(1, -165, 1, -45) })

-- /* STREAMING_CHUNK:Setting up Notifiers, Watermarks, and Core Behaviors... */
local TooltipFrame = Create("Frame", { Parent = ScreenGui, Size = UDim2.new(0, 0, 0, 25), BackgroundColor3 = Color3.fromRGB(20, 20, 20), Visible = false, ZIndex = 100, ClipsDescendants = true }, { MakeCorner(4), MakeStroke(1, 0.5), Create("TextLabel", {Name = "Text", BackgroundTransparency = 1, Size = UDim2.new(1, -10, 1, 0), Position = UDim2.new(0, 5, 0, 0), Font = Enum.Font.GothamSemibold, TextSize = 13, Theme = {TextColor3 = "TextColor"}, TextXAlignment = Enum.TextXAlignment.Left, RichText = true}) })
local NotifyContainer = Create("Frame", { Name = "NotifyContainer", Parent = ScreenGui, BackgroundTransparency = 1, Position = UDim2.new(1, -20, 1, -20), Size = UDim2.new(0, 250, 1, -40), AnchorPoint = Vector2.new(1, 1) }, { Create("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 10), VerticalAlignment = Enum.VerticalAlignment.Bottom}) })

local WatermarkFrame = Create("Frame", { Parent = ScreenGui, Size = UDim2.new(0, 200, 0, 30), Position = UDim2.new(0, 20, 0, 20), Visible = false, Theme = {BackgroundColor3 = "Background"} }, { MakeCorner(4), MakeStroke(1, 0.5) })
local WatermarkText = Create("TextLabel", { Parent = WatermarkFrame, Size = UDim2.new(1, -20, 1, 0), Position = UDim2.new(0, 10, 0, 0), BackgroundTransparency = 1, Font = Enum.Font.GothamSemibold, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, Theme = {TextColor3 = "TextColor"}, RichText = true })
Kavo:DraggingEnabled(WatermarkFrame)

local ActiveModsFrame = Create("Frame", { Parent = ScreenGui, Size = UDim2.new(0, 180, 0, 30), Position = UDim2.new(0, 20, 0, 60), Visible = false, Theme = {BackgroundColor3 = "Background"}, ClipsDescendants = true }, { MakeCorner(4), MakeStroke(1, 0.5) })
Create("TextLabel", { Parent = ActiveModsFrame, Size = UDim2.new(1, 0, 0, 30), BackgroundTransparency = 1, Text = "Active Modules", Font = Enum.Font.GothamBold, TextSize = 13, Theme = {TextColor3 = "SchemeColor"} })
Create("Frame", { Parent = ActiveModsFrame, Size = UDim2.new(1, 0, 0, 1), Position = UDim2.new(0, 0, 0, 30), BackgroundColor3 = Color3.fromRGB(50, 50, 50), BorderSizePixel = 0 })
local ActiveModsList = Create("Frame", { Parent = ActiveModsFrame, Size = UDim2.new(1, 0, 1, -31), Position = UDim2.new(0, 0, 0, 31), BackgroundTransparency = 1 }, { Create("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 2)}) })
Kavo:DraggingEnabled(ActiveModsFrame)

local function AddTooltipBehavior(element, text)
    local conn
    element.MouseEnter:Connect(function() 
        TooltipFrame.Text.Text = text; local size = game:GetService("TextService"):GetTextSize(text, 13, Enum.Font.GothamSemibold, Vector2.new(500, 25))
        TooltipFrame.Size = UDim2.new(0, size.X + 15, 0, 25); TooltipFrame.Visible = true
        conn = RS.RenderStepped:Connect(function() local mouse = UIS:GetMouseLocation(); TooltipFrame.Position = UDim2.new(0, mouse.X + 15, 0, mouse.Y - 20) end)
    end)
    element.MouseLeave:Connect(function() if conn then conn:Disconnect() TooltipFrame.Visible = false end end)
end

table.insert(activeConnections, UIS.InputBegan:Connect(function(input, processed) if not processed and input.KeyCode == uiToggleKey then Main.Visible = not Main.Visible end end))

local Window = { ActiveModulesEnabled = false, GlobalElements = {} }
local firstTab = true
local activeModsTable = {}

function Window:Unload()
    for _, conn in pairs(activeConnections) do conn:Disconnect() end
    table.clear(activeConnections); table.clear(themeObjects); ScreenGui:Destroy()
end

function Window:SetWatermark(state, text)
    WatermarkFrame.Visible = state
    local function UpdateWM(newText) WatermarkText.Text = newText; local textBounds = game:GetService("TextService"):GetTextSize(newText, 13, Enum.Font.GothamSemibold, Vector2.new(1000, 30)); WatermarkFrame.Size = UDim2.new(0, textBounds.X + 20, 0, 30) end
    if text then UpdateWM(text) end
    return { Update = UpdateWM }
end

function Window:SetActiveModules(state) Window.ActiveModulesEnabled = state; ActiveModsFrame.Visible = state end

local function UpdateActiveMods(name, state)
    if not Window.ActiveModulesEnabled then return end
    if state then
        if not activeModsTable[name] then activeModsTable[name] = Create("TextLabel", { Parent = ActiveModsList, Size = UDim2.new(1, -20, 0, 20), Position = UDim2.new(0, 10, 0, 0), BackgroundTransparency = 1, Font = Enum.Font.Gotham, TextSize = 12, Text = name, TextXAlignment = Enum.TextXAlignment.Left, Theme = {TextColor3 = "TextColor"} }) end
    else if activeModsTable[name] then activeModsTable[name]:Destroy(); activeModsTable[name] = nil end end
    local count = 0; for _ in pairs(activeModsTable) do count = count + 1 end
    Tween(ActiveModsFrame, {Size = UDim2.new(0, 180, 0, 30 + (count * 22))}, 0.2)
end

function Window:Notify(title, text, duration, notifyType)
    duration = duration or 4; notifyType = notifyType or "Info"
    local colors = {Info = "SchemeColor", Success = Color3.fromRGB(46, 204, 113), Error = Color3.fromRGB(231, 76, 60), Warning = Color3.fromRGB(241, 196, 15)}
    local hColor = type(colors[notifyType]) == "string" and currentTheme.SchemeColor or colors[notifyType]

    local notifyWrapper = Create("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 65), ClipsDescendants = true, Parent = NotifyContainer })
    local notifyFrame = Create("Frame", { Size = UDim2.new(1, 0, 1, 0), Position = UDim2.new(1, 50, 0, 0), Theme = {BackgroundColor3 = "Background"}, Parent = notifyWrapper }, { MakeCorner(4), MakeStroke(1, 0.5), Create("Frame", {Size = UDim2.new(0, 4, 1, 0), BackgroundColor3 = hColor, BorderSizePixel = 0}, {MakeCorner(4)}), Create("TextLabel", { Text = title, Font = Enum.Font.GothamBold, TextSize = 14, Size = UDim2.new(1, -25, 0, 20), Position = UDim2.new(0, 15, 0, 5), TextXAlignment = Enum.TextXAlignment.Left, BackgroundTransparency = 1, TextColor3 = hColor }), Create("TextLabel", { Text = text, Font = Enum.Font.Gotham, TextSize = 12, Size = UDim2.new(1, -25, 0, 35), Position = UDim2.new(0, 15, 0, 25), TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true, BackgroundTransparency = 1, Theme = {TextColor3 = "TextColor"} }) })
    Tween(notifyFrame, {Position = UDim2.new(0, 0, 0, 0)})
    task.delay(duration, function() local out = TS:Create(notifyFrame, tweenInfo, {Position = UDim2.new(1, 50, 0, 0)}); out:Play(); out.Completed:Connect(function() notifyWrapper:Destroy() end) end)
end

function Window:ChangeTheme(themeName) if themes[themeName] then currentTheme = themes[themeName]; UpdateTheme() end end
function Window:SaveConfig(folderName, fileName) if not isfolder(folderName) then makefolder(folderName) end; writefile(folderName.."/"..fileName..".json", HTTP:JSONEncode(Kavo.Flags)); Window:Notify("Config Saved", "Successfully saved settings to " .. fileName, 3, "Success") end
function Window:LoadConfig(folderName, fileName) local path = folderName.."/"..fileName..".json"; if isfile(path) then local data = HTTP:JSONDecode(readfile(path)); for flag, value in pairs(data) do if Kavo.Elements[flag] then Kavo.Elements[flag](value) end end; Window:Notify("Config Loaded", "Successfully loaded settings.", 3, "Success") else Window:Notify("Config Error", "Save file not found.", 3, "Error") end end

-- /* STREAMING_CHUNK:Building the Global Omnibar Search Logic... */
SearchResultsList.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() SearchResultsList.CanvasSize = UDim2.new(0, 0, 0, SearchResultsList.UIListLayout.AbsoluteContentSize.Y) end)

SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
    local query = SearchBox.Text:lower()
    if query == "" then
        TabFrames.Visible = true; SearchResultsList.Visible = false
    else
        TabFrames.Visible = false; SearchResultsList.Visible = true
        for _, v in pairs(SearchResultsList:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
        for _, data in ipairs(Window.GlobalElements) do
            if data.Name:lower():find(query) then
                local resBtn = Create("TextButton", { Parent = SearchResultsList, Size = UDim2.new(1, 0, 0, 30), AutoButtonColor = false, Theme = {BackgroundColor3 = "Background"}, Text = "" }, { MakeCorner(4), MakeStroke(1, 0.5), Create("TextLabel", { BackgroundTransparency = 1, Size = UDim2.new(1, -10, 1, 0), Position = UDim2.new(0, 5, 0, 0), Font = Enum.Font.Gotham, TextSize = 12, Text = data.Name, TextXAlignment = Enum.TextXAlignment.Left, Theme = {TextColor3 = "TextColor"} }) })
                resBtn.MouseEnter:Connect(function() Tween(resBtn, {BackgroundColor3 = Lighten(currentTheme.Background, 0.1)}) end)
                resBtn.MouseLeave:Connect(function() Tween(resBtn, {BackgroundColor3 = currentTheme.Background}) end)
                resBtn.MouseButton1Click:Connect(function()
                    SearchBox.Text = "" -- Close Search
                    data.NavigateTo() -- Trigger element focus
                end)
            end
        end
    end
end)

-- /* STREAMING_CHUNK:Constructing Tabs, Sections, and Component Logic... */
function Window:NewTab(tabName, iconId)
    local TabBtn = Create("TextButton", { Parent = TabFrames, Size = UDim2.new(1, 0, 0, 28), BackgroundTransparency = firstTab and 0 or 1, AutoButtonColor = false, Text = "", Theme = {BackgroundColor3 = "SchemeColor"} }, { MakeCorner(4), Create("TextLabel", { BackgroundTransparency = 1, Size = UDim2.new(1, iconId and -25 or 0, 1, 0), Position = UDim2.new(0, iconId and 25 or 0, 0, 0), Font = Enum.Font.GothamSemibold, TextSize = 13, Text = tabName, Theme = {TextColor3 = "TextColor"} }) })
    if iconId then Create("ImageLabel", { Parent = TabBtn, BackgroundTransparency = 1, Size = UDim2.new(0, 16, 0, 16), Position = UDim2.new(0, 5, 0.5, -8), Image = iconId, Theme = {ImageColor3 = "TextColor"} }) end

    local Page = Create("ScrollingFrame", { Parent = PageContainer, Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, ScrollBarThickness = 4, Visible = firstTab, Theme = {ScrollBarImageColor3 = "SchemeColor"} }, { Create("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 8)}) })
    Page.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() Page.CanvasSize = UDim2.new(0, 0, 0, Page.UIListLayout.AbsoluteContentSize.Y) end)
    TabFrames.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() TabFrames.CanvasSize = UDim2.new(0, 0, 0, TabFrames.UIListLayout.AbsoluteContentSize.Y) end)

    local function ActivateTab()
        for _, v in pairs(PageContainer:GetChildren()) do v.Visible = false end
        for _, v in pairs(TabFrames:GetChildren()) do if v:IsA("TextButton") then Tween(v, {BackgroundTransparency = 1}) end end
        Page.Visible = true; Tween(TabBtn, {BackgroundTransparency = 0})
    end
    TabBtn.MouseButton1Click:Connect(ActivateTab)
    firstTab = false; local Sections = {}

    function Sections:NewSection(secName, hidden)
        local SectionFrame = Create("Frame", {Parent = Page, Size = UDim2.new(1, 0, 0, 33), BackgroundTransparency = 1, ClipsDescendants = true})
        local open = true
        local SectionHead = Create("TextButton", { Parent = SectionFrame, Size = UDim2.new(1, 0, 0, 33), Theme = {BackgroundColor3 = "SchemeColor"}, AutoButtonColor = false, Text = "" }, { MakeCorner(4) })
        Create("TextLabel", { Parent = SectionHead, BackgroundTransparency = 1, Size = UDim2.new(1, -30, 1, 0), Position = UDim2.new(0, 10, 0, 0), Font = Enum.Font.GothamBold, Text = secName, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left, Theme = {TextColor3 = "TextColor"}, RichText = true })
        local CollapseArrow = Create("ImageLabel", { Parent = SectionHead, BackgroundTransparency = 1, Size = UDim2.new(0, 20, 0, 20), Position = UDim2.new(1, -25, 0.5, -10), Image = "rbxassetid://3926305904", ImageRectOffset = Vector2.new(564, 284), ImageRectSize = Vector2.new(36, 36), Theme = {ImageColor3 = "TextColor"} })

        if hidden then SectionHead.Visible = false; SectionHead.Size = UDim2.new(1,0,0,0) end
        local ContentFrame = Create("Frame", {Parent = SectionFrame, Size = UDim2.new(1, 0, 0, 0), BackgroundTransparency = 1, ClipsDescendants = true})
        local ContentLayout = Create("UIListLayout", {Parent = ContentFrame, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 5)})

        local function UpdateSectionSize()
            local headH = hidden and 0 or 38
            if open then SectionFrame.Size = UDim2.new(1, 0, 0, headH + ContentLayout.AbsoluteContentSize.Y); ContentFrame.Size = UDim2.new(1, 0, 0, ContentLayout.AbsoluteContentSize.Y)
            else SectionFrame.Size = UDim2.new(1, 0, 0, headH > 0 and 33 or 0); ContentFrame.Size = UDim2.new(1, 0, 0, 0) end
        end
        ContentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(UpdateSectionSize)

        local function ToggleSection(forceState)
            if forceState ~= nil then open = forceState else open = not open end
            Tween(CollapseArrow, {Rotation = open and 0 or -90}, 0.2); UpdateSectionSize()
        end
        SectionHead.MouseButton1Click:Connect(ToggleSection)

        local Elements = {}
        
        -- Registers element to OmniSearch
        local function RegisterToSearch(title, elementFrame)
            table.insert(Window.GlobalElements, {
                Name = secName .. " > " .. title,
                NavigateTo = function()
                    ActivateTab()
                    if not open then ToggleSection(true) end
                    -- Flash highlight
                    local originalColor = currentTheme.ElementColor
                    Tween(elementFrame, {BackgroundColor3 = currentTheme.SchemeColor}, 0.2)
                    task.delay(0.5, function() Tween(elementFrame, {BackgroundColor3 = currentTheme.ElementColor}, 0.2) end)
                    -- Scroll into view (Approximate target)
                    task.wait(0.1) 
                    local targetY = elementFrame.AbsolutePosition.Y - Page.AbsolutePosition.Y + Page.CanvasPosition.Y - 50
                    TS:Create(Page, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {CanvasPosition = Vector2.new(0, math.max(0, targetY))}):Play()
                end
            })
        end

        local function Wrapper(title, infoText, iconId)
            local btn = Create("TextButton", { Parent = ContentFrame, Size = UDim2.new(1, 0, 0, 35), AutoButtonColor = false, Text = "", ClipsDescendants = true, Theme = {BackgroundColor3 = "ElementColor"} }, { MakeCorner(4), MakeStroke(1, 0.8), Create("TextLabel", { Name = "Title", BackgroundTransparency = 1, Size = UDim2.new(1, -40, 1, 0), Position = UDim2.new(0, 35, 0, 0), Font = Enum.Font.GothamSemibold, Text = title, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, Theme = {TextColor3 = "TextColor"}, RichText = true }) })
            btn.MouseEnter:Connect(function() Tween(btn, {BackgroundColor3 = Lighten(currentTheme.ElementColor, 0.05)}) end)
            btn.MouseLeave:Connect(function() Tween(btn, {BackgroundColor3 = currentTheme.ElementColor}) end)
            if infoText and infoText ~= "" then local infoIcon = Create("ImageLabel", { Parent = btn, BackgroundTransparency = 1, Size = UDim2.new(0, 18, 0, 18), Position = UDim2.new(1, -25, 0.5, -9), Image = "rbxassetid://3926305904", ImageRectOffset = Vector2.new(764, 764), ImageRectSize = Vector2.new(36, 36), Theme = {ImageColor3 = "SchemeColor"} }); AddTooltipBehavior(infoIcon, infoText) end
            RegisterToSearch(title, btn)
            return btn
        end

        local function BindBaseAPI(elementTable, btnInstance) elementTable.Destroy = function() btnInstance:Destroy() end; elementTable.SetVisible = function(self, state) btnInstance.Visible = state end; return elementTable end

        -- /* STREAMING_CHUNK:Injecting interactable UI elements (Paragraph, Label, Button)... */
        function Elements:NewParagraph(text)
            local lbl = Create("TextLabel", { Parent = ContentFrame, Size = UDim2.new(1, 0, 0, 0), BackgroundTransparency = 1, Font = Enum.Font.Gotham, Text = text, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true, AutomaticSize = Enum.AutomaticSize.Y, Theme = {TextColor3 = "TextColor"}, RichText = true }, { Create("UIPadding", {PaddingTop = UDim.new(0, 5), PaddingBottom = UDim.new(0, 5), PaddingLeft = UDim.new(0, 5), PaddingRight = UDim.new(0, 5)}) })
            return BindBaseAPI({ UpdateParagraph = function(self, newText) lbl.Text = newText end }, lbl)
        end

        function Elements:NewLabel(text)
            local lbl = Create("TextLabel", { Parent = ContentFrame, Size = UDim2.new(1, 0, 0, 30), BackgroundTransparency = 1, Font = Enum.Font.GothamSemibold, Text = text, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, Theme = {TextColor3 = "TextColor"}, RichText = true }, { Create("UIPadding", {PaddingLeft = UDim.new(0, 10)}) })
            return BindBaseAPI({ UpdateLabel = function(self, newText) lbl.Text = newText end }, lbl)
        end

        function Elements:NewButton(bname, tipINf, callback, iconId)
            local btn = Wrapper(bname, tipINf, iconId)
            Create("ImageLabel", { Parent = btn, BackgroundTransparency = 1, Size = UDim2.new(0, 20, 0, 20), Position = UDim2.new(0, 7, 0.5, -10), Image = iconId or "rbxassetid://3926305904", ImageRectOffset = iconId and Vector2.new(0,0) or Vector2.new(84, 204), ImageRectSize = iconId and Vector2.new(0,0) or Vector2.new(36, 36), Theme = {ImageColor3 = "SchemeColor"} })
            btn.MouseButton1Click:Connect(function() RippleEffect(btn); if callback then pcall(callback) end end)
            return BindBaseAPI({ UpdateButton = function(self, newName) btn.Title.Text = newName end }, btn)
        end

        -- /* STREAMING_CHUNK:Creating Toggles and Enhanced Textboxes with Copy... */
        function Elements:NewToggle(tname, tip, callback, flag, iconId)
            local btn = Wrapper(tname, tip, iconId); local state = false
            local icon = Create("ImageLabel", { Parent = btn, BackgroundTransparency = 1, Size = UDim2.new(0, 20, 0, 20), Position = UDim2.new(0, 7, 0.5, -10), Image = iconId or "rbxassetid://3926309567", ImageRectOffset = iconId and Vector2.new(0,0) or Vector2.new(628, 420), ImageRectSize = iconId and Vector2.new(0,0) or Vector2.new(48, 48), Theme = {ImageColor3 = "SchemeColor"} })
            
            local function Fire(force)
                if force ~= nil then state = force else state = not state end
                if flag then Kavo.Flags[flag] = state end
                if not iconId then icon.ImageRectOffset = state and Vector2.new(784, 420) or Vector2.new(628, 420) else icon.ImageTransparency = state and 0 or 0.5 end
                UpdateActiveMods(tname, state); if callback then pcall(callback, state) end
            end
            btn.MouseButton1Click:Connect(function() RippleEffect(btn); Fire() end)
            if flag then Kavo.Flags[flag] = state; Kavo.Elements[flag] = Fire end
            
            return BindBaseAPI({ UpdateToggle = function(self, newText, forceState) if newText then btn.Title.Text = newText end if forceState ~= nil and state ~= forceState then Fire(forceState) end end }, btn)
        end

        function Elements:NewTextBox(tname, tip, callback, flag, iconId)
            local btn = Wrapper(tname, tip, iconId)
            Create("ImageLabel", { Parent = btn, BackgroundTransparency = 1, Size = UDim2.new(0, 20, 0, 20), Position = UDim2.new(0, 7, 0.5, -10), Image = iconId or "rbxassetid://3926305904", ImageRectOffset = iconId and Vector2.new(0,0) or Vector2.new(324, 604), ImageRectSize = iconId and Vector2.new(0,0) or Vector2.new(36, 36), Theme = {ImageColor3 = "SchemeColor"} })
            local box = Create("TextBox", { Parent = btn, Size = UDim2.new(0, 120, 0, 22), Position = UDim2.new(1, -155, 0.5, -11), Font = Enum.Font.Gotham, TextSize = 12, Text = "", PlaceholderText = "Type...", ClearTextOnFocus = false, Theme = {BackgroundColor3 = "Background", TextColor3 = "TextColor"} }, {MakeCorner(4), MakeStroke(1, 0.8)})
            
            -- Copy Button Addition
            local copyBtn = Create("ImageButton", { Parent = btn, BackgroundTransparency = 1, Size = UDim2.new(0, 16, 0, 16), Position = UDim2.new(1, -180, 0.5, -8), Image = "rbxassetid://3926305904", ImageRectOffset = Vector2.new(84, 204), ImageRectSize = Vector2.new(36, 36), Theme = {ImageColor3 = "SchemeColor"} })
            copyBtn.MouseButton1Click:Connect(function() setclipboard(box.Text); Window:Notify("Copied", "Text copied to clipboard.", 2, "Success") end)

            local function SetText(txt) box.Text = txt; if flag then Kavo.Flags[flag] = txt end; if callback then pcall(callback, txt) end end
            box.FocusLost:Connect(function(enter) if enter then SetText(box.Text) end end)
            if flag then Kavo.Flags[flag] = ""; Kavo.Elements[flag] = SetText end
            return BindBaseAPI({ UpdateTextBox = SetText }, btn)
        end

        -- /* STREAMING_CHUNK:Creating Precision Slider with Step support... */
        function Elements:NewSlider(sname, tip, max, min, step, callback, flag, suffix, iconId)
            min = min or 0; max = max or 100; step = step or 1; suffix = suffix or ""; local btn = Wrapper(sname, tip, iconId); local Value = min
            Create("ImageLabel", { Parent = btn, BackgroundTransparency = 1, Size = UDim2.new(0, 20, 0, 20), Position = UDim2.new(0, 7, 0.5, -10), Image = iconId or "rbxassetid://3926307971", ImageRectOffset = iconId and Vector2.new(0,0) or Vector2.new(404, 164), ImageRectSize = iconId and Vector2.new(0,0) or Vector2.new(36, 36), Theme = {ImageColor3 = "SchemeColor"} })
            
            local valText = Create("TextBox", { Parent = btn, BackgroundTransparency = 1, Size = UDim2.new(0, 40, 1, 0), Position = UDim2.new(0.4, 0, 0, 0), Font = Enum.Font.GothamSemibold, TextSize = 13, Text = tostring(min) .. suffix, Theme = {TextColor3 = "TextColor"}, ClearTextOnFocus = false })
            local track = Create("Frame", { Parent = btn, Size = UDim2.new(0, 130, 0, 8), Position = UDim2.new(1, -165, 0.5, -4), Theme = {BackgroundColor3 = "Background"} }, {MakeCorner(4), MakeStroke(1, 0.8)})
            local fill = Create("Frame", { Parent = track, Size = UDim2.new(0, 0, 1, 0), Theme = {BackgroundColor3 = "SchemeColor"} }, {MakeCorner(4)})
            
            local function SetValue(v)
                v = math.clamp(v, min, max); v = math.floor((v / step) + 0.5) * step
                local precision = 0; local stepStr = tostring(step); if stepStr:find("%.") then precision = #stepStr:match("%.(%d+)") end
                local formatted = string.format("%." .. precision .. "f", v)
                Value = tonumber(formatted) or v
                local percent = (Value - min) / (max - min)
                Tween(fill, {Size = UDim2.new(percent, 0, 1, 0)}, 0.1); valText.Text = tostring(Value) .. suffix
                if flag then Kavo.Flags[flag] = Value end; if callback then pcall(callback, Value) end
            end

            local dragging = false
            local function UpdateSlide(input) local percent = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1); SetValue(min + ((max - min) * percent)) end
            
            track.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true UpdateSlide(input) end end)
            table.insert(activeConnections, UIS.InputChanged:Connect(function(input) if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then UpdateSlide(input) end end))
            table.insert(activeConnections, UIS.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end))
            valText.FocusLost:Connect(function() local num = tonumber(valText.Text:gsub(suffix, "")); if num then SetValue(num) else valText.Text = tostring(Value) .. suffix end end)
            if flag then Kavo.Flags[flag] = min; Kavo.Elements[flag] = SetValue end
            return BindBaseAPI({ UpdateSlider = SetValue }, btn)
        end

        -- /* STREAMING_CHUNK:Creating Searchable Dropdowns and Player Selectors... */
        function Elements:NewDropdown(dropname, tip, list, callback, isMultiSelect, flag, iconId)
            local btn = Wrapper(dropname, tip, iconId); local open = false; local selectedMulti = {}
            local DropIcon = Create("ImageLabel", { Parent = btn, BackgroundTransparency = 1, Size = UDim2.new(0, 20, 0, 20), Position = UDim2.new(0, 7, 0, 8), Image = iconId or "rbxassetid://3926305904", ImageRectOffset = iconId and Vector2.new(0,0) or Vector2.new(644, 364), ImageRectSize = iconId and Vector2.new(0,0) or Vector2.new(36, 36), Theme = {ImageColor3 = "SchemeColor"} })
            
            local DropContainer = Create("Frame", { Parent = ContentFrame, Size = UDim2.new(1, 0, 0, 0), BackgroundTransparency = 1, ClipsDescendants = true, Visible = false })
            local SearchBox = Create("TextBox", { Parent = DropContainer, Size = UDim2.new(1, -6, 0, 26), Position = UDim2.new(0, 3, 0, 2), BackgroundTransparency = 0.5, Font = Enum.Font.Gotham, TextSize = 12, Text = "", PlaceholderText = "Search...", ClearTextOnFocus = false, Theme = {BackgroundColor3 = "Background", TextColor3 = "TextColor"} }, {MakeCorner(4), MakeStroke(1, 0.5)})
            local ListFrame = Create("ScrollingFrame", { Parent = DropContainer, Size = UDim2.new(1, 0, 1, -30), Position = UDim2.new(0, 0, 0, 30), BackgroundTransparency = 1, ScrollBarThickness = 2, Theme = {ScrollBarImageColor3 = "SchemeColor"} })
            local ListLayout = Create("UIListLayout", {Parent = ListFrame, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 2)})
            ListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() ListFrame.CanvasSize = UDim2.new(0,0,0, ListLayout.AbsoluteContentSize.Y) end)

            local function Populate(newList)
                for _, v in pairs(ListFrame:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
                table.clear(selectedMulti); btn.Title.Text = dropname
                
                for _, v in ipairs(newList) do
                    local opt = Create("TextButton", { Parent = ListFrame, Size = UDim2.new(1, 0, 0, 30), AutoButtonColor = false, Font = Enum.Font.Gotham, Text = "  " .. tostring(v), TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, Theme = {BackgroundColor3 = "Background", TextColor3 = "TextColor"} }, {MakeCorner(4), MakeStroke(1, 0.9)})
                    opt.MouseEnter:Connect(function() Tween(opt, {BackgroundColor3 = Lighten(currentTheme.Background, 0.05)}) end)
                    opt.MouseLeave:Connect(function() if not isMultiSelect or not table.find(selectedMulti, v) then Tween(opt, {BackgroundColor3 = currentTheme.Background}) end end)
                    
                    opt.MouseButton1Click:Connect(function()
                        if isMultiSelect then
                            local idx = table.find(selectedMulti, v)
                            if idx then table.remove(selectedMulti, idx) else table.insert(selectedMulti, v) end
                            btn.Title.Text = dropname .. (#selectedMulti > 0 and (" (" .. #selectedMulti .. ")") or "")
                            Tween(opt, {BackgroundColor3 = table.find(selectedMulti, v) and Lighten(currentTheme.SchemeColor, -0.3) or currentTheme.Background})
                            if flag then Kavo.Flags[flag] = selectedMulti end; if callback then pcall(callback, selectedMulti) end
                        else
                            btn.Title.Text = tostring(v); btn.MouseButton1Click:Fire()
                            if flag then Kavo.Flags[flag] = v end; if callback then pcall(callback, v) end
                        end
                    end)
                end
            end
            Populate(list or {})

            SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
                local query = SearchBox.Text:lower()
                for _, v in pairs(ListFrame:GetChildren()) do if v:IsA("TextButton") then v.Visible = (query == "" or v.Text:lower():find(query)) end end
            end)

            btn.MouseButton1Click:Connect(function()
                RippleEffect(btn); open = not open; Tween(DropIcon, {Rotation = open and 180 or 0})
                if open then DropContainer.Visible = true; SearchBox.Text = ""; Tween(DropContainer, {Size = UDim2.new(1, 0, 0, math.clamp(ListLayout.AbsoluteContentSize.Y + 30, 30, 150))})
                else local t = TS:Create(DropContainer, tweenInfo, {Size = UDim2.new(1, 0, 0, 0)}); t:Play(); t.Completed:Connect(function() if not open then DropContainer.Visible = false end end) end
            end)
            
            local function SetVal(val) if not isMultiSelect then btn.Title.Text = tostring(val); if flag then Kavo.Flags[flag] = val end; if callback then pcall(callback, val) end end end
            if flag and not isMultiSelect then Kavo.Flags[flag] = ""; Kavo.Elements[flag] = SetVal end
            return BindBaseAPI({ Refresh = function(self, newList) Populate(newList) end, SetOption = SetVal }, btn)
        end

        function Elements:NewPlayerDropdown(dropname, tip, callback, isMultiSelect, flag, iconId)
            local drop = Elements:NewDropdown(dropname, tip, {}, callback, isMultiSelect, flag, iconId)
            local function UpdatePlayers() local plrs = {}; for _, v in ipairs(PLRS:GetPlayers()) do if v ~= PLRS.LocalPlayer then table.insert(plrs, v.Name) end end; drop:Refresh(plrs) end
            UpdatePlayers(); table.insert(activeConnections, PLRS.PlayerAdded:Connect(UpdatePlayers)); table.insert(activeConnections, PLRS.PlayerRemoving:Connect(UpdatePlayers))
            return drop
        end
        
        -- /* STREAMING_CHUNK:Finalizing UI Elements (ColorPicker & Keybinds)... */
        function Elements:NewColorPicker(cname, tip, defaultColor, callback, flag, iconId)
            local btn = Wrapper(cname, tip, iconId); local open = false; local color = defaultColor or Color3.fromRGB(255, 255, 255); local h, s, v = Color3.toHSV(color)
            local ColorPreview = Create("Frame", { Parent = btn, Size = UDim2.new(0, 42, 0, 18), Position = UDim2.new(1, -70, 0.5, -9), BackgroundColor3 = color }, {MakeCorner(4), MakeStroke(1, 0.5)})
            local PickerFrame = Create("Frame", { Parent = ContentFrame, Size = UDim2.new(1, 0, 0, 0), ClipsDescendants = true, Visible = false, Theme = {BackgroundColor3 = "ElementColor"} }, {MakeCorner(4), MakeStroke(1, 0.8)})
            local SatVibranceMap = Create("ImageButton", { Parent = PickerFrame, Size = UDim2.new(0, 211, 0, 93), Position = UDim2.new(0, 10, 0, 10), Image = "http://www.roblox.com/asset/?id=6523286724", AutoButtonColor = false }, {MakeCorner(4)})
            local HueMap = Create("ImageButton", { Parent = PickerFrame, Size = UDim2.new(0, 18, 0, 93), Position = UDim2.new(0, 235, 0, 10), Image = "http://www.roblox.com/asset/?id=6523291212", AutoButtonColor = false }, {MakeCorner(4)})
            local SVDot = Create("Frame", { Parent = SatVibranceMap, Size = UDim2.new(0, 6, 0, 6), AnchorPoint = Vector2.new(0.5, 0.5), BackgroundColor3 = Color3.fromRGB(255,255,255) }, {MakeCorner(3)})
            local HueDot = Create("Frame", { Parent = HueMap, Size = UDim2.new(1, 4, 0, 4), Position = UDim2.new(0, -2, 0, 0), BackgroundColor3 = Color3.fromRGB(255,255,255) }, {MakeCorner(2)})

            local function UpdateColor(newColor)
                if newColor then h, s, v = Color3.toHSV(newColor) end
                color = Color3.fromHSV(h, s, v); ColorPreview.BackgroundColor3 = color; SVDot.Position = UDim2.new(s, 0, 1 - v, 0); HueDot.Position = UDim2.new(0, -2, 1 - h, 0)
                if flag then Kavo.Flags[flag] = {color.R, color.G, color.B} end; if callback then pcall(callback, color) end
            end

            local draggingSV, draggingHue = false, false
            local function TrackSV(input) s = math.clamp((input.Position.X - SatVibranceMap.AbsolutePosition.X) / SatVibranceMap.AbsoluteSize.X, 0, 1); v = 1 - math.clamp((input.Position.Y - SatVibranceMap.AbsolutePosition.Y) / SatVibranceMap.AbsoluteSize.Y, 0, 1); UpdateColor() end
            local function TrackHue(input) h = 1 - math.clamp((input.Position.Y - HueMap.AbsolutePosition.Y) / HueMap.AbsoluteSize.Y, 0, 1); UpdateColor() end

            SatVibranceMap.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then draggingSV = true TrackSV(input) end end)
            HueMap.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then draggingHue = true TrackHue(input) end end)
            table.insert(activeConnections, UIS.InputChanged:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement then if draggingSV then TrackSV(input) elseif draggingHue then TrackHue(input) end end end))
            table.insert(activeConnections, UIS.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then draggingSV, draggingHue = false, false end end))

            btn.MouseButton1Click:Connect(function()
                RippleEffect(btn); open = not open
                if open then PickerFrame.Visible = true; Tween(PickerFrame, {Size = UDim2.new(1, 0, 0, 113)}); UpdateColor()
                else local t = TS:Create(PickerFrame, tweenInfo, {Size = UDim2.new(1, 0, 0, 0)}); t:Play(); t.Completed:Connect(function() if not open then PickerFrame.Visible = false end end) end
            end)
            
            UpdateColor(); if flag then Kavo.Flags[flag] = {color.R, color.G, color.B}; Kavo.Elements[flag] = function(colTbl) UpdateColor(Color3.new(unpack(colTbl))) end end
            return BindBaseAPI({ UpdateColor = UpdateColor }, btn)
        end

        function Elements:NewKeybind(kname, tip, default, callback, flag, iconId)
            local btn = Wrapper(kname, tip, iconId); local key = default; local binding = false
            Create("ImageLabel", { Parent = btn, BackgroundTransparency = 1, Size = UDim2.new(0, 20, 0, 20), Position = UDim2.new(0, 7, 0.5, -10), Image = iconId or "rbxassetid://3926305904", ImageRectOffset = iconId and Vector2.new(0,0) or Vector2.new(364, 284), ImageRectSize = iconId and Vector2.new(0,0) or Vector2.new(36, 36), Theme = {ImageColor3 = "SchemeColor"} })
            local valText = Create("TextLabel", { Parent = btn, BackgroundTransparency = 1, Size = UDim2.new(0, 100, 1, 0), Position = UDim2.new(1, -135, 0, 0), Font = Enum.Font.GothamSemibold, TextSize = 13, Text = key and key.Name or "None", TextXAlignment = Enum.TextXAlignment.Right, Theme = {TextColor3 = "SchemeColor"} })

            local function SetKey(newKey) local keyName = (typeof(newKey) == "EnumItem") and newKey.Name or newKey; key = Enum.KeyCode[keyName]; valText.Text = keyName; if flag then Kavo.Flags[flag] = keyName end end
            btn.MouseButton1Click:Connect(function() binding = true; valText.Text = "..." end)
            table.insert(activeConnections, UIS.InputBegan:Connect(function(input, processed) if binding and input.UserInputType == Enum.UserInputType.Keyboard then binding = false; SetKey(input.KeyCode) elseif not binding and not processed and key and input.KeyCode == key then if callback then pcall(callback) end end end))
            if flag then Kavo.Flags[flag] = key.Name; Kavo.Elements[flag] = SetKey end
            return BindBaseAPI({ UpdateKeybind = SetKey }, btn)
        end

        return Elements
    end
    return Sections
end
return Window


end

return Kavo
