local p = game:GetService("Players")
local lp = p.LocalPlayer
local r = game:GetService("RunService")
local u = game:GetService("UserInputService")
local c = workspace.CurrentCamera

-- [[ 配置 ]] --
_G.Aimbot = true
_G.FOV = 400
_G.LockPart = "Head" 

-- [[ 1. ESP 渲染 (方框 + 射線 + 血量條) ]] --
local function CreateESP(v)
    if v == lp then return end
    
    local box = Drawing.new("Square")
    box.Color = Color3.new(1, 0, 0)
    box.Thickness = 1.5
    box.Filled = false
    
    local line = Drawing.new("Line")
    line.Color = Color3.new(1, 1, 1) -- 白色射線比較不會擋視線
    line.Thickness = 1
    line.Transparency = 0.5

    -- 血量條背景 (黑框)
    local healthBarBg = Drawing.new("Square")
    healthBarBg.Thickness = 1
    healthBarBg.Filled = true
    healthBarBg.Color = Color3.new(0, 0, 0)
    healthBarBg.Transparency = 0.5
    
    -- 血量條 (彩色部分)
    local healthBar = Drawing.new("Square")
    healthBar.Thickness = 1
    healthBar.Filled = true
    healthBar.ZIndex = 1

    r.RenderStepped:Connect(function()
        if v.Character and v.Character:FindFirstChild("HumanoidRootPart") and v.Character:FindFirstChild("Humanoid") then
            local hum = v.Character.Humanoid
            local hrp = v.Character.HumanoidRootPart
            local pos, on = c:WorldToViewportPoint(hrp.Position)
            
            if on and hum.Health > 0 then
                local size = 3000 / pos.Z
                local x = pos.X - size/2
                local y = pos.Y - size/2
                local height = size * 1.5

                -- 更新方框
                box.Size = Vector2.new(size, height)
                box.Position = Vector2.new(x, y)
                box.Visible = true
                
                -- 更新射線
                line.From = Vector2.new(c.ViewportSize.X / 2, c.ViewportSize.Y)
                line.To = Vector2.new(pos.X, y + height)
                line.Visible = true

                -- 更新血量條
                local healthPercent = hum.Health / hum.MaxHealth
                local barWidth = 3
                local barPadding = 5
                
                healthBarBg.Size = Vector2.new(barWidth + 2, height)
                healthBarBg.Position = Vector2.new(x - barPadding - 1, y)
                healthBarBg.Visible = true

                healthBar.Size = Vector2.new(barWidth, height * healthPercent)
                healthBar.Position = Vector2.new(x - barPadding, y + (height * (1 - healthPercent)))
                -- 根據血量百分比換顏色 (綠 -> 黃 -> 紅)
                healthBar.Color = Color3.fromHSV(healthPercent * 0.3, 1, 1)
                healthBar.Visible = true
            else
                box.Visible = false
                line.Visible = false
                healthBar.Visible = false
                healthBarBg.Visible = false
            end
        else
            box.Visible = false
            line.Visible = false
            healthBar.Visible = false
            healthBarBg.Visible = false
        end
    end)
end

p.PlayerAdded:Connect(CreateESP)
for _, v in pairs(p:GetPlayers()) do CreateESP(v) end

-- [[ 2. Aimbot 核心 (手動開火) ]] --
r.RenderStepped:Connect(function()
    if not _G.Aimbot or not u:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then return end
    
    local target = nil
    local minDist = _G.FOV
    local mPos = u:GetMouseLocation()

    for _, v in pairs(p:GetPlayers()) do
        if v ~= lp and v.Character and v.Character:FindFirstChild(_G.LockPart) then
            local part = v.Character[_G.LockPart]
            local hum = v.Character:FindFirstChild("Humanoid")
            if hum and hum.Health > 0 then
                local sPos, on = c:WorldToViewportPoint(part.Position)
                if on then
                    local mag = (Vector2.new(sPos.X, sPos.Y) - mPos).Magnitude
                    if mag < minDist then
                        minDist = mag
                        target = sPos
                    end
                end
            end
        end
    end

    if target then
        mousemoverel(target.X - mPos.X, target.Y - mPos.Y)
    end
end)

print("Rivals Final: Box, Tracer, HealthBar & Aim Loaded.")
