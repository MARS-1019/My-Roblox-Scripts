-- [[ MARS HUB V2 - INTEGRATED EDITION (FLY FIX + RAINBOW CROSSHAIR) ]] --
if _G.MarsLoaded then 
    local old = game:GetService("CoreGui"):FindFirstChild("MarsHub_V2")
    local oldCross = game:GetService("CoreGui"):FindFirstChild("CrazyCrosshair")
    if old then old:Destroy() end
    if oldCross then oldCross:Destroy() end
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
    WallCheck = false,
    FOV = 150,
    LockPart = "Head",
    ShowFOV = false,
    ESP_Box = false,
    ESP_Name = false,
    ESP_Health = false,
    Fly = false,
    FlySpeed = 50,
    Noclip = false,
    TPAura = false,
    -- 偏移量設定
    Off_X = 0, 
    Off_Y = 4, 
    Off_Z = 0, 
    MenuKey = Enum.KeyCode.Insert,
    -- 準星設定
    RainbowCrosshair = true
}

local CurrentTarget = nil
local TargetIndex = 0

-- [[ 1. 彩虹準星 (旋轉+伸縮) ]] --
local function CreateRainbowCrosshair()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "CrazyCrosshair"
    screenGui.Parent = cg
    screenGui.IgnoreGuiInset = true

    local holder = Instance.new("Frame")
    holder.Size = UDim2.new(0, 0, 0, 0)
    holder.Position = UDim2.new(0.5, 0, 0.5, 0)
    holder.BackgroundTransparency = 1
    holder.Parent = screenGui

    local function createBar()
        local bar = Instance.new("Frame")
        bar.AnchorPoint = Vector2.new(0.5, 0.5)
        bar.BorderSizePixel = 0
        bar.Parent = holder
        return bar
    end

    local t = createBar(); local b = createBar(); local l = createBar(); local r_bar = createBar()
    local angle = 0

    r.RenderStepped:Connect(function(dt)
        if not Config.RainbowCrosshair then screenGui.Enabled = false return end
        screenGui.Enabled = true
        
        angle = angle + (dt * 180)
        holder.Rotation = angle
        
        local hue = tick() % 2 / 2
        local color = Color3.fromHSV(hue, 1, 1)
        
        local breathe = (math.sin(tick() * 5) + 1) / 2
        local length = 5 + (breathe * 15)
        local gap = 5 + (breathe * 5)
        local thickness = 2

        t.Size = UDim2.new(0, thickness, 0, length); t.Position = UDim2.new(0, 0, 0, -gap - (length/2)); t.BackgroundColor3 = color
        b.Size = UDim2.new(0, thickness, 0, length); b.Position = UDim2.new(0, 0, 0, gap + (length/2)); b.BackgroundColor3 = color
        l.Size = UDim2.new(0, length, 0, thickness); l.Position = UDim2.new(0, -gap - (length/2), 0, 0); l.BackgroundColor3 = color
        r_bar.Size = UDim2.new(0, length, 0, thickness); r_bar.Position = UDim2.new(0, gap + (length/2), 0, 0); r_bar.BackgroundColor3 = color
    end)
end

-- [[ 2. FPS 優化 ]] --
local function BoostFPS()
    settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
    for _, v in pairs(game:GetDescendants()) do
        if v:IsA("Part") or v:IsA("UnionOperation") or v:IsA("MeshPart") then
            v.Material = Enum.Material.SmoothPlastic
            v.Reflectance = 0
        elseif v:IsA("Decal") or v:IsA("Texture") then
            v:Destroy()
        elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then
            v.Enabled = false
        end
    end
    workspace.Terrain.WaterWaveSize = 0
    workspace.Terrain.WaterWaveSpeed = 0
    game:GetService("Lighting").GlobalShadows = false
end

-- [[ 3. 目標獲取邏輯 ]] --
local function GetNextTarget()
    local targetList = {}
    for _, v in pairs(p:GetPlayers()) do
        if v ~= lp and v.Character and v.Character:FindFirstChild("HumanoidRootPart") and v.Character.Humanoid.Health > 0 then
            table.insert(targetList, v)
        end
    end
    if #targetList == 0 then return nil end
    TargetIndex = (TargetIndex % #targetList) + 1
    return targetList[TargetIndex]
end

-- [[ 4. UI 介面核心 ]] --
local ScreenGui = Instance.new("ScreenGui", cg); ScreenGui.Name = "MarsHub_V2"
local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 260, 0, 580); Main.Position = UDim2.new(0.1, 0, 0.2, 0); Main.BackgroundColor3 = Color3.fromRGB(15, 15, 15); Main.Active = true; Main.Draggable = true
Instance.new("UICorner", Main)

