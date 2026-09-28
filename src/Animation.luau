local table_clear = table.clear or function(t) for k in pairs(t) do t[k] = nil end end
--[=[
    Animation Engine
    Provides responsive, fluid animations using TweenService.
    Supports hover, press, release, slide, fade, tab transitions, scale, and cleanup.
]=]

local TweenService = game and game:GetService("TweenService")

local Animation = {}
Animation.__index = Animation

Animation.Presets = {
    Fast = TweenInfo.new(0.18, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
    Normal = TweenInfo.new(0.28, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
    Smooth = TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
    Spring = TweenInfo.new(0.32, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
    Bounce = TweenInfo.new(0.4, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out),
    Tab = TweenInfo.new(0.24, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
}

Animation.ActiveTweens = {}

function Animation.Tween(instance, tweenInfo, goals)
    if not instance or not TweenService then return nil end
    
    tweenInfo = tweenInfo or Animation.Presets.Normal
    local tween = TweenService:Create(instance, tweenInfo, goals)
    
    Animation.ActiveTweens[tween] = true
    
    tween.Completed:Connect(function()
        Animation.ActiveTweens[tween] = nil
    end)
    
    tween:Play()
    return tween
end

function Animation.Press(instance, normalScale, pressedScale)
    normalScale = normalScale or 1.0
    pressedScale = pressedScale or 0.96
    
    local uiScale = instance:FindFirstChildOfClass("UIScale")
    if not uiScale then
        uiScale = Instance.new("UIScale")
        uiScale.Scale = normalScale
        uiScale.Parent = instance
    end
    
    return {
        OnPress = function()
            Animation.Tween(uiScale, Animation.Presets.Fast, { Scale = pressedScale })
        end,
        OnRelease = function()
            Animation.Tween(uiScale, Animation.Presets.Fast, { Scale = normalScale })
        end
    }
end

function Animation.FadeIn(instance, targetTransparency, duration)
    targetTransparency = targetTransparency or 0
    local tInfo = duration and TweenInfo.new(duration, Enum.EasingStyle.Quart, Enum.EasingDirection.Out) or Animation.Presets.Normal
    
    if instance:IsA("CanvasGroup") then
        return Animation.Tween(instance, tInfo, { GroupTransparency = targetTransparency })
    elseif instance:IsA("GuiObject") then
        return Animation.Tween(instance, tInfo, { BackgroundTransparency = targetTransparency })
    end
end

function Animation.FadeOut(instance, targetTransparency, duration, onComplete)
    targetTransparency = targetTransparency or 1
    local tInfo = duration and TweenInfo.new(duration, Enum.EasingStyle.Quart, Enum.EasingDirection.Out) or Animation.Presets.Normal
    
    local tween
    if instance:IsA("CanvasGroup") then
        tween = Animation.Tween(instance, tInfo, { GroupTransparency = targetTransparency })
    elseif instance:IsA("GuiObject") then
        tween = Animation.Tween(instance, tInfo, { BackgroundTransparency = targetTransparency })
    end
    
    if tween and onComplete then
        tween.Completed:Connect(onComplete)
    elseif onComplete then
        task.delay(duration or 0.28, onComplete)
    end
    return tween
end

function Animation.SlideIn(instance, targetPos, startPos, duration)
    if startPos then
        instance.Position = startPos
    end
    local tInfo = duration and TweenInfo.new(duration, Enum.EasingStyle.Quart, Enum.EasingDirection.Out) or Animation.Presets.Normal
    return Animation.Tween(instance, tInfo, { Position = targetPos })
end

function Animation.SlideOut(instance, targetPos, duration, onComplete)
    local tInfo = duration and TweenInfo.new(duration, Enum.EasingStyle.Quart, Enum.EasingDirection.Out) or Animation.Presets.Normal
    local tween = Animation.Tween(instance, tInfo, { Position = targetPos })
    if tween and onComplete then
        tween.Completed:Connect(onComplete)
    elseif onComplete then
        task.delay(duration or 0.28, onComplete)
    end
    return tween
end

function Animation.Cleanup()
    for tween in pairs(Animation.ActiveTweens) do
        pcall(function()
            tween:Cancel()
        end)
    end
    table_clear(Animation.ActiveTweens)
end

return Animation
