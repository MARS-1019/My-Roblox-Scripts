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
    WallCheck = false, -- Wall Check 開關
    FOV = 150,
    LockPart = "Head",
    ShowFOV = false,
    ESP = false,
    ESP_Box = false,
    ESP_Tracer = false,
    Fly = false,
    FlySpeed = 50,
    MenuKey = Enum.KeyCode.Insert
}

-- [[ UI 建立 ]] --
local ScreenGui = Instance.new("ScreenGui", cg)
ScreenGui.Name = "MarsHub_V2"
ScreenGui.ResetOnSpawn = false

local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 250, 0, 450)
Main.Position = UDim2.new(0.1, 0, 0.2, 0)
Main.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 8)

local Container = Instance.new("ScrollingFrame", Main)
Container.Size = UDim2.new(1, -20, 1, -60)
Container.Position = UDim2.new(0, 10, 0, 50)
Container.BackgroundTransparency = 1
Container.CanvasSize = UDim2.new(0, 0, 2, 0)
Container.ScrollBarThickness = 2
Instance.new("UIListLayout", Container).Padding = UDim.new(0, 8)

-- UI 組件
local function AddToggle(text, configKey)
    local Btn = Instance.new("TextButton", Container)
    Btn.Size = UDim2.new(1, 0, 0, 30)
    Btn.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    Btn.Text = text .. ": OFF"
    Btn.TextColor3 = Color3.new(0.8, 0.8, 0.8)
    Btn.Font = Enum.Font.Gotham; Btn.TextSize = 13
    Instance.new("UICorner", Btn)
    Btn.MouseButton1Click:Connect(function()
        Config[configKey] = not Config[configKey]
        Btn.Text = text .. ": " .. (Config[configKey] and "ON" or "OFF")
        Btn.BackgroundColor3 = Config[configKey] and Color3.fromRGB(200, 0, 0) or Color3.fromRGB(35, 35, 40)
    end)
end

local function AddSlider(text, min, max, configKey)
    local Frame = Instance.new("Frame", Container); Frame.Size = UDim2.new(1, 0, 0, 45); Frame.BackgroundTransparency = 1
    local Label = Instance.new("TextLabel", Frame); Label.Size = UDim2.new(1, 0, 0, 15); Label.Text = text .. ": " .. Config[configKey]; Label.TextColor3 = Color3.new(1, 1, 1); Label.BackgroundTransparency = 1
    local SliderBG = Instance.new("Frame", Frame); SliderBG.Size = UDim2.new(1, 0, 0, 8); SliderBG.Position = UDim2.new(0, 0, 0, 25); SliderBG.BackgroundColor3 = Color3.fromRGB(30,30,30)
    local Bar = Instance.new("Frame", SliderBG); Bar.Size = UDim2.new((Config[configKey]-min)/(max-min),0,1,0); Bar.BackgroundColor3 = Color3.fromRGB(200,0,0); Bar.BorderSizePixel = 0
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

-- 選單設置
AddToggle("Silent Lock (右鍵)", "Aimbot")
AddToggle("Wall Check (不鎖牆後)", "WallCheck")
AddToggle("Show FOV", "ShowFOV")
AddSlider("Aimbot FOV", 50, 1000, "FOV")
AddToggle("Enable ESP", "ESP")
AddToggle("Box ESP", "ESP_Box")
AddToggle("Snaplines", "ESP_Tracer")
AddToggle("Fly Mode", "Fly")
AddSlider("Fly Speed", 10, 500, "FlySpeed")

-- [[ 核心功能 ]] --
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1; FOVCircle.Color = Color3.new(1, 0, 0); FOVCircle.Transparency = 0.8

-- Wall Check 函數
local function IsVisible(targetPart)
    if not Config.WallCheck then return true end
    local cam = workspace.CurrentCamera
    local char = lp.Character
    if not char then return false end
    
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {char, cam} -- 排除自己和攝像機
    
    local origin = cam.CFrame.Position
    local direction = (targetPart.Position - origin)
    local result = workspace:Raycast(origin, direction, params)
    
    -- 如果射線沒打到牆，或者打到的東西是目標的隊友/角色一部分
    if not result or result.Instance:IsDescendantOf(targetPart.Parent) then
        return true
    end
    return false
