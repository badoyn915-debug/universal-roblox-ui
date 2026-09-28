--[=[
    Universal UI - Loader
    Public loader for initializing and launching the Universal UI Library.
]=]

print("==================================================")
print("[UniversalUI] Initializing Universal Roblox UI...")
print("[UniversalUI] Version: 1.0.0 | GitHub: badoyn915-debug/universal-roblox-ui")
print("[UniversalUI] Downloading bundle from GitHub raw...")

local GITHUB_URL = "https://raw.githubusercontent.com/badoyn915-debug/universal-roblox-ui/main/dist/bundle.lua"

local success, source = pcall(function()
    return game:HttpGet(GITHUB_URL, true)
end)

if not success or not source or #source == 0 then
    local errMessage = "[UniversalUI] ERROR: Failed to download library from GitHub: " .. tostring(source)
    warn(errMessage)
    error(errMessage)
end

print("[UniversalUI] Bundle downloaded successfully (" .. tostring(#source) .. " bytes). Compiling...")

local loadedFn, compileErr = loadstring(source, "UniversalUI")
if not loadedFn then
    local errMessage = "[UniversalUI] ERROR: Compilation error: " .. tostring(compileErr)
    warn(errMessage)
    error(errMessage)
end

local Library = loadedFn()

if getgenv then
    getgenv().UniversalUI = Library
end
_G.UniversalUI = Library

print("[UniversalUI] Library successfully compiled and initialized!")
print("[UniversalUI] Creating UI Window...")

-- Create and display the showcase UI window
local Window = Library:CreateWindow({
    Title = "Universal UI",
    Subtitle = "Premium Mobile Glassmorphic Interface",
    Icon = "Logo",
})

-- ==================== TAB 1: MAIN ====================
local MainTab = Window:AddTab({
    Title = "Main",
    Description = "Character & movement controls",
    Icon = "Movement",
})

local MovementSection = MainTab:AddSection({
    Title = "Character Movement",
    Description = "Precision sliders & toggles for player movement",
})

MovementSection:AddSlider({
    Title = "Walkspeed Multiplier",
    Description = "Adjust character movement velocity",
    Min = 16,
    Max = 250,
    Default = 32,
    Increment = 1,
    Icon = "Sliders",
    Callback = function(value)
        print("[UniversalUI] Walkspeed set to:", value)
    end
})

MovementSection:AddSlider({
    Title = "Jump Power",
    Description = "Configure jump height multiplier",
    Min = 50,
    Max = 350,
    Default = 50,
    Increment = 5,
    Icon = "Sliders",
    Callback = function(value)
        print("[UniversalUI] Jump power set to:", value)
    end
})

MovementSection:AddSlider({
    Title = "World Gravity",
    Description = "Adjust physics gravity force",
    Min = 0,
    Max = 196,
    Default = 196,
    Increment = 2,
    Icon = "Sliders",
    Callback = function(value)
        print("[UniversalUI] Gravity set to:", value)
    end
})

MovementSection:AddToggle({
    Title = "Speed Boost",
    Description = "Quickly toggles movement acceleration",
    Default = true,
    Icon = "Zap",
    Callback = function(value)
        print("[UniversalUI] Speed Boost:", value)
    end
})

MovementSection:AddToggle({
    Title = "Infinite Jump",
    Description = "Allows jumping repeatedly in mid-air",
    Default = false,
    Icon = "Check",
    Callback = function(value)
        print("[UniversalUI] Infinite Jump:", value)
    end
})

MovementSection:AddToggle({
    Title = "Noclip Mode",
    Description = "Disables character collision with walls",
    Default = false,
    Icon = "Shield",
    Callback = function(value)
        print("[UniversalUI] Noclip:", value)
    end
})

local ActionSection = MainTab:AddSection({
    Title = "Quick Actions",
    Description = "Instant teleportation & character commands",
})

ActionSection:AddButton({
    Title = "Teleport to Spawn",
    Description = "Instantly returns character to origin spawn",
    Icon = "Click",
    Callback = function()
        Library:Notify({
            Title = "Teleport",
            Description = "Character teleported to spawn point",
            Type = "Success",
            Duration = 3,
        })
    end
})

ActionSection:AddButton({
    Title = "Emergency Reset",
    Description = "Resets character state and reloads position",
    Icon = "Close",
    Callback = function()
        Library:Notify({
            Title = "Reset",
            Description = "Character state reset triggered",
            Type = "Warning",
            Duration = 3,
        })
    end
})

-- ==================== TAB 2: VISUALS ====================
local VisualsTab = Window:AddTab({
    Title = "Visuals",
    Description = "ESP & wallhack options",
    Icon = "Eye",
})

local ESPSection = VisualsTab:AddSection({
    Title = "ESP Configuration",
    Description = "Target detection, overlays, and tracer lines",
})

ESPSection:AddToggle({
    Title = "Master ESP",
    Description = "Master switch for all visual overlays",
    Default = true,
    Icon = "Eye",
    Callback = function(value)
        print("[UniversalUI] Master ESP:", value)
    end
})

ESPSection:AddToggle({
    Title = "Player Boxes",
    Description = "Draws 2D bounding boxes around targets",
    Default = true,
    Icon = "Check",
    Callback = function(value)
        print("[UniversalUI] Player Boxes:", value)
    end
})

ESPSection:AddToggle({
    Title = "Tracer Lines",
    Description = "Renders direction snaplines to players",
    Default = false,
    Icon = "Lightning",
    Callback = function(value)
        print("[UniversalUI] Tracer Lines:", value)
    end
})

ESPSection:AddToggle({
    Title = "Chams Glow",
    Description = "Highlights player models through barriers",
    Default = true,
    Icon = "Sparkles",
    Callback = function(value)
        print("[UniversalUI] Chams Glow:", value)
    end
})

ESPSection:AddDropdown({
    Title = "Box Style",
    Description = "Select outline geometry",
    Values = {"Corner 2D", "Full Box 2D", "Bounding 3D"},
    Default = "Corner 2D",
    Icon = "Sliders",
    Callback = function(value)
        print("[UniversalUI] Box Style:", value)
    end
})

ESPSection:AddMultiDropdown({
    Title = "Target Filters",
    Description = "Select entities to include in visual scan",
    Values = {"Enemies", "Teammates", "NPCs", "Items", "Vehicles"},
    Default = {"Enemies", "NPCs"},
    Icon = "Target",
    Callback = function(selected)
        print("[UniversalUI] ESP Target count:", #selected)
    end
})

ESPSection:AddSlider({
    Title = "Max Render Distance",
    Description = "Maximum distance in studs for visual detection",
    Min = 100,
    Max = 5000,
    Default = 2000,
    Increment = 50,
    Icon = "Sliders",
    Callback = function(value)
        print("[UniversalUI] Max distance:", value)
    end
})

ESPSection:AddColorPicker({
    Title = "Enemy Highlight Color",
    Description = "Color used for enemy silhouettes",
    Default = Color3.fromRGB(255, 75, 75),
    Icon = "Palette",
    Callback = function(color)
        print("[UniversalUI] Enemy color updated")
    end
})

-- ==================== TAB 3: COMBAT ====================
local CombatTab = Window:AddTab({
    Title = "Combat",
    Description = "Aimbot & targeting tuning",
    Icon = "Combat",
})

local AimbotSection = CombatTab:AddSection({
    Title = "Aimbot Parameters",
    Description = "Automatic aiming and field of view calibration",
})

AimbotSection:AddToggle({
    Title = "Enable Aimbot",
    Description = "Locks camera onto prioritized targets",
    Default = false,
    Icon = "Target",
    Callback = function(value)
        print("[UniversalUI] Aimbot active:", value)
    end
})

AimbotSection:AddToggle({
    Title = "Show FOV Circle",
    Description = "Draws targeting radius circle on screen",
    Default = true,
    Icon = "Crosshair",
    Callback = function(value)
        print("[UniversalUI] FOV Circle:", value)
    end
})

AimbotSection:AddSlider({
    Title = "FOV Radius",
    Description = "Radius of aim acquisition zone",
    Min = 30,
    Max = 600,
    Default = 140,
    Increment = 5,
    Icon = "Sliders",
    Callback = function(value)
        print("[UniversalUI] FOV Radius:", value)
    end
})

AimbotSection:AddSlider({
    Title = "Smoothness Factor",
    Description = "Aim interpolation smoothness (lower is faster)",
    Min = 1,
    Max = 25,
    Default = 6,
    Increment = 1,
    Icon = "Sliders",
    Callback = function(value)
        print("[UniversalUI] Smoothness:", value)
    end
})

AimbotSection:AddDropdown({
    Title = "Target Bone",
    Description = "Body part to lock aim onto",
    Values = {"Head", "UpperTorso", "HumanoidRootPart"},
    Default = "Head",
    Icon = "Target",
    Callback = function(value)
        print("[UniversalUI] Target bone:", value)
    end
})

AimbotSection:AddDropdown({
    Title = "Priority Filter",
    Description = "Determines how targets are selected",
    Values = {"Closest to Crosshair", "Lowest Distance", "Lowest Health"},
    Default = "Closest to Crosshair",
    Icon = "Sliders",
    Callback = function(value)
        print("[UniversalUI] Priority filter:", value)
    end
})

AimbotSection:AddKeybind({
    Title = "Aim Activation Key",
    Description = "Hold key to activate aim assistance",
    Default = Enum.KeyCode.E,
    Icon = "Key",
    Callback = function(key)
        print("[UniversalUI] Aim key pressed")
    end
})

-- ==================== TAB 4: SETTINGS ====================
local SettingsTab = Window:AddTab({
    Title = "Settings",
    Description = "Appearance & theme customizer",
    Icon = "Settings",
})

local AppearanceSection = SettingsTab:AddSection({
    Title = "Appearance & Theme",
    Description = "Real-time theme switching & glass styling",
})

AppearanceSection:AddColorPicker({
    Title = "Accent Highlight Color",
    Description = "Dynamically adjusts all glowing borders and highlights",
    Default = Color3.fromRGB(88, 101, 242),
    Icon = "Palette",
    Callback = function(color)
        Library:SetTheme({ Accent = color })
    end
})

AppearanceSection:AddDropdown({
    Title = "Preset Color Themes",
    Description = "Apply crafted aesthetic presets instantly",
    Values = {"Neon Indigo", "Cyber Emerald", "Midnight Violet", "Crimson Blood", "Ice Cyan"},
    Default = "Neon Indigo",
    Icon = "Palette",
    Callback = function(preset)
        if preset == "Neon Indigo" then
            Library:SetTheme({ Accent = Color3.fromRGB(88, 101, 242), Background = Color3.fromRGB(12, 14, 22) })
        elseif preset == "Cyber Emerald" then
            Library:SetTheme({ Accent = Color3.fromRGB(46, 213, 115), Background = Color3.fromRGB(10, 20, 16) })
        elseif preset == "Midnight Violet" then
            Library:SetTheme({ Accent = Color3.fromRGB(155, 89, 182), Background = Color3.fromRGB(18, 12, 24) })
        elseif preset == "Crimson Blood" then
            Library:SetTheme({ Accent = Color3.fromRGB(235, 60, 75), Background = Color3.fromRGB(20, 10, 12) })
        elseif preset == "Ice Cyan" then
            Library:SetTheme({ Accent = Color3.fromRGB(52, 180, 235), Background = Color3.fromRGB(10, 16, 24) })
        end
    end
})

AppearanceSection:AddTextBox({
    Title = "Search Player",
    Description = "Target a specific player name in server",
    Placeholder = "Enter username...",
    Default = "",
    Icon = "User",
    Callback = function(text)
        print("[UniversalUI] Target player entered:", text)
    end
})

AppearanceSection:AddKeybind({
    Title = "Menu Toggle Key",
    Description = "Desktop keyboard keybind to toggle interface",
    Default = Enum.KeyCode.RightControl,
    Icon = "Key",
    Callback = function()
        Window:ToggleVisibility()
    end
})

AppearanceSection:AddButton({
    Title = "Trigger Success Toast",
    Description = "Demonstrates notification progress indicator",
    Icon = "Info",
    Callback = function()
        Library:Notify({
            Title = "Notification System",
            Description = "All components, blur, and mobile FAB active!",
            Type = "Success",
            Duration = 3.5,
        })
    end
})

AppearanceSection:AddLabel({
    Title = "Framework Performance",
    Description = "Glassmorphism UI • Real Lighting Blur • Mobile Floating FAB Active",
    Icon = "Zap",
})

AppearanceSection:AddParagraph({
    Title = "Universal UI Architecture",
    Description = "Universal UI is designed with premium frosted glassmorphism, responsive touch dragging, screen edge boundary clamping, and fluid physics-based animations. Optimized for mobile devices with a floating draggable button.",
    Icon = "Folder",
})

-- Welcome Notification
Library:Notify({
    Title = "Universal UI Active",
    Description = "Frosted glass interface loaded! Tap the floating button or press RCtrl to toggle.",
    Type = "Success",
    Duration = 4,
})

print("[UniversalUI] GUI Window and Mobile FAB created and visible!")
print("==================================================")

return Library
