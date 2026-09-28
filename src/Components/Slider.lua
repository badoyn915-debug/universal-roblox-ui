local math_clamp = math.clamp or function(v, min, max) return math.max(min, math.min(max, v)) end
--[=[
    Slider Component
    Precision slider with mouse and touch dragging, step increments, fill bar, and live value badge.
]=]

local UserInputService = game and game:GetService("UserInputService")

local Slider = {}
Slider.__index = Slider

function Slider.new(config, parent, Theme, Animation, Utility, Assets)
    local self = setmetatable({}, Slider)
    
    self.Config = config
    self.Min = config.Min or 0
    self.Max = config.Max or 100
    self.Increment = config.Increment or 1
    self.Value = config.Default or self.Min
    self.Callback = config.Callback or function() end
    
    local card = Utility.Create("Frame", {
        Name = "Slider_" .. (config.Title or "Item"),
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
    
    -- Header Row: Title & Value display
    local headerRow = Utility.Create("Frame", {
        Name = "HeaderRow",
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Parent = card,
    })
    
    local headerLayout = Utility.Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        HorizontalAlignment = Enum.HorizontalAlignment.SpaceBetween,
        Parent = headerRow,
    })
    
    local leftContainer = Utility.Create("Frame", {
        Name = "LeftContainer",
        Size = UDim2.new(1, -60, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Parent = headerRow,
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
    
    local textContainer = Utility.Create("Frame", {
        Name = "TextContainer",
        Size = UDim2.new(1, (iconId and iconId ~= "") and -28 or 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Parent = leftContainer,
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
        Text = config.Title or "Slider",
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
    
    -- Value badge
    local valueBadge = Utility.Create("TextLabel", {
        Name = "ValueBadge",
        Size = UDim2.new(0, 50, 0, 20),
        BackgroundColor3 = Theme:Get("SurfaceSecondary"),
        BackgroundTransparency = 0.4,
        Font = Enum.Font.GothamBold,
        Text = tostring(self.Value),
        TextSize = 11,
        TextColor3 = Theme:Get("Accent"),
        Parent = headerRow,
    })
    Utility.AddCorner(valueBadge, 6)
    Theme:Register(valueBadge, { BackgroundColor3 = "SurfaceSecondary", TextColor3 = "Accent" })
    
    -- Slider Track Frame (touch friendly hit target)
    local hitArea = Utility.Create("Frame", {
        Name = "HitArea",
        Size = UDim2.new(1, 0, 0, 24),
        BackgroundTransparency = 1,
        Parent = card,
    })
    
    local track = Utility.Create("Frame", {
        Name = "Track",
        Size = UDim2.new(1, 0, 0, 6),
        Position = UDim2.new(0, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = Theme:Get("SurfaceSecondary"),
        BorderSizePixel = 0,
        Parent = hitArea,
    })
    Utility.AddCorner(track, 3)
    Theme:Register(track, { BackgroundColor3 = "SurfaceSecondary" })
    
    local initialRatio = math_clamp((self.Value - self.Min) / (self.Max - self.Min), 0, 1)
    
    local fillBar = Utility.Create("Frame", {
        Name = "FillBar",
        Size = UDim2.new(initialRatio, 0, 1, 0),
        BackgroundColor3 = Theme:Get("Accent"),
        BorderSizePixel = 0,
        Parent = track,
    })
    Utility.AddCorner(fillBar, 3)
    Theme:Register(fillBar, { BackgroundColor3 = "Accent" })
    
    local knob = Utility.Create("Frame", {
        Name = "Knob",
        Size = UDim2.new(0, 14, 0, 14),
        Position = UDim2.new(initialRatio, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BorderSizePixel = 0,
        Parent = track,
    })
    Utility.AddCorner(knob, 7)
    
    local dragging = false
    
    local function snap(val)
        local stepped = math.floor((val - self.Min) / self.Increment + 0.5) * self.Increment + self.Min
        return math_clamp(stepped, self.Min, self.Max)
    end
    
    local function updateFromInput(inputX, animate)
        local trackWidth = track.AbsoluteSize.X
        if trackWidth <= 0 then return end
        
        local relX = inputX - track.AbsolutePosition.X
        local ratio = math_clamp(relX / trackWidth, 0, 1)
        local rawVal = self.Min + ratio * (self.Max - self.Min)
        local finalVal = snap(rawVal)
        
        -- Round decimal places according to increment
        local decimalPlaces = 0
        local incStr = tostring(self.Increment)
        if incStr:find("%.") then
            decimalPlaces = #incStr - incStr:find("%.")
        end
        finalVal = Utility.Round(finalVal, decimalPlaces)
        
        self.Value = finalVal
        valueBadge.Text = tostring(finalVal)
        
        local finalRatio = math_clamp((finalVal - self.Min) / (self.Max - self.Min), 0, 1)
        
        if animate then
            Animation.Tween(fillBar, Animation.Presets.Fast, { Size = UDim2.new(finalRatio, 0, 1, 0) })
            Animation.Tween(knob, Animation.Presets.Fast, { Position = UDim2.new(finalRatio, 0, 0.5, 0) })
        else
            fillBar.Size = UDim2.new(finalRatio, 0, 1, 0)
            knob.Position = UDim2.new(finalRatio, 0, 0.5, 0)
        end
        
        task.spawn(self.Callback, self.Value)
    end
    
    local function startDrag(input)
        dragging = true
        Animation.Tween(knob, Animation.Presets.Fast, { Size = UDim2.new(0, 18, 0, 18) })
        updateFromInput(input.Position.X, false)
        
        local moveConn
        local endConn
        
        moveConn = UserInputService.InputChanged:Connect(function(moveInput)
            if dragging and (moveInput.UserInputType == Enum.UserInputType.MouseMovement or moveInput.UserInputType == Enum.UserInputType.Touch) then
                updateFromInput(moveInput.Position.X, false)
            end
        end)
        
        endConn = UserInputService.InputEnded:Connect(function(endInput)
            if endInput.UserInputType == Enum.UserInputType.MouseButton1 or endInput.UserInputType == Enum.UserInputType.Touch then
                dragging = false
                Animation.Tween(knob, Animation.Presets.Fast, { Size = UDim2.new(0, 14, 0, 14) })
                if moveConn then moveConn:Disconnect() end
                if endConn then endConn:Disconnect() end
            end
        end)
        
        Utility.AddConnection(moveConn)
        Utility.AddConnection(endConn)
    end
    
    Utility.AddConnection(hitArea.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            startDrag(input)
        end
    end))
    
    self.Card = card
    self.FillBar = fillBar
    self.Knob = knob
    self.ValueBadge = valueBadge
    self.Snap = snap
    
    return self
end

function Slider:Set(value)
    local stepped = self.Snap(value)
    self.Value = stepped
    self.ValueBadge.Text = tostring(stepped)
    local ratio = math_clamp((stepped - self.Min) / (self.Max - self.Min), 0, 1)
    self.FillBar.Size = UDim2.new(ratio, 0, 1, 0)
    self.Knob.Position = UDim2.new(ratio, 0, 0.5, 0)
    task.spawn(self.Callback, self.Value)
end

function Slider:Get()
    return self.Value
end

return Slider
