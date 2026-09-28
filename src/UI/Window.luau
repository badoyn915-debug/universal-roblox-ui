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
