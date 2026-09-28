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
    
    local leftContainer = Utility.Create("Frame", {
        Name = "LeftContainer",
        Size = UDim2.new(1, -70, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Parent = row,
    })
    
    local leftLayout = Utility.Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        Padding = UDim.new(0, 10),
        Parent = leftContainer,
    })
    
    local rawIcon = config.Icon
    if rawIcon and Assets[rawIcon] then rawIcon = Assets[rawIcon] end
    local iconId = (Assets.Resolve and Assets.Resolve(rawIcon)) or rawIcon
    if iconId and iconId ~= "" then
        local compIcon = Utility.Create("ImageLabel", {
            Name = "Icon",
            Size = UDim2.new(0, 18, 0, 18),
            BackgroundTransparency = 1,
            Image = iconId,
            ImageColor3 = Theme:Get("Accent"),
            ScaleType = Enum.ScaleType.Fit,
            Parent = leftContainer,
        })
        Theme:Register(compIcon, { ImageColor3 = "Accent" })
    end
    
    -- Left text side
    local textContainer = Utility.Create("Frame", {
        Name = "TextContainer",
        Size = UDim2.new(1, (iconId and iconId ~= "") and -28 or 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Parent = leftContainer,
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
