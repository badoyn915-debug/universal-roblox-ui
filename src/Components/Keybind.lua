--[=[
    Keybind Component
    Keyboard binding control with dynamic listening, visual key badge, and trigger execution.
]=]

local UserInputService = game and game:GetService("UserInputService")

local Keybind = {}
Keybind.__index = Keybind

function Keybind.new(config, parent, Theme, Animation, Utility, Assets)
    local self = setmetatable({}, Keybind)
    
    self.Config = config
    self.Key = config.Default or Enum.KeyCode.Unknown
    self.Callback = config.Callback or function() end
    self.Listening = false
    
    local card = Utility.Create("Frame", {
        Name = "Keybind_" .. (config.Title or "Item"),
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
    
    local textContainer = Utility.Create("Frame", {
        Name = "TextContainer",
        Size = UDim2.new(1, -90, 0, 0),
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
        Text = config.Title or "Keybind",
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
    
    local function getKeyName(key)
        if not key or key == Enum.KeyCode.Unknown then
            return "None"
        end
        if type(key) == "userdata" or type(key) == "table" then
            return key.Name or tostring(key)
        end
        return tostring(key)
    end
    
    -- Bind Badge Button
    local bindBtn = Utility.Create("TextButton", {
        Name = "BindButton",
        Size = UDim2.new(0, 75, 0, 26),
        BackgroundColor3 = Theme:Get("SurfaceSecondary"),
        BackgroundTransparency = 0.4,
        Font = Enum.Font.GothamBold,
        Text = "[" .. getKeyName(self.Key) .. "]",
        TextSize = 11,
        TextColor3 = Theme:Get("Text"),
        AutoButtonColor = false,
        Parent = row,
    })
    Utility.AddCorner(bindBtn, 6)
    Theme:Register(bindBtn, { BackgroundColor3 = "SurfaceSecondary", TextColor3 = "Text" })
    
    local function startListening()
        if self.Listening then return end
        self.Listening = true
        bindBtn.Text = "[ ... ]"
        Animation.Tween(bindBtn, Animation.Presets.Fast, { BackgroundColor3 = Theme:Get("Accent") })
        
        local inputConn
        inputConn = UserInputService.InputBegan:Connect(function(input, gameProcessed)
            if input.UserInputType == Enum.UserInputType.Keyboard then
                self.Listening = false
                if input.KeyCode == Enum.KeyCode.Escape then
                    self.Key = Enum.KeyCode.Unknown
                else
                    self.Key = input.KeyCode
                end
                
                bindBtn.Text = "[" .. getKeyName(self.Key) .. "]"
                Animation.Tween(bindBtn, Animation.Presets.Fast, { BackgroundColor3 = Theme:Get("SurfaceSecondary") })
                
                if inputConn then inputConn:Disconnect() end
            end
        end)
        Utility.AddConnection(inputConn)
    end
    
    Utility.AddConnection(bindBtn.MouseButton1Click:Connect(startListening))
    
    -- Global key listener to fire callback
    local triggerConn = UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed and not self.Listening and self.Key ~= Enum.KeyCode.Unknown then
            if input.KeyCode == self.Key then
                task.spawn(self.Callback, self.Key)
            end
        end
    end)
    Utility.AddConnection(triggerConn)
    
    self.Card = card
    self.BindBtn = bindBtn
    self.GetKeyName = getKeyName
    
    return self
end

function Keybind:Set(keyCode)
    self.Key = keyCode or Enum.KeyCode.Unknown
    self.BindBtn.Text = "[" .. self.GetKeyName(self.Key) .. "]"
end

function Keybind:Get()
    return self.Key
end

return Keybind
