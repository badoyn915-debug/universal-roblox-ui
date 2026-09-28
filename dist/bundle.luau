--[=[
    Universal UI Library
    Modern Premium Mobile-First Glassmorphic GUI Framework for Roblox
    Compiled Standalone Distribution
]=]

local typeof = typeof or type
local math_clamp = math.clamp or function(v, min, max) return math.max(min, math.min(max, v)) end
local table_clear = table.clear or function(t) for k in pairs(t) do t[k] = nil end end
local table_find = table.find or function(t, val) for i, v in ipairs(t) do if v == val then return i end end return nil end

local Modules = {}
local Cache = {}

local function import(name)
    if Cache[name] ~= nil then
        return Cache[name]
    end
    local factory = Modules[name]
    if not factory then
        error("[UniversalUI] Module not found: " .. tostring(name))
    end
    local result = factory(import)
    Cache[name] = result
    return result
end

-- Module: Assets
Modules["Assets"] = function(import)
--[=[
    Asset Configuration
    Configured with high-definition transparent vector glyphs (Lucide icon pack).
    All icons have transparent backgrounds and match the frosted glass theme via ImageColor3 tinting.
    User's custom Logo slot is preserved and prioritized.
]=]

local Assets = {
    -- User Custom Logo (can be overridden by user)
    Logo = "rbxassetid://10709782497", -- Modern sparkle / star glyph fallback
    MainIcon = "rbxassetid://10709789710", -- Layers glyph
    Settings = "rbxassetid://10734950309", -- Gear / settings
    
    -- Window Controls
    Close = "rbxassetid://10747384394", -- Cross / Close
    Minimize = "rbxassetid://10734896206", -- Minus / Minimize
    Maximize = "rbxassetid://10734895916", -- Square / Maximize
    
    -- Navigation & Indicators
    ChevronDown = "rbxassetid://10709790948",
    ChevronRight = "rbxassetid://10709791437",
    Check = "rbxassetid://10709790644",
    Search = "rbxassetid://10734943674",
    
    -- Notifications
    Info = "rbxassetid://10723415903",
    Success = "rbxassetid://10709790537",
    Warning = "rbxassetid://10709752996",
    Error = "rbxassetid://10709752835",
    
    -- Interactive Components
    ColorPicker = "rbxassetid://10723346959", -- Palette
    SliderKnob = "",
    DragHandle = "rbxassetid://10723374276", -- Grip vertical
}

return Assets

end

-- Module: Theme
Modules["Theme"] = function(import)
local table_clear = table.clear or function(t) for k in pairs(t) do t[k] = nil end end
--[=[
    Theme System
    Provides a dynamic theme state and automatic theme updating across all registered UI elements.
    Supports real-time theme swapping with smooth transitions without recreating the GUI.
]=]

local TweenService = game and game:GetService("TweenService")
local typeof = typeof or type

local Theme = {}
Theme.__index = Theme

Theme.Defaults = {
    Background = Color3.fromRGB(15, 17, 24),
    Surface = Color3.fromRGB(24, 28, 42),
    SurfaceSecondary = Color3.fromRGB(34, 40, 60),
    Text = Color3.fromRGB(245, 247, 252),
    TextSecondary = Color3.fromRGB(150, 160, 180),
    Accent = Color3.fromRGB(88, 101, 242),
    AccentHover = Color3.fromRGB(105, 118, 255),
    Border = Color3.fromRGB(255, 255, 255),
    BorderTransparency = 0.88,
    Transparency = 0.18,
    Success = Color3.fromRGB(46, 213, 115),
    Warning = Color3.fromRGB(255, 171, 0),
    Error = Color3.fromRGB(255, 71, 87),
    Info = Color3.fromRGB(52, 152, 219),
}

Theme.Current = {}
for k, v in pairs(Theme.Defaults) do
    Theme.Current[k] = v
end

Theme.Registry = {}

function Theme:Get(key)
    return self.Current[key] or self.Defaults[key]
end

function Theme:Register(instance, propertyMap)
    if not instance then return end
    
    self.Registry[instance] = propertyMap
    
    -- Apply current theme values immediately
    for prop, themeKey in pairs(propertyMap) do
        local val = self:Get(themeKey)
        if val ~= nil then
            pcall(function()
                instance[prop] = val
            end)
        end
    end
    
    -- Auto unregister when instance destroyed
    if instance.Destroying then
        instance.Destroying:Connect(function()
            Theme.Registry[instance] = nil
        end)
    end
end

function Theme:Unregister(instance)
    if instance then
        self.Registry[instance] = nil
    end
end

function Theme:SetTheme(newTheme, animate)
    if type(newTheme) ~= "table" then return end
    
    for k, v in pairs(newTheme) do
        self.Current[k] = v
    end
    
    local shouldAnimate = (animate ~= false) and (TweenService ~= nil)
    local tweenInfo = shouldAnimate and TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out) or nil
    
    for instance, propertyMap in pairs(self.Registry) do
        if instance and instance.Parent then
            for prop, themeKey in pairs(propertyMap) do
                local val = self:Get(themeKey)
                if val ~= nil then
                    if shouldAnimate and (typeof(val) == "Color3" or typeof(val) == "number") then
                        pcall(function()
                            local t = TweenService:Create(instance, tweenInfo, { [prop] = val })
                            t:Play()
                        end)
                    else
                        pcall(function()
                            instance[prop] = val
                        end)
                    end
                end
            end
        else
            self.Registry[instance] = nil
        end
    end
end

function Theme:ClearRegistry()
    table_clear(self.Registry)
end

return Theme

end

-- Module: Animation
Modules["Animation"] = function(import)
local table_clear = table.clear or function(t) for k in pairs(t) do t[k] = nil end end
--[=[
    Animation Engine
    Provides responsive, fluid animations using TweenService.
    Supports hover, press, release, slide, fade, tab transitions, scale, and cleanup.
]=]

local TweenService = game and game:GetService("TweenService")

local Animation = {}
Animation.__index = Animation

Animation.Presets = {
    Fast = TweenInfo.new(0.18, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
    Normal = TweenInfo.new(0.28, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
    Smooth = TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
    Spring = TweenInfo.new(0.32, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
    Bounce = TweenInfo.new(0.4, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out),
    Tab = TweenInfo.new(0.24, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
}

Animation.ActiveTweens = {}

function Animation.Tween(instance, tweenInfo, goals)
    if not instance or not TweenService then return nil end
    
    tweenInfo = tweenInfo or Animation.Presets.Normal
    local tween = TweenService:Create(instance, tweenInfo, goals)
    
    Animation.ActiveTweens[tween] = true
    
    tween.Completed:Connect(function()
        Animation.ActiveTweens[tween] = nil
    end)
    
    tween:Play()
    return tween
end

function Animation.Press(instance, normalScale, pressedScale)
    normalScale = normalScale or 1.0
    pressedScale = pressedScale or 0.96
    
    local uiScale = instance:FindFirstChildOfClass("UIScale")
    if not uiScale then
        uiScale = Instance.new("UIScale")
        uiScale.Scale = normalScale
        uiScale.Parent = instance
    end
    
    return {
        OnPress = function()
            Animation.Tween(uiScale, Animation.Presets.Fast, { Scale = pressedScale })
        end,
        OnRelease = function()
            Animation.Tween(uiScale, Animation.Presets.Fast, { Scale = normalScale })
        end
    }
end

function Animation.FadeIn(instance, targetTransparency, duration)
    targetTransparency = targetTransparency or 0
    local tInfo = duration and TweenInfo.new(duration, Enum.EasingStyle.Quart, Enum.EasingDirection.Out) or Animation.Presets.Normal
    
    if instance:IsA("CanvasGroup") then
        return Animation.Tween(instance, tInfo, { GroupTransparency = targetTransparency })
    elseif instance:IsA("GuiObject") then
        return Animation.Tween(instance, tInfo, { BackgroundTransparency = targetTransparency })
    end
end

function Animation.FadeOut(instance, targetTransparency, duration, onComplete)
    targetTransparency = targetTransparency or 1
    local tInfo = duration and TweenInfo.new(duration, Enum.EasingStyle.Quart, Enum.EasingDirection.Out) or Animation.Presets.Normal
    
    local tween
    if instance:IsA("CanvasGroup") then
        tween = Animation.Tween(instance, tInfo, { GroupTransparency = targetTransparency })
    elseif instance:IsA("GuiObject") then
        tween = Animation.Tween(instance, tInfo, { BackgroundTransparency = targetTransparency })
    end
    
    if tween and onComplete then
        tween.Completed:Connect(onComplete)
    elseif onComplete then
        task.delay(duration or 0.28, onComplete)
    end
    return tween
end

function Animation.SlideIn(instance, targetPos, startPos, duration)
    if startPos then
        instance.Position = startPos
    end
    local tInfo = duration and TweenInfo.new(duration, Enum.EasingStyle.Quart, Enum.EasingDirection.Out) or Animation.Presets.Normal
    return Animation.Tween(instance, tInfo, { Position = targetPos })
end

function Animation.SlideOut(instance, targetPos, duration, onComplete)
    local tInfo = duration and TweenInfo.new(duration, Enum.EasingStyle.Quart, Enum.EasingDirection.Out) or Animation.Presets.Normal
    local tween = Animation.Tween(instance, tInfo, { Position = targetPos })
    if tween and onComplete then
        tween.Completed:Connect(onComplete)
    elseif onComplete then
        task.delay(duration or 0.28, onComplete)
    end
    return tween
end

function Animation.Cleanup()
    for tween in pairs(Animation.ActiveTweens) do
        pcall(function()
            tween:Cancel()
        end)
    end
    table_clear(Animation.ActiveTweens)
end

return Animation

end

-- Module: Utility
Modules["Utility"] = function(import)
local table_clear = table.clear or function(t) for k in pairs(t) do t[k] = nil end end
local math_clamp = math.clamp or function(v, min, max) return math.max(min, math.min(max, v)) end
--[=[
    Utility Module
    Helper functions for UI construction, connection tracking, touch/mouse dragging with screen clamping,
    and mobile screen detection.
]=]

local UserInputService = game and game:GetService("UserInputService")
local TweenService = game and game:GetService("TweenService")
local Workspace = game and game:GetService("Workspace")

local Utility = {}
Utility.__index = Utility

-- Connection tracker
Utility.Connections = {}

function Utility.AddConnection(conn)
    if conn then
        table.insert(Utility.Connections, conn)
    end
    return conn
end

function Utility.DisconnectAll()
    for _, conn in ipairs(Utility.Connections) do
        if conn and conn.Disconnect then
            pcall(function()
                conn:Disconnect()
            end)
        end
    end
    table_clear(Utility.Connections)
end

-- Instance creation helper
function Utility.Create(className, properties, children)
    local inst = Instance.new(className)
    if properties then
        for k, v in pairs(properties) do
            inst[k] = v
        end
    end
    if children then
        for _, child in ipairs(children) do
            if child then
                child.Parent = inst
            end
        end
    end
    return inst
end

function Utility.AddCorner(parent, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 12)
    corner.Parent = parent
    return corner
end

function Utility.AddStroke(parent, color, thickness, transparency)
    local stroke = Instance.new("UIStroke")
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Color = color or Color3.fromRGB(255, 255, 255)
    stroke.Thickness = thickness or 1
    stroke.Transparency = transparency or 0.88
    stroke.Parent = parent
    return stroke
end

function Utility.AddPadding(parent, top, bottom, left, right)
    local padding = Instance.new("UIPadding")
    padding.PaddingTop = UDim.new(0, top or 8)
    padding.PaddingBottom = UDim.new(0, bottom or 8)
    padding.PaddingLeft = UDim.new(0, left or 12)
    padding.PaddingRight = UDim.new(0, right or 12)
    padding.Parent = parent
    return padding
end

function Utility.GetViewportSize()
    local camera = Workspace and Workspace.CurrentCamera
    if camera then
        return camera.ViewportSize
    end
    return Vector2.new(1280, 720)
end

function Utility.IsMobile()
    if not UserInputService then return false end
    return UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
end

-- Screen-constrained Draggable Implementation (Mouse + Touch)
function Utility.MakeDraggable(frame, dragHandle)
    dragHandle = dragHandle or frame
    
    local dragging = false
    local dragInput = nil
    local dragStart = nil
    local startPos = nil
    
    local function update(input)
        local delta = input.Position - dragStart
        local viewport = Utility.GetViewportSize()
        
        -- Clamping calculation to keep the window fully within screen boundaries
        local frameSize = frame.AbsoluteSize
        local newX = math_clamp(startPos.X.Offset + delta.X, 0, math.max(0, viewport.X - frameSize.X))
        local newY = math_clamp(startPos.Y.Offset + delta.Y, 0, math.max(0, viewport.Y - frameSize.Y))
        
        local targetPosition = UDim2.new(startPos.X.Scale, newX, startPos.Y.Scale, newY)
        
        if TweenService then
            TweenService:Create(frame, TweenInfo.new(0.08, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                Position = targetPosition
            }):Play()
        else
            frame.Position = targetPosition
        end
    end
    
    local beganConn = dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            
            local changedConn
            changedConn = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    if changedConn then
                        changedConn:Disconnect()
                    end
                end
            end)
            Utility.AddConnection(changedConn)
        end
    end)
    Utility.AddConnection(beganConn)
    
    local inputChangedConn = dragHandle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    Utility.AddConnection(inputChangedConn)
    
    local globalChangedConn = UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)
    Utility.AddConnection(globalChangedConn)
end

function Utility.Round(num, decimals)
    local mult = 10 ^ (decimals or 0)
    return math.floor(num * mult + 0.5) / mult
end

function Utility.GetGuiParent()
    if gethui then
        local success, hui = pcall(gethui)
        if success and hui then return hui end
    end
    
    local CoreGui = game:GetService("CoreGui")
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer
    
    local success, _ = pcall(function()
        local _ = CoreGui.Name
    end)
    if success then
        return CoreGui
    end
    
    if LocalPlayer and LocalPlayer:FindFirstChildOfClass("PlayerGui") then
        return LocalPlayer:FindFirstChildOfClass("PlayerGui")
    end
    
    return CoreGui
end

return Utility

end

-- Module: Components/Button
Modules["Components/Button"] = function(import)
--[=[
    Button Component
    Interactive button with press animations, hover states, optional icon, and description.
]=]

local Button = {}
Button.__index = Button

function Button.new(config, parent, Theme, Animation, Utility, Assets)
    local self = setmetatable({}, Button)
    
    self.Config = config
    self.Callback = config.Callback or function() end
    
    local card = Utility.Create("Frame", {
        Name = "Button_" .. (config.Title or "Item"),
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = Theme:Get("Surface"),
        BackgroundTransparency = Theme:Get("Transparency"),
        BorderSizePixel = 0,
        Parent = parent,
    })
    Utility.AddCorner(card, 10)
    Utility.AddStroke(card, Theme:Get("Border"), 1, 0.92)
    Utility.AddPadding(card, 10, 10, 14, 14)
    Theme:Register(card, { BackgroundColor3 = "Surface" })
    
    local row = Utility.Create("Frame", {
        Name = "Row",
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Parent = card,
    })
    
    local rowLayout = Utility.Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        HorizontalAlignment = Enum.HorizontalAlignment.SpaceBetween,
        Parent = row,
    })
    
    -- Left text side
    local textContainer = Utility.Create("Frame", {
        Name = "TextContainer",
        Size = UDim2.new(1, -70, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Parent = row,
    })
    
    local textLayout = Utility.Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Vertical,
        Padding = UDim.new(0, 3),
        Parent = textContainer,
    })
    
    local titleLabel = Utility.Create("TextLabel", {
        Name = "Title",
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamMedium,
        Text = config.Title or "Button",
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true,
        TextColor3 = Theme:Get("Text"),
        Parent = textContainer,
    })
    Theme:Register(titleLabel, { TextColor3 = "Text" })
    
    local descLabel = nil
    if config.Description and config.Description ~= "" then
        descLabel = Utility.Create("TextLabel", {
            Name = "Description",
            Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            Font = Enum.Font.Gotham,
            Text = config.Description,
            TextSize = 11,
            TextTransparency = 0.45,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextWrapped = true,
            TextColor3 = Theme:Get("TextSecondary"),
            Parent = textContainer,
        })
        Theme:Register(descLabel, { TextColor3 = "TextSecondary" })
    end
    
    -- Action trigger button
    local triggerBtn = Utility.Create("TextButton", {
        Name = "Trigger",
        Size = UDim2.new(0, 58, 0, 28),
        BackgroundColor3 = Theme:Get("Accent"),
        BackgroundTransparency = 0.1,
        Font = Enum.Font.GothamBold,
        Text = "Click",
        TextSize = 11,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        AutoButtonColor = false,
        Parent = row,
    })
    Utility.AddCorner(triggerBtn, 7)
    Theme:Register(triggerBtn, { BackgroundColor3 = "Accent" })
    
    local pressAnim = Animation.Press(card, 1.0, 0.98)
    
    local function fire()
        pressAnim.OnPress()
        task.delay(0.08, pressAnim.OnRelease)
        task.spawn(self.Callback)
    end
    
    -- Make entire card or trigger button clickable
    local fullBtn = Utility.Create("TextButton", {
        Name = "ClickOverlay",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "",
        Parent = card,
    })
    
    Utility.AddConnection(fullBtn.MouseEnter:Connect(function()
        Animation.Tween(card, Animation.Presets.Fast, { BackgroundTransparency = math.max(0, Theme:Get("Transparency") - 0.08) })
    end))
    
    Utility.AddConnection(fullBtn.MouseLeave:Connect(function()
        Animation.Tween(card, Animation.Presets.Fast, { BackgroundTransparency = Theme:Get("Transparency") })
    end))
    
    Utility.AddConnection(fullBtn.MouseButton1Down:Connect(pressAnim.OnPress))
    Utility.AddConnection(fullBtn.MouseButton1Up:Connect(pressAnim.OnRelease))
    Utility.AddConnection(fullBtn.MouseButton1Click:Connect(fire))
    Utility.AddConnection(triggerBtn.MouseButton1Click:Connect(fire))
    
    self.Card = card
    self.TitleLabel = titleLabel
    self.DescLabel = descLabel
    self.TriggerBtn = triggerBtn
    
    return self
