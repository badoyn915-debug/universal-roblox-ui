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
