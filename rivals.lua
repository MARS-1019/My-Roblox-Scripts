-- [[ 核心守護與美化 ]] --
if _G.MarsLoaded then 
    local old = game:GetService("CoreGui"):FindFirstChild("MarsHub_V3")
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
    WallShot = false,
    Noclip = false,
    FOV = 200,
    -- [[ ESP 細分配置 ]] --
    ESP_Box = false,
    ESP_Skeleton = false,
    ESP_Health = false,
    ESP_Name = false,
    ESP_Distance = false,
    -- [[ 其他 ]] --
    Fly = false,
    FlySpeed = 50,
    MenuKey = Enum.KeyCode.Insert
}

-- [[ 1. 高級霓虹 GUI 構建 ]] --
local ScreenGui = Instance.new("ScreenGui", cg)
ScreenGui.Name = "MarsHub_V3"

local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 280, 0, 550); Main.Position = UDim2.new(0.1, 0, 0.2, 0)
Main.BackgroundColor3 = Color3.fromRGB(10, 10, 12); Main.BorderSizePixel = 0; Main.Active = true; Main.Draggable = true
local Corner = Instance.new("UICorner", Main); Corner.CornerRadius = UDim.new(0, 10)
local Stroke = Instance.new("UIStroke", Main); Stroke.Color = Color3.fromRGB(0, 255, 255); Stroke.Thickness = 2

local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1, 0, 0, 45); Title.Text = "MARS HUB V3 • NEON"; Title.TextColor3 = Color3.fromRGB(0, 255, 255)
Title.Font = Enum.Font.GothamBold; Title.TextSize = 16; Title.BackgroundTransparency = 1

local Container = Instance.new("ScrollingFrame", Main)
Container.Size = UDim2.new(1, -20, 1, -70); Container.Position = UDim2.new(0, 10, 0, 50)
Container.BackgroundTransparency = 1; Container.CanvasSize = UDim2.new(0, 0, 4, 0); Container.ScrollBarThickness = 2
local List = Instance.new("UIListLayout", Container); List.Padding = UDim.new(0, 10)

-- [[ UI 輔助函數 ]] --
local function CreateToggle(text, configKey)
    local b = Instance.new("TextButton", Container)
    b.Size = UDim2.new(1, 0, 0, 35); b.BackgroundColor3 = Color3.fromRGB(25, 25, 30); b.Text = text
    b.TextColor3 = Color3.fromRGB(200, 200, 200); b.Font = Enum.Font.Gotham; b.TextSize = 14
    Instance.new("UICorner", b)
    local s = Instance.new("UIStroke", b); s.Color = Color3.fromRGB(50, 50, 50); s.Thickness = 1
    
    b.MouseButton1Click:Connect(function()
        Config[configKey] = not Config[configKey]
        b.TextColor3 = Config[configKey] and Color3.fromRGB(0, 255, 255) or Color3.fromRGB(200, 200, 200)
        s.Color = Config[configKey] and Color3.fromRGB(0, 255, 255) or Color3.fromRGB(50, 50, 50)
    end)
end

-- [[ 功能按鈕佈署 ]] --
CreateToggle("Silent Aimbot (自瞄)", "Aimbot")
CreateToggle("Wall Shot (子彈穿牆)", "WallShot")
CreateToggle("Noclip (人物穿牆)", "Noclip")
CreateToggle("ESP Box (方框)", "ESP_Box")
CreateToggle("ESP Skeleton (骨架)", "ESP_Skeleton")
CreateToggle("ESP Health (血條)", "ESP_Health")
CreateToggle("ESP Name (名字)", "ESP_Name")
CreateToggle("ESP Distance (距離)", "ESP_Distance")
CreateToggle("Flight (飛行)", "Fly")

