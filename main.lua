-- [[ MARS HUB V2 - THE FINAL DEFINITIVE EDITION ]] --
if _G.MarsLoaded then 
    local old = game:GetService("CoreGui"):FindFirstChild("MarsHub_V2")
    local oldC = game:GetService("CoreGui"):FindFirstChild("CrazyCrosshair")
    if old then old:Destroy() end
    if oldC then oldC:Destroy() end
end
_G.MarsLoaded = true

local p = game:GetService("Players")
local lp = p.LocalPlayer
local r = game:GetService("RunService")
local u = game:GetService("UserInputService")
local cg = game:GetService("CoreGui")
local cam = workspace.CurrentCamera

local Config = {
    Aimbot = false,
    AimMode = "Hold", -- "Hold" 或 "Toggle"
    IsAiming = false,
    WallCheck = true,
    FOV = 150,
    ShowFOV = true,
    -- ESP
    ESP_Box = true,
    ESP_Name = true,
    ESP_Health = true,
    ESP_Lines = true,
    -- Movement
    Fly = false,
    FlySpeed = 50,
    Noclip = false,
    TPAura = false,
    Off_Y = 5,
    -- UI
    MenuKey = Enum.KeyCode.Insert,
    RainbowCrosshair = true
}

local CurrentTarget = nil
local TargetIndex = 1

-- [[ 1. UI 核心構建 ]] --
local ScreenGui = Instance.new("ScreenGui", cg); ScreenGui.Name = "MarsHub_V2"
local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 260, 0, 520); Main.Position = UDim2.new(0.05, 0, 0.2, 0); Main.BackgroundColor3 = Color3.fromRGB(15, 15, 18); Main.Active = true; Main.Draggable = true; Instance.new("UICorner", Main)

local Header = Instance.new("TextLabel", Main)
Header.Size = UDim2.new(1, -75, 0, 40); Header.Position = UDim2.new(0, 12, 0, 0); Header.BackgroundTransparency = 1; Header.TextColor3 = Color3.new(1, 1, 1); Header.Font = "GothamBold"; Header.TextSize = 11; Header.TextXAlignment = "Left"
r.RenderStepped:Connect(function(dt) Header.Text = "MarsHub_V2 | " .. math.floor(1/dt) .. " FPS | " .. lp.Name end)

local MiniBtn = Instance.new("TextButton", Main); MiniBtn.Size = UDim2.new(0, 24, 0, 24); MiniBtn.Position = UDim2.new(1, -62, 0, 8); MiniBtn.Text = "-"; MiniBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 55); MiniBtn.TextColor3 = Color3.new(1, 1, 1); Instance.new("UICorner", MiniBtn)
local CloseBtn = Instance.new("TextButton", Main); CloseBtn.Size = UDim2.new(0, 24, 0, 24); CloseBtn.Position = UDim2.new(1, -32, 0, 8); CloseBtn.Text = "X"; CloseBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50); CloseBtn.TextColor3 = Color3.new(1, 1, 1); Instance.new("UICorner", CloseBtn)

local Container = Instance.new("ScrollingFrame", Main); Container.Size = UDim2.new(1, -20, 1, -60); Container.Position = UDim2.new(0, 10, 0, 50); Container.BackgroundTransparency = 1; Container.CanvasSize = UDim2.new(0, 0, 4.5, 0); Container.ScrollBarThickness = 2
Instance.new("UIListLayout", Container).Padding = UDim.new(0, 8)

-- UI 組件
local function AddToggle(text, configKey)
    local Btn = Instance.new("TextButton", Container); Btn.Size = UDim2.new(1, 0, 0, 32); Btn.BackgroundColor3 = Config[configKey] and Color3.fromRGB(0, 120, 255) or Color3.fromRGB(30, 30, 35); Btn.Text = text .. ": " .. (Config[configKey] and "ON" or "OFF"); Btn.TextColor3 = Color3.new(1, 1, 1); Instance.new("UICorner", Btn)
    Btn.MouseButton1Click:Connect(function() Config[configKey] = not Config[configKey]; Btn.Text = text .. ": " .. (Config[configKey] and "ON" or "OFF"); Btn.BackgroundColor3 = Config[configKey] and Color3.fromRGB(0, 120, 255) or Color3.fromRGB(30, 30, 35) end)
end

