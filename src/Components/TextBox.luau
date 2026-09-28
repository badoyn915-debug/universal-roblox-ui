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
