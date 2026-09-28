#!/usr/bin/env python3
"""
Bundle builder for Universal UI Library.
Bundles modular source files into a high-performance standalone distribution.
"""
import os

BASE_DIR = os.path.dirname(os.path.abspath(__file__))

modules = [
    ("Assets", "src/Assets.luau"),
    ("Theme", "src/Theme.luau"),
    ("Animation", "src/Animation.luau"),
    ("Utility", "src/Utility.luau"),
    ("Components/Button", "src/Components/Button.luau"),
    ("Components/Toggle", "src/Components/Toggle.luau"),
    ("Components/Slider", "src/Components/Slider.luau"),
    ("Components/Dropdown", "src/Components/Dropdown.luau"),
    ("Components/MultiDropdown", "src/Components/MultiDropdown.luau"),
    ("Components/TextBox", "src/Components/TextBox.luau"),
    ("Components/Keybind", "src/Components/Keybind.luau"),
    ("Components/ColorPicker", "src/Components/ColorPicker.luau"),
    ("Components/Label", "src/Components/Label.luau"),
    ("Components/Paragraph", "src/Components/Paragraph.luau"),
    ("UI/TopBar", "src/UI/TopBar.luau"),
    ("UI/Sidebar", "src/UI/Sidebar.luau"),
    ("UI/Section", "src/UI/Section.luau"),
    ("UI/Tab", "src/UI/Tab.luau"),
    ("UI/Notifications", "src/UI/Notifications.luau"),
    ("UI/Window", "src/UI/Window.luau"),
    ("Library", "src/Library.luau"),
]

bundle_lines = [
    "--[=[",
    "    Universal UI Library",
    "    Modern Premium Mobile-First Glassmorphic GUI Framework for Roblox",
    "    Compiled Standalone Distribution",
    "]=]",
    "",
    "local typeof = typeof or type",
    "local math_clamp = math.clamp or function(v, min, max) return math.max(min, math.min(max, v)) end",
    "local table_clear = table.clear or function(t) for k in pairs(t) do t[k] = nil end end",
    "local table_find = table.find or function(t, val) for i, v in ipairs(t) do if v == val then return i end end return nil end",
    "",
    "local Modules = {}",
    "local Cache = {}",
    "",
    "local function import(name)",
    "    if Cache[name] ~= nil then",
    "        return Cache[name]",
    "    end",
    "    local factory = Modules[name]",
    "    if not factory then",
    "        error(\"[UniversalUI] Module not found: \" .. tostring(name))",
    "    end",
    "    local result = factory(import)",
    "    Cache[name] = result",
    "    return result",
    "end",
    ""
]

for name, relpath in modules:
    fullpath = os.path.join(BASE_DIR, relpath)
    with open(fullpath, "r", encoding="utf-8") as f:
        code = f.read()
    bundle_lines.append(f"-- Module: {name}")
    bundle_lines.append(f"Modules[\"{name}\"] = function(import)")
    bundle_lines.append(code)
    bundle_lines.append("end\n")

bundle_lines.append("local Library = import(\"Library\")")
bundle_lines.append("return Library.init(import)")

bundle_content = "\n".join(bundle_lines)
dist_path = os.path.join(BASE_DIR, "dist", "bundle.luau")
os.makedirs(os.path.dirname(dist_path), exist_ok=True)
with open(dist_path, "w", encoding="utf-8") as f:
    f.write(bundle_content)

print(f"Successfully compiled {len(modules)} modules into {dist_path} ({len(bundle_content)} bytes)")
