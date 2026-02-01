local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Mars Hub | Rivals ULTIMATE",
   LoadingTitle = "Mars Systems Loading...",
   LoadingSubtitle = "Aimbot + ESP + Fly Edition",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = "MarsConfig",
      FileName = "UltimateSettings"
   }
})

-- [[ 核心全局變數 ]] --
_G.Aimbot = false
_G.FOV = 400
_G.LockPart = "Head"
_G.ShowFOV = false

_G.ESP_Enabled = false
_G.ESP_Box = false
_G.ESP_Name = false
_G.ESP_HealthBar = false
_G.ESP_Tracer = false

_G.FlyEnabled = false
_G.FlySpeed = 50

local p = game:GetService("Players")
local lp = p.LocalPlayer
local r = game:GetService("RunService")
local u = game:GetService("UserInputService")
local c = workspace.CurrentCamera

-- [[ FOV 渲染 ]] --
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1
FOVCircle.Color = Color3.fromRGB(0, 255, 255)
FOVCircle.Filled = false
FOVCircle.Transparency = 0.7

-- [[ UI 標籤頁面 ]] --
local CombatTab = Window:CreateTab("Combat", 4483362458)
local VisualTab = Window:CreateTab("Visuals", 4483345998)
local MovementTab = Window:CreateTab("Movement", 4483362748)

-- [[ 1. Combat (戰鬥系統) ]] --
CombatTab:CreateSection("Aimbot Settings")
CombatTab:CreateToggle({
   Name = "Enable Aimbot (Hold Right Click)",
   CurrentValue = false,
   Callback = function(v) _G.Aimbot = v end,
})
CombatTab:CreateToggle({
   Name = "Show FOV Circle",
   CurrentValue = false,
   Callback = function(v) _G.ShowFOV = v end,
})
CombatTab:CreateSlider({
   Name = "Aimbot FOV",
   Range = {0, 1000},
   Increment = 1,
   Suffix = "px",
   CurrentValue = 400,
   Callback = function(v) _G.FOV = v end,
})
CombatTab:CreateDropdown({
   Name = "Target Part",
   Options = {"Head", "HumanoidRootPart", "UpperTorso"},
   CurrentOption = "Head",
   Callback = function(v) _G.LockPart = v end,
})

-- [[ 2. Visuals (透視) ]] --
VisualTab:CreateSection("ESP Settings")
VisualTab:CreateToggle({
   Name = "Enable Visuals",
   CurrentValue = false,
   Callback = function(v) _G.ESP_Enabled = v end,
})
VisualTab:CreateToggle({ Name = "Boxes", CurrentValue = false, Callback = function(v) _G.ESP_Box = v end })
VisualTab:CreateToggle({ Name = "Names", CurrentValue = false, Callback = function(v) _G.ESP_Name = v end })
VisualTab:CreateToggle({ Name = "Health Bars", CurrentValue = false, Callback = function(v) _G.ESP_HealthBar = v end })
VisualTab:CreateToggle({ Name = "Snaplines", CurrentValue = false, Callback = function(v) _G.ESP_Tracer = v end })

-- [[ 3. Movement (飛行功能) ]] --
MovementTab:CreateSection("Flight Controls")
MovementTab:CreateToggle({
   Name = "Fly Mode",
   CurrentValue = false,
   Callback = function(v) 
      _G.FlyEnabled = v 
      if not v then
         -- 關閉飛行時重置重力與速度
         if lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
            lp.Character.HumanoidRootPart.Velocity = Vector3.new(0,0,0)
         end
      end
   end,
})
MovementTab:CreateSlider({
   Name = "Fly Speed",
   Range = {10, 300},
   Increment = 5,
   Suffix = " Speed",
   CurrentValue = 50,
   Callback = function(v) _G.FlySpeed = v end,
})

-- [[ 核心功能邏輯 ]] --

