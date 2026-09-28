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
