local table_clear = table.clear or function(t) for k in pairs(t) do t[k] = nil end end
--[=[
    MultiDropdown Component
    Multi-selection menu with count badges, active check indicators, and fluid accordion animation.
]=]

local MultiDropdown = {}
MultiDropdown.__index = MultiDropdown

function MultiDropdown.new(config, parent, Theme, Animation, Utility, Assets)
    local self = setmetatable({}, MultiDropdown)
    
    self.Config = config
    self.Values = config.Values or {}
    self.Selected = {}
    if config.Default and type(config.Default) == "table" then
        for _, item in ipairs(config.Default) do
            self.Selected[item] = true
        end
    end
    
    self.Callback = config.Callback or function() end
    self.IsOpen = false
    self.OptionButtons = {}
    
    local card = Utility.Create("Frame", {
        Name = "MultiDropdown_" .. (config.Title or "Item"),
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
    
    local colLayout = Utility.Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Vertical,
        Padding = UDim.new(0, 8),
        Parent = card,
    })
    
    -- Main Row
    local mainRow = Utility.Create("Frame", {
        Name = "MainRow",
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Parent = card,
    })
    
    local mainLayout = Utility.Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        HorizontalAlignment = Enum.HorizontalAlignment.SpaceBetween,
        Parent = mainRow,
    })
    
    local textContainer = Utility.Create("Frame", {
        Name = "TextContainer",
        Size = UDim2.new(1, -130, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Parent = mainRow,
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
        Text = config.Title or "Multi Dropdown",
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
    
    -- Selected count pill
    local selectBox = Utility.Create("Frame", {
        Name = "SelectBox",
        Size = UDim2.new(0, 115, 0, 26),
        BackgroundColor3 = Theme:Get("SurfaceSecondary"),
        BackgroundTransparency = 0.3,
        BorderSizePixel = 0,
        Parent = mainRow,
    })
    Utility.AddCorner(selectBox, 7)
    Utility.AddPadding(selectBox, 0, 0, 8, 8)
    Theme:Register(selectBox, { BackgroundColor3 = "SurfaceSecondary" })
    
    local function getSelectedCount()
        local c = 0
        for _, selected in pairs(self.Selected) do
            if selected then c = c + 1 end
        end
        return c
    end
    
    local selectedText = Utility.Create("TextLabel", {
        Name = "SelectedText",
        Size = UDim2.new(1, -20, 1, 0),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamMedium,
        Text = tostring(getSelectedCount()) .. " Selected",
        TextSize = 11,
        TextTruncate = Enum.TextTruncate.AtEnd,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextColor3 = Theme:Get("Text"),
        Parent = selectBox,
    })
    Theme:Register(selectedText, { TextColor3 = "Text" })
    
    local chevron = Utility.Create("TextLabel", {
        Name = "Chevron",
        Size = UDim2.new(0, 16, 0, 16),
        Position = UDim2.new(1, -16, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        Text = "▾",
        TextSize = 14,
        TextColor3 = Theme:Get("TextSecondary"),
        Parent = selectBox,
    })
    Theme:Register(chevron, { TextColor3 = "TextSecondary" })
    
    -- Options container
    local optionsList = Utility.Create("Frame", {
        Name = "OptionsList",
        Size = UDim2.new(1, 0, 0, 0),
        BackgroundTransparency = 1,
        ClipsDescendants = true,
        Visible = false,
        Parent = card,
    })
    
    local optionsLayout = Utility.Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Vertical,
        Padding = UDim.new(0, 4),
        Parent = optionsList,
    })
    
    local function getSelectedList()
        local list = {}
        for item, active in pairs(self.Selected) do
            if active then table.insert(list, item) end
        end
        return list
    end
    
    local function renderOptions()
        for _, btn in ipairs(self.OptionButtons) do
            btn:Destroy()
        end
        table_clear(self.OptionButtons)
        
        selectedText.Text = tostring(getSelectedCount()) .. " Selected"
        
        for _, val in ipairs(self.Values) do
            local isSelected = not not self.Selected[val]
            local optBtn = Utility.Create("TextButton", {
                Name = "Option_" .. tostring(val),
                Size = UDim2.new(1, 0, 0, 30),
                BackgroundColor3 = isSelected and Theme:Get("Accent") or Theme:Get("SurfaceSecondary"),
                BackgroundTransparency = isSelected and 0.25 or 0.6,
                Font = isSelected and Enum.Font.GothamBold or Enum.Font.GothamMedium,
                Text = (isSelected and "  ✓  " or "      ") .. tostring(val),
                TextSize = 12,
                TextColor3 = isSelected and Color3.fromRGB(255, 255, 255) or Theme:Get("Text"),
                TextXAlignment = Enum.TextXAlignment.Left,
                AutoButtonColor = false,
                Parent = optionsList,
            })
            Utility.AddCorner(optBtn, 6)
            
            local pressAnim = Animation.Press(optBtn, 1.0, 0.98)
            
            Utility.AddConnection(optBtn.MouseButton1Down:Connect(pressAnim.OnPress))
            Utility.AddConnection(optBtn.MouseButton1Up:Connect(pressAnim.OnRelease))
            Utility.AddConnection(optBtn.MouseButton1Click:Connect(function()
                if self.Selected[val] then
                    self.Selected[val] = nil
                else
                    self.Selected[val] = true
                end
                renderOptions()
                task.spawn(self.Callback, getSelectedList())
            end))
            
            table.insert(self.OptionButtons, optBtn)
        end
    end
    
    local function toggleOpen()
        self.IsOpen = not self.IsOpen
        if self.IsOpen then
            optionsList.Visible = true
            local targetHeight = #self.Values * 34
            Animation.Tween(optionsList, Animation.Presets.Fast, { Size = UDim2.new(1, 0, 0, targetHeight) })
            Animation.Tween(chevron, Animation.Presets.Fast, { Rotation = 180 })
        else
            local tween = Animation.Tween(optionsList, Animation.Presets.Fast, { Size = UDim2.new(1, 0, 0, 0) })
            Animation.Tween(chevron, Animation.Presets.Fast, { Rotation = 0 })
            if tween then
                tween.Completed:Connect(function()
                    if not self.IsOpen then
                        optionsList.Visible = false
                    end
                end)
            else
                optionsList.Visible = false
            end
        end
    end
    
    local triggerBtn = Utility.Create("TextButton", {
        Name = "TriggerOverlay",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "",
        Parent = selectBox,
    })
    Utility.AddConnection(triggerBtn.MouseButton1Click:Connect(toggleOpen))
    
    self.Card = card
    self.SelectedText = selectedText
    self.Chevron = chevron
    self.OptionsList = optionsList
    self.ToggleOpen = toggleOpen
    self.RenderOptions = renderOptions
    self.GetSelectedList = getSelectedList
    
    renderOptions()
    return self
end

function MultiDropdown:Set(selectedList)
    table_clear(self.Selected)
    if type(selectedList) == "table" then
        for _, v in ipairs(selectedList) do
            self.Selected[v] = true
        end
    end
    self.RenderOptions()
    task.spawn(self.Callback, self.GetSelectedList())
end

function MultiDropdown:Get()
    return self.GetSelectedList()
end

function MultiDropdown:Refresh(newValues)
    self.Values = newValues or {}
    for k in pairs(self.Selected) do
        if not table.find(self.Values, k) then
            self.Selected[k] = nil
        end
    end
    self.RenderOptions()
end

return MultiDropdown