end

function Button:SetText(title, desc)
    if title then
        self.TitleLabel.Text = title
    end
    if desc and self.DescLabel then
        self.DescLabel.Text = desc
    end
end

function Button:Fire()
    task.spawn(self.Callback)
end

return Button

end

-- Module: Components/Toggle
Modules["Components/Toggle"] = function(import)
--[=[
    Toggle Component
    Fluid toggle switch with animated sliding knob, responsive touch support, and state callbacks.
]=]

local Toggle = {}
Toggle.__index = Toggle

function Toggle.new(config, parent, Theme, Animation, Utility, Assets)
    local self = setmetatable({}, Toggle)
    
    self.Config = config
    self.Value = config.Default or false
    self.Callback = config.Callback or function() end
    
    local card = Utility.Create("Frame", {
        Name = "Toggle_" .. (config.Title or "Item"),
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = Theme:Get("Surface"),
        BackgroundTransparency = Theme:Get("Transparency"),
        BorderSizePixel = 0,
        Parent = parent,
    })
    Utility.AddCorner(card, 10)
    Utility.AddStroke(card, Theme:Get("Border"), 1, 0.92)
    Utility.AddPadding(card, 10, 10, 14, 14)
    Theme:Register(card, { BackgroundColor3 = "Surface" })
    
    local row = Utility.Create("Frame", {
        Name = "Row",
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Parent = card,
    })
    
    local rowLayout = Utility.Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        HorizontalAlignment = Enum.HorizontalAlignment.SpaceBetween,
        Parent = row,
    })
    
    -- Left text side
    local textContainer = Utility.Create("Frame", {
        Name = "TextContainer",
        Size = UDim2.new(1, -60, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Parent = row,
    })
    
    local textLayout = Utility.Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Vertical,
        Padding = UDim.new(0, 3),
        Parent = textContainer,
    })
    
    local titleLabel = Utility.Create("TextLabel", {
        Name = "Title",
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamMedium,
        Text = config.Title or "Toggle",
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true,
        TextColor3 = Theme:Get("Text"),
        Parent = textContainer,
    })
    Theme:Register(titleLabel, { TextColor3 = "Text" })
    
    local descLabel = nil
    if config.Description and config.Description ~= "" then
        descLabel = Utility.Create("TextLabel", {
            Name = "Description",
            Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            Font = Enum.Font.Gotham,
            Text = config.Description,
            TextSize = 11,
            TextTransparency = 0.45,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextWrapped = true,
            TextColor3 = Theme:Get("TextSecondary"),
            Parent = textContainer,
        })
        Theme:Register(descLabel, { TextColor3 = "TextSecondary" })
    end
    
    -- Switch Pill Container
    local pill = Utility.Create("Frame", {
        Name = "SwitchPill",
        Size = UDim2.new(0, 42, 0, 22),
        BackgroundColor3 = self.Value and Theme:Get("Accent") or Theme:Get("SurfaceSecondary"),
        BackgroundTransparency = 0.2,
        BorderSizePixel = 0,
        Parent = row,
    })
    Utility.AddCorner(pill, 11)
    
    local knob = Utility.Create("Frame", {
        Name = "Knob",
        Size = UDim2.new(0, 16, 0, 16),
        Position = self.Value and UDim2.new(1, -19, 0.5, 0) or UDim2.new(0, 3, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BorderSizePixel = 0,
        Parent = pill,
    })
    Utility.AddCorner(knob, 8)
    
    local pressAnim = Animation.Press(card, 1.0, 0.98)
    
    local function updateVisuals(animate)
        local targetColor = self.Value and Theme:Get("Accent") or Theme:Get("SurfaceSecondary")
        local targetPos = self.Value and UDim2.new(1, -19, 0.5, 0) or UDim2.new(0, 3, 0.5, 0)
        
        if animate ~= false then
            Animation.Tween(pill, Animation.Presets.Fast, { BackgroundColor3 = targetColor })
            Animation.Tween(knob, Animation.Presets.Fast, { Position = targetPos })
        else
            pill.BackgroundColor3 = targetColor
            knob.Position = targetPos
        end
    end
    
    local function toggle()
        self.Value = not self.Value
        updateVisuals(true)
        task.spawn(self.Callback, self.Value)
    end
    
    local overlayBtn = Utility.Create("TextButton", {
        Name = "ClickOverlay",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "",
        Parent = card,
    })
    
    Utility.AddConnection(overlayBtn.MouseButton1Down:Connect(pressAnim.OnPress))
    Utility.AddConnection(overlayBtn.MouseButton1Up:Connect(pressAnim.OnRelease))
    Utility.AddConnection(overlayBtn.MouseButton1Click:Connect(toggle))
    
    self.Card = card
    self.Pill = pill
    self.Knob = knob
    self.TitleLabel = titleLabel
    self.DescLabel = descLabel
    self.UpdateVisuals = updateVisuals
    
    return self
end

function Toggle:Set(value)
    self.Value = not not value
    self.UpdateVisuals(true)
    task.spawn(self.Callback, self.Value)
end

function Toggle:Get()
    return self.Value
end

return Toggle

end

-- Module: Components/Slider
Modules["Components/Slider"] = function(import)
local math_clamp = math.clamp or function(v, min, max) return math.max(min, math.min(max, v)) end
--[=[
    Slider Component
    Precision slider with mouse and touch dragging, step increments, fill bar, and live value badge.
]=]

local UserInputService = game and game:GetService("UserInputService")

local Slider = {}
Slider.__index = Slider

function Slider.new(config, parent, Theme, Animation, Utility, Assets)
    local self = setmetatable({}, Slider)
    
    self.Config = config
    self.Min = config.Min or 0
    self.Max = config.Max or 100
    self.Increment = config.Increment or 1
    self.Value = config.Default or self.Min
    self.Callback = config.Callback or function() end
    
    local card = Utility.Create("Frame", {
        Name = "Slider_" .. (config.Title or "Item"),
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = Theme:Get("Surface"),
        BackgroundTransparency = Theme:Get("Transparency"),
        BorderSizePixel = 0,
        Parent = parent,
    })
    Utility.AddCorner(card, 10)
    Utility.AddStroke(card, Theme:Get("Border"), 1, 0.92)
    Utility.AddPadding(card, 10, 10, 14, 14)
    Theme:Register(card, { BackgroundColor3 = "Surface" })
    
    local colLayout = Utility.Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Vertical,
        Padding = UDim.new(0, 8),
        Parent = card,
    })
    
    -- Header Row: Title & Value display
    local headerRow = Utility.Create("Frame", {
        Name = "HeaderRow",
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Parent = card,
    })
    
    local headerLayout = Utility.Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        HorizontalAlignment = Enum.HorizontalAlignment.SpaceBetween,
        Parent = headerRow,
    })
    
    local textContainer = Utility.Create("Frame", {
        Name = "TextContainer",
        Size = UDim2.new(1, -60, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Parent = headerRow,
    })
    
    local titleLayout = Utility.Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Vertical,
        Padding = UDim.new(0, 2),
        Parent = textContainer,
    })
    
    local titleLabel = Utility.Create("TextLabel", {
        Name = "Title",
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamMedium,
        Text = config.Title or "Slider",
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true,
        TextColor3 = Theme:Get("Text"),
        Parent = textContainer,
    })
    Theme:Register(titleLabel, { TextColor3 = "Text" })
    
    if config.Description and config.Description ~= "" then
        local descLabel = Utility.Create("TextLabel", {
            Name = "Description",
            Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            Font = Enum.Font.Gotham,
            Text = config.Description,
            TextSize = 11,
            TextTransparency = 0.45,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextWrapped = true,
            TextColor3 = Theme:Get("TextSecondary"),
            Parent = textContainer,
        })
        Theme:Register(descLabel, { TextColor3 = "TextSecondary" })
    end
    
    -- Value badge
    local valueBadge = Utility.Create("TextLabel", {
        Name = "ValueBadge",
        Size = UDim2.new(0, 50, 0, 20),
        BackgroundColor3 = Theme:Get("SurfaceSecondary"),
        BackgroundTransparency = 0.4,
        Font = Enum.Font.GothamBold,
        Text = tostring(self.Value),
        TextSize = 11,
        TextColor3 = Theme:Get("Accent"),
        Parent = headerRow,
    })
    Utility.AddCorner(valueBadge, 6)
    Theme:Register(valueBadge, { BackgroundColor3 = "SurfaceSecondary", TextColor3 = "Accent" })
    
    -- Slider Track Frame (touch friendly hit target)
    local hitArea = Utility.Create("Frame", {
        Name = "HitArea",
        Size = UDim2.new(1, 0, 0, 24),
        BackgroundTransparency = 1,
        Parent = card,
    })
    
    local track = Utility.Create("Frame", {
        Name = "Track",
        Size = UDim2.new(1, 0, 0, 6),
        Position = UDim2.new(0, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = Theme:Get("SurfaceSecondary"),
        BorderSizePixel = 0,
        Parent = hitArea,
    })
    Utility.AddCorner(track, 3)
    Theme:Register(track, { BackgroundColor3 = "SurfaceSecondary" })
    
    local initialRatio = math_clamp((self.Value - self.Min) / (self.Max - self.Min), 0, 1)
    
    local fillBar = Utility.Create("Frame", {
        Name = "FillBar",
        Size = UDim2.new(initialRatio, 0, 1, 0),
        BackgroundColor3 = Theme:Get("Accent"),
        BorderSizePixel = 0,
        Parent = track,
    })
    Utility.AddCorner(fillBar, 3)
    Theme:Register(fillBar, { BackgroundColor3 = "Accent" })
    
    local knob = Utility.Create("Frame", {
        Name = "Knob",
        Size = UDim2.new(0, 14, 0, 14),
        Position = UDim2.new(initialRatio, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BorderSizePixel = 0,
        Parent = track,
    })
    Utility.AddCorner(knob, 7)
    
    local dragging = false
    
    local function snap(val)
        local stepped = math.floor((val - self.Min) / self.Increment + 0.5) * self.Increment + self.Min
        return math_clamp(stepped, self.Min, self.Max)
    end
    
    local function updateFromInput(inputX, animate)
        local trackWidth = track.AbsoluteSize.X
        if trackWidth <= 0 then return end
        
        local relX = inputX - track.AbsolutePosition.X
        local ratio = math_clamp(relX / trackWidth, 0, 1)
        local rawVal = self.Min + ratio * (self.Max - self.Min)
        local finalVal = snap(rawVal)
        
        -- Round decimal places according to increment
        local decimalPlaces = 0
        local incStr = tostring(self.Increment)
        if incStr:find("%.") then
            decimalPlaces = #incStr - incStr:find("%.")
        end
        finalVal = Utility.Round(finalVal, decimalPlaces)
        
        self.Value = finalVal
        valueBadge.Text = tostring(finalVal)
        
        local finalRatio = math_clamp((finalVal - self.Min) / (self.Max - self.Min), 0, 1)
        
        if animate then
            Animation.Tween(fillBar, Animation.Presets.Fast, { Size = UDim2.new(finalRatio, 0, 1, 0) })
            Animation.Tween(knob, Animation.Presets.Fast, { Position = UDim2.new(finalRatio, 0, 0.5, 0) })
        else
            fillBar.Size = UDim2.new(finalRatio, 0, 1, 0)
            knob.Position = UDim2.new(finalRatio, 0, 0.5, 0)
        end
        
        task.spawn(self.Callback, self.Value)
    end
    
    local function startDrag(input)
        dragging = true
        Animation.Tween(knob, Animation.Presets.Fast, { Size = UDim2.new(0, 18, 0, 18) })
        updateFromInput(input.Position.X, false)
        
        local moveConn
        local endConn
        
        moveConn = UserInputService.InputChanged:Connect(function(moveInput)
            if dragging and (moveInput.UserInputType == Enum.UserInputType.MouseMovement or moveInput.UserInputType == Enum.UserInputType.Touch) then
                updateFromInput(moveInput.Position.X, false)
            end
        end)
        
        endConn = UserInputService.InputEnded:Connect(function(endInput)
            if endInput.UserInputType == Enum.UserInputType.MouseButton1 or endInput.UserInputType == Enum.UserInputType.Touch then
                dragging = false
                Animation.Tween(knob, Animation.Presets.Fast, { Size = UDim2.new(0, 14, 0, 14) })
                if moveConn then moveConn:Disconnect() end
                if endConn then endConn:Disconnect() end
            end
        end)
        
        Utility.AddConnection(moveConn)
        Utility.AddConnection(endConn)
    end
    
    Utility.AddConnection(hitArea.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            startDrag(input)
        end
    end))
    
    self.Card = card
    self.FillBar = fillBar
    self.Knob = knob
    self.ValueBadge = valueBadge
    self.Snap = snap
    
    return self
end

function Slider:Set(value)
    local stepped = self.Snap(value)
    self.Value = stepped
    self.ValueBadge.Text = tostring(stepped)
    local ratio = math_clamp((stepped - self.Min) / (self.Max - self.Min), 0, 1)
    self.FillBar.Size = UDim2.new(ratio, 0, 1, 0)
    self.Knob.Position = UDim2.new(ratio, 0, 0.5, 0)
    task.spawn(self.Callback, self.Value)
end

function Slider:Get()
    return self.Value
end

return Slider

end

-- Module: Components/Dropdown
Modules["Components/Dropdown"] = function(import)
local table_clear = table.clear or function(t) for k in pairs(t) do t[k] = nil end end
--[=[
    Dropdown Component
    Single-selection menu with smooth animated expansion, chevron rotation, and mobile-friendly options.
]=]

local Dropdown = {}
Dropdown.__index = Dropdown

function Dropdown.new(config, parent, Theme, Animation, Utility, Assets)
    local self = setmetatable({}, Dropdown)
    
    self.Config = config
    self.Values = config.Values or {}
    self.Value = config.Default or (self.Values[1] or "")
    self.Callback = config.Callback or function() end
    self.IsOpen = false
    self.OptionButtons = {}
    
    local card = Utility.Create("Frame", {
        Name = "Dropdown_" .. (config.Title or "Item"),
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = Theme:Get("Surface"),
        BackgroundTransparency = Theme:Get("Transparency"),
        BorderSizePixel = 0,
        Parent = parent,
    })
    Utility.AddCorner(card, 10)
    Utility.AddStroke(card, Theme:Get("Border"), 1, 0.92)
    Utility.AddPadding(card, 10, 10, 14, 14)
    Theme:Register(card, { BackgroundColor3 = "Surface" })
    
    local colLayout = Utility.Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Vertical,
        Padding = UDim.new(0, 8),
        Parent = card,
    })
    
    -- Main Row: Title + Selected Value Pill & Chevron
    local mainRow = Utility.Create("Frame", {
        Name = "MainRow",
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Parent = card,
    })
    
    local mainLayout = Utility.Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        HorizontalAlignment = Enum.HorizontalAlignment.SpaceBetween,
        Parent = mainRow,
    })
    
    local textContainer = Utility.Create("Frame", {
        Name = "TextContainer",
        Size = UDim2.new(1, -130, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Parent = mainRow,
    })
    
    local titleLayout = Utility.Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Vertical,
        Padding = UDim.new(0, 2),
        Parent = textContainer,
    })
    
    local titleLabel = Utility.Create("TextLabel", {
        Name = "Title",
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamMedium,
        Text = config.Title or "Dropdown",
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true,
        TextColor3 = Theme:Get("Text"),
        Parent = textContainer,
    })
    Theme:Register(titleLabel, { TextColor3 = "Text" })
    
    if config.Description and config.Description ~= "" then
        local descLabel = Utility.Create("TextLabel", {
            Name = "Description",
            Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            Font = Enum.Font.Gotham,
            Text = config.Description,
            TextSize = 11,
            TextTransparency = 0.45,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextWrapped = true,
            TextColor3 = Theme:Get("TextSecondary"),
            Parent = textContainer,
        })
        Theme:Register(descLabel, { TextColor3 = "TextSecondary" })
    end
    
    -- Selected display box
    local selectBox = Utility.Create("Frame", {
        Name = "SelectBox",
        Size = UDim2.new(0, 115, 0, 26),
        BackgroundColor3 = Theme:Get("SurfaceSecondary"),
        BackgroundTransparency = 0.3,
        BorderSizePixel = 0,
        Parent = mainRow,
    })
    Utility.AddCorner(selectBox, 7)
    Utility.AddPadding(selectBox, 0, 0, 8, 8)
    Theme:Register(selectBox, { BackgroundColor3 = "SurfaceSecondary" })
    
    local selectedText = Utility.Create("TextLabel", {
        Name = "SelectedText",
        Size = UDim2.new(1, -20, 1, 0),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamMedium,
        Text = tostring(self.Value),
        TextSize = 11,
        TextTruncate = Enum.TextTruncate.AtEnd,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextColor3 = Theme:Get("Text"),
        Parent = selectBox,
    })
    Theme:Register(selectedText, { TextColor3 = "Text" })
    
    local chevron = Utility.Create("TextLabel", {
        Name = "Chevron",
        Size = UDim2.new(0, 16, 0, 16),
        Position = UDim2.new(1, -16, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        Text = "▾",
        TextSize = 14,
        TextColor3 = Theme:Get("TextSecondary"),
        Parent = selectBox,
    })
    Theme:Register(chevron, { TextColor3 = "TextSecondary" })
    
    -- Options dropdown container
    local optionsList = Utility.Create("Frame", {
        Name = "OptionsList",
        Size = UDim2.new(1, 0, 0, 0),
        BackgroundTransparency = 1,
        ClipsDescendants = true,
        Visible = false,
        Parent = card,
    })
    
    local optionsLayout = Utility.Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Vertical,
        Padding = UDim.new(0, 4),
        Parent = optionsList,
    })
    
    local function renderOptions()
        for _, btn in ipairs(self.OptionButtons) do
            btn:Destroy()
        end
        table_clear(self.OptionButtons)
        
        for _, val in ipairs(self.Values) do
            local isSelected = (val == self.Value)
            local optBtn = Utility.Create("TextButton", {
                Name = "Option_" .. tostring(val),
                Size = UDim2.new(1, 0, 0, 30),
                BackgroundColor3 = isSelected and Theme:Get("Accent") or Theme:Get("SurfaceSecondary"),
                BackgroundTransparency = isSelected and 0.2 or 0.6,
                Font = isSelected and Enum.Font.GothamBold or Enum.Font.GothamMedium,
                Text = "  " .. tostring(val),
                TextSize = 12,
                TextColor3 = isSelected and Color3.fromRGB(255, 255, 255) or Theme:Get("Text"),
                TextXAlignment = Enum.TextXAlignment.Left,
                AutoButtonColor = false,
                Parent = optionsList,
            })
            Utility.AddCorner(optBtn, 6)
            
            local pressAnim = Animation.Press(optBtn, 1.0, 0.98)
            
            Utility.AddConnection(optBtn.MouseButton1Down:Connect(pressAnim.OnPress))
            Utility.AddConnection(optBtn.MouseButton1Up:Connect(pressAnim.OnRelease))
            Utility.AddConnection(optBtn.MouseButton1Click:Connect(function()
                self:Set(val)
                self:ToggleOpen()
            end))
            
            table.insert(self.OptionButtons, optBtn)
        end
    end
    
    local function toggleOpen()
        self.IsOpen = not self.IsOpen
        if self.IsOpen then
            optionsList.Visible = true
            local targetHeight = #self.Values * 34
            Animation.Tween(optionsList, Animation.Presets.Fast, { Size = UDim2.new(1, 0, 0, targetHeight) })
            Animation.Tween(chevron, Animation.Presets.Fast, { Rotation = 180 })
        else
            local tween = Animation.Tween(optionsList, Animation.Presets.Fast, { Size = UDim2.new(1, 0, 0, 0) })
            Animation.Tween(chevron, Animation.Presets.Fast, { Rotation = 0 })
            if tween then
                tween.Completed:Connect(function()
                    if not self.IsOpen then
                        optionsList.Visible = false
                    end
                end)
            else
                optionsList.Visible = false
            end
        end
    end
    
    local triggerBtn = Utility.Create("TextButton", {
        Name = "TriggerOverlay",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "",
        Parent = selectBox,
    })
    Utility.AddConnection(triggerBtn.MouseButton1Click:Connect(toggleOpen))
    
    self.Card = card
    self.SelectedText = selectedText
    self.Chevron = chevron
    self.OptionsList = optionsList
    self.ToggleOpen = toggleOpen
    self.RenderOptions = renderOptions
    
    renderOptions()
    return self
