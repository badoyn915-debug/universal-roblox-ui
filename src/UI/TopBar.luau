--[=[
    TopBar UI Component
    Displays Title, Subtitle, Icon, Minimize and Close buttons.
]=]

local TopBar = {}
TopBar.__index = TopBar

function TopBar.new(config, Theme, Animation, Utility, Assets)
    local frame = Utility.Create("Frame", {
        Name = "TopBar",
        Size = UDim2.new(1, 0, 0, 48),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
    })
    
    local padding = Utility.AddPadding(frame, 0, 0, 16, 16)
    
    -- Left info container
    local leftContainer = Utility.Create("Frame", {
        Name = "LeftContainer",
        Size = UDim2.new(1, -100, 1, 0),
        BackgroundTransparency = 1,
        Parent = frame,
    })
    
    local leftLayout = Utility.Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        Padding = UDim.new(0, 10),
        Parent = leftContainer,
    })
    
    -- Icon (if provided or present in config/Assets)
    local iconId = config.Icon or Assets.Logo or Assets.MainIcon
    local iconImage = nil
    if iconId and iconId ~= "" then
        iconImage = Utility.Create("ImageLabel", {
            Name = "WindowIcon",
            Size = UDim2.new(0, 24, 0, 24),
            BackgroundTransparency = 1,
            Image = iconId,
            ScaleType = Enum.ScaleType.Fit,
            Parent = leftContainer,
        })
    end
    
    -- Titles container
    local titlesContainer = Utility.Create("Frame", {
        Name = "TitlesContainer",
        Size = UDim2.new(1, -34, 1, 0),
        BackgroundTransparency = 1,
        Parent = leftContainer,
    })
    
    local titleLayout = Utility.Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Vertical,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        Padding = UDim.new(0, 2),
        Parent = titlesContainer,
    })
    
    local titleLabel = Utility.Create("TextLabel", {
        Name = "Title",
        Size = UDim2.new(1, 0, 0, 18),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        Text = config.Title or "Universal UI",
        TextSize = 15,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextColor3 = Theme:Get("Text"),
        Parent = titlesContainer,
    })
    Theme:Register(titleLabel, { TextColor3 = "Text" })
    
    local subtitleLabel = Utility.Create("TextLabel", {
        Name = "Subtitle",
        Size = UDim2.new(1, 0, 0, 13),
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham,
        Text = config.Subtitle or "Modern Interface",
        TextSize = 11,
        TextTransparency = 0.4,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextColor3 = Theme:Get("TextSecondary"),
        Parent = titlesContainer,
    })
    Theme:Register(subtitleLabel, { TextColor3 = "TextSecondary" })
    
    -- Right controls container (Minimize, Close)
    local controlsContainer = Utility.Create("Frame", {
        Name = "ControlsContainer",
        Size = UDim2.new(0, 70, 1, 0),
        Position = UDim2.new(1, -70, 0, 0),
        BackgroundTransparency = 1,
        Parent = frame,
    })
    
    local controlsLayout = Utility.Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Right,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        Padding = UDim.new(0, 8),
        Parent = controlsContainer,
    })
    
    local function createControlButton(name, text, iconId, onClick)
        local btn = Utility.Create("TextButton", {
            Name = name,
            Size = UDim2.new(0, 28, 0, 28),
            BackgroundColor3 = Theme:Get("SurfaceSecondary"),
            BackgroundTransparency = 0.5,
            Font = Enum.Font.GothamBold,
            Text = (not iconId or iconId == "") and text or "",
            TextColor3 = Theme:Get("Text"),
            TextSize = 13,
            AutoButtonColor = false,
            Parent = controlsContainer,
        })
        Utility.AddCorner(btn, 8)
        Theme:Register(btn, { BackgroundColor3 = "SurfaceSecondary", TextColor3 = "Text" })
        
        if iconId and iconId ~= "" then
            local img = Utility.Create("ImageLabel", {
                Name = "Icon",
                Size = UDim2.new(0, 14, 0, 14),
                Position = UDim2.new(0.5, 0, 0.5, 0),
                AnchorPoint = Vector2.new(0.5, 0.5),
                BackgroundTransparency = 1,
                Image = iconId,
                ImageColor3 = Theme:Get("Text"),
                Parent = btn,
            })
            Theme:Register(img, { ImageColor3 = "Text" })
        end
        
        local pressAnim = Animation.Press(btn, 1.0, 0.92)
        local hoverIn = function()
            Animation.Tween(btn, Animation.Presets.Fast, { BackgroundTransparency = 0.2 })
        end
        local hoverOut = function()
            Animation.Tween(btn, Animation.Presets.Fast, { BackgroundTransparency = 0.5 })
        end
        
        Utility.AddConnection(btn.MouseEnter:Connect(hoverIn))
        Utility.AddConnection(btn.MouseLeave:Connect(hoverOut))
        Utility.AddConnection(btn.MouseButton1Down:Connect(pressAnim.OnPress))
        Utility.AddConnection(btn.MouseButton1Up:Connect(pressAnim.OnRelease))
        Utility.AddConnection(btn.MouseButton1Click:Connect(onClick))
        
        return btn
    end
    
    local minBtn = createControlButton("MinimizeBtn", "−", Assets and Assets.Minimize, function()
        if config.OnMinimize then
            config.OnMinimize()
        end
    end)
    
    local closeBtn = createControlButton("CloseBtn", "×", Assets and Assets.Close, function()
        if config.OnClose then
            config.OnClose()
        end
    end)
    
    return {
        Frame = frame,
        TitleLabel = titleLabel,
        SubtitleLabel = subtitleLabel,
        IconImage = iconImage,
        MinimizeButton = minBtn,
        CloseButton = closeBtn,
    }
end

return TopBar
