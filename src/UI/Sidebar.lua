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
    
    local rawIcon = tabConfig.Icon
    if rawIcon and self.Assets[rawIcon] then
        rawIcon = self.Assets[rawIcon]
    end
    if not rawIcon or rawIcon == "" then
        rawIcon = self.Assets.MainIcon
    end
    local iconId = (self.Assets.Resolve and self.Assets.Resolve(rawIcon)) or rawIcon
    
    local iconImg = nil
    if iconId and iconId ~= "" then
        iconImg = self.Utility.Create("ImageLabel", {
            Name = "TabIcon",
            Size = UDim2.new(0, 18, 0, 18),
            Position = UDim2.new(0, 12, 0.5, 0),
            AnchorPoint = Vector2.new(0, 0.5),
            BackgroundTransparency = 1,
            Image = iconId,
            ImageColor3 = self.Theme:Get("TextSecondary"),
            ScaleType = Enum.ScaleType.Fit,
            Parent = tabBtn,
        })
    end
    
    local contentContainer = self.Utility.Create("Frame", {
        Name = "Content",
        Size = UDim2.new(1, iconImg and -36 or -16, 1, 0),
        Position = UDim2.new(0, iconImg and 34 or 14, 0, 0),
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
                if iconImg then
                    self.Animation.Tween(iconImg, self.Animation.Presets.Fast, {
                        ImageColor3 = self.Theme:Get("Accent")
                    })
                end
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
                if iconImg then
                    self.Animation.Tween(iconImg, self.Animation.Presets.Fast, {
                        ImageColor3 = self.Theme:Get("TextSecondary")
                    })
                end
            end
        end
    }
    
    table.insert(self.Tabs, tabData)
    return tabData
end

return Sidebar
