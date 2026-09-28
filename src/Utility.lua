local table_clear = table.clear or function(t) for k in pairs(t) do t[k] = nil end end
local math_clamp = math.clamp or function(v, min, max) return math.max(min, math.min(max, v)) end
--[=[
    Utility Module
    Helper functions for UI construction, connection tracking, touch/mouse dragging with screen clamping,
    and mobile screen detection.
]=]

local UserInputService = game and game:GetService("UserInputService")
local TweenService = game and game:GetService("TweenService")
local Workspace = game and game:GetService("Workspace")

local Utility = {}
Utility.__index = Utility

-- Connection tracker
Utility.Connections = {}

function Utility.AddConnection(conn)
    if conn then
        table.insert(Utility.Connections, conn)
    end
    return conn
end

function Utility.DisconnectAll()
    for _, conn in ipairs(Utility.Connections) do
        if conn and conn.Disconnect then
            pcall(function()
                conn:Disconnect()
            end)
        end
    end
    table_clear(Utility.Connections)
end

-- Instance creation helper
function Utility.Create(className, properties, children)
    local inst = Instance.new(className)
    if properties then
        for k, v in pairs(properties) do
            inst[k] = v
        end
    end
    if children then
        for _, child in ipairs(children) do
            if child then
                child.Parent = inst
            end
        end
    end
    return inst
end

function Utility.AddCorner(parent, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 12)
    corner.Parent = parent
    return corner
end

function Utility.AddStroke(parent, color, thickness, transparency)
    local stroke = Instance.new("UIStroke")
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Color = color or Color3.fromRGB(255, 255, 255)
    stroke.Thickness = thickness or 1
    stroke.Transparency = transparency or 0.88
    stroke.Parent = parent
    return stroke
end

function Utility.AddPadding(parent, top, bottom, left, right)
    local padding = Instance.new("UIPadding")
    padding.PaddingTop = UDim.new(0, top or 8)
    padding.PaddingBottom = UDim.new(0, bottom or 8)
    padding.PaddingLeft = UDim.new(0, left or 12)
    padding.PaddingRight = UDim.new(0, right or 12)
    padding.Parent = parent
    return padding
end

function Utility.GetViewportSize()
    local camera = Workspace and Workspace.CurrentCamera
    if camera then
        return camera.ViewportSize
    end
    return Vector2.new(1280, 720)
end

function Utility.IsMobile()
    if not UserInputService then return false end
    return UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
end

-- Universal Draggable Implementation (Mouse + Touch anywhere on screen)
function Utility.MakeDraggable(frame, dragHandle)
    dragHandle = dragHandle or frame
    
    local dragging = false
    local dragStart = nil
    local startPos = nil
    
    local beganConn = dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            
            local inputEndedConn
            inputEndedConn = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    if inputEndedConn then
                        inputEndedConn:Disconnect()
                    end
                end
            end)
            Utility.AddConnection(inputEndedConn)
        end
    end)
    Utility.AddConnection(beganConn)
    
    local globalChangedConn = UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
    Utility.AddConnection(globalChangedConn)
    
    local globalEndedConn = UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    Utility.AddConnection(globalEndedConn)
end

function Utility.Round(num, decimals)
    local mult = 10 ^ (decimals or 0)
    return math.floor(num * mult + 0.5) / mult
end

function Utility.GetGuiParent()
    if gethui then
        local success, hui = pcall(gethui)
        if success and hui then return hui end
    end
    
    local CoreGui = game:GetService("CoreGui")
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer
    
    local testWritable = false
    pcall(function()
        local test = Instance.new("Folder")
        test.Parent = CoreGui
        test.Parent = nil
        testWritable = true
    end)
    if testWritable then
        return CoreGui
    end
    
    if LocalPlayer then
        local pGui = LocalPlayer:FindFirstChildOfClass("PlayerGui") or LocalPlayer:WaitForChild("PlayerGui", 4)
        if pGui then return pGui end
    end
    
    return CoreGui
end

return Utility
