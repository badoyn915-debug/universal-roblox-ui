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