end

-- ESP 循環
local function CreateESP(target)
    if target == lp then return end
    local b = Drawing.new("Square"); local t = Drawing.new("Line")
    task.spawn(function()
        while target and ScreenGui.Parent do
            pcall(function()
                local char = target.Character
                local cam = workspace.CurrentCamera
                if Config.ESP and char and char:FindFirstChild("HumanoidRootPart") and char.Humanoid.Health > 0 then
                    local root = char.HumanoidRootPart
                    local pos, on = cam:WorldToViewportPoint(root.Position)
                    if on then
                        local size = 3000 / pos.Z
                        b.Visible = Config.ESP_Box; b.Size = Vector2.new(size, size * 1.5); b.Position = Vector2.new(pos.X - size/2, pos.Y - size/2); b.Color = Color3.new(1, 1, 1)
                        t.Visible = Config.ESP_Tracer; t.From = Vector2.new(cam.ViewportSize.X/2, cam.ViewportSize.Y); t.To = Vector2.new(pos.X, pos.Y + (size*0.75)); t.Color = Color3.new(1, 1, 1)
                    else b.Visible = false t.Visible = false end
                else b.Visible = false t.Visible = false end
            end)
            r.RenderStepped:Wait()
        end
        b:Remove(); t:Remove()
    end)
end

-- 主循環
task.spawn(function()
    while ScreenGui.Parent do
        pcall(function()
            local cam = workspace.CurrentCamera
            local mPos = u:GetMouseLocation()
            FOVCircle.Visible = Config.ShowFOV; FOVCircle.Radius = Config.FOV; FOVCircle.Position = mPos

            -- 飛行 (含空格上升/Ctrl下降)
            if Config.Fly and lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
                local hrp = lp.Character.HumanoidRootPart
                local vel = Vector3.new(0, 0, 0)
                if u:IsKeyDown(Enum.KeyCode.W) then vel += cam.CFrame.LookVector end
                if u:IsKeyDown(Enum.KeyCode.S) then vel -= cam.CFrame.LookVector end
                if u:IsKeyDown(Enum.KeyCode.A) then vel -= cam.CFrame.RightVector end
                if u:IsKeyDown(Enum.KeyCode.D) then vel += cam.CFrame.RightVector end
                if u:IsKeyDown(Enum.KeyCode.Space) then vel += Vector3.new(0, 1, 0) end
                if u:IsKeyDown(Enum.KeyCode.LeftControl) then vel -= Vector3.new(0, 1, 0) end
                hrp.Velocity = vel * Config.FlySpeed
            end

            -- 強力鎖死 + Wall Check
            if Config.Aimbot and u:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
                local target = nil; local dist = Config.FOV
                for _, v in pairs(p:GetPlayers()) do
                    if v ~= lp and v.Character and v.Character:FindFirstChild(Config.LockPart) then
                        local targetPart = v.Character[Config.LockPart]
                        if v.Character.Humanoid.Health > 0 then
                            local sPos, on = cam:WorldToViewportPoint(targetPart.Position)
                            if on then
                                local mag = (Vector2.new(sPos.X, sPos.Y) - mPos).Magnitude
                                -- 關鍵：檢查距離 + 是否可見
                                if mag < dist and IsVisible(targetPart) then
                                    dist = mag
                                    target = sPos
                                end
                            end
                        end
                    end
                end
                if target then mousemoverel(target.X - mPos.X, target.Y - mPos.Y) end
            end
        end)
        r.RenderStepped:Wait()
    end
end)

p.PlayerAdded:Connect(CreateESP)
for _, v in pairs(p:GetPlayers()) do CreateESP(v) end
u.InputBegan:Connect(function(i) if i.KeyCode == Config.MenuKey then Main.Visible = not Main.Visible end end)
