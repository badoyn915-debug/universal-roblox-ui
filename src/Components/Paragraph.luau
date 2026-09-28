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
