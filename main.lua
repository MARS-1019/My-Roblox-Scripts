local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Mars Hub | Rivals ULTIMATE",
   LoadingTitle = "Mars Premium Systems Loading...",
   LoadingSubtitle = "by Gemini Editor",
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
_G.ESP_HealthText = false
_G.ESP_Tracer = false

local p = game:GetService("Players")
local lp = p.LocalPlayer
local r = game:GetService("RunService")
local u = game:GetService("UserInputService")
local c = workspace.CurrentCamera
local lighting = game:GetService("Lighting")

-- [[ FOV 圓圈渲染 ]] --
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1
FOVCircle.Color = Color3.fromRGB(0, 255, 255)
FOVCircle.Filled = false
FOVCircle.Transparency = 0.7

-- [[ UI 標籤頁面 ]] --
local CombatTab = Window:CreateTab("Combat", 4483362458)
local VisualTab = Window:CreateTab("Visuals", 4483345998)
local SkinTab = Window:CreateTab("Skins", 11293237142)
local PerfTab = Window:CreateTab("Performance", 4370345144)

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

-- [[ 2. Visuals (全功能透視) ]] --
VisualTab:CreateSection("ESP Master Switch")
VisualTab:CreateToggle({
   Name = "Enable Visuals",
   CurrentValue = false,
   Callback = function(v) _G.ESP_Enabled = v end,
})
VisualTab:CreateSection("Options")
VisualTab:CreateToggle({ Name = "Boxes", CurrentValue = false, Callback = function(v) _G.ESP_Box = v end })
VisualTab:CreateToggle({ Name = "Names", CurrentValue = false, Callback = function(v) _G.ESP_Name = v end })
VisualTab:CreateToggle({ Name = "Health Bars", CurrentValue = false, Callback = function(v) _G.ESP_HealthBar = v end })
VisualTab:CreateToggle({ Name = "Health Numbers", CurrentValue = false, Callback = function(v) _G.ESP_HealthText = v end })
VisualTab:CreateToggle({ Name = "Snaplines (Tracers)", CurrentValue = false, Callback = function(v) _G.ESP_Tracer = v end })

-- [[ 3. Skins (皮膚解鎖) ]] --
SkinTab:CreateSection("Local Skin Unlocker")
SkinTab:CreateParagraph({Title = "Instructions", Content = "Click spoofing then check your locker. Note: This is client-side only."})

SkinTab:CreateButton({
   Name = "Unlock All Skins (Spoof Owned)",
   Callback = function()
       local count = 0
       -- 掃描全域 Boolean 數值
       for _, v in pairs(game:GetDescendants()) do
           if (v.Name == "Owned" or v.Name == "Unlocked") and v:IsA("BoolValue") then
               v.Value = true
               count = count + 1
           end
       end
       -- 掃描 ModuleScripts 配置
       for _, mod in pairs(game:GetService("ReplicatedStorage"):GetDescendants()) do
           if mod:IsA("ModuleScript") and (mod.Name:find("Skin") or mod.Name:find("Config")) then
               pcall(function()
                   local table_ = require(mod)
                   if type(table_) == "table" then
                       for i, val in pairs(table_) do
                           if i == "IsOwned" or i == "Unlocked" then table_[i] = true end
                       end
                   end
               end)
           end
       end
       Rayfield:Notify({Title = "Skins", Content = "Spoofing complete. Found: " .. tostring(count), Duration = 3})
   end,
})

SkinTab:CreateButton({
   Name = "Gold Weapon Visuals",
   Callback = function()
       for _, v in pairs(game:GetDescendants()) do
           if v:IsA("MeshPart") or v:IsA("Part") then
               if v.Parent:IsA("Model") and (v.Parent.Name:find("Gun") or v.Parent.Name:find("Weapon")) then
                   v.Material = Enum.Material.Neon
                   v.Color = Color3.fromRGB(255, 215, 0)
               end
           end
       end
   end,
})

-- [[ 4. Performance (極致性能優化) ]] --
PerfTab:CreateSection("FPS Boost")
PerfTab:CreateButton({
   Name = "Ultra Low GFX (No Textures / Smooth)",
   Callback = function()
       for _, v in pairs(game:GetDescendants()) do
           if v:IsA("Part") or v:IsA("MeshPart") or v:IsA("UnionOperation") then
               v.Material = Enum.Material.SmoothPlastic
               v.Reflectance = 0
               if v:IsA("MeshPart") then v.TextureID = "" end
           elseif v:IsA("Decal") or v:IsA("Texture") then
               v:Destroy()
           elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then
               v.Enabled = false
           end
       end
       lighting.GlobalShadows = false
       settings().Rendering.QualityLevel = 1
       Rayfield:Notify({Title = "Success", Content = "Everything is now Smooth Plastic.", Duration = 3})
   end,
})
PerfTab:CreateButton({
   Name = "Unlock FPS (999 Cap)",
   Callback = function()
       if setfpscap then setfpscap(999) 
       Rayfield:Notify({Title = "FPS", Content = "FPS Unlocked!", Duration = 3})
       else Rayfield:Notify({Title = "Error", Content = "Executor not supported.", Duration = 3}) end
   end,
})

-- [[ 核心循環與功能函數 ]] --

local function CreateESP(player)
    if player == lp then return end
    local box = Drawing.new("Square"); local line = Drawing.new("Line"); local name = Drawing.new("Text")
    local healthTxt = Drawing.new("Text"); local healthBarBg = Drawing.new("Square"); local healthBar = Drawing.new("Square")
    
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
                healthTxt.Visible = _G.ESP_HealthText; healthTxt.Text = tostring(math.floor(hum.Health)); healthTxt.Position = Vector2.new(x - 30, y + (height * (1 - hpPercent))); healthTxt.Outline = true
                return
            end
        end
        box.Visible = false; line.Visible = false; name.Visible = false; healthBar.Visible = false; healthBarBg.Visible = false; healthTxt.Visible = false
    end)
end

r.RenderStepped:Connect(function()
    FOVCircle.Visible = _G.ShowFOV
    FOVCircle.Radius = _G.FOV
    FOVCircle.Position = u:GetMouseLocation()

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

Rayfield:Notify({Title = "Mars Hub Loaded", Content = "Ultimate Version 4.0", Duration = 5})