local Container = Instance.new("ScrollingFrame", Main); Container.Size = UDim2.new(1, -20, 1, -60); Container.Position = UDim2.new(0, 10, 0, 50); Container.BackgroundTransparency = 1; Container.CanvasSize = UDim2.new(0, 0, 2.8, 0); Container.ScrollBarThickness = 0
Instance.new("UIListLayout", Container).Padding = UDim.new(0, 8)

local function AddToggle(text, configKey)
    local Btn = Instance.new("TextButton", Container); Btn.Size = UDim2.new(1, 0, 0, 30); Btn.BackgroundColor3 = Config[configKey] and Color3.fromRGB(0, 120, 255) or Color3.fromRGB(35, 35, 40); Btn.Text = text .. ": " .. (Config[configKey] and "ON" or "OFF"); Btn.TextColor3 = Color3.new(0.8, 0.8, 0.8); Btn.Font = Enum.Font.Gotham; Instance.new("UICorner", Btn)
    Btn.MouseButton1Click:Connect(function()
        Config[configKey] = not Config[configKey]
        Btn.Text = text .. ": " .. (Config[configKey] and "ON" or "OFF")
        Btn.BackgroundColor3 = Config[configKey] and Color3.fromRGB(0, 120, 255) or Color3.fromRGB(35, 35, 40)
    end)
end

local function AddSlider(text, min, max, configKey)
    local Frame = Instance.new("Frame", Container); Frame.Size = UDim2.new(1, 0, 0, 45); Frame.BackgroundTransparency = 1
    local Label = Instance.new("TextLabel", Frame); Label.Size = UDim2.new(1, 0, 0, 15); Label.Text = text .. ": " .. Config[configKey]; Label.TextColor3 = Color3.new(1, 1, 1); Label.BackgroundTransparency = 1; Label.Font = Enum.Font.Code
    local SliderBG = Instance.new("Frame", Frame); SliderBG.Size = UDim2.new(1, 0, 0, 8); SliderBG.Position = UDim2.new(0, 0, 0, 25); SliderBG.BackgroundColor3 = Color3.fromRGB(30,30,30)
    local Bar = Instance.new("Frame", SliderBG); Bar.Size = UDim2.new((Config[configKey]-min)/(max-min),0,1,0); Bar.BackgroundColor3 = Color3.fromRGB(0, 255, 150); Bar.BorderSizePixel = 0
    SliderBG.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then local con; con = u.InputChanged:Connect(function(i2) if i2.UserInputType == Enum.UserInputType.MouseMovement then local rel = math.clamp((u:GetMouseLocation().X - SliderBG.AbsolutePosition.X)/SliderBG.AbsoluteSize.X, 0, 1); Config[configKey] = math.floor(min + (max-min)*rel); Label.Text = text .. ": " .. Config[configKey]; Bar.Size = UDim2.new(rel, 0, 1, 0) end end); u.InputEnded:Connect(function(i3) if i3.UserInputType == Enum.UserInputType.MouseButton1 then con:Disconnect() end end) end end)
end

local function AddButton(text, callback)
    local Btn = Instance.new("TextButton", Container); Btn.Size = UDim2.new(1, 0, 0, 30); Btn.BackgroundColor3 = Color3.fromRGB(60, 30, 90); Btn.Text = text; Btn.TextColor3 = Color3.new(1, 1, 1); Btn.Font = Enum.Font.GothamBold; Instance.new("UICorner", Btn)
    Btn.MouseButton1Click:Connect(callback)
end

AddButton("🚀 BOOST FPS", BoostFPS)
AddToggle("RAINBOW CROSSHAIR", "RainbowCrosshair")
AddToggle("TP AURA", "TPAura")
AddSlider("L/R Offset", -10, 10, "Off_X")
AddSlider("Up/Down Offset", -10, 10, "Off_Y")
AddSlider("F/B Offset", -10, 10, "Off_Z")
AddToggle("Noclip", "Noclip")
AddToggle("Fly Mode", "Fly")
AddSlider("Fly Speed", 10, 500, "FlySpeed")
AddToggle("Aimbot", "Aimbot")
AddToggle("Wall Check", "WallCheck")
AddSlider("FOV", 50, 800, "FOV")
AddToggle("Show FOV", "ShowFOV")
AddToggle("ESP Box", "ESP_Box")
AddToggle("ESP Name", "ESP_Name")
AddToggle("ESP Health", "ESP_Health")

-- [[ 5. 核心循環 ]] --
r.Stepped:Connect(function()
    if Config.Noclip and lp.Character then
        for _, v in pairs(lp.Character:GetDescendants()) do if v:IsA("BasePart") then v.CanCollide = false end end
    end

    if Config.TPAura then
        if not CurrentTarget or not CurrentTarget.Parent or not CurrentTarget.Character or CurrentTarget.Character.Humanoid.Health <= 0 then
            CurrentTarget = GetNextTarget()
        end
        if CurrentTarget and CurrentTarget.Character and CurrentTarget.Character:FindFirstChild("HumanoidRootPart") then
            local myHrp = lp.Character:FindFirstChild("HumanoidRootPart")
            if myHrp then
                myHrp.CFrame = CurrentTarget.Character.HumanoidRootPart.CFrame * CFrame.new(Config.Off_X, Config.Off_Y, Config.Off_Z)
                myHrp.Velocity = Vector3.zero
            end
        end
    end
end)

