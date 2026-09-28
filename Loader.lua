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
    Subtitle = "Premium Mobile Interface",
})

local MainTab = Window:AddTab({
    Title = "Main",
    Description = "General settings & features",
})

local ConfigTab = Window:AddTab({
    Title = "Controls",
    Description = "Interactive components",
})

-- Section 1: Features
local MainSection = MainTab:AddSection({
    Title = "Features",
    Description = "Interactive component demonstration",
})

MainSection:AddToggle({
    Title = "Speed Boost",
    Description = "Multiplies player walkspeed",
    Default = false,
    Callback = function(value)
        print("[UniversalUI] Speed Boost:", value)
    end
})

MainSection:AddSlider({
    Title = "Walkspeed Multiplier",
    Description = "Adjust character movement speed",
    Min = 16,
    Max = 150,
    Default = 32,
    Increment = 1,
    Callback = function(value)
        print("[UniversalUI] Speed set to:", value)
    end
})

MainSection:AddButton({
    Title = "Send Notification",
    Description = "Displays an animated toast alert",
    Callback = function()
        Library:Notify({
            Title = "Universal UI",
            Description = "Action executed successfully!",
            Type = "Success",
            Duration = 3,
        })
    end
})

MainSection:AddDropdown({
    Title = "Aim Target Mode",
    Description = "Select targeting priority",
    Values = {"Closest", "Lowest HP", "Highest Threat", "Random"},
    Default = "Closest",
    Callback = function(value)
        print("[UniversalUI] Mode selected:", value)
    end
})

MainSection:AddMultiDropdown({
    Title = "Visual Features",
    Description = "Choose active visual overlays",
    Values = {"ESP Box", "Tracer Lines", "Chams", "Name Tags"},
    Default = {"ESP Box", "Chams"},
    Callback = function(selected)
        print("[UniversalUI] Active visuals count:", #selected)
    end
})

-- Section 2: Controls
local ControlsSection = ConfigTab:AddSection({
    Title = "Inputs & Tuning",
    Description = "Input fields, keybinds, and color pickers",
})

ControlsSection:AddTextBox({
    Title = "Target Player",
    Description = "Enter target username",
    Placeholder = "Search player name...",
    Default = "",
    Callback = function(text)
        print("[UniversalUI] Target player:", text)
    end
})

ControlsSection:AddKeybind({
    Title = "Menu Keybind",
    Description = "Key used to toggle menu visibility",
    Default = Enum.KeyCode.RightControl,
    Callback = function(key)
        print("[UniversalUI] Keybind triggered:", tostring(key))
    end
})

ControlsSection:AddColorPicker({
    Title = "Accent Color",
    Description = "Dynamically adjusts the UI theme accent",
    Default = Color3.fromRGB(88, 101, 242),
    Callback = function(color)
        Library:SetTheme({ Accent = color })
    end
})

ControlsSection:AddLabel({
    Title = "System Status",
    Description = "Running smoothly on Luau engine without memory leaks",
})

ControlsSection:AddParagraph({
    Title = "Information",
    Description = "Universal UI is designed for maximum mobile responsiveness, touch gesture support, screen boundary clamping, and instant runtime theme switching.",
})

-- Welcome Notification
Library:Notify({
    Title = "Universal UI",
    Description = "Interface loaded and ready to use!",
    Type = "Success",
    Duration = 4,
})

print("[UniversalUI] GUI Window created and visible!")
print("==================================================")

return Library