end

function Dropdown:Set(value)
    self.Value = value
    self.SelectedText.Text = tostring(value)
    self.RenderOptions()
    task.spawn(self.Callback, self.Value)
end

function Dropdown:Get()
    return self.Value
end

function Dropdown:Refresh(newValues)
    self.Values = newValues or {}
    if not table.find(self.Values, self.Value) then
        self.Value = self.Values[1] or ""
        self.SelectedText.Text = tostring(self.Value)
    end
    self.RenderOptions()
end

return Dropdown

end

-- Module: Components/MultiDropdown
Modules["Components/MultiDropdown"] = function(import)
local table_clear = table.clear or function(t) for k in pairs(t) do t[k] = nil end end
--[=[
    MultiDropdown Component
    Multi-selection menu with count badges, active check indicators, and fluid accordion animation.
]=]

local MultiDropdown = {}
MultiDropdown.__index = MultiDropdown

function MultiDropdown.new(config, parent, Theme, Animation, Utility, Assets)
    local self = setmetatable({}, MultiDropdown)
    
    self.Config = config
    self.Values = config.Values or {}
    self.Selected = {}
    if config.Default and type(config.Default) == "table" then
        for _, item in ipairs(config.Default) do
            self.Selected[item] = true
        end
    end
    
    self.Callback = config.Callback or function() end
    self.IsOpen = false
    self.OptionButtons = {}
    
    local card = Utility.Create("Frame", {
        Name = "MultiDropdown_" .. (config.Title or "Item"),
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = Theme:Get("Surface"),
        BackgroundTransparency = Theme:Get("Transparency"),
        BorderSizePixel = 0,
        Parent = parent,
    })
    Utility.AddCorner(card, 10)
    Utility.AddStroke(card, Theme:Get("Border"), 1, 0.92)
    Utility.AddPadding(card, 10, 10, 14, 14)
    Theme:Register(card, { BackgroundColor3 = "Surface" })
    
    local colLayout = Utility.Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Vertical,
        Padding = UDim.new(0, 8),
        Parent = card,
    })
    
    -- Main Row
    local mainRow = Utility.Create("Frame", {
        Name = "MainRow",
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Parent = card,
    })
    
    local mainLayout = Utility.Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        HorizontalAlignment = Enum.HorizontalAlignment.SpaceBetween,
        Parent = mainRow,
    })
    
    local textContainer = Utility.Create("Frame", {
        Name = "TextContainer",
        Size = UDim2.new(1, -130, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Parent = mainRow,
    })
    
    local titleLayout = Utility.Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Vertical,
        Padding = UDim.new(0, 2),
        Parent = textContainer,
    })
    
    local titleLabel = Utility.Create("TextLabel", {
        Name = "Title",
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamMedium,
        Text = config.Title or "Multi Dropdown",
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true,
        TextColor3 = Theme:Get("Text"),
        Parent = textContainer,
    })
    Theme:Register(titleLabel, { TextColor3 = "Text" })
    
    if config.Description and config.Description ~= "" then
        local descLabel = Utility.Create("TextLabel", {
            Name = "Description",
            Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            Font = Enum.Font.Gotham,
            Text = config.Description,
            TextSize = 11,
            TextTransparency = 0.45,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextWrapped = true,
            TextColor3 = Theme:Get("TextSecondary"),
            Parent = textContainer,
        })
        Theme:Register(descLabel, { TextColor3 = "TextSecondary" })
    end
    
    -- Selected count pill
    local selectBox = Utility.Create("Frame", {
        Name = "SelectBox",
        Size = UDim2.new(0, 115, 0, 26),
        BackgroundColor3 = Theme:Get("SurfaceSecondary"),
        BackgroundTransparency = 0.3,
        BorderSizePixel = 0,
        Parent = mainRow,
    })
    Utility.AddCorner(selectBox, 7)
    Utility.AddPadding(selectBox, 0, 0, 8, 8)
    Theme:Register(selectBox, { BackgroundColor3 = "SurfaceSecondary" })
    
    local function getSelectedCount()
        local c = 0
        for _, selected in pairs(self.Selected) do
            if selected then c = c + 1 end
        end
        return c
    end
    
    local selectedText = Utility.Create("TextLabel", {
        Name = "SelectedText",
        Size = UDim2.new(1, -20, 1, 0),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamMedium,
        Text = tostring(getSelectedCount()) .. " Selected",
        TextSize = 11,
        TextTruncate = Enum.TextTruncate.AtEnd,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextColor3 = Theme:Get("Text"),
        Parent = selectBox,
    })
    Theme:Register(selectedText, { TextColor3 = "Text" })
    
    local chevron = Utility.Create("TextLabel", {
        Name = "Chevron",
        Size = UDim2.new(0, 16, 0, 16),
        Position = UDim2.new(1, -16, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        Text = "▾",
        TextSize = 14,
        TextColor3 = Theme:Get("TextSecondary"),
        Parent = selectBox,
    })
    Theme:Register(chevron, { TextColor3 = "TextSecondary" })
    
    -- Options container
    local optionsList = Utility.Create("Frame", {
        Name = "OptionsList",
        Size = UDim2.new(1, 0, 0, 0),
        BackgroundTransparency = 1,
        ClipsDescendants = true,
        Visible = false,
        Parent = card,
    })
    
    local optionsLayout = Utility.Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Vertical,
        Padding = UDim.new(0, 4),
        Parent = optionsList,
    })
    
    local function getSelectedList()
        local list = {}
        for item, active in pairs(self.Selected) do
            if active then table.insert(list, item) end
        end
        return list
    end
    
    local function renderOptions()
        for _, btn in ipairs(self.OptionButtons) do
            btn:Destroy()
        end
        table_clear(self.OptionButtons)
        
        selectedText.Text = tostring(getSelectedCount()) .. " Selected"
        
        for _, val in ipairs(self.Values) do
            local isSelected = not not self.Selected[val]
            local optBtn = Utility.Create("TextButton", {
                Name = "Option_" .. tostring(val),
                Size = UDim2.new(1, 0, 0, 30),
                BackgroundColor3 = isSelected and Theme:Get("Accent") or Theme:Get("SurfaceSecondary"),
                BackgroundTransparency = isSelected and 0.25 or 0.6,
                Font = isSelected and Enum.Font.GothamBold or Enum.Font.GothamMedium,
                Text = (isSelected and "  ✓  " or "      ") .. tostring(val),
                TextSize = 12,
                TextColor3 = isSelected and Color3.fromRGB(255, 255, 255) or Theme:Get("Text"),
                TextXAlignment = Enum.TextXAlignment.Left,
                AutoButtonColor = false,
                Parent = optionsList,
            })
            Utility.AddCorner(optBtn, 6)
            
            local pressAnim = Animation.Press(optBtn, 1.0, 0.98)
            
            Utility.AddConnection(optBtn.MouseButton1Down:Connect(pressAnim.OnPress))
            Utility.AddConnection(optBtn.MouseButton1Up:Connect(pressAnim.OnRelease))
            Utility.AddConnection(optBtn.MouseButton1Click:Connect(function()
                if self.Selected[val] then
                    self.Selected[val] = nil
                else
                    self.Selected[val] = true
                end
                renderOptions()
                task.spawn(self.Callback, getSelectedList())
            end))
            
            table.insert(self.OptionButtons, optBtn)
        end
    end
    
    local function toggleOpen()
        self.IsOpen = not self.IsOpen
        if self.IsOpen then
            optionsList.Visible = true
            local targetHeight = #self.Values * 34
            Animation.Tween(optionsList, Animation.Presets.Fast, { Size = UDim2.new(1, 0, 0, targetHeight) })
            Animation.Tween(chevron, Animation.Presets.Fast, { Rotation = 180 })
        else
            local tween = Animation.Tween(optionsList, Animation.Presets.Fast, { Size = UDim2.new(1, 0, 0, 0) })
            Animation.Tween(chevron, Animation.Presets.Fast, { Rotation = 0 })
            if tween then
                tween.Completed:Connect(function()
                    if not self.IsOpen then
                        optionsList.Visible = false
                    end
                end)
            else
                optionsList.Visible = false
            end
        end
    end
    
    local triggerBtn = Utility.Create("TextButton", {
        Name = "TriggerOverlay",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "",
        Parent = selectBox,
    })
    Utility.AddConnection(triggerBtn.MouseButton1Click:Connect(toggleOpen))
    
    self.Card = card
    self.SelectedText = selectedText
    self.Chevron = chevron
    self.OptionsList = optionsList
    self.ToggleOpen = toggleOpen
    self.RenderOptions = renderOptions
    self.GetSelectedList = getSelectedList
    
    renderOptions()
    return self
