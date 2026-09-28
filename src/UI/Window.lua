local math_clamp = math.clamp or function(v, min, max) return math.max(min, math.min(max, v)) end
--[=[
    Window UI Component
    Top-level window managing TopBar, Sidebar, Tab pages, Dragging, Screen Bounds Clamping,
    Minimization pill, Mobile Floating Toggle Button (FAB), Lighting Blur Effect,
    and Mobile Responsive Scaling.
]=]

local UserInputService = game and game:GetService("UserInputService")
local Workspace = game and game:GetService("Workspace")
local Lighting = game and game:GetService("Lighting")

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
    self.IsOpen = true
    
    -- Root ScreenGui
    local guiParent = modules.Utility.GetGuiParent()
    local screenGui = self.Utility.Create("ScreenGui", {
        Name = "UniversalUI_" .. (config.Title or "Window"),
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        DisplayOrder = 100,
    })
    
    if syn and syn.protect_gui then
        pcall(syn.protect_gui, screenGui)
    end
    
    local parented = false
    pcall(function()
        screenGui.Parent = guiParent
        parented = true
    end)
    if not parented then
        pcall(function()
            local Players = game:GetService("Players")
            if Players.LocalPlayer then
                screenGui.Parent = Players.LocalPlayer:FindFirstChildOfClass("PlayerGui")
            end
        end)
    end
    self.ScreenGui = screenGui
    
    -- Lighting Blur Effect (for authentic frosted glass backdrop)
    local blurEffect = nil
    if Lighting then
        pcall(function()
            blurEffect = Lighting:FindFirstChild("UniversalUI_Blur")
            if not blurEffect then
                blurEffect = Instance.new("BlurEffect")
                blurEffect.Name = "UniversalUI_Blur"
                blurEffect.Size = 16
                blurEffect.Enabled = true
                blurEffect.Parent = Lighting
            else
                blurEffect.Enabled = true
            end
        end)
    end
    self.BlurEffect = blurEffect
    
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
        BackgroundTransparency = self.Theme:Get("GlassTransparency") or 0.35,
        BorderSizePixel = 0,
        GroupTransparency = 0,
        ClipsDescendants = true,
        Parent = self.ScreenGui,
    })
    self.Utility.AddCorner(self.MainFrame, 16)
    self.Utility.AddStroke(self.MainFrame, self.Theme:Get("Border"), 1.2, self.Theme:Get("BorderTransparency") or 0.8)
    self.Theme:Register(self.MainFrame, { BackgroundColor3 = "Background" })
    
    -- Subtle frosted glass sheen gradient
    local glassSheen = self.Utility.Create("UIGradient", {
        Name = "GlassSheen",
        Rotation = 45,
        Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0.1),
            NumberSequenceKeypoint.new(0.5, 0.25),
            NumberSequenceKeypoint.new(1, 0.4),
        }),
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(210, 220, 250)),
        }),
        Parent = self.MainFrame,
    })
    
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
    
    -- Mobile Floating Action Button (FAB) Toggle (Always accessible on touch devices)
    local rawLogo = self.Assets.Logo or self.Assets.MainIcon
    local logoIcon = (self.Assets.Resolve and self.Assets.Resolve(rawLogo)) or rawLogo
    
    local mobileFab = self.Utility.Create("Frame", {
        Name = "MobileToggleFAB",
        Size = UDim2.new(0, 46, 0, 46),
        Position = UDim2.new(0, 16, 0.5, -23),
        BackgroundColor3 = self.Theme:Get("Surface"),
        BackgroundTransparency = 0.2,
        BorderSizePixel = 0,
        ZIndex = 500,
        Visible = true,
        Parent = self.ScreenGui,
    })
    self.Utility.AddCorner(mobileFab, 23)
    local fabStroke = self.Utility.AddStroke(mobileFab, self.Theme:Get("Accent"), 1.8, 0.3)
    self.Theme:Register(mobileFab, { BackgroundColor3 = "Surface" })
    self.Theme:Register(fabStroke, { Color = "Accent" })
    
    local fabIcon = self.Utility.Create("ImageLabel", {
        Name = "Icon",
        Size = UDim2.new(0, 24, 0, 24),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        Image = logoIcon,
        ImageColor3 = self.Theme:Get("Accent"),
        ScaleType = Enum.ScaleType.Fit,
        Parent = mobileFab,
    })
    self.Theme:Register(fabIcon, { ImageColor3 = "Accent" })
    
    local fabClick = self.Utility.Create("TextButton", {
        Name = "ClickTrigger",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "",
        Parent = mobileFab,
    })
    
    -- Enable dragging on the mobile button with screen boundary clamping
    self.Utility.MakeDraggable(mobileFab, fabClick)
    
    self.Utility.AddConnection(fabClick.MouseButton1Click:Connect(function()
        self:ToggleVisibility()
    end))
    self.MobileFab = mobileFab
    
    -- Minimize Floating Pill Frame (collapsible desktop dock)
    self.PillFrame = self.Utility.Create("Frame", {
        Name = "MinimizedPill",
        Size = UDim2.new(0, 120, 0, 36),
        Position = UDim2.new(0.5, -60, 0, 20),
        BackgroundColor3 = self.Theme:Get("Surface"),
        BackgroundTransparency = 0.25,
        BorderSizePixel = 0,
        Visible = false,
        Parent = self.ScreenGui,
    })
    self.Utility.AddCorner(self.PillFrame, 18)
    self.Utility.AddStroke(self.PillFrame, self.Theme:Get("Border"), 1, 0.8)
    self.Theme:Register(self.PillFrame, { BackgroundColor3 = "Surface" })
    
    local pillLayout = self.Utility.Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        Padding = UDim.new(0, 8),
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