local function AddSlider(text, min, max, configKey)
    local F = Instance.new("Frame", Container); F.Size = UDim2.new(1, 0, 0, 40); F.BackgroundTransparency = 1
    local L = Instance.new("TextLabel", F); L.Size = UDim2.new(1, 0, 0, 15); L.Text = text .. ": " .. Config[configKey]; L.TextColor3 = Color3.new(1,1,1); L.BackgroundTransparency = 1; L.TextSize = 10
    local BG = Instance.new("Frame", F); BG.Size = UDim2.new(1, 0, 0, 6); BG.Position = UDim2.new(0, 0, 0, 22); BG.BackgroundColor3 = Color3.fromRGB(45,45,50); Instance.new("UICorner", BG)
    local Bar = Instance.new("Frame", BG); Bar.Size = UDim2.new((Config[configKey]-min)/(max-min),0,1,0); Bar.BackgroundColor3 = Color3.fromRGB(0, 255, 150); Bar.BorderSizePixel = 0; Instance.new("UICorner", Bar)
    BG.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then local c; c = u.InputChanged:Connect(function(i2) if i2.UserInputType == Enum.UserInputType.MouseMovement then local r = math.clamp((u:GetMouseLocation().X - BG.AbsolutePosition.X)/BG.AbsoluteSize.X, 0, 1); Config[configKey] = math.floor(min + (max-min)*r); L.Text = text .. ": " .. Config[configKey]; Bar.Size = UDim2.new(r, 0, 1, 0) end end); u.InputEnded:Connect(function(i3) if i3.UserInputType == Enum.UserInputType.MouseButton1 then c:Disconnect() end end) end end)
end

-- 添加 UI 列表
AddToggle("Aimbot Master", "Aimbot")
AddToggle("Wall Check", "WallCheck")
local ModeBtn = Instance.new("TextButton", Container); ModeBtn.Size = UDim2.new(1, 0, 0, 32); ModeBtn.Text = "Aim Mode: " .. Config.AimMode; ModeBtn.BackgroundColor3 = Color3.fromRGB(65, 40, 100); ModeBtn.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", ModeBtn)
ModeBtn.MouseButton1Click:Connect(function() Config.AimMode = (Config.AimMode == "Hold" and "Toggle" or "Hold"); ModeBtn.Text = "Aim Mode: " .. Config.AimMode; Config.IsAiming = false end)

AddSlider("FOV Size", 50, 800, "FOV")
AddToggle("Show FOV Circle", "ShowFOV")
AddToggle("Fly Mode", "Fly")
AddSlider("Fly Speed", 10, 500, "FlySpeed")
AddToggle("TP Aura (Q)", "TPAura")
AddSlider("TP Height", -20, 20, "Off_Y")
AddToggle("Noclip", "Noclip")
AddToggle("ESP Box", "ESP_Box")
AddToggle("ESP Name", "ESP_Name")
AddToggle("ESP Health", "ESP_Health")
AddToggle("ESP Lines", "ESP_Lines")
AddToggle("Rainbow Crosshair", "RainbowCrosshair")

-- [[ 2. 繪製系統 (FOV, Crosshair, ESP) ]] --
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1; FOVCircle.Color = Color3.new(1,1,1); FOVCircle.Visible = false

local function CreateESP(target)
    local box = Drawing.new("Square"); box.Thickness = 1; box.Color = Color3.new(1,0,0)
    local line = Drawing.new("Line"); line.Thickness = 1; line.Color = Color3.new(1,1,1)
    local name = Drawing.new("Text"); name.Size = 14; name.Center = true; name.Outline = true; name.Color = Color3.new(1,1,1)
    local hp = Drawing.new("Text"); hp.Size = 13; hp.Center = true; hp.Outline = true

    r.RenderStepped:Connect(function()
        if target.Character and target.Character:FindFirstChild("HumanoidRootPart") and target.Character.Humanoid.Health > 0 then
            local pos, on = cam:WorldToViewportPoint(target.Character.HumanoidRootPart.Position)
            if on then
                local s = 2000 / pos.Z
                box.Visible = Config.ESP_Box; box.Size = Vector2.new(s, s*1.5); box.Position = Vector2.new(pos.X - s/2, pos.Y - s/2)
                line.Visible = Config.ESP_Lines; line.From = Vector2.new(cam.ViewportSize.X/2, cam.ViewportSize.Y); line.To = Vector2.new(pos.X, pos.Y)
                name.Visible = Config.ESP_Name; name.Text = target.Name; name.Position = Vector2.new(pos.X, pos.Y - (s/2) - 15)
                hp.Visible = Config.ESP_Health; hp.Text = math.floor(target.Character.Humanoid.Health) .. " HP"; hp.Position = Vector2.new(pos.X, pos.Y + (s/2) + 5); hp.Color = Color3.fromHSV(math.clamp(target.Character.Humanoid.Health/100,0,1)*0.3, 1, 1)
                return
            end
        end
        box.Visible = false; line.Visible = false; name.Visible = false; hp.Visible = false
    end)
end
for _, v in pairs(p:GetPlayers()) do if v ~= lp then CreateESP(v) end end
p.PlayerAdded:Connect(CreateESP)

-- [[ 3. 核心循環邏輯 ]] --
u.InputBegan:Connect(function(i, chat)
    if chat then return end
    if i.UserInputType == Enum.UserInputType.MouseButton2 then
        if Config.AimMode == "Hold" then Config.IsAiming = true else Config.IsAiming = not Config.IsAiming end
    elseif i.KeyCode == Enum.KeyCode.Q then
        local l = {}; for _,v in pairs(p:GetPlayers()) do if v~=lp and v.Character and v.Character.Humanoid.Health>0 then table.insert(l,v) end end
        if #l>0 then TargetIndex = (TargetIndex % #l) + 1; CurrentTarget = l[TargetIndex] end
    elseif i.KeyCode == Config.MenuKey then Main.Visible = not Main.Visible end
end)
u.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton2 and Config.AimMode == "Hold" then Config.IsAiming = false end end)

