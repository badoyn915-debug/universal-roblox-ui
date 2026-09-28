--[=[
    Asset Configuration
    Configured with high-definition transparent vector glyphs (Lucide icon pack).
    All icons have transparent backgrounds and match the frosted glass theme via ImageColor3 tinting.
    User's custom Logo slot is preserved and prioritized.
]=]

local Assets = {
    -- User Custom Logo (can be overridden by user)
    Logo = "rbxassetid://10709782497", -- Modern sparkle / star glyph fallback
    MainIcon = "rbxassetid://10709789710", -- Layers glyph
    Settings = "rbxassetid://10734950309", -- Gear / settings
    
    -- Window Controls
    Close = "rbxassetid://10747384394", -- Cross / Close
    Minimize = "rbxassetid://10734896206", -- Minus / Minimize
    Maximize = "rbxassetid://10734895916", -- Square / Maximize
    
    -- Navigation & Indicators
    ChevronDown = "rbxassetid://10709790948",
    ChevronRight = "rbxassetid://10709791437",
    Check = "rbxassetid://10709790644",
    Search = "rbxassetid://10734943674",
    
    -- Notifications
    Info = "rbxassetid://10723415903",
    Success = "rbxassetid://10709790537",
    Warning = "rbxassetid://10709752996",
    Error = "rbxassetid://10709752835",
    
    -- Interactive Components
    ColorPicker = "rbxassetid://10723346959", -- Palette
    SliderKnob = "",
    DragHandle = "rbxassetid://10723374276", -- Grip vertical
}

return Assets