end

function MultiDropdown:Set(selectedList)
    table_clear(self.Selected)
    if type(selectedList) == "table" then
        for _, v in ipairs(selectedList) do
            self.Selected[v] = true
        end
    end
    self.RenderOptions()
    task.spawn(self.Callback, self.GetSelectedList())
end

function MultiDropdown:Get()
    return self.GetSelectedList()
end

function MultiDropdown:Refresh(newValues)
    self.Values = newValues or {}
    for k in pairs(self.Selected) do
        if not table.find(self.Values, k) then
            self.Selected[k] = nil
        end
    end
    self.RenderOptions()
end

return MultiDropdown

end

-- Module: Components/TextBox
Modules["Components/TextBox"] = function(import)
--[=[
    TextBox Component
    Text input field with placeholder, clear button, focus highlight, and change/submit callbacks.
]=]

local TextBox = {}
TextBox.__index = TextBox

function TextBox.new(config, parent, Theme, Animation, Utility, Assets)
    local self = setmetatable({}, TextBox)
    
    self.Config = config
    self.Value = config.Default or ""
    self.Callback = config.Callback or function() end
    
    local card = Utility.Create("Frame", {
        Name = "TextBox_" .. (config.Title or "Item"),
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = Theme:Get("Surface"),
        BackgroundTransparency = Theme:Get("Transparency"),
        BorderSizePixel = 0,
        Parent = parent,
    })
    Utility.AddCorner(card, 10)
    local cardStroke = Utility.AddStroke(card, Theme:Get("Border"), 1, 0.92)
    Utility.AddPadding(card, 10, 10, 14, 14)
    Theme:Register(card, { BackgroundColor3 = "Surface" })
    
    local row = Utility.Create("Frame", {
        Name = "Row",
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Parent = card,
    })
    
    local rowLayout = Utility.Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        HorizontalAlignment = Enum.HorizontalAlignment.SpaceBetween,
        Parent = row,
    })
    
    -- Left text info
    local textContainer = Utility.Create("Frame", {
        Name = "TextContainer",
        Size = UDim2.new(1, -140, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Parent = row,
    })
    
    local titleLayout = Utility.Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Vertical,
        Padding = UDim.new(0, 2),
        Parent = textContainer,
    })
    
    local titleLabel = Utility.Create("TextLabel", {
        Name = "Title",
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamMedium,
        Text = config.Title or "Text Box",
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true,
        TextColor3 = Theme:Get("Text"),
        Parent = textContainer,
    })
    Theme:Register(titleLabel, { TextColor3 = "Text" })
    
    if config.Description and config.Description ~= "" then
        local descLabel = Utility.Create("TextLabel", {
            Name = "Description",
            Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            Font = Enum.Font.Gotham,
            Text = config.Description,
            TextSize = 11,
            TextTransparency = 0.45,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextWrapped = true,
            TextColor3 = Theme:Get("TextSecondary"),
            Parent = textContainer,
        })
        Theme:Register(descLabel, { TextColor3 = "TextSecondary" })
    end
    
    -- Input Box Frame
    local inputFrame = Utility.Create("Frame", {
        Name = "InputFrame",
        Size = UDim2.new(0, 125, 0, 28),
        BackgroundColor3 = Theme:Get("SurfaceSecondary"),
        BackgroundTransparency = 0.3,
        BorderSizePixel = 0,
        Parent = row,
    })
    Utility.AddCorner(inputFrame, 7)
    local inputStroke = Utility.AddStroke(inputFrame, Theme:Get("Accent"), 1, 1)
    Theme:Register(inputFrame, { BackgroundColor3 = "SurfaceSecondary" })
    
    local clearBtn = Utility.Create("TextButton", {
        Name = "ClearBtn",
        Size = UDim2.new(0, 18, 0, 18),
        Position = UDim2.new(1, -22, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        Text = "×",
        TextSize = 13,
        TextColor3 = Theme:Get("TextSecondary"),
        Visible = #self.Value > 0,
        Parent = inputFrame,
    })
    
    local box = Utility.Create("TextBox", {
        Name = "InputField",
        Size = UDim2.new(1, -26, 1, 0),
        Position = UDim2.new(0, 8, 0, 0),
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham,
        PlaceholderText = config.Placeholder or "Type here...",
        PlaceholderColor3 = Theme:Get("TextSecondary"),
        Text = self.Value,
        TextColor3 = Theme:Get("Text"),
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
        ClearTextOnFocus = false,
        Parent = inputFrame,
    })
    Theme:Register(box, { TextColor3 = "Text", PlaceholderColor3 = "TextSecondary" })
    
    Utility.AddConnection(box.Focused:Connect(function()
        Animation.Tween(inputStroke, Animation.Presets.Fast, { Transparency = 0 })
    end))
    
    Utility.AddConnection(box.FocusLost:Connect(function(enterPressed)
        Animation.Tween(inputStroke, Animation.Presets.Fast, { Transparency = 1 })
        self.Value = box.Text
        clearBtn.Visible = #self.Value > 0
        task.spawn(self.Callback, self.Value)
    end))
    
    Utility.AddConnection(box:GetPropertyChangedSignal("Text"):Connect(function()
        clearBtn.Visible = #box.Text > 0
    end))
    
    Utility.AddConnection(clearBtn.MouseButton1Click:Connect(function()
        box.Text = ""
        self.Value = ""
        clearBtn.Visible = false
        task.spawn(self.Callback, "")
    end))
    
    self.Card = card
    self.Box = box
    self.ClearBtn = clearBtn
    
    return self
end

function TextBox:Set(text)
    self.Value = tostring(text or "")
    self.Box.Text = self.Value
    self.ClearBtn.Visible = #self.Value > 0
    task.spawn(self.Callback, self.Value)
end

function TextBox:Get()
    return self.Value
end

return TextBox

end

-- Module: Components/Keybind
Modules["Components/Keybind"] = function(import)
--[=[
    Keybind Component
    Keyboard binding control with dynamic listening, visual key badge, and trigger execution.
]=]

local UserInputService = game and game:GetService("UserInputService")

local Keybind = {}
Keybind.__index = Keybind

function Keybind.new(config, parent, Theme, Animation, Utility, Assets)
    local self = setmetatable({}, Keybind)
    
    self.Config = config
    self.Key = config.Default or Enum.KeyCode.Unknown
    self.Callback = config.Callback or function() end
    self.Listening = false
    
    local card = Utility.Create("Frame", {
        Name = "Keybind_" .. (config.Title or "Item"),
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = Theme:Get("Surface"),
        BackgroundTransparency = Theme:Get("Transparency"),
        BorderSizePixel = 0,
        Parent = parent,
    })
    Utility.AddCorner(card, 10)
    Utility.AddStroke(card, Theme:Get("Border"), 1, 0.92)
    Utility.AddPadding(card, 10, 10, 14, 14)
    Theme:Register(card, { BackgroundColor3 = "Surface" })
    
    local row = Utility.Create("Frame", {
        Name = "Row",
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Parent = card,
    })
    
    local rowLayout = Utility.Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        HorizontalAlignment = Enum.HorizontalAlignment.SpaceBetween,
        Parent = row,
    })
    
    local textContainer = Utility.Create("Frame", {
        Name = "TextContainer",
        Size = UDim2.new(1, -90, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Parent = row,
    })
    
    local titleLayout = Utility.Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Vertical,
        Padding = UDim.new(0, 2),
        Parent = textContainer,
    })
    
    local titleLabel = Utility.Create("TextLabel", {
        Name = "Title",
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamMedium,
        Text = config.Title or "Keybind",
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true,
        TextColor3 = Theme:Get("Text"),
        Parent = textContainer,
    })
    Theme:Register(titleLabel, { TextColor3 = "Text" })
    
    if config.Description and config.Description ~= "" then
        local descLabel = Utility.Create("TextLabel", {
            Name = "Description",
            Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            Font = Enum.Font.Gotham,
            Text = config.Description,
            TextSize = 11,
            TextTransparency = 0.45,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextWrapped = true,
            TextColor3 = Theme:Get("TextSecondary"),
            Parent = textContainer,
        })
        Theme:Register(descLabel, { TextColor3 = "TextSecondary" })
    end
    
    local function getKeyName(key)
        if not key or key == Enum.KeyCode.Unknown then
            return "None"
        end
        if type(key) == "userdata" or type(key) == "table" then
            return key.Name or tostring(key)
        end
        return tostring(key)
    end
    
    -- Bind Badge Button
    local bindBtn = Utility.Create("TextButton", {
        Name = "BindButton",
        Size = UDim2.new(0, 75, 0, 26),
        BackgroundColor3 = Theme:Get("SurfaceSecondary"),
        BackgroundTransparency = 0.4,
        Font = Enum.Font.GothamBold,
        Text = "[" .. getKeyName(self.Key) .. "]",
        TextSize = 11,
        TextColor3 = Theme:Get("Text"),
        AutoButtonColor = false,
        Parent = row,
    })
    Utility.AddCorner(bindBtn, 6)
    Theme:Register(bindBtn, { BackgroundColor3 = "SurfaceSecondary", TextColor3 = "Text" })
    
    local function startListening()
        if self.Listening then return end
        self.Listening = true
        bindBtn.Text = "[ ... ]"
        Animation.Tween(bindBtn, Animation.Presets.Fast, { BackgroundColor3 = Theme:Get("Accent") })
        
        local inputConn
        inputConn = UserInputService.InputBegan:Connect(function(input, gameProcessed)
            if input.UserInputType == Enum.UserInputType.Keyboard then
                self.Listening = false
                if input.KeyCode == Enum.KeyCode.Escape then
                    self.Key = Enum.KeyCode.Unknown
                else
                    self.Key = input.KeyCode
                end
                
                bindBtn.Text = "[" .. getKeyName(self.Key) .. "]"
                Animation.Tween(bindBtn, Animation.Presets.Fast, { BackgroundColor3 = Theme:Get("SurfaceSecondary") })
                
                if inputConn then inputConn:Disconnect() end
            end
        end)
        Utility.AddConnection(inputConn)
    end
    
    Utility.AddConnection(bindBtn.MouseButton1Click:Connect(startListening))
    
    -- Global key listener to fire callback
    local triggerConn = UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed and not self.Listening and self.Key ~= Enum.KeyCode.Unknown then
            if input.KeyCode == self.Key then
                task.spawn(self.Callback, self.Key)
            end
        end
    end)
    Utility.AddConnection(triggerConn)
    
    self.Card = card
    self.BindBtn = bindBtn
    self.GetKeyName = getKeyName
    
    return self
