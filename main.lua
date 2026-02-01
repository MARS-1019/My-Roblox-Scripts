-- [[ 守護進程 ]] --
if _G.MarsLoaded then 
    local old = game:GetService("CoreGui"):FindFirstChild("MarsHub_V2")
    if old then old:Destroy() end
end
_G.MarsLoaded = true

local p = game:GetService("Players")
local lp = p.LocalPlayer
local r = game:GetService("RunService")
local u = game:GetService("UserInputService")
local cg = game:GetService("CoreGui")

local Config = {
    Aimbot = false,
    WallCheck = false,
    FOV = 150,
    LockPart = "Head",
    ShowFOV = false,
    ESP_Box = false,
    ESP_Tracer = false,
    ESP_Name = false,
    ESP_Health = false,
    Fly = false,
    FlySpeed = 50,
    MenuKey = Enum.KeyCode.Insert
}

-- [[ FPS 優化函數 ]] --
local function BoostFPS()
    local settings = settings()
    settings.Rendering.QualityLevel = Enum.QualityLevel.Level01
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
    workspace.Terrain.WaterReflectance = 0
    workspace.Terrain.WaterTransparency = 0
    game:GetService("Lighting").GlobalShadows = false
    game:GetService("Lighting").FogEnd = 9e9
end

-- [[ UI 介面 ]] --
local ScreenGui = Instance.new("ScreenGui", cg)
ScreenGui.Name = "MarsHub_V2"
ScreenGui.ResetOnSpawn = false

local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 250, 0, 500)
Main.Position = UDim2.new(0.1, 0, 0.2, 0)
Main.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Main.Active = true; Main.Draggable = true
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 8)

local Container = Instance.new("ScrollingFrame", Main)
Container.Size = UDim2.new(1, -20, 1, -60)
Container.Position = UDim2.new(0, 10, 0, 50)
Container.BackgroundTransparency = 1
Container.CanvasSize = UDim2.new(0, 0, 2.5, 0)
Container.ScrollBarThickness = 0
Instance.new("UIListLayout", Container).Padding = UDim.new(0, 8)

local function AddToggle(text, configKey)
    local Btn = Instance.new("TextButton", Container)
    Btn.Size = UDim2.new(1, 0, 0, 30); Btn.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    Btn.Text = text .. ": OFF"; Btn.TextColor3 = Color3.new(0.8, 0.8, 0.8)
    Btn.Font = Enum.Font.Gotham; Btn.TextSize = 13
    Instance.new("UICorner", Btn)
    Btn.MouseButton1Click:Connect(function()
        Config[configKey] = not Config[configKey]
        Btn.Text = text .. ": " .. (Config[configKey] and "ON" or "OFF")
        Btn.BackgroundColor3 = Config[configKey] and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(35, 35, 40)
    end)
end

local function AddButton(text, callback)
    local Btn = Instance.new("TextButton", Container)
    Btn.Size = UDim2.new(1, 0, 0, 30); Btn.BackgroundColor3 = Color3.fromRGB(60, 30, 90)
    Btn.Text = text; Btn.TextColor3 = Color3.new(1, 1, 1)
    Btn.Font = Enum.Font.GothamBold; Btn.TextSize = 13
    Instance.new("UICorner", Btn)
    Btn.MouseButton1Click:Connect(callback)
end

local function AddSlider(text, min, max, configKey)
    local Frame = Instance.new("Frame", Container); Frame.Size = UDim2.new(1, 0, 0, 45); Frame.BackgroundTransparency = 1
    local Label = Instance.new("TextLabel", Frame); Label.Size = UDim2.new(1, 0, 0, 15); Label.Text = text .. ": " .. Config[configKey]; Label.TextColor3 = Color3.new(1, 1, 1); Label.BackgroundTransparency = 1
    local SliderBG = Instance.new("Frame", Frame); SliderBG.Size = UDim2.new(1, 0, 0, 8); SliderBG.Position = UDim2.new(0, 0, 0, 25); SliderBG.BackgroundColor3 = Color3.fromRGB(30,30,30)
    local Bar = Instance.new("Frame", SliderBG); Bar.Size = UDim2.new((Config[configKey]-min)/(max-min),0,1,0); Bar.BackgroundColor3 = Color3.fromRGB(0, 150, 0); Bar.BorderSizePixel = 0
    SliderBG.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            local con; con = u.InputChanged:Connect(function(i2)
                if i2.UserInputType == Enum.UserInputType.MouseMovement then
                    local rel = math.clamp((u:GetMouseLocation().X - SliderBG.AbsolutePosition.X)/SliderBG.AbsoluteSize.X, 0, 1)
                    Config[configKey] = math.floor(min + (max-min)*rel)
                    Label.Text = text .. ": " .. Config[configKey]
                    Bar.Size = UDim2.new(rel, 0, 1, 0)
                end
            end)
            u.InputEnded:Connect(function(i3) if i3.UserInputType == Enum.UserInputType.MouseButton1 then con:Disconnect() end end)
        end
    end)
end

AddButton("🚀 BOOST FPS (提升幀數)", function() BoostFPS() end)
AddToggle("Silent Lock", "Aimbot")
AddToggle("Wall Check", "WallCheck")
AddToggle("Show FOV", "ShowFOV")
AddSlider("Aimbot FOV", 50, 1000, "FOV")
AddToggle("ESP Box", "ESP_Box")
AddToggle("ESP Name", "ESP_Name")
AddToggle("ESP Health", "ESP_Health")
AddToggle("ESP Snaplines", "ESP_Tracer")
AddToggle("Fly Mode", "Fly")
AddSlider("Fly Speed", 10, 500, "FlySpeed")