-- ESP 函數
local function CreateESP(player)
    if player == lp then return end
    local box = Drawing.new("Square"); local line = Drawing.new("Line"); local name = Drawing.new("Text")
    local healthBarBg = Drawing.new("Square"); local healthBar = Drawing.new("Square")
    
    r.RenderStepped:Connect(function()
        local char = player.Character
        if _G.ESP_Enabled and char and char:FindFirstChild("Humanoid") and char:FindFirstChild("HumanoidRootPart") then
            local hum = char.Humanoid; local hrp = char.HumanoidRootPart
            local pos, on = c:WorldToViewportPoint(hrp.Position)
            
            if on and hum.Health > 0 then
                local size = 3000 / pos.Z; local x, y = pos.X - size/2, pos.Y - size/2; local height = size * 1.5
                
                box.Visible = _G.ESP_Box; box.Size = Vector2.new(size, height); box.Position = Vector2.new(x, y); box.Color = Color3.new(1, 0, 0); box.Thickness = 1
                line.Visible = _G.ESP_Tracer; line.From = Vector2.new(c.ViewportSize.X/2, c.ViewportSize.Y); line.To = Vector2.new(pos.X, y + height); line.Color = Color3.new(1,1,1)
                name.Visible = _G.ESP_Name; name.Text = player.Name; name.Size = 14; name.Outline = true; name.Center = true; name.Position = Vector2.new(pos.X, y - 20)
                
                local hpPercent = hum.Health / hum.MaxHealth
                healthBarBg.Visible = _G.ESP_HealthBar; healthBarBg.Size = Vector2.new(5, height); healthBarBg.Position = Vector2.new(x - 7, y); healthBarBg.Filled = true; healthBarBg.Color = Color3.new(0,0,0)
                healthBar.Visible = _G.ESP_HealthBar; healthBar.Size = Vector2.new(3, height * hpPercent); healthBar.Position = Vector2.new(x - 6, y + (height * (1 - hpPercent))); healthBar.Filled = true; healthBar.Color = Color3.fromHSV(hpPercent * 0.3, 1, 1)
                return
            end
        end
        box.Visible = false; line.Visible = false; name.Visible = false; healthBar.Visible = false; healthBarBg.Visible = false
    end)
end

-- 飛行與自瞄循環
r.RenderStepped:Connect(function()
    -- FOV 更新
    FOVCircle.Visible = _G.ShowFOV
    FOVCircle.Radius = _G.FOV
    FOVCircle.Position = u:GetMouseLocation()

    -- 飛行邏輯
    if _G.FlyEnabled and lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = lp.Character.HumanoidRootPart
        local moveDir = Vector3.new(0,0,0)
        
        if u:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + c.CFrame.LookVector end
        if u:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - c.CFrame.LookVector end
        if u:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - c.CFrame.RightVector end
        if u:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + c.CFrame.RightVector end
        if u:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0,1,0) end
        if u:IsKeyDown(Enum.KeyCode.LeftControl) then moveDir = moveDir - Vector3.new(0,1,0) end
        
        hrp.Velocity = moveDir * _G.FlySpeed
    end

    -- 自瞄邏輯
    if _G.Aimbot and u:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local target = nil; local minDist = _G.FOV; local mPos = u:GetMouseLocation()
        for _, v in pairs(p:GetPlayers()) do
            if v ~= lp and v.Character and v.Character:FindFirstChild(_G.LockPart) then
                local hum = v.Character:FindFirstChild("Humanoid")
                if hum and hum.Health > 0 then
                    local sPos, on = c:WorldToViewportPoint(v.Character[_G.LockPart].Position)
                    if on then
                        local mag = (Vector2.new(sPos.X, sPos.Y) - mPos).Magnitude
                        if mag < minDist then minDist = mag; target = sPos end
                    end
                end
            end
        end
        if target then mousemoverel(target.X - mPos.X, target.Y - mPos.Y) end
    end
end)

p.PlayerAdded:Connect(CreateESP)
for _, v in pairs(p:GetPlayers()) do CreateESP(v) end

Rayfield:Notify({Title = "Mars Hub Loaded", Content = "Aimbot & Fly Ready!", Duration = 5})
