--[=[
    Universal UI - Loader
    Public loader for initializing the Universal UI Library.
]=]

local GITHUB_URL = "https://raw.githubusercontent.com/badoyn915-debug/universal-roblox-ui/main/dist/bundle.luau"

local success, source = pcall(function()
    return game:HttpGet(GITHUB_URL, true)
end)

if not success or not source or #source == 0 then
    error("[UniversalUI] Failed to download library: " .. tostring(source))
end

local loadedFn, compileErr = loadstring(source, "UniversalUI")
if not loadedFn then
    error("[UniversalUI] Compilation error: " .. tostring(compileErr))
end

return loadedFn()
