--[=[
    Asset Configuration
    Configured with high-definition transparent vector glyphs (Lucide icon pack)
    and user custom logo support with automatic executor asset resolution.
]=]

local getcustomasset = getcustomasset or getsynasset
local isfile = isfile or function() return false end
local writefile = writefile or function() end

local function resolveAsset(pathOrUrl)
    if not pathOrUrl or pathOrUrl == "" then return "" end
    if pathOrUrl:sub(1, 13) == "rbxassetid://" or pathOrUrl:sub(1, 10) == "rbxasset://" then
        return pathOrUrl
    end
    if getcustomasset and (pathOrUrl:sub(1, 7) == "http://" or pathOrUrl:sub(1, 8) == "https://") then
        local filename = "universal_ui_logo.png"
        if not isfile(filename) and writefile and game and game.HttpGet then
            pcall(function()
                writefile(filename, game:HttpGet(pathOrUrl))
            end)
        end
        if isfile(filename) then
            local success, asset = pcall(getcustomasset, filename)
            if success and asset then return asset end
        end
    end
    return pathOrUrl
end

local Assets = {
    -- User Custom Logo (placed in assets/logo.png)
    Logo = "https://raw.githubusercontent.com/badoyn915-debug/universal-roblox-ui/main/assets/logo.png",
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
    
    -- Helpers
    Resolve = resolveAsset,
}

return Assets