local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1.5; FOVCircle.Visible = false; FOVCircle.Color = Color3.new(1,1,1)

r.RenderStepped:Connect(function()
    FOVCircle.Visible = Config.ShowFOV
    FOVCircle.Radius = Config.FOV
    FOVCircle.Position = u:GetMouseLocation()
    
    -- Aimbot 邏輯
    if Config.Aimbot and u:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local targetPos = nil; local dist = Config.FOV
        for _, v in pairs(p:GetPlayers()) do
            if v ~= lp and v.Character and v.Character:FindFirstChild(Config.LockPart) then
                local head = v.Character[Config.LockPart]
                local sPos, on = cam:WorldToViewportPoint(head.Position)
                if on and v.Character.Humanoid.Health > 0 then
                    local mag = (Vector2.new(sPos.X, sPos.Y) - u:GetMouseLocation()).Magnitude
                    if mag < dist then
                        if Config.TPAura or not Config.WallCheck or #cam:GetPartsObscuringTarget({head.Position}, {lp.Character, v.Character}) == 0 then
                            dist = mag; targetPos = sPos
                        end
                    end
                end
            end
        end
        if targetPos then mousemoverel(targetPos.X - u:GetMouseLocation().X, targetPos.Y - u:GetMouseLocation().Y) end
    end

    -- 修改後的飛行控制 (Space 上升 / Ctrl 下降)
    if Config.Fly and lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = lp.Character.HumanoidRootPart
        local moveVec = Vector3.zero
        if u:IsKeyDown(Enum.KeyCode.W) then moveVec += cam.CFrame.LookVector end
        if u:IsKeyDown(Enum.KeyCode.S) then moveVec -= cam.CFrame.LookVector end
        if u:IsKeyDown(Enum.KeyCode.A) then moveVec -= cam.CFrame.RightVector end
        if u:IsKeyDown(Enum.KeyCode.D) then moveVec += cam.CFrame.RightVector end
        if u:IsKeyDown(Enum.KeyCode.Space) then moveVec += Vector3.new(0, 1, 0) end
        if u:IsKeyDown(Enum.KeyCode.LeftControl) then moveVec -= Vector3.new(0, 1, 0) end
        
        if moveVec.Magnitude > 0 then
            hrp.Velocity = moveVec.Unit * Config.FlySpeed
        else
            hrp.Velocity = Vector3.zero
        end
    end
end)

-- [[ 6. ESP 與 初始化 ]] --
local function CreateESP(target)
    if target == lp then return end
    local b = Drawing.new("Square"); local nm = Drawing.new("Text"); local hp = Drawing.new("Text")
    b.Thickness = 1; nm.Size = 13; nm.Center = true; nm.Outline = true; hp.Size = 13; hp.Center = true; hp.Outline = true
    r.RenderStepped:Connect(function()
        if target.Character and target.Character:FindFirstChild("HumanoidRootPart") and target.Character.Humanoid.Health > 0 then
            local pos, on = cam:WorldToViewportPoint(target.Character.HumanoidRootPart.Position)
            if on then
                local size = 2500 / pos.Z
                b.Visible = Config.ESP_Box; b.Size = Vector2.new(size, size*1.5); b.Position = Vector2.new(pos.X - size/2, pos.Y - size/2); b.Color = Color3.new(1,1,1)
                nm.Visible = Config.ESP_Name; nm.Text = target.Name; nm.Position = Vector2.new(pos.X, pos.Y - size/2 - 15); nm.Color = Color3.new(1,1,1)
                hp.Visible = Config.ESP_Health; local h = target.Character.Humanoid.Health
                hp.Text = math.floor(h).." HP"; hp.Position = Vector2.new(pos.X, pos.Y + size/2 + 5); hp.Color = Color3.fromHSV(math.clamp(h/100, 0, 1) * 0.3, 1, 1)
                return
            end
        end
        b.Visible = false; nm.Visible = false; hp.Visible = false
    end)
end

for _, v in pairs(p:GetPlayers()) do CreateESP(v) end
p.PlayerAdded:Connect(CreateESP)
u.InputBegan:Connect(function(i, chat)
    if chat then return end
    if i.KeyCode == Enum.KeyCode.Q then CurrentTarget = GetNextTarget()
    elseif i.KeyCode == Config.MenuKey then Main.Visible = not Main.Visible end
end)

CreateRainbowCrosshair() -- 啟動準星
