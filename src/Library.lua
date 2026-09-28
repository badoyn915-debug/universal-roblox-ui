local table_clear = table.clear or function(t) for k in pairs(t) do t[k] = nil end end
--[=[
    Universal UI Library
    Main orchestration module that provides the top-level API, lifecycle management,
    theme control, notification system, and memory leak prevention.
]=]

local Library = {}
Library.__index = Library

function Library.init(import)
    local Theme = import("Theme")
    local Animation = import("Animation")
    local Utility = import("Utility")
    local Assets = import("Assets")
    
    local Button = import("Components/Button")
    local Toggle = import("Components/Toggle")
    local Slider = import("Components/Slider")
    local Dropdown = import("Components/Dropdown")
    local MultiDropdown = import("Components/MultiDropdown")
    local TextBox = import("Components/TextBox")
    local Keybind = import("Components/Keybind")
    local ColorPicker = import("Components/ColorPicker")
    local Label = import("Components/Label")
    local Paragraph = import("Components/Paragraph")
    
    local TopBar = import("UI/TopBar")
    local Sidebar = import("UI/Sidebar")
    local Section = import("UI/Section")
    local Tab = import("UI/Tab")
    local Notifications = import("UI/Notifications")
    local Window = import("UI/Window")
    
    local Components = {
        Button = Button,
        Toggle = Toggle,
        Slider = Slider,
        Dropdown = Dropdown,
        MultiDropdown = MultiDropdown,
        TextBox = TextBox,
        Keybind = Keybind,
        ColorPicker = ColorPicker,
        Label = Label,
        Paragraph = Paragraph,
    }
    
    local Modules = {
        Theme = Theme,
        Animation = Animation,
        Utility = Utility,
        Assets = Assets,
        TopBar = TopBar,
        Sidebar = Sidebar,
        Section = Section,
        Tab = Tab,
        Notifications = Notifications,
        Window = Window,
        Components = Components,
    }
    
    local self = setmetatable({}, Library)
    self.Modules = Modules
    self.Theme = Theme
    self.Assets = Assets
    self.Windows = {}
    self.NotificationSystem = nil
    
    print("[UniversalUI] Framework initialized successfully! (v1.0.0)")
    return self
end

function Library:CreateWindow(config)
    config = config or {}
    local window = self.Modules.Window.new(config, self.Modules)
    table.insert(self.Windows, window)
    
    -- Initialize notification system parented to the GUI root if not done yet
    if not self.NotificationSystem then
        self.NotificationSystem = self.Modules.Notifications.new(
            window.ScreenGui,
            self.Theme,
            self.Modules.Animation,
            self.Modules.Utility,
            self.Assets
        )
    end
    
    return window
end

function Library:Notify(config)
    if self.NotificationSystem then
        self.NotificationSystem:Notify(config)
    else
        -- Fallback if no window created yet: create a lightweight notification GUI
        local guiParent = self.Modules.Utility.GetGuiParent()
        local notifyGui = self.Modules.Utility.Create("ScreenGui", {
            Name = "UniversalUI_Toasts",
            ResetOnSpawn = false,
            DisplayOrder = 110,
            Parent = guiParent,
        })
        self.NotificationSystem = self.Modules.Notifications.new(
            notifyGui,
            self.Theme,
            self.Modules.Animation,
            self.Modules.Utility,
            self.Assets
        )
        self.NotificationSystem:Notify(config)
    end
end

function Library:SetTheme(newTheme, animate)
    self.Theme:SetTheme(newTheme, animate)
end

function Library:Destroy()
    -- 1. Cancel and cleanup all running tweens
    self.Modules.Animation.Cleanup()
    
    -- 2. Disconnect all tracked RBXScriptConnections
    self.Modules.Utility.DisconnectAll()
    
    -- 3. Clear Theme instance registry
    self.Theme:ClearRegistry()
    
    -- 4. Destroy all Window ScreenGuis
    for _, win in ipairs(self.Windows) do
        pcall(function()
            win:Destroy()
        end)
    end
    table_clear(self.Windows)
    
    -- 5. Destroy notifications
    if self.NotificationSystem then
        pcall(function()
            self.NotificationSystem:Destroy()
        end)
        self.NotificationSystem = nil
    end
end

return Library