-- [[ 2. 高級 ESP 繪製系統 ]] --
local function DrawESP(player)
    local box = Drawing.new("Square"); box.Visible = false; box.Color = Color3.new(1,1,1); box.Thickness = 1
    local name = Drawing.new("Text"); name.Visible = false; name.Color = Color3.new(1,1,1); name.Size = 14; name.Center = true; name.Outline = true
    local hpLine = Drawing.new("Line"); hpLine.Visible = false; hpLine.Thickness = 2
    
    r.RenderStepped:Connect(function()
        local char = player.Character
        if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Humanoid") and player ~= lp and char.Humanoid.Health > 0 then
            local hrp = char.HumanoidRootPart
            local pos, on = workspace.CurrentCamera:WorldToViewportPoint(hrp.Position)
            
            if on then
                local size = 2000 / pos.Z
                -- 方框
                if Config.ESP_Box then
                    box.Visible = true; box.Size = Vector2.new(size, size * 1.5)
                    box.Position = Vector2.new(pos.X - size/2, pos.Y - size/2); box.Color = Color3.fromRGB(0, 255, 255)
                else box.Visible = false end
                -- 名字與距離
                if Config.ESP_Name then
                    name.Visible = true; name.Text = player.Name .. (Config.ESP_Distance and " ["..math.floor((lp.Character.Head.Position - hrp.Position).Magnitude).."m]" or "")
                    name.Position = Vector2.new(pos.X, pos.Y - size/2 - 20)
                else name.Visible = false end
                -- 血條 (邏輯簡化版)
                if Config.ESP_Health then
                    hpLine.Visible = true; hpLine.From = Vector2.new(pos.X - size/2 - 5, pos.Y + size/2)
                    hpLine.To = Vector2.new(pos.X - size/2 - 5, pos.Y + size/2 - (size * 1.5 * (char.Humanoid.Health/100)))
                    hpLine.Color = Color3.new(0, 1, 0)
                else hpLine.Visible = false end
                
                -- [[ 骨架系統 Skeleton (Highlight 替代版) ]] --
                if Config.ESP_Skeleton then
                    local h = char:FindFirstChild("Neon_Skeleton") or Instance.new("Highlight", char)
                    h.Name = "Neon_Skeleton"; h.FillTransparency = 1; h.OutlineColor = Color3.fromRGB(255, 255, 255); h.Enabled = true
                elseif char:FindFirstChild("Neon_Skeleton") then char.Neon_Skeleton.Enabled = false end
                
                return
            end
        end
        box.Visible = false; name.Visible = false; hpLine.Visible = false
    end)
end

-- [[ 3. 核心暴力邏輯 (Noclip/Wallshot/Aimbot) ]] --
r.Stepped:Connect(function()
    pcall(function()
        if Config.Noclip and lp.Character then
            for _, v in pairs(lp.Character:GetDescendants()) do
                if v:IsA("BasePart") then v.CanCollide = false end
            end
        end
        
        if Config.Fly and lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
            lp.Character.HumanoidRootPart.Velocity = Vector3.new(0,2,0) -- 懸停力
        end

        if Config.Aimbot and u:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
            local target, dist = nil, Config.FOV
            for _, v in pairs(p:GetPlayers()) do
                if v ~= lp and v.Character and v.Character:FindFirstChild("Head") then
                    local head = v.Character.Head
                    local sPos, on = workspace.CurrentCamera:WorldToViewportPoint(head.Position)
                    if on and v.Character.Humanoid.Health > 0 then
                        local mag = (Vector2.new(sPos.X, sPos.Y) - u:GetMouseLocation()).Magnitude
                        if mag < dist then
                            -- 子彈穿牆判斷
                            if Config.WallShot or #workspace.CurrentCamera:GetPartsObscuringTarget({head.Position}, {lp.Character, v.Character}) == 0 then
                                target = sPos; dist = mag
                            end
                        end
                    end
                end
            end
            if target then mousemoverel(target.X - u:GetMouseLocation().X, target.Y - u:GetMouseLocation().Y) end
        end
    end)
end)

-- 初始化
for _, v in pairs(p:GetPlayers()) do DrawESP(v) end
p.PlayerAdded:Connect(DrawESP)
u.InputBegan:Connect(function(i) if i.KeyCode == Config.MenuKey then Main.Visible = not Main.Visible end end)
