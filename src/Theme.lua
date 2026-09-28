local table_clear = table.clear or function(t) for k in pairs(t) do t[k] = nil end end
--[=[
    Theme System
    Provides a dynamic theme state and automatic theme updating across all registered UI elements.
    Supports real-time theme swapping with smooth transitions without recreating the GUI.
]=]

local TweenService = game and game:GetService("TweenService")
local typeof = typeof or type

local Theme = {}
Theme.__index = Theme

Theme.Defaults = {
    Background = Color3.fromRGB(12, 14, 22),
    Surface = Color3.fromRGB(18, 22, 36),
    SurfaceSecondary = Color3.fromRGB(28, 34, 52),
    Text = Color3.fromRGB(250, 252, 255),
    TextSecondary = Color3.fromRGB(160, 172, 195),
    Accent = Color3.fromRGB(88, 101, 242),
    AccentHover = Color3.fromRGB(105, 118, 255),
    Border = Color3.fromRGB(255, 255, 255),
    BorderTransparency = 0.8,
    Transparency = 0.42,
    GlassTransparency = 0.35,
    Success = Color3.fromRGB(46, 213, 115),
    Warning = Color3.fromRGB(255, 171, 0),
    Error = Color3.fromRGB(255, 71, 87),
    Info = Color3.fromRGB(52, 152, 219),
}

Theme.Current = {}
for k, v in pairs(Theme.Defaults) do
    Theme.Current[k] = v
end

Theme.Registry = {}

function Theme:Get(key)
    return self.Current[key] or self.Defaults[key]
end

function Theme:Register(instance, propertyMap)
    if not instance then return end
    
    self.Registry[instance] = propertyMap
    
    -- Apply current theme values immediately
    for prop, themeKey in pairs(propertyMap) do
        local val = self:Get(themeKey)
        if val ~= nil then
            pcall(function()
                instance[prop] = val
            end)
        end
    end
    
    -- Auto unregister when instance destroyed
    if instance.Destroying then
        instance.Destroying:Connect(function()
            Theme.Registry[instance] = nil
        end)
    end
end

function Theme:Unregister(instance)
    if instance then
        self.Registry[instance] = nil
    end
end

function Theme:SetTheme(newTheme, animate)
    if type(newTheme) ~= "table" then return end
    
    for k, v in pairs(newTheme) do
        self.Current[k] = v
    end
    
    local shouldAnimate = (animate ~= false) and (TweenService ~= nil)
    local tweenInfo = shouldAnimate and TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out) or nil
    
    for instance, propertyMap in pairs(self.Registry) do
        if instance and instance.Parent then
            for prop, themeKey in pairs(propertyMap) do
                local val = self:Get(themeKey)
                if val ~= nil then
                    if shouldAnimate and (typeof(val) == "Color3" or typeof(val) == "number") then
                        pcall(function()
                            local t = TweenService:Create(instance, tweenInfo, { [prop] = val })
                            t:Play()
                        end)
                    else
                        pcall(function()
                            instance[prop] = val
                        end)
                    end
                end
            end
        else
            self.Registry[instance] = nil
        end
    end
end

function Theme:ClearRegistry()
    table_clear(self.Registry)
end

return Theme
