--[=[
    Notifications System
    Floating toast notification system with progress bar, type styling, fluid slide/fade animations,
    and automatic cleanup.
]=]

local TweenService = game and game:GetService("TweenService")

local Notifications = {}
Notifications.__index = Notifications

function Notifications.new(guiParent, Theme, Animation, Utility, Assets)
    local self = setmetatable({}, Notifications)
    
    self.Theme = Theme
    self.Animation = Animation
    self.Utility = Utility
    self.Assets = Assets
    
    -- Dedicated container for notifications
    self.Container = Utility.Create("Frame", {
        Name = "NotificationContainer",
        Size = UDim2.new(0, 310, 1, -20),
        Position = UDim2.new(1, -320, 0, 10),
        BackgroundTransparency = 1,
        ClipsDescendants = false,
        Parent = guiParent,
    })
    
    local listLayout = Utility.Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Vertical,
        VerticalAlignment = Enum.VerticalAlignment.Bottom,
        HorizontalAlignment = Enum.HorizontalAlignment.Right,
        Padding = UDim.new(0, 10),
        Parent = self.Container,
    })
    
    return self
end

function Notifications:Notify(config)
    local title = config.Title or "Notification"
    local desc = config.Description or ""
    local duration = config.Duration or 3.5
    local nType = config.Type or "Info" -- Info, Success, Warning, Error
    
    local typeColors = {
        Info = self.Theme:Get("Info") or Color3.fromRGB(52, 152, 219),
        Success = self.Theme:Get("Success") or Color3.fromRGB(46, 213, 115),
        Warning = self.Theme:Get("Warning") or Color3.fromRGB(255, 171, 0),
        Error = self.Theme:Get("Error") or Color3.fromRGB(255, 71, 87),
    }
    
    local typeIcons = {
        Info = self.Assets.Info,
        Success = self.Assets.Success,
        Warning = self.Assets.Warning,
        Error = self.Assets.Error,
    }
    
    local accentColor = typeColors[nType] or self.Theme:Get("Accent")
    local iconId = config.Icon or typeIcons[nType] or self.Assets.Info
    
    local card = self.Utility.Create("CanvasGroup", {
        Name = "Toast_" .. nType,
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = self.Theme:Get("Surface"),
        BackgroundTransparency = 0.1,
        GroupTransparency = 1,
        Position = UDim2.new(1, 40, 0, 0),
        Parent = self.Container,
    })
    self.Utility.AddCorner(card, 12)
    self.Utility.AddStroke(card, self.Theme:Get("Border"), 1, 0.88)
    self.Utility.AddPadding(card, 12, 14, 14, 14)
    
    local mainRow = self.Utility.Create("Frame", {
        Name = "MainRow",
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Parent = card,
    })
    
    local rowLayout = self.Utility.Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        Padding = UDim.new(0, 10),
        Parent = mainRow,
    })
    
    -- Type badge or icon
    if iconId and iconId ~= "" then
        local iconImg = self.Utility.Create("ImageLabel", {
            Name = "Icon",
            Size = UDim2.new(0, 22, 0, 22),
            BackgroundTransparency = 1,
            Image = iconId,
            ImageColor3 = accentColor,
            Parent = mainRow,
        })
    else
        local badge = self.Utility.Create("Frame", {
            Name = "Badge",
            Size = UDim2.new(0, 8, 0, 22),
            BackgroundColor3 = accentColor,
            BorderSizePixel = 0,
            Parent = mainRow,
        })
        self.Utility.AddCorner(badge, 4)
    end
    
    local textContainer = self.Utility.Create("Frame", {
        Name = "TextContainer",
        Size = UDim2.new(1, -34, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Parent = mainRow,
    })
    
    local textLayout = self.Utility.Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Vertical,
        Padding = UDim.new(0, 2),
        Parent = textContainer,
    })
    
    local titleLabel = self.Utility.Create("TextLabel", {
        Name = "Title",
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        Text = title,
        TextSize = 13,
        TextColor3 = self.Theme:Get("Text"),
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = textContainer,
    })
    
    if desc and desc ~= "" then
        local descLabel = self.Utility.Create("TextLabel", {
            Name = "Description",
            Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            Font = Enum.Font.Gotham,
            Text = desc,
            TextSize = 11,
            TextTransparency = 0.4,
            TextColor3 = self.Theme:Get("TextSecondary"),
            TextXAlignment = Enum.TextXAlignment.Left,
            TextWrapped = true,
            Parent = textContainer,
        })
    end
    
    -- Progress Bar Track & Fill
    local progressTrack = self.Utility.Create("Frame", {
        Name = "ProgressTrack",
        Size = UDim2.new(1, 0, 0, 3),
        Position = UDim2.new(0, 0, 1, 10),
        BackgroundColor3 = self.Theme:Get("SurfaceSecondary"),
        BorderSizePixel = 0,
        Parent = card,
    })
    self.Utility.AddCorner(progressTrack, 2)
    
    local progressFill = self.Utility.Create("Frame", {
        Name = "ProgressFill",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = accentColor,
        BorderSizePixel = 0,
        Parent = progressTrack,
    })
    self.Utility.AddCorner(progressFill, 2)
    
    -- Animate In
    self.Animation.Tween(card, self.Animation.Presets.Spring, {
        GroupTransparency = 0,
        Position = UDim2.new(0, 0, 0, 0)
    })
    
    -- Animate Progress Bar
    if TweenService then
        local progressTween = TweenService:Create(progressFill, TweenInfo.new(duration, Enum.EasingStyle.Linear), {
            Size = UDim2.new(0, 0, 1, 0)
        })
        progressTween:Play()
    end
    
    local dismissed = false
    local function dismiss()
        if dismissed then return end
        dismissed = true
        
        local outTween = self.Animation.Tween(card, self.Animation.Presets.Fast, {
            GroupTransparency = 1,
            Position = UDim2.new(1, 40, 0, 0)
        })
        if outTween then
            outTween.Completed:Connect(function()
                card:Destroy()
            end)
        else
            card:Destroy()
        end
    end
    
    local clickBtn = self.Utility.Create("TextButton", {
        Name = "DismissClick",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "",
        Parent = card,
    })
    self.Utility.AddConnection(clickBtn.MouseButton1Click:Connect(dismiss))
    
    task.delay(duration, dismiss)
end

function Notifications:Destroy()
    if self.Container then
        self.Container:Destroy()
    end
end

return Notifications
