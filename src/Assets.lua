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
    if (getcustomasset or getsynasset) and (pathOrUrl:sub(1, 7) == "http://" or pathOrUrl:sub(1, 8) == "https://") then
        local gca = getcustomasset or getsynasset
        local filename = "universal_ui_logo.png"
        if not isfile(filename) and writefile and game and game.HttpGet then
            pcall(function()
                writefile(filename, game:HttpGet(pathOrUrl))
            end)
        end
        if isfile(filename) then
            local success, asset = pcall(gca, filename)
            if success and asset then return asset end
        end
    end
    -- Fallback to high-quality vector asset if http URL cannot be converted by executor
    if pathOrUrl:sub(1, 4) == "http" then
        return "rbxassetid://10709789710"
    end
    return pathOrUrl
end

local Assets = {
    -- User Custom Logo (placed in assets/logo.png)
    Logo = resolveAsset("https://raw.githubusercontent.com/badoyn915-debug/universal-roblox-ui/main/assets/logo.png"),
    MainIcon = "rbxassetid://10709789710", -- Layers glyph
    Settings = "rbxassetid://10734950309", -- Gear / settings
    
    -- Category & Tab Icons
    Combat = "rbxassetid://10709791523",
    Visuals = "rbxassetid://10723345518",
    Eye = "rbxassetid://10723345518",
    Movement = "rbxassetid://10747373176",
    User = "rbxassetid://10747373176",
    Home = "rbxassetid://10723415903",
    Sliders = "rbxassetid://10734950020",
    Target = "rbxassetid://10723343537",
    Crosshair = "rbxassetid://10723343537",
    Zap = "rbxassetid://10709810948",
    Lightning = "rbxassetid://10709810948",
    Shield = "rbxassetid://10734951847",
    Palette = "rbxassetid://10723346959",
    Keyboard = "rbxassetid://10723346158",
    Key = "rbxassetid://10723346158",
    Click = "rbxassetid://10723416496",
    Cursor = "rbxassetid://10723416496",
    Sparkles = "rbxassetid://10709782497",
    Layers = "rbxassetid://10709789710",
    Folder = "rbxassetid://10723346416",
    Terminal = "rbxassetid://10734952815",
    Tool = "rbxassetid://10734953683",
    
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