-- [[ 超絲滑 ESP 渲染系統 ]] --
local function CreateESP(target)
    if target == lp then return end
    
    local b = Drawing.new("Square")
    local t = Drawing.new("Line")
    local nm = Drawing.new("Text")
    local hp = Drawing.new("Text")
    
    -- 初始化繪圖屬性（避免在循環中重複賦值）
    b.Thickness = 1; b.Filled = false; b.Transparency = 1
    t.Thickness = 1; t.Transparency = 1
    nm.Size = 13; nm.Center = true; nm.Outline = true; nm.Font = 2
    hp.Size = 13; hp.Center = true; hp.Outline = true; hp.Font = 2

    local connection
    connection = r.RenderStepped:Connect(function()
        local char = target.Character
        local cam = workspace.CurrentCamera
        
        -- 檢查玩家效度
        if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Humanoid") and char.Humanoid.Health > 0 then
            local root = char.HumanoidRootPart
            local pos, on = cam:WorldToViewportPoint(root.Position)
            
            if on then
                local size = 2500 / pos.Z
                local lerpSpeed = 0.8 -- 插值速度（1為瞬間移動，數值越小越順滑但會有延遲感）
                
                -- 方框更新
                if Config.ESP_Box then
                    b.Visible = true
                    b.Size = b.Size:Lerp(Vector2.new(size, size * 1.5), lerpSpeed)
                    b.Position = b.Position:Lerp(Vector2.new(pos.X - size/2, pos.Y - size/2), lerpSpeed)
                    b.Color = Color3.new(1,1,1)
                else b.Visible = false end
                
                -- 連接線更新
                if Config.ESP_Tracer then
                    t.Visible = true
                    t.From = Vector2.new(cam.ViewportSize.X/2, cam.ViewportSize.Y)
                    t.To = t.To:Lerp(Vector2.new(pos.X, pos.Y + (size*0.75)), lerpSpeed)
                    t.Color = Color3.new(1,1,1)
                else t.Visible = false end
                
                -- 名字更新
                if Config.ESP_Name then
                    nm.Visible = true
                    nm.Text = target.Name
                    nm.Position = nm.Position:Lerp(Vector2.new(pos.X, pos.Y - size/2 - 15), lerpSpeed)
                    nm.Color = Color3.new(1,1,1)
                else nm.Visible = false end
                
                -- 血量更新
                if Config.ESP_Health then
                    hp.Visible = true
                    local h = char.Humanoid.Health
                    hp.Text = math.floor(h).." HP"
                    hp.Position = hp.Position:Lerp(Vector2.new(pos.X, pos.Y + size/2 + 10), lerpSpeed)
                    hp.Color = Color3.fromHSV(math.clamp(h/100, 0, 1) * 0.3, 1, 1)
                else hp.Visible = false end
                
                return
            end
        end
        
        -- 不在螢幕內或死亡時隱藏
        b.Visible = false; t.Visible = false; nm.Visible = false; hp.Visible = false
        
        -- 如果玩家離開則斷開連接
        if not target.Parent then
            b:Remove(); t:Remove(); nm:Remove(); hp:Remove()
            connection:Disconnect()
        end
    end)
end

-- [[ 主循環（保持不動） ]] --
task.spawn(function()
    while ScreenGui.Parent do
        local cam = workspace.CurrentCamera
        pcall(function()
            if Config.Fly and lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
                local hrp = lp.Character.HumanoidRootPart
                local vel = Vector3.zero
                if u:IsKeyDown(Enum.KeyCode.W) then vel += cam.CFrame.LookVector end
                if u:IsKeyDown(Enum.KeyCode.S) then vel -= cam.CFrame.LookVector end
                if u:IsKeyDown(Enum.KeyCode.A) then vel -= cam.CFrame.RightVector end
                if u:IsKeyDown(Enum.KeyCode.D) then vel += cam.CFrame.RightVector end
                if u:IsKeyDown(Enum.KeyCode.Space) then vel += Vector3.new(0, 1, 0) end
                if u:IsKeyDown(Enum.KeyCode.LeftControl) then vel -= Vector3.new(0, 1, 0) end
                hrp.Velocity = vel * Config.FlySpeed
            end
            if Config.Aimbot and u:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
                local target = nil; local dist = Config.FOV
                for _, v in pairs(p:GetPlayers()) do
                    if v ~= lp and v.Character and v.Character:FindFirstChild(Config.LockPart) then
                        local head = v.Character[Config.LockPart]
                        local sPos, on = cam:WorldToViewportPoint(head.Position)
                        if on and v.Character.Humanoid.Health > 0 then
                            local mag = (Vector2.new(sPos.X, sPos.Y) - u:GetMouseLocation()).Magnitude
                            if mag < dist then
                                if not Config.WallCheck or (#cam:GetPartsObscuringTarget({head.Position}, {lp.Character, v.Character}) == 0) then
                                    dist = mag; target = sPos
                                end
                            end
                        end
                    end
                end
                if target then mousemoverel(target.X - u:GetMouseLocation().X, target.Y - u:GetMouseLocation().Y) end
            end
        end)
        r.RenderStepped:Wait()
    end
end)

p.PlayerAdded:Connect(CreateESP)
for _, v in pairs(p:GetPlayers()) do CreateESP(v) end
u.InputBegan:Connect(function(i) if i.KeyCode == Config.MenuKey then Main.Visible = not Main.Visible end end)
