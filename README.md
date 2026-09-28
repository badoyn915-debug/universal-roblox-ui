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
├── Loader.luau                  # Public GitHub raw loader
├── init.luau                    # Entry point for local execution
├── build.py                     # Standalone bundler utility
├── dist/
│   └── bundle.luau              # Compiled single-file distribution
└── src/
    ├── Library.luau             # Core library orchestrator
    ├── Assets.luau              # Vector icon configuration
    ├── Theme.luau               # Theme registry & dynamic updater
    ├── Animation.luau           # TweenService animation manager
    ├── Utility.luau             # UI helper functions, touch/mouse dragging
    ├── UI/
    │   ├── Window.luau          # Root window with screen clamping & minimization
    │   ├── TopBar.luau          # Title, subtitle, icon, control buttons
    │   ├── Sidebar.luau         # Tab list with animated indicators
    │   ├── Tab.luau             # Scrollable page container with CanvasGroup transitions
    │   ├── Section.luau         # Component group with dividers and headers
    │   └── Notifications.luau   # Floating toast system with duration progress bar
    └── Components/
        ├── Button.luau          # Button with press & hover animations
        ├── Toggle.luau          # Animated sliding toggle switch
        ├── Slider.luau          # Mouse & touch slider with step increments
        ├── Dropdown.luau        # Single-selection expandable menu
        ├── MultiDropdown.luau   # Multi-selection menu with count badges
        ├── TextBox.luau         # Input field with focus ring & clear button
        ├── Keybind.luau         # Key listener & binder
        ├── ColorPicker.luau     # RGB palette sliders with live swatch
        ├── Label.luau           # Read-only information card
        └── Paragraph.luau       # Auto-sizing multiline text display
```

---

## Quick Start Example

```lua
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/badoyn915-debug/universal-roblox-ui/main/dist/bundle.luau"))()

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
