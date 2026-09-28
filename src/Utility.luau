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

-- Screen-constrained Draggable Implementation (Mouse + Touch)
function Utility.MakeDraggable(frame, dragHandle)
    dragHandle = dragHandle or frame
    
    local dragging = false
    local dragInput = nil
    local dragStart = nil
    local startPos = nil
    
    local function update(input)
        local delta = input.Position - dragStart
        local viewport = Utility.GetViewportSize()
        
        -- Clamping calculation to keep the window fully within screen boundaries
        local frameSize = frame.AbsoluteSize
        local newX = math_clamp(startPos.X.Offset + delta.X, 0, math.max(0, viewport.X - frameSize.X))
        local newY = math_clamp(startPos.Y.Offset + delta.Y, 0, math.max(0, viewport.Y - frameSize.Y))
        
        local targetPosition = UDim2.new(startPos.X.Scale, newX, startPos.Y.Scale, newY)
        
        if TweenService then
            TweenService:Create(frame, TweenInfo.new(0.08, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                Position = targetPosition
            }):Play()
        else
            frame.Position = targetPosition
        end
    end
    
    local beganConn = dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            
            local changedConn
            changedConn = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    if changedConn then
                        changedConn:Disconnect()
                    end
                end
            end)
            Utility.AddConnection(changedConn)
        end
    end)
    Utility.AddConnection(beganConn)
    
    local inputChangedConn = dragHandle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    Utility.AddConnection(inputChangedConn)
    
    local globalChangedConn = UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)
    Utility.AddConnection(globalChangedConn)
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
    
    local success, _ = pcall(function()
        local _ = CoreGui.Name
    end)
    if success then
        return CoreGui
    end
    
    if LocalPlayer and LocalPlayer:FindFirstChildOfClass("PlayerGui") then
        return LocalPlayer:FindFirstChildOfClass("PlayerGui")
    end
    
    return CoreGui
end

return Utility
