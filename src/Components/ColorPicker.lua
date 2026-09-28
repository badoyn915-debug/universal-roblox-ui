local math_clamp = math.clamp or function(v, min, max) return math.max(min, math.min(max, v)) end
--[=[
    ColorPicker Component
    Interactive color selector with preview swatch, RGB tuning sliders, and fluid collapsible panel.
]=]

local UserInputService = game and game:GetService("UserInputService")

local ColorPicker = {}
ColorPicker.__index = ColorPicker

function ColorPicker.new(config, parent, Theme, Animation, Utility, Assets)
    local self = setmetatable({}, ColorPicker)
    
    self.Config = config
    self.Color = config.Default or Color3.fromRGB(88, 101, 242)
    self.Callback = config.Callback or function() end
    self.IsOpen = false
    
    local r = math.floor(self.Color.R * 255 + 0.5)
    local g = math.floor(self.Color.G * 255 + 0.5)
    local b = math.floor(self.Color.B * 255 + 0.5)
    
    local card = Utility.Create("Frame", {
        Name = "ColorPicker_" .. (config.Title or "Item"),
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
        Padding = UDim.new(0, 10),
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
        Size = UDim2.new(1, -60, 0, 0),
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
        Text = config.Title or "Color Picker",
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
    
    -- Swatch Preview Box
    local swatch = Utility.Create("TextButton", {
        Name = "Swatch",
        Size = UDim2.new(0, 36, 0, 24),
        BackgroundColor3 = self.Color,
        BorderSizePixel = 0,
        AutoButtonColor = false,
        Text = "",
        Parent = mainRow,
    })
    Utility.AddCorner(swatch, 6)
    Utility.AddStroke(swatch, Theme:Get("Border"), 1, 0.7)
    
    -- Expanded Controls Panel
    local panel = Utility.Create("Frame", {
        Name = "Panel",
        Size = UDim2.new(1, 0, 0, 0),
        BackgroundTransparency = 1,
        ClipsDescendants = true,
        Visible = false,
        Parent = card,
    })
    
    local panelLayout = Utility.Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Vertical,
        Padding = UDim.new(0, 8),
        Parent = panel,
    })
    
    local function createChannelSlider(channelName, channelColor, initialVal, onValChange)
        local cRow = Utility.Create("Frame", {
            Name = channelName .. "Row",
            Size = UDim2.new(1, 0, 0, 22),
            BackgroundTransparency = 1,
            Parent = panel,
        })
        
        local cLabel = Utility.Create("TextLabel", {
            Name = "Label",
            Size = UDim2.new(0, 20, 1, 0),
            BackgroundTransparency = 1,
            Font = Enum.Font.GothamBold,
            Text = channelName,
            TextSize = 11,
            TextColor3 = channelColor,
            Parent = cRow,
        })
        
        local track = Utility.Create("Frame", {
            Name = "Track",
            Size = UDim2.new(1, -64, 0, 6),
            Position = UDim2.new(0, 24, 0.5, 0),
            AnchorPoint = Vector2.new(0, 0.5),
            BackgroundColor3 = Theme:Get("SurfaceSecondary"),
            BorderSizePixel = 0,
            Parent = cRow,
        })
        Utility.AddCorner(track, 3)
        
        local fill = Utility.Create("Frame", {
            Name = "Fill",
            Size = UDim2.new(initialVal / 255, 0, 1, 0),
            BackgroundColor3 = channelColor,
            BorderSizePixel = 0,
            Parent = track,
        })
        Utility.AddCorner(fill, 3)
        
        local vLabel = Utility.Create("TextLabel", {
            Name = "Val",
            Size = UDim2.new(0, 32, 1, 0),
            Position = UDim2.new(1, -32, 0, 0),
            BackgroundTransparency = 1,
            Font = Enum.Font.GothamMedium,
            Text = tostring(initialVal),
            TextSize = 11,
            TextColor3 = Theme:Get("TextSecondary"),
            Parent = cRow,
        })
        
        local dragging = false
        local function update(inputX)
            local w = track.AbsoluteSize.X
            if w <= 0 then return end
            local ratio = math_clamp((inputX - track.AbsolutePosition.X) / w, 0, 1)
            local val = math.floor(ratio * 255 + 0.5)
            fill.Size = UDim2.new(ratio, 0, 1, 0)
            vLabel.Text = tostring(val)
            onValChange(val)
        end
        
        Utility.AddConnection(cRow.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                update(input.Position.X)
                
                local moveConn, endConn
                moveConn = UserInputService.InputChanged:Connect(function(mInput)
                    if dragging and (mInput.UserInputType == Enum.UserInputType.MouseMovement or mInput.UserInputType == Enum.UserInputType.Touch) then
                        update(mInput.Position.X)
                    end
                end)
                endConn = UserInputService.InputEnded:Connect(function(eInput)
                    if eInput.UserInputType == Enum.UserInputType.MouseButton1 or eInput.UserInputType == Enum.UserInputType.Touch then
                        dragging = false
                        if moveConn then moveConn:Disconnect() end
                        if endConn then endConn:Disconnect() end
                    end
                end)
                Utility.AddConnection(moveConn)
                Utility.AddConnection(endConn)
            end
        end))
        
        return {
            Set = function(val)
                val = math_clamp(val, 0, 255)
                fill.Size = UDim2.new(val / 255, 0, 1, 0)
                vLabel.Text = tostring(val)
            end
        }
    end
    
    local function applyColor()
        self.Color = Color3.fromRGB(r, g, b)
        swatch.BackgroundColor3 = self.Color
        task.spawn(self.Callback, self.Color)
    end
    
    local redSlider = createChannelSlider("R", Color3.fromRGB(255, 80, 80), r, function(val)
        r = val
        applyColor()
    end)
    
    local greenSlider = createChannelSlider("G", Color3.fromRGB(80, 230, 120), g, function(val)
        g = val
        applyColor()
    end)
    
    local blueSlider = createChannelSlider("B", Color3.fromRGB(80, 150, 255), b, function(val)
        b = val
        applyColor()
    end)
    
    local function togglePanel()
        self.IsOpen = not self.IsOpen
        if self.IsOpen then
            panel.Visible = true
            Animation.Tween(panel, Animation.Presets.Fast, { Size = UDim2.new(1, 0, 0, 90) })
        else
            local tween = Animation.Tween(panel, Animation.Presets.Fast, { Size = UDim2.new(1, 0, 0, 0) })
            if tween then
                tween.Completed:Connect(function()
                    if not self.IsOpen then
                        panel.Visible = false
                    end
                end)
            else
                panel.Visible = false
            end
        end
    end
    
    Utility.AddConnection(swatch.MouseButton1Click:Connect(togglePanel))
    
    self.Card = card
    self.Swatch = swatch
    self.Panel = panel
    self.RedSlider = redSlider
    self.GreenSlider = greenSlider
    self.BlueSlider = blueSlider
    
    return self
end

function ColorPicker:Set(color3)
    self.Color = color3 or Color3.fromRGB(255, 255, 255)
    local r = math.floor(self.Color.R * 255 + 0.5)
    local g = math.floor(self.Color.G * 255 + 0.5)
    local b = math.floor(self.Color.B * 255 + 0.5)
    self.Swatch.BackgroundColor3 = self.Color
    self.RedSlider.Set(r)
    self.GreenSlider.Set(g)
    self.BlueSlider.Set(b)
    task.spawn(self.Callback, self.Color)
end

function ColorPicker:Get()
    return self.Color
end

return ColorPicker