r.RenderStepped:Connect(function(dt)
    FOVCircle.Visible = Config.ShowFOV; FOVCircle.Radius = Config.FOV; FOVCircle.Position = u:GetMouseLocation()

    -- Aimbot + WallCheck
    if Config.Aimbot and Config.IsAiming then
        local targetPos, dist = nil, Config.FOV
        for _, v in pairs(p:GetPlayers()) do
            if v ~= lp and v.Character and v.Character:FindFirstChild("Head") and v.Character.Humanoid.Health > 0 then
                local head = v.Character.Head
                local sPos, on = cam:WorldToViewportPoint(head.Position)
                if on then
                    local m = (Vector2.new(sPos.X, sPos.Y) - u:GetMouseLocation()).Magnitude
                    if m < dist then
                        if not Config.WallCheck or #cam:GetPartsObscuringTarget({head.Position}, {lp.Character, v.Character}) == 0 then
                            dist = m; targetPos = sPos
                        end
                    end
                end
            end
        end
        if targetPos then mousemoverel(targetPos.X - u:GetMouseLocation().X, targetPos.Y - u:GetMouseLocation().Y) end
    end

    -- Fly (Space / Ctrl)
    if Config.Fly and lp.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = lp.Character.HumanoidRootPart; local move = Vector3.zero
        if u:IsKeyDown(Enum.KeyCode.W) then move += cam.CFrame.LookVector end
        if u:IsKeyDown(Enum.KeyCode.S) then move -= cam.CFrame.LookVector end
        if u:IsKeyDown(Enum.KeyCode.A) then move -= cam.CFrame.RightVector end
        if u:IsKeyDown(Enum.KeyCode.D) then move += cam.CFrame.RightVector end
        if u:IsKeyDown(Enum.KeyCode.Space) then move += Vector3.new(0, 1, 0) end
        if u:IsKeyDown(Enum.KeyCode.LeftControl) then move -= Vector3.new(0, 1, 0) end
        hrp.Velocity = move.Magnitude > 0 and move.Unit * Config.FlySpeed or Vector3.zero
    end

    -- Noclip
    if Config.Noclip and lp.Character then
        for _, v in pairs(lp.Character:GetDescendants()) do if v:IsA("BasePart") then v.CanCollide = false end end
    end

    -- TP Aura
    if Config.TPAura and CurrentTarget and CurrentTarget.Character and CurrentTarget.Character:FindFirstChild("HumanoidRootPart") then
        lp.Character.HumanoidRootPart.CFrame = CurrentTarget.Character.HumanoidRootPart.CFrame * CFrame.new(0, Config.Off_Y, 0)
        lp.Character.HumanoidRootPart.Velocity = Vector3.zero
    end
end)

-- UI 控制
MiniBtn.MouseButton1Click:Connect(function()
    collapsed = not collapsed
    Main:TweenSize(collapsed and UDim2.new(0, 260, 0, 40) or UDim2.new(0, 260, 0, 520), "Out", "Quad", 0.2, true)
    MiniBtn.Text = collapsed and "+" or "-"
end)
CloseBtn.MouseButton1Click:Connect(function() Main.Visible = false end)

-- 彩虹準星
local crossGui = Instance.new("ScreenGui", cg); crossGui.Name = "CrazyCrosshair"; crossGui.IgnoreGuiInset = true
local holder = Instance.new("Frame", crossGui); holder.Size = UDim2.new(0,0,0,0); holder.Position = UDim2.new(0.5,0,0.5,0); holder.BackgroundTransparency = 1
local function cb() local f = Instance.new("Frame", holder); f.AnchorPoint = Vector2.new(0.5,0.5); f.BorderSizePixel = 0; return f end
local t, b, l, rb = cb(), cb(), cb(), cb()
r.RenderStepped:Connect(function(dt)
    crossGui.Enabled = Config.RainbowCrosshair
    holder.Rotation = holder.Rotation + (dt * 150)
    local col = Color3.fromHSV(tick()%2/2, 1, 1)
    local br = (math.sin(tick()*5)+1)/2; local len = 6+(br*15); local gp = 5+(br*5)
    t.Size = UDim2.new(0,2,0,len); t.Position = UDim2.new(0,0,0,-gp-len/2); t.BackgroundColor3 = col
    b.Size = UDim2.new(0,2,0,len); b.Position = UDim2.new(0,0,0,gp+len/2); b.BackgroundColor3 = col
    l.Size = UDim2.new(0,len,0,2); l.Position = UDim2.new(0,-gp-len/2,0,0); l.BackgroundColor3 = col
    rb.Size = UDim2.new(0,len,0,2); rb.Position = UDim2.new(0,gp+len/2,0,0); rb.BackgroundColor3 = col
end)