function Window:ToggleVisibility()
    self.IsOpen = not self.IsOpen
    
    if self.IsOpen then
        self.MainFrame.Visible = true
        if self.BlurEffect then self.BlurEffect.Enabled = true end
        self.Animation.Tween(self.MainFrame, self.Animation.Presets.Spring, {
            GroupTransparency = 0,
            Position = self.NormalPosition
        })
    else
        self.NormalPosition = self.MainFrame.Position
        local tween = self.Animation.Tween(self.MainFrame, self.Animation.Presets.Fast, {
            GroupTransparency = 1,
            Position = UDim2.new(self.NormalPosition.X.Scale, self.NormalPosition.X.Offset, 0, -50)
        })
        if self.BlurEffect then self.BlurEffect.Enabled = false end
        if tween then
            tween.Completed:Connect(function()
                if not self.IsOpen then
                    self.MainFrame.Visible = false
                end
            end)
        else
            self.MainFrame.Visible = false
        end
    end
end

function Window:ToggleMinimize()
    self.IsMinimized = not self.IsMinimized
    
    if self.IsMinimized then
        self.NormalPosition = self.MainFrame.Position
        local tween = self.Animation.Tween(self.MainFrame, self.Animation.Presets.Fast, {
            GroupTransparency = 1,
            Position = UDim2.new(self.NormalPosition.X.Scale, self.NormalPosition.X.Offset, 0, -50)
        })
        if self.BlurEffect then self.BlurEffect.Enabled = false end
        if tween then
            tween.Completed:Connect(function()
                self.MainFrame.Visible = false
                self.PillFrame.Visible = true
                self.PillFrame.Position = UDim2.new(0.5, -60, 0, -40)
                self.Animation.Tween(self.PillFrame, self.Animation.Presets.Spring, {
                    Position = UDim2.new(0.5, -60, 0, 20)
                })
            end)
        else
            self.MainFrame.Visible = false
            self.PillFrame.Visible = true
        end
    else
        local tween = self.Animation.Tween(self.PillFrame, self.Animation.Presets.Fast, {
            Position = UDim2.new(0.5, -60, 0, -40)
        })
        if tween then
            tween.Completed:Connect(function()
                self.PillFrame.Visible = false
                self.MainFrame.Visible = true
                if self.BlurEffect then self.BlurEffect.Enabled = true end
                self.Animation.Tween(self.MainFrame, self.Animation.Presets.Spring, {
                    GroupTransparency = 0,
                    Position = self.NormalPosition
                })
            end)
        else
            self.PillFrame.Visible = false
            self.MainFrame.Visible = true
            if self.BlurEffect then self.BlurEffect.Enabled = true end
        end
    end
end

function Window:Close()
    self.IsOpen = false
    local tween = self.Animation.Tween(self.MainFrame, self.Animation.Presets.Fast, {
        GroupTransparency = 1,
        Position = UDim2.new(self.MainFrame.Position.X.Scale, self.MainFrame.Position.X.Offset, 0.5, 50)
    })
    if self.BlurEffect then self.BlurEffect.Enabled = false end
    if tween then
        tween.Completed:Connect(function()
            self.MainFrame.Visible = false
        end)
    else
        self.MainFrame.Visible = false
    end
end

function Window:Destroy()
    if self.BlurEffect then
        pcall(function()
            self.BlurEffect:Destroy()
        end)
        self.BlurEffect = nil
    end
    if self.ScreenGui then
        self.ScreenGui:Destroy()
    end
end

return Window