end

function Keybind:Set(keyCode)
    self.Key = keyCode or Enum.KeyCode.Unknown
    self.BindBtn.Text = "[" .. self.GetKeyName(self.Key) .. "]"
end

function Keybind:Get()
    return self.Key
end

return Keybind

end

-- Module: Components/ColorPicker
Modules["Components/ColorPicker"] = function(import)
local math_clamp = math.clamp or function(v, min, max) return math.max(min, math.min(max, v)) end
--[=[
    ColorPicker Component
    Interactive color selector with preview swatch, RGB tuning sliders, and fluid collapsible panel.
]=]

local UserInputService = game and game:GetService("UserInputService")

local ColorPicker = {}
ColorPicker.__index = ColorPicker

function ColorPicker.new(config, parent, Theme, Animation, Utility, Assets)
    local self = setmetatable({}, ColorPicker)
    
    self.Config = config
    self.Color = config.Default or Color3.fromRGB(88, 101, 242)
    self.Callback = config.Callback or function() end
    self.IsOpen = false
    
    local r = math.floor(self.Color.R * 255 + 0.5)
    local g = math.floor(self.Color.G * 255 + 0.5)
    local b = math.floor(self.Color.B * 255 + 0.5)
    
    local card = Utility.Create("Frame", {
        Name = "ColorPicker_" .. (config.Title or "Item"),
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = Theme:Get("Surface"),
        BackgroundTransparency = Theme:Get("Transparency"),
        BorderSizePixel = 0,
        Parent = parent,
    })
    Utility.AddCorner(card, 10)
    Utility.AddStroke(card, Theme:Get("Border"), 1, 0.92)
    Utility.AddPadding(card, 10, 10, 14, 14)
    Theme:Register(card, { BackgroundColor3 = "Surface" })
    
    local colLayout = Utility.Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Vertical,
        Padding = UDim.new(0, 10),
        Parent = card,
    })
    
    -- Main Row
    local mainRow = Utility.Create("Frame", {
        Name = "MainRow",
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Parent = card,
    })
    
    local mainLayout = Utility.Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        HorizontalAlignment = Enum.HorizontalAlignment.SpaceBetween,
        Parent = mainRow,
    })
    
    local textContainer = Utility.Create("Frame", {
        Name = "TextContainer",
        Size = UDim2.new(1, -60, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Parent = mainRow,
    })
    
    local titleLayout = Utility.Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Vertical,
        Padding = UDim.new(0, 2),
        Parent = textContainer,
    })
    
    local titleLabel = Utility.Create("TextLabel", {
        Name = "Title",
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamMedium,
        Text = config.Title or "Color Picker",
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true,
        TextColor3 = Theme:Get("Text"),
        Parent = textContainer,
    })
    Theme:Register(titleLabel, { TextColor3 = "Text" })
    
    if config.Description and config.Description ~= "" then
        local descLabel = Utility.Create("TextLabel", {
            Name = "Description",
            Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            Font = Enum.Font.Gotham,
            Text = config.Description,
            TextSize = 11,
            TextTransparency = 0.45,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextWrapped = true,
            TextColor3 = Theme:Get("TextSecondary"),
            Parent = textContainer,
        })
        Theme:Register(descLabel, { TextColor3 = "TextSecondary" })
    end
    
    -- Swatch Preview Box
    local swatch = Utility.Create("TextButton", {
        Name = "Swatch",
        Size = UDim2.new(0, 36, 0, 24),
        BackgroundColor3 = self.Color,
        BorderSizePixel = 0,
        AutoButtonColor = false,
        Text = "",
        Parent = mainRow,
    })
    Utility.AddCorner(swatch, 6)
    Utility.AddStroke(swatch, Theme:Get("Border"), 1, 0.7)
    
    -- Expanded Controls Panel
    local panel = Utility.Create("Frame", {
        Name = "Panel",
        Size = UDim2.new(1, 0, 0, 0),
        BackgroundTransparency = 1,
        ClipsDescendants = true,
        Visible = false,
        Parent = card,
    })
    
    local panelLayout = Utility.Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Vertical,
        Padding = UDim.new(0, 8),
        Parent = panel,
    })
    
    local function createChannelSlider(channelName, channelColor, initialVal, onValChange)
        local cRow = Utility.Create("Frame", {
            Name = channelName .. "Row",
            Size = UDim2.new(1, 0, 0, 22),
            BackgroundTransparency = 1,
            Parent = panel,
        })
        
        local cLabel = Utility.Create("TextLabel", {
            Name = "Label",
            Size = UDim2.new(0, 20, 1, 0),
            BackgroundTransparency = 1,
            Font = Enum.Font.GothamBold,
            Text = channelName,
            TextSize = 11,
            TextColor3 = channelColor,
            Parent = cRow,
        })
        
        local track = Utility.Create("Frame", {
            Name = "Track",
            Size = UDim2.new(1, -64, 0, 6),
            Position = UDim2.new(0, 24, 0.5, 0),
            AnchorPoint = Vector2.new(0, 0.5),
            BackgroundColor3 = Theme:Get("SurfaceSecondary"),
            BorderSizePixel = 0,
            Parent = cRow,
        })
        Utility.AddCorner(track, 3)
        
        local fill = Utility.Create("Frame", {
            Name = "Fill",
            Size = UDim2.new(initialVal / 255, 0, 1, 0),
            BackgroundColor3 = channelColor,
            BorderSizePixel = 0,
            Parent = track,
        })
        Utility.AddCorner(fill, 3)
        
        local vLabel = Utility.Create("TextLabel", {
            Name = "Val",
            Size = UDim2.new(0, 32, 1, 0),
            Position = UDim2.new(1, -32, 0, 0),
            BackgroundTransparency = 1,
            Font = Enum.Font.GothamMedium,
            Text = tostring(initialVal),
            TextSize = 11,
            TextColor3 = Theme:Get("TextSecondary"),
            Parent = cRow,
        })
        
        local dragging = false
        local function update(inputX)
            local w = track.AbsoluteSize.X
            if w <= 0 then return end
            local ratio = math_clamp((inputX - track.AbsolutePosition.X) / w, 0, 1)
            local val = math.floor(ratio * 255 + 0.5)
            fill.Size = UDim2.new(ratio, 0, 1, 0)
            vLabel.Text = tostring(val)
            onValChange(val)
        end
        
        Utility.AddConnection(cRow.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                update(input.Position.X)
                
                local moveConn, endConn
                moveConn = UserInputService.InputChanged:Connect(function(mInput)
                    if dragging and (mInput.UserInputType == Enum.UserInputType.MouseMovement or mInput.UserInputType == Enum.UserInputType.Touch) then
                        update(mInput.Position.X)
                    end
                end)
                endConn = UserInputService.InputEnded:Connect(function(eInput)
                    if eInput.UserInputType == Enum.UserInputType.MouseButton1 or eInput.UserInputType == Enum.UserInputType.Touch then
                        dragging = false
                        if moveConn then moveConn:Disconnect() end
                        if endConn then endConn:Disconnect() end
                    end
                end)
                Utility.AddConnection(moveConn)
                Utility.AddConnection(endConn)
            end
        end))
        
        return {
            Set = function(val)
                val = math_clamp(val, 0, 255)
                fill.Size = UDim2.new(val / 255, 0, 1, 0)
                vLabel.Text = tostring(val)
            end
        }
    end
    
    local function applyColor()
        self.Color = Color3.fromRGB(r, g, b)
        swatch.BackgroundColor3 = self.Color
        task.spawn(self.Callback, self.Color)
    end
    
    local redSlider = createChannelSlider("R", Color3.fromRGB(255, 80, 80), r, function(val)
        r = val
        applyColor()
    end)
    
    local greenSlider = createChannelSlider("G", Color3.fromRGB(80, 230, 120), g, function(val)
        g = val
        applyColor()
    end)
    
    local blueSlider = createChannelSlider("B", Color3.fromRGB(80, 150, 255), b, function(val)
        b = val
        applyColor()
    end)
    
    local function togglePanel()
        self.IsOpen = not self.IsOpen
        if self.IsOpen then
            panel.Visible = true
            Animation.Tween(panel, Animation.Presets.Fast, { Size = UDim2.new(1, 0, 0, 90) })
        else
            local tween = Animation.Tween(panel, Animation.Presets.Fast, { Size = UDim2.new(1, 0, 0, 0) })
            if tween then
                tween.Completed:Connect(function()
                    if not self.IsOpen then
                        panel.Visible = false
                    end
                end)
            else
                panel.Visible = false
            end
        end
    end
    
    Utility.AddConnection(swatch.MouseButton1Click:Connect(togglePanel))
    
    self.Card = card
    self.Swatch = swatch
    self.Panel = panel
    self.RedSlider = redSlider
    self.GreenSlider = greenSlider
    self.BlueSlider = blueSlider
    
    return self
end

function ColorPicker:Set(color3)
    self.Color = color3 or Color3.fromRGB(255, 255, 255)
    local r = math.floor(self.Color.R * 255 + 0.5)
    local g = math.floor(self.Color.G * 255 + 0.5)
    local b = math.floor(self.Color.B * 255 + 0.5)
    self.Swatch.BackgroundColor3 = self.Color
    self.RedSlider.Set(r)
    self.GreenSlider.Set(g)
    self.BlueSlider.Set(b)
    task.spawn(self.Callback, self.Color)
end

function ColorPicker:Get()
    return self.Color
end

return ColorPicker

end

-- Module: Components/Label
Modules["Components/Label"] = function(import)
--[=[
    Label Component
    Information card displaying clean typography, optional icon, and secondary description.
]=]

local Label = {}
Label.__index = Label

function Label.new(config, parent, Theme, Animation, Utility, Assets)
    local self = setmetatable({}, Label)
    
    self.Config = config
    
    local card = Utility.Create("Frame", {
        Name = "Label_" .. (config.Title or "Item"),
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = Theme:Get("Surface"),
        BackgroundTransparency = Theme:Get("Transparency") + 0.1,
        BorderSizePixel = 0,
        Parent = parent,
    })
    Utility.AddCorner(card, 10)
    Utility.AddStroke(card, Theme:Get("Border"), 1, 0.94)
    Utility.AddPadding(card, 10, 10, 14, 14)
    Theme:Register(card, { BackgroundColor3 = "Surface" })
    
    local textContainer = Utility.Create("Frame", {
        Name = "TextContainer",
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Parent = card,
    })
    
    local textLayout = Utility.Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Vertical,
        Padding = UDim.new(0, 3),
        Parent = textContainer,
    })
    
    local titleLabel = Utility.Create("TextLabel", {
        Name = "Title",
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamMedium,
        Text = config.Title or "Label",
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true,
        TextColor3 = Theme:Get("Text"),
        Parent = textContainer,
    })
    Theme:Register(titleLabel, { TextColor3 = "Text" })
    
    local descLabel = nil
    if config.Description and config.Description ~= "" then
        descLabel = Utility.Create("TextLabel", {
            Name = "Description",
            Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            Font = Enum.Font.Gotham,
            Text = config.Description,
            TextSize = 11,
            TextTransparency = 0.45,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextWrapped = true,
            TextColor3 = Theme:Get("TextSecondary"),
            Parent = textContainer,
        })
        Theme:Register(descLabel, { TextColor3 = "TextSecondary" })
    end
    
    self.Card = card
    self.TitleLabel = titleLabel
    self.DescLabel = descLabel
    
    return self
