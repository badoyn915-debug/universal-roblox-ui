# Universal UI Library

A modern, premium, mobile-first glassmorphic GUI framework built natively for Luau and Roblox executors.

---

## Highlights

- **Glassmorphism Aesthetic**: Frosted semi-transparent backgrounds, subtle borders, high corner radiuses, and fluid transitions.
- **Mobile-First Touch Architecture**: Full touch drag support with screen clamping, responsive `UIScale`, finger-friendly hit targets (≥40px), and seamless orientation adaptability (Portrait and Landscape).
- **Comprehensive Component Suite**: Window, Tabs, Sections, Buttons, Toggles, Sliders, Dropdowns, MultiDropdowns, TextBoxes, Keybinds, ColorPickers, Labels, Paragraphs, and Toasts.
- **Zero Polling & High Performance**: Event-driven architecture with zero unnecessary `RenderStepped` or `Heartbeat` polling loops.
- **Robust Memory Management**: Complete cleanup on `Library:Destroy()`, automatically cancelling all tweens, disconnecting all RBXScriptConnections, and clearing theme registries.
- **Runtime Theme Swapping**: Seamlessly change color themes dynamically without recreating the UI.

---

## Project Structure

```
├── Loader.lua                  # Public GitHub raw loader
├── init.lua                    # Entry point for local execution
├── build.py                     # Standalone bundler utility
├── dist/
│   └── bundle.lua              # Compiled single-file distribution
└── src/
    ├── Library.lua             # Core library orchestrator
    ├── Assets.lua              # Vector icon configuration
    ├── Theme.lua               # Theme registry & dynamic updater
    ├── Animation.lua           # TweenService animation manager
    ├── Utility.lua             # UI helper functions, touch/mouse dragging
    ├── UI/
    │   ├── Window.lua          # Root window with screen clamping & minimization
    │   ├── TopBar.lua          # Title, subtitle, icon, control buttons
    │   ├── Sidebar.lua         # Tab list with animated indicators
    │   ├── Tab.lua             # Scrollable page container with CanvasGroup transitions
    │   ├── Section.lua         # Component group with dividers and headers
    │   └── Notifications.lua   # Floating toast system with duration progress bar
    └── Components/
        ├── Button.lua          # Button with press & hover animations
        ├── Toggle.lua          # Animated sliding toggle switch
        ├── Slider.lua          # Mouse & touch slider with step increments
        ├── Dropdown.lua        # Single-selection expandable menu
        ├── MultiDropdown.lua   # Multi-selection menu with count badges
        ├── TextBox.lua         # Input field with focus ring & clear button
        ├── Keybind.lua         # Key listener & binder
        ├── ColorPicker.lua     # RGB palette sliders with live swatch
        ├── Label.lua           # Read-only information card
        └── Paragraph.lua       # Auto-sizing multiline text display
```

---

## Quick Start Example

```lua
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/badoyn915-debug/universal-roblox-ui/main/dist/bundle.lua"))()

local Window = Library:CreateWindow({
    Title = "Universal UI",
    Subtitle = "Premium Mobile Interface",
})

local Tab = Window:AddTab({
    Title = "Main",
    Description = "General settings",
})

local Section = Tab:AddSection({
    Title = "Features",
    Description = "Toggle and adjust parameters",
})

Section:AddToggle({
    Title = "Speed Boost",
    Description = "Enables faster movement speed",
    Default = false,
    Callback = function(enabled)
        print("Speed Boost:", enabled)
    end
})

Section:AddSlider({
    Title = "Speed Multiplier",
    Description = "Set the boost factor",
    Min = 1,
    Max = 100,
    Default = 16,
    Increment = 1,
    Callback = function(value)
        print("Speed set to:", value)
    end
})

Section:AddDropdown({
    Title = "Selection Mode",
    Description = "Pick target detection strategy",
    Values = {"Closest", "Farthest", "Lowest Health"},
    Default = "Closest",
    Callback = function(selected)
        print("Selected mode:", selected)
    end
})

Library:Notify({
    Title = "Welcome",
    Description = "Universal UI initialized successfully!",
    Type = "Success",
    Duration = 4,
})
```

---

## Theme Configuration

Customize colors dynamically at any time:

```lua
Library:SetTheme({
    Background = Color3.fromRGB(15, 17, 24),
    Surface = Color3.fromRGB(24, 28, 42),
    Accent = Color3.fromRGB(88, 101, 242),
    Text = Color3.fromRGB(245, 247, 252),
    TextSecondary = Color3.fromRGB(150, 160, 180),
})
```

---

## Cleanup & Memory Safety

To completely remove the GUI and free all memory, active connections, and tweens:

```lua
Library:Destroy()
```
