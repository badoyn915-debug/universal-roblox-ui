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