end

function Label:Set(title, desc)
    if title then
        self.TitleLabel.Text = title
    end
    if desc and self.DescLabel then
        self.DescLabel.Text = desc
    end
end

return Label

end

-- Module: Components/Paragraph
Modules["Components/Paragraph"] = function(import)
--[=[
    Paragraph Component
    Displays structured multiline text with auto-resizing, clean typography, and subtle card styling.
]=]

local Paragraph = {}
Paragraph.__index = Paragraph

function Paragraph.new(config, parent, Theme, Animation, Utility, Assets)
    local self = setmetatable({}, Paragraph)
    
    self.Config = config
    
    local card = Utility.Create("Frame", {
        Name = "Paragraph_" .. (config.Title or "Item"),
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = Theme:Get("Surface"),
        BackgroundTransparency = Theme:Get("Transparency") + 0.05,
        BorderSizePixel = 0,
        Parent = parent,
    })
    Utility.AddCorner(card, 10)
    Utility.AddStroke(card, Theme:Get("Border"), 1, 0.94)
    Utility.AddPadding(card, 12, 12, 14, 14)
    Theme:Register(card, { BackgroundColor3 = "Surface" })
    
    local textContainer = Utility.Create("Frame", {
        Name = "TextContainer",
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Parent = card,
    })
    
    local textLayout = Utility.Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Vertical,
        Padding = UDim.new(0, 5),
        Parent = textContainer,
    })
    
    local titleLabel = Utility.Create("TextLabel", {
        Name = "Title",
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamMedium,
        Text = config.Title or "Paragraph",
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true,
        TextColor3 = Theme:Get("Text"),
        Parent = textContainer,
    })
    Theme:Register(titleLabel, { TextColor3 = "Text" })
    
    local descLabel = Utility.Create("TextLabel", {
        Name = "Content",
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham,
        Text = config.Description or config.Content or "",
        TextSize = 12,
        LineHeight = 1.25,
        TextTransparency = 0.35,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true,
        TextColor3 = Theme:Get("TextSecondary"),
        Parent = textContainer,
    })
    Theme:Register(descLabel, { TextColor3 = "TextSecondary" })
    
    self.Card = card
    self.TitleLabel = titleLabel
    self.DescLabel = descLabel
    
    return self
end

function Paragraph:Set(title, desc)
    if title then
        self.TitleLabel.Text = title
    end
    if desc then
        self.DescLabel.Text = desc
    end
end

return Paragraph

end

-- Module: UI/TopBar
Modules["UI/TopBar"] = function(import)
--[=[
    TopBar UI Component
    Displays Title, Subtitle, Icon, Minimize and Close buttons.
]=]

local TopBar = {}
TopBar.__index = TopBar

function TopBar.new(config, Theme, Animation, Utility, Assets)
    local frame = Utility.Create("Frame", {
        Name = "TopBar",
        Size = UDim2.new(1, 0, 0, 48),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
    })
    
    local padding = Utility.AddPadding(frame, 0, 0, 16, 16)
    
    -- Left info container
    local leftContainer = Utility.Create("Frame", {
        Name = "LeftContainer",
        Size = UDim2.new(1, -100, 1, 0),
        BackgroundTransparency = 1,
        Parent = frame,
    })
    
    local leftLayout = Utility.Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        Padding = UDim.new(0, 10),
        Parent = leftContainer,
    })
    
    -- Icon (if provided or present in config/Assets)
    local iconId = config.Icon or Assets.Logo or Assets.MainIcon
    local iconImage = nil
    if iconId and iconId ~= "" then
        iconImage = Utility.Create("ImageLabel", {
            Name = "WindowIcon",
            Size = UDim2.new(0, 24, 0, 24),
            BackgroundTransparency = 1,
            Image = iconId,
            ScaleType = Enum.ScaleType.Fit,
            Parent = leftContainer,
        })
    end
    
    -- Titles container
    local titlesContainer = Utility.Create("Frame", {
        Name = "TitlesContainer",
        Size = UDim2.new(1, -34, 1, 0),
        BackgroundTransparency = 1,
        Parent = leftContainer,
    })
    
    local titleLayout = Utility.Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Vertical,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        Padding = UDim.new(0, 2),
        Parent = titlesContainer,
    })
    
    local titleLabel = Utility.Create("TextLabel", {
        Name = "Title",
        Size = UDim2.new(1, 0, 0, 18),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        Text = config.Title or "Universal UI",
        TextSize = 15,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextColor3 = Theme:Get("Text"),
        Parent = titlesContainer,
    })
    Theme:Register(titleLabel, { TextColor3 = "Text" })
    
    local subtitleLabel = Utility.Create("TextLabel", {
        Name = "Subtitle",
        Size = UDim2.new(1, 0, 0, 13),
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham,
        Text = config.Subtitle or "Modern Interface",
        TextSize = 11,
        TextTransparency = 0.4,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextColor3 = Theme:Get("TextSecondary"),
        Parent = titlesContainer,
    })
    Theme:Register(subtitleLabel, { TextColor3 = "TextSecondary" })
    
    -- Right controls container (Minimize, Close)
    local controlsContainer = Utility.Create("Frame", {
        Name = "ControlsContainer",
        Size = UDim2.new(0, 70, 1, 0),
        Position = UDim2.new(1, -70, 0, 0),
        BackgroundTransparency = 1,
        Parent = frame,
    })
    
    local controlsLayout = Utility.Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Right,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        Padding = UDim.new(0, 8),
        Parent = controlsContainer,
    })
    
    local function createControlButton(name, text, iconId, onClick)
        local btn = Utility.Create("TextButton", {
            Name = name,
            Size = UDim2.new(0, 28, 0, 28),
            BackgroundColor3 = Theme:Get("SurfaceSecondary"),
            BackgroundTransparency = 0.5,
            Font = Enum.Font.GothamBold,
            Text = (not iconId or iconId == "") and text or "",
            TextColor3 = Theme:Get("Text"),
            TextSize = 13,
            AutoButtonColor = false,
            Parent = controlsContainer,
        })
        Utility.AddCorner(btn, 8)
        Theme:Register(btn, { BackgroundColor3 = "SurfaceSecondary", TextColor3 = "Text" })
        
        if iconId and iconId ~= "" then
            local img = Utility.Create("ImageLabel", {
                Name = "Icon",
                Size = UDim2.new(0, 14, 0, 14),
                Position = UDim2.new(0.5, 0, 0.5, 0),
                AnchorPoint = Vector2.new(0.5, 0.5),
                BackgroundTransparency = 1,
                Image = iconId,
                ImageColor3 = Theme:Get("Text"),
                Parent = btn,
            })
            Theme:Register(img, { ImageColor3 = "Text" })
        end
        
        local pressAnim = Animation.Press(btn, 1.0, 0.92)
        local hoverIn = function()
            Animation.Tween(btn, Animation.Presets.Fast, { BackgroundTransparency = 0.2 })
        end
        local hoverOut = function()
            Animation.Tween(btn, Animation.Presets.Fast, { BackgroundTransparency = 0.5 })
        end
        
        Utility.AddConnection(btn.MouseEnter:Connect(hoverIn))
        Utility.AddConnection(btn.MouseLeave:Connect(hoverOut))
        Utility.AddConnection(btn.MouseButton1Down:Connect(pressAnim.OnPress))
        Utility.AddConnection(btn.MouseButton1Up:Connect(pressAnim.OnRelease))
        Utility.AddConnection(btn.MouseButton1Click:Connect(onClick))
        
        return btn
    end
    
    local minBtn = createControlButton("MinimizeBtn", "−", Assets and Assets.Minimize, function()
        if config.OnMinimize then
            config.OnMinimize()
        end
    end)
    
    local closeBtn = createControlButton("CloseBtn", "×", Assets and Assets.Close, function()
        if config.OnClose then
            config.OnClose()
        end
    end)
    
    return {
        Frame = frame,
        TitleLabel = titleLabel,
        SubtitleLabel = subtitleLabel,
        IconImage = iconImage,
        MinimizeButton = minBtn,
        CloseButton = closeBtn,
    }
end

return TopBar

end

-- Module: UI/Sidebar
Modules["UI/Sidebar"] = function(import)
--[=[
    Sidebar UI Component
    Manages navigation tabs with active indicators, icons, titles, and descriptions.
]=]

local Sidebar = {}
Sidebar.__index = Sidebar

function Sidebar.new(parent, Theme, Animation, Utility, Assets)
    local self = setmetatable({}, Sidebar)
    
    self.Theme = Theme
    self.Animation = Animation
    self.Utility = Utility
    self.Assets = Assets
    self.Tabs = {}
    self.ActiveTab = nil
    
    self.Frame = Utility.Create("Frame", {
        Name = "Sidebar",
        Size = UDim2.new(0, 165, 1, -56),
        Position = UDim2.new(0, 8, 0, 48),
        BackgroundColor3 = Theme:Get("SurfaceSecondary"),
        BackgroundTransparency = 0.6,
        BorderSizePixel = 0,
        Parent = parent,
    })
    Utility.AddCorner(self.Frame, 12)
    Utility.AddStroke(self.Frame, Theme:Get("Border"), 1, 0.92)
    Theme:Register(self.Frame, { BackgroundColor3 = "SurfaceSecondary" })
    
    local padding = Utility.AddPadding(self.Frame, 8, 8, 8, 8)
    
    self.TabList = Utility.Create("ScrollingFrame", {
        Name = "TabList",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = Theme:Get("Accent"),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Parent = self.Frame,
    })
    Theme:Register(self.TabList, { ScrollBarImageColor3 = "Accent" })
    
    local listLayout = Utility.Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Vertical,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 6),
        Parent = self.TabList,
    })
    
    return self
end

function Sidebar:AddTabButton(tabConfig, onClick)
    local tabBtn = self.Utility.Create("TextButton", {
        Name = "Tab_" .. (tabConfig.Title or "Tab"),
        Size = UDim2.new(1, 0, 0, tabConfig.Description and 46 or 36),
        BackgroundColor3 = self.Theme:Get("Surface"),
        BackgroundTransparency = 1,
        AutoButtonColor = false,
        Text = "",
        Parent = self.TabList,
    })
    self.Utility.AddCorner(tabBtn, 8)
    
    -- Active Indicator pill on left edge
    local indicator = self.Utility.Create("Frame", {
        Name = "ActiveIndicator",
        Size = UDim2.new(0, 3, 0, 0),
        Position = UDim2.new(0, 4, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = self.Theme:Get("Accent"),
        BackgroundTransparency = 0,
        BorderSizePixel = 0,
        Parent = tabBtn,
    })
    self.Utility.AddCorner(indicator, 2)
    self.Theme:Register(indicator, { BackgroundColor3 = "Accent" })
    
    local contentContainer = self.Utility.Create("Frame", {
        Name = "Content",
        Size = UDim2.new(1, -16, 1, 0),
        Position = UDim2.new(0, 14, 0, 0),
        BackgroundTransparency = 1,
        Parent = tabBtn,
    })
    
    local rowLayout = self.Utility.Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Vertical,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        Padding = UDim.new(0, 2),
        Parent = contentContainer,
    })
    
    local titleLabel = self.Utility.Create("TextLabel", {
        Name = "Title",
        Size = UDim2.new(1, 0, 0, 16),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamMedium,
        Text = tabConfig.Title or "Tab",
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextColor3 = self.Theme:Get("TextSecondary"),
        Parent = contentContainer,
    })
    self.Theme:Register(titleLabel, { TextColor3 = "TextSecondary" })
    
    local descLabel = nil
    if tabConfig.Description and tabConfig.Description ~= "" then
        descLabel = self.Utility.Create("TextLabel", {
            Name = "Description",
            Size = UDim2.new(1, 0, 0, 12),
            BackgroundTransparency = 1,
            Font = Enum.Font.Gotham,
            Text = tabConfig.Description,
            TextSize = 10,
            TextTransparency = 0.45,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextColor3 = self.Theme:Get("TextSecondary"),
            Parent = contentContainer,
        })
        self.Theme:Register(descLabel, { TextColor3 = "TextSecondary" })
    end
    
    local pressAnim = self.Animation.Press(tabBtn, 1.0, 0.97)
    
    self.Utility.AddConnection(tabBtn.MouseEnter:Connect(function()
        if self.ActiveTab ~= tabBtn then
            self.Animation.Tween(tabBtn, self.Animation.Presets.Fast, { BackgroundTransparency = 0.7 })
        end
    end))
    
    self.Utility.AddConnection(tabBtn.MouseLeave:Connect(function()
        if self.ActiveTab ~= tabBtn then
            self.Animation.Tween(tabBtn, self.Animation.Presets.Fast, { BackgroundTransparency = 1 })
        end
    end))
    
    self.Utility.AddConnection(tabBtn.MouseButton1Down:Connect(pressAnim.OnPress))
    self.Utility.AddConnection(tabBtn.MouseButton1Up:Connect(pressAnim.OnRelease))
    self.Utility.AddConnection(tabBtn.MouseButton1Click:Connect(onClick))
    
    local tabData = {
        Button = tabBtn,
        Indicator = indicator,
        TitleLabel = titleLabel,
        DescLabel = descLabel,
        SetActive = function(active)
            if active then
                self.ActiveTab = tabBtn
                self.Animation.Tween(tabBtn, self.Animation.Presets.Fast, {
                    BackgroundTransparency = 0.3,
                    BackgroundColor3 = self.Theme:Get("SurfaceSecondary")
                })
                self.Animation.Tween(indicator, self.Animation.Presets.Fast, {
                    Size = UDim2.new(0, 3, 0, 20)
                })
                self.Animation.Tween(titleLabel, self.Animation.Presets.Fast, {
                    TextColor3 = self.Theme:Get("Text")
                })
            else
                self.Animation.Tween(tabBtn, self.Animation.Presets.Fast, {
                    BackgroundTransparency = 1
                })
                self.Animation.Tween(indicator, self.Animation.Presets.Fast, {
                    Size = UDim2.new(0, 3, 0, 0)
                })
                self.Animation.Tween(titleLabel, self.Animation.Presets.Fast, {
                    TextColor3 = self.Theme:Get("TextSecondary")
                })
            end
        end
    }
    
    table.insert(self.Tabs, tabData)
    return tabData
