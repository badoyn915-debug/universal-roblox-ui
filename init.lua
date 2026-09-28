--[=[
    Universal UI Entry Point
]=]

local function loadBundle()
    local success, res = pcall(function()
        return loadfile("dist/bundle.lua")()
    end)
    if success and res then
        return res
    end
    error("[UniversalUI] Failed to load local distribution bundle.")
end

return loadBundle()