end

return Sidebar

end

-- Module: UI/Section
Modules["UI/Section"] = function(import)
--[=[
    Section UI Component
    Groups interactive components under a common title, description, and visual divider.
]=]

local Section = {}
Section.__index = Section

function Section.new(config, parent, Theme, Animation, Utility, Assets, Components)
    local self = setmetatable({}, Section)
    
    self.Config = config
    self.Theme = Theme
    self.Animation = Animation
    self.Utility = Utility
    self.Assets = Assets
    self.Components = Components or {}
    self.Items = {}
    
    local container = Utility.Create("Frame", {
        Name = "Section_" .. (config.Title or "Group"),
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Parent = parent,
    })
    
    local containerLayout = Utility.Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Vertical,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 8),
        Parent = container,
    })
    
    -- Section Header (Title, Description, Divider)
    if config.Title or config.Description then
        local header = Utility.Create("Frame", {
            Name = "Header",
            Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            Parent = container,
        })
        
        local headerLayout = Utility.Create("UIListLayout", {
            FillDirection = Enum.FillDirection.Vertical,
            Padding = UDim.new(0, 3),
            Parent = header,
        })
        
        if config.Title then
            local titleLabel = Utility.Create("TextLabel", {
                Name = "Title",
                Size = UDim2.new(1, 0, 0, 18),
                BackgroundTransparency = 1,
                Font = Enum.Font.GothamBold,
                Text = string.upper(config.Title),
                TextSize = 12,
                TextColor3 = Theme:Get("Accent"),
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = header,
            })
            Theme:Register(titleLabel, { TextColor3 = "Accent" })
        end
        
        if config.Description then
            local descLabel = Utility.Create("TextLabel", {
                Name = "Description",
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundTransparency = 1,
                Font = Enum.Font.Gotham,
                Text = config.Description,
                TextSize = 11,
                TextTransparency = 0.45,
                TextColor3 = Theme:Get("TextSecondary"),
                TextXAlignment = Enum.TextXAlignment.Left,
                TextWrapped = true,
                Parent = header,
            })
            Theme:Register(descLabel, { TextColor3 = "TextSecondary" })
        end
        
        -- Divider Line
        local divider = Utility.Create("Frame", {
            Name = "Divider",
            Size = UDim2.new(1, 0, 0, 1),
            BackgroundColor3 = Theme:Get("Border"),
            BackgroundTransparency = 0.9,
            BorderSizePixel = 0,
            Parent = header,
        })
        Theme:Register(divider, { BackgroundColor3 = "Border" })
    end
    
    self.Container = container
    return self
end

function Section:AddButton(config)
    local btn = self.Components.Button.new(config, self.Container, self.Theme, self.Animation, self.Utility, self.Assets)
    table.insert(self.Items, btn)
    return btn
end

function Section:AddToggle(config)
    local toggle = self.Components.Toggle.new(config, self.Container, self.Theme, self.Animation, self.Utility, self.Assets)
    table.insert(self.Items, toggle)
    return toggle
end

function Section:AddSlider(config)
    local slider = self.Components.Slider.new(config, self.Container, self.Theme, self.Animation, self.Utility, self.Assets)
    table.insert(self.Items, slider)
    return slider
end

function Section:AddDropdown(config)
    local dropdown = self.Components.Dropdown.new(config, self.Container, self.Theme, self.Animation, self.Utility, self.Assets)
    table.insert(self.Items, dropdown)
    return dropdown
end

function Section:AddMultiDropdown(config)
    local mDropdown = self.Components.MultiDropdown.new(config, self.Container, self.Theme, self.Animation, self.Utility, self.Assets)
    table.insert(self.Items, mDropdown)
    return mDropdown
end

function Section:AddTextBox(config)
    local textBox = self.Components.TextBox.new(config, self.Container, self.Theme, self.Animation, self.Utility, self.Assets)
    table.insert(self.Items, textBox)
    return textBox
end

function Section:AddKeybind(config)
    local keybind = self.Components.Keybind.new(config, self.Container, self.Theme, self.Animation, self.Utility, self.Assets)
    table.insert(self.Items, keybind)
    return keybind
end

function Section:AddColorPicker(config)
    local colorPicker = self.Components.ColorPicker.new(config, self.Container, self.Theme, self.Animation, self.Utility, self.Assets)
    table.insert(self.Items, colorPicker)
    return colorPicker
end

function Section:AddLabel(config)
    local label = self.Components.Label.new(config, self.Container, self.Theme, self.Animation, self.Utility, self.Assets)
    table.insert(self.Items, label)
    return label
end

function Section:AddParagraph(config)
    local para = self.Components.Paragraph.new(config, self.Container, self.Theme, self.Animation, self.Utility, self.Assets)
    table.insert(self.Items, para)
    return para
end

return Section

end

-- Module: UI/Tab
Modules["UI/Tab"] = function(import)
--[=[
    Tab Page Component
    Contains the scrolling view for sections and interactive controls with fluid transitions.
]=]

local Tab = {}
Tab.__index = Tab

function Tab.new(config, container, SectionModule, Theme, Animation, Utility, Assets, Components)
    local self = setmetatable({}, Tab)
    
    self.Config = config
    self.Theme = Theme
    self.Animation = Animation
    self.Utility = Utility
    self.Assets = Assets
    self.SectionModule = SectionModule
    self.Components = Components or {}
    self.Sections = {}
    
    self.PageFrame = Utility.Create("CanvasGroup", {
        Name = "Tab_" .. (config.Title or "Page"),
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        GroupTransparency = 1,
        Visible = false,
        Parent = container,
    })
    
    self.ScrollList = Utility.Create("ScrollingFrame", {
        Name = "ScrollList",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = Theme:Get("Accent"),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Parent = self.PageFrame,
    })
    Theme:Register(self.ScrollList, { ScrollBarImageColor3 = "Accent" })
    
    local padding = Utility.AddPadding(self.ScrollList, 10, 16, 12, 12)
    
    local listLayout = Utility.Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Vertical,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 12),
        Parent = self.ScrollList,
    })
    
    return self
end

function Tab:Show()
    self.PageFrame.Visible = true
    self.PageFrame.GroupTransparency = 1
    self.PageFrame.Position = UDim2.new(0, 8, 0, 0)
    
    self.Animation.Tween(self.PageFrame, self.Animation.Presets.Fast, {
        GroupTransparency = 0,
        Position = UDim2.new(0, 0, 0, 0),
    })
end

function Tab:Hide()
    local tween = self.Animation.Tween(self.PageFrame, self.Animation.Presets.Fast, {
        GroupTransparency = 1,
        Position = UDim2.new(0, -8, 0, 0),
    })
    if tween then
        tween.Completed:Connect(function()
            if self.PageFrame.GroupTransparency == 1 then
                self.PageFrame.Visible = false
            end
        end)
    else
        self.PageFrame.Visible = false
    end
end

function Tab:AddSection(sectionConfig)
    local section = self.SectionModule.new(sectionConfig, self.ScrollList, self.Theme, self.Animation, self.Utility, self.Assets, self.Components)
    table.insert(self.Sections, section)
    return section
end

return Tab

end

-- Module: UI/Notifications
Modules["UI/Notifications"] = function(import)
--[=[
    Notifications System
    Floating toast notification system with progress bar, type styling, fluid slide/fade animations,
    and automatic cleanup.
]=]

local TweenService = game and game:GetService("TweenService")

local Notifications = {}
Notifications.__index = Notifications

function Notifications.new(guiParent, Theme, Animation, Utility, Assets)
    local self = setmetatable({}, Notifications)
    
    self.Theme = Theme
    self.Animation = Animation
    self.Utility = Utility
    self.Assets = Assets
    
    -- Dedicated container for notifications
    self.Container = Utility.Create("Frame", {
        Name = "NotificationContainer",
        Size = UDim2.new(0, 310, 1, -20),
        Position = UDim2.new(1, -320, 0, 10),
        BackgroundTransparency = 1,
        ClipsDescendants = false,
        Parent = guiParent,
    })
    
    local listLayout = Utility.Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Vertical,
        VerticalAlignment = Enum.VerticalAlignment.Bottom,
        HorizontalAlignment = Enum.HorizontalAlignment.Right,
        Padding = UDim.new(0, 10),
        Parent = self.Container,
    })
    
    return self
end

function Notifications:Notify(config)
    local title = config.Title or "Notification"
    local desc = config.Description or ""
    local duration = config.Duration or 3.5
    local nType = config.Type or "Info" -- Info, Success, Warning, Error
    
    local typeColors = {
        Info = self.Theme:Get("Info") or Color3.fromRGB(52, 152, 219),
        Success = self.Theme:Get("Success") or Color3.fromRGB(46, 213, 115),
        Warning = self.Theme:Get("Warning") or Color3.fromRGB(255, 171, 0),
        Error = self.Theme:Get("Error") or Color3.fromRGB(255, 71, 87),
    }
    
    local typeIcons = {
        Info = self.Assets.Info,
        Success = self.Assets.Success,
        Warning = self.Assets.Warning,
        Error = self.Assets.Error,
    }
    
    local accentColor = typeColors[nType] or self.Theme:Get("Accent")
    local iconId = config.Icon or typeIcons[nType] or self.Assets.Info
    
    local card = self.Utility.Create("CanvasGroup", {
        Name = "Toast_" .. nType,
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = self.Theme:Get("Surface"),
        BackgroundTransparency = 0.1,
        GroupTransparency = 1,
        Position = UDim2.new(1, 40, 0, 0),
        Parent = self.Container,
    })
    self.Utility.AddCorner(card, 12)
    self.Utility.AddStroke(card, self.Theme:Get("Border"), 1, 0.88)
    self.Utility.AddPadding(card, 12, 14, 14, 14)
    
    local mainRow = self.Utility.Create("Frame", {
        Name = "MainRow",
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Parent = card,
    })
    
    local rowLayout = self.Utility.Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        Padding = UDim.new(0, 10),
        Parent = mainRow,
    })
    
    -- Type badge or icon
    if iconId and iconId ~= "" then
        local iconImg = self.Utility.Create("ImageLabel", {
            Name = "Icon",
            Size = UDim2.new(0, 22, 0, 22),
            BackgroundTransparency = 1,
            Image = iconId,
            ImageColor3 = accentColor,
            Parent = mainRow,
        })
    else
        local badge = self.Utility.Create("Frame", {
            Name = "Badge",
            Size = UDim2.new(0, 8, 0, 22),
            BackgroundColor3 = accentColor,
            BorderSizePixel = 0,
            Parent = mainRow,
        })
        self.Utility.AddCorner(badge, 4)
    end
    
    local textContainer = self.Utility.Create("Frame", {
        Name = "TextContainer",
        Size = UDim2.new(1, -34, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Parent = mainRow,
    })
    
    local textLayout = self.Utility.Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Vertical,
        Padding = UDim.new(0, 2),
        Parent = textContainer,
    })
    
    local titleLabel = self.Utility.Create("TextLabel", {
        Name = "Title",
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        Text = title,
        TextSize = 13,
        TextColor3 = self.Theme:Get("Text"),
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = textContainer,
    })
    
    if desc and desc ~= "" then
        local descLabel = self.Utility.Create("TextLabel", {
            Name = "Description",
            Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            Font = Enum.Font.Gotham,
            Text = desc,
            TextSize = 11,
            TextTransparency = 0.4,
            TextColor3 = self.Theme:Get("TextSecondary"),
            TextXAlignment = Enum.TextXAlignment.Left,
            TextWrapped = true,
            Parent = textContainer,
        })
    end
    
    -- Progress Bar Track & Fill
    local progressTrack = self.Utility.Create("Frame", {
        Name = "ProgressTrack",
        Size = UDim2.new(1, 0, 0, 3),
        Position = UDim2.new(0, 0, 1, 10),
        BackgroundColor3 = self.Theme:Get("SurfaceSecondary"),
        BorderSizePixel = 0,
        Parent = card,
    })
    self.Utility.AddCorner(progressTrack, 2)
    
    local progressFill = self.Utility.Create("Frame", {
        Name = "ProgressFill",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = accentColor,
        BorderSizePixel = 0,
        Parent = progressTrack,
    })
    self.Utility.AddCorner(progressFill, 2)
    
    -- Animate In
    self.Animation.Tween(card, self.Animation.Presets.Spring, {
        GroupTransparency = 0,
        Position = UDim2.new(0, 0, 0, 0)
    })
    
    -- Animate Progress Bar
    if TweenService then
        local progressTween = TweenService:Create(progressFill, TweenInfo.new(duration, Enum.EasingStyle.Linear), {
            Size = UDim2.new(0, 0, 1, 0)
        })
        progressTween:Play()
    end
    
    local dismissed = false
    local function dismiss()
        if dismissed then return end
        dismissed = true
        
        local outTween = self.Animation.Tween(card, self.Animation.Presets.Fast, {
            GroupTransparency = 1,
            Position = UDim2.new(1, 40, 0, 0)
        })
        if outTween then
            outTween.Completed:Connect(function()
                card:Destroy()
            end)
        else
            card:Destroy()
        end
    end
    
    local clickBtn = self.Utility.Create("TextButton", {
        Name = "DismissClick",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "",
        Parent = card,
    })
    self.Utility.AddConnection(clickBtn.MouseButton1Click:Connect(dismiss))
    
    task.delay(duration, dismiss)
end

function Notifications:Destroy()
    if self.Container then
        self.Container:Destroy()
    end
end

return Notifications

end

-- Module: UI/Window
Modules["UI/Window"] = function(import)
local math_clamp = math.clamp or function(v, min, max) return math.max(min, math.min(max, v)) end
--[=[
    Window UI Component
    Top-level window managing TopBar, Sidebar, Tab pages, Dragging, Screen Bounds Clamping,
    Minimization pill, and Mobile Responsive Scaling.
]=]

local UserInputService = game and game:GetService("UserInputService")
local Workspace = game and game:GetService("Workspace")

local Window = {}
Window.__index = Window

function Window.new(config, modules)
    local self = setmetatable({}, Window)
    
    self.Config = config
    self.Theme = modules.Theme
    self.Animation = modules.Animation
    self.Utility = modules.Utility
    self.Assets = modules.Assets
    self.Modules = modules
    self.Tabs = {}
    self.CurrentTab = nil
    self.IsMinimized = false
    
    -- Root ScreenGui
    local guiParent = modules.Utility.GetGuiParent()
    self.ScreenGui = self.Utility.Create("ScreenGui", {
        Name = "UniversalUI_" .. (config.Title or "Window"),
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        DisplayOrder = 100,
        Parent = guiParent,
    })
    
    -- Main Window Frame (Glassmorphism card)
    local viewport = self.Utility.GetViewportSize()
    local isMobile = self.Utility.IsMobile() or (viewport.X < 650)
    
    local defaultWidth = isMobile and math.min(viewport.X - 32, 480) or 560
    local defaultHeight = isMobile and math.min(viewport.Y - 60, 360) or 360
    
    self.NormalSize = UDim2.new(0, defaultWidth, 0, defaultHeight)
    self.NormalPosition = UDim2.new(0.5, -defaultWidth / 2, 0.5, -defaultHeight / 2)
    
    self.MainFrame = self.Utility.Create("CanvasGroup", {
        Name = "MainFrame",
        Size = self.NormalSize,
        Position = self.NormalPosition,
        BackgroundColor3 = self.Theme:Get("Background"),
        BackgroundTransparency = self.Theme:Get("Transparency"),
        BorderSizePixel = 0,
        GroupTransparency = 1,
        ClipsDescendants = true,
        Parent = self.ScreenGui,
    })
    self.Utility.AddCorner(self.MainFrame, 16)
    self.Utility.AddStroke(self.MainFrame, self.Theme:Get("Border"), 1, self.Theme:Get("BorderTransparency"))
    self.Theme:Register(self.MainFrame, { BackgroundColor3 = "Background" })
    
    -- Mobile Responsive Scaling (UIScale)
    local uiScale = self.Utility.Create("UIScale", {
        Name = "WindowScale",
        Scale = 1.0,
        Parent = self.MainFrame,
    })
    self.UIScale = uiScale
    
    local function updateScale()
        local vp = self.Utility.GetViewportSize()
        if vp.X < 500 then
            local scaleFactor = math_clamp(vp.X / 520, 0.75, 1.0)
            uiScale.Scale = scaleFactor
        else
            uiScale.Scale = 1.0
        end
    end
    updateScale()
    
    if Workspace and Workspace.CurrentCamera then
        self.Utility.AddConnection(Workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(updateScale))
    end
    
    -- Minimize Floating Pill Frame
    self.PillFrame = self.Utility.Create("Frame", {
        Name = "MinimizedPill",
        Size = UDim2.new(0, 110, 0, 36),
        Position = UDim2.new(0.5, -55, 0, 20),
        BackgroundColor3 = self.Theme:Get("Surface"),
        BackgroundTransparency = 0.15,
        BorderSizePixel = 0,
        Visible = false,
        Parent = self.ScreenGui,
    })
    self.Utility.AddCorner(self.PillFrame, 18)
    self.Utility.AddStroke(self.PillFrame, self.Theme:Get("Border"), 1, 0.85)
    self.Theme:Register(self.PillFrame, { BackgroundColor3 = "Surface" })
    
    local pillLayout = self.Utility.Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        Padding = UDim.new(0, 6),
        Parent = self.PillFrame,
    })
    
    local pillDot = self.Utility.Create("Frame", {
        Name = "Dot",
        Size = UDim2.new(0, 8, 0, 8),
        BackgroundColor3 = self.Theme:Get("Accent"),
        BorderSizePixel = 0,
        Parent = self.PillFrame,
    })
    self.Utility.AddCorner(pillDot, 4)
    self.Theme:Register(pillDot, { BackgroundColor3 = "Accent" })
    
    local pillText = self.Utility.Create("TextLabel", {
        Name = "PillText",
        Size = UDim2.new(0, 0, 1, 0),
        AutomaticSize = Enum.AutomaticSize.X,
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        Text = config.Title or "UI",
        TextSize = 12,
        TextColor3 = self.Theme:Get("Text"),
        Parent = self.PillFrame,
    })
    self.Theme:Register(pillText, { TextColor3 = "Text" })
    
    local pillBtn = self.Utility.Create("TextButton", {
        Name = "ExpandButton",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "",
        Parent = self.PillFrame,
    })
    
    self.Utility.AddConnection(pillBtn.MouseButton1Click:Connect(function()
        self:ToggleMinimize()
    end))
    self.Utility.MakeDraggable(self.PillFrame)
    
    -- TopBar
    self.TopBar = modules.TopBar.new({
        Title = config.Title,
        Subtitle = config.Subtitle,
        Icon = config.Icon,
        OnMinimize = function()
            self:ToggleMinimize()
        end,
        OnClose = function()
            self:Close()
        end
    }, self.Theme, self.Animation, self.Utility, self.Assets)
    self.TopBar.Frame.Parent = self.MainFrame
    
    -- Draggable TopBar and Window Frame with Screen Bounds Clamping
    self.Utility.MakeDraggable(self.MainFrame, self.TopBar.Frame)
    
    -- Sidebar for Tabs
    self.Sidebar = modules.Sidebar.new(self.MainFrame, self.Theme, self.Animation, self.Utility, self.Assets)
    
    -- Tab Content Container Frame
    self.ContentContainer = self.Utility.Create("Frame", {
        Name = "ContentContainer",
        Size = UDim2.new(1, -190, 1, -56),
        Position = UDim2.new(0, 180, 0, 48),
        BackgroundTransparency = 1,
        ClipsDescendants = true,
        Parent = self.MainFrame,
    })
    
    -- Fade In Window on launch
    self.Animation.Tween(self.MainFrame, self.Animation.Presets.Spring, {
        GroupTransparency = 0,
        Position = self.NormalPosition
    })
    
    return self
end

function Window:AddTab(tabConfig)
    local tab = self.Modules.Tab.new(
        tabConfig,
        self.ContentContainer,
        self.Modules.Section,
        self.Theme,
        self.Animation,
        self.Utility,
        self.Assets,
        self.Modules.Components
    )
    
    local tabBtnData = self.Sidebar:AddTabButton(tabConfig, function()
        self:SelectTab(tab, tabBtnData)
    end)
    
    local entry = { Tab = tab, ButtonData = tabBtnData }
    table.insert(self.Tabs, entry)
    
    -- If first tab, select it automatically
    if #self.Tabs == 1 then
        self:SelectTab(tab, tabBtnData)
    end
    
    return tab
end

function Window:SelectTab(tab, buttonData)
    if self.CurrentTab == tab then return end
    
    for _, item in ipairs(self.Tabs) do
        if item.Tab ~= tab then
            item.Tab:Hide()
            item.ButtonData.SetActive(false)
        end
    end
    
    self.CurrentTab = tab
    buttonData.SetActive(true)
    tab:Show()
end

function Window:ToggleMinimize()
    self.IsMinimized = not self.IsMinimized
    
    if self.IsMinimized then
        self.NormalPosition = self.MainFrame.Position
        local tween = self.Animation.Tween(self.MainFrame, self.Animation.Presets.Fast, {
            GroupTransparency = 1,
            Position = UDim2.new(self.NormalPosition.X.Scale, self.NormalPosition.X.Offset, 0, -50)
        })
        if tween then
            tween.Completed:Connect(function()
                self.MainFrame.Visible = false
                self.PillFrame.Visible = true
                self.PillFrame.Position = UDim2.new(0.5, -55, 0, -40)
                self.Animation.Tween(self.PillFrame, self.Animation.Presets.Spring, {
                    Position = UDim2.new(0.5, -55, 0, 20)
                })
            end)
        else
            self.MainFrame.Visible = false
            self.PillFrame.Visible = true
        end
    else
        local tween = self.Animation.Tween(self.PillFrame, self.Animation.Presets.Fast, {
            Position = UDim2.new(0.5, -55, 0, -40)
        })
        if tween then
            tween.Completed:Connect(function()
                self.PillFrame.Visible = false
                self.MainFrame.Visible = true
                self.Animation.Tween(self.MainFrame, self.Animation.Presets.Spring, {
                    GroupTransparency = 0,
                    Position = self.NormalPosition
                })
            end)
        else
            self.PillFrame.Visible = false
            self.MainFrame.Visible = true
        end
    end
end

function Window:Close()
    local tween = self.Animation.Tween(self.MainFrame, self.Animation.Presets.Fast, {
        GroupTransparency = 1,
        Position = UDim2.new(self.MainFrame.Position.X.Scale, self.MainFrame.Position.X.Offset, 0.5, 50)
    })
    if tween then
        tween.Completed:Connect(function()
            self.ScreenGui.Enabled = false
        end)
    else
        self.ScreenGui.Enabled = false
    end
end

function Window:Destroy()
    if self.ScreenGui then
        self.ScreenGui:Destroy()
    end
end

return Window

end

-- Module: Library
Modules["Library"] = function(import)
local table_clear = table.clear or function(t) for k in pairs(t) do t[k] = nil end end
--[=[
    Universal UI Library
    Main orchestration module that provides the top-level API, lifecycle management,
    theme control, notification system, and memory leak prevention.
]=]

local Library = {}
Library.__index = Library

function Library.init(import)
    local Theme = import("Theme")
    local Animation = import("Animation")
    local Utility = import("Utility")
    local Assets = import("Assets")
    
    local Button = import("Components/Button")
    local Toggle = import("Components/Toggle")
    local Slider = import("Components/Slider")
    local Dropdown = import("Components/Dropdown")
    local MultiDropdown = import("Components/MultiDropdown")
    local TextBox = import("Components/TextBox")
    local Keybind = import("Components/Keybind")
    local ColorPicker = import("Components/ColorPicker")
    local Label = import("Components/Label")
    local Paragraph = import("Components/Paragraph")
    
    local TopBar = import("UI/TopBar")
    local Sidebar = import("UI/Sidebar")
    local Section = import("UI/Section")
    local Tab = import("UI/Tab")
    local Notifications = import("UI/Notifications")
    local Window = import("UI/Window")
    
    local Components = {
        Button = Button,
        Toggle = Toggle,
        Slider = Slider,
        Dropdown = Dropdown,
        MultiDropdown = MultiDropdown,
        TextBox = TextBox,
        Keybind = Keybind,
        ColorPicker = ColorPicker,
        Label = Label,
        Paragraph = Paragraph,
    }
    
    local Modules = {
        Theme = Theme,
        Animation = Animation,
        Utility = Utility,
        Assets = Assets,
        TopBar = TopBar,
        Sidebar = Sidebar,
        Section = Section,
        Tab = Tab,
        Notifications = Notifications,
        Window = Window,
        Components = Components,
    }
    
    local self = setmetatable({}, Library)
    self.Modules = Modules
    self.Theme = Theme
    self.Assets = Assets
    self.Windows = {}
    self.NotificationSystem = nil
    
    return self
end

function Library:CreateWindow(config)
    config = config or {}
    local window = self.Modules.Window.new(config, self.Modules)
    table.insert(self.Windows, window)
    
    -- Initialize notification system parented to the GUI root if not done yet
    if not self.NotificationSystem then
        self.NotificationSystem = self.Modules.Notifications.new(
            window.ScreenGui,
            self.Theme,
            self.Modules.Animation,
            self.Modules.Utility,
            self.Assets
        )
    end
    
    return window
end

function Library:Notify(config)
    if self.NotificationSystem then
        self.NotificationSystem:Notify(config)
    else
        -- Fallback if no window created yet: create a lightweight notification GUI
        local guiParent = self.Modules.Utility.GetGuiParent()
        local notifyGui = self.Modules.Utility.Create("ScreenGui", {
            Name = "UniversalUI_Toasts",
            ResetOnSpawn = false,
            DisplayOrder = 110,
            Parent = guiParent,
        })
        self.NotificationSystem = self.Modules.Notifications.new(
            notifyGui,
            self.Theme,
            self.Modules.Animation,
            self.Modules.Utility,
            self.Assets
        )
        self.NotificationSystem:Notify(config)
    end
end

function Library:SetTheme(newTheme, animate)
    self.Theme:SetTheme(newTheme, animate)
end

function Library:Destroy()
    -- 1. Cancel and cleanup all running tweens
    self.Modules.Animation.Cleanup()
    
    -- 2. Disconnect all tracked RBXScriptConnections
    self.Modules.Utility.DisconnectAll()
    
    -- 3. Clear Theme instance registry
    self.Theme:ClearRegistry()
    
    -- 4. Destroy all Window ScreenGuis
    for _, win in ipairs(self.Windows) do
        pcall(function()
            win:Destroy()
        end)
    end
    table_clear(self.Windows)
    
    -- 5. Destroy notifications
    if self.NotificationSystem then
        pcall(function()
            self.NotificationSystem:Destroy()
        end)
        self.NotificationSystem = nil
    end
end

return Library

end

local Library = import("Library")
return Library.init(import)