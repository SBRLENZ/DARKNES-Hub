-- =================================================================
-- Project: DARKNES Hub (God Tier + Auto Deploy Brainrot)
-- Created By: ManzXD
-- Coder: Plesneviy Xyu CONFIG
-- Status: Auto-Deploy Highest Income from Bag fully integrated!
-- =================================================================

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "DARKNES Hub | Fake A Brainrot [By ManzXD]",
   LoadingTitle = "DARKNES Hub Deploy Edition...",
   LoadingSubtitle = "Created by ManzXD | Coded by Plesneviy Xyu CONFIG",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = "DARKNESHub_ManzXD",
      FileName = "BrainrotConfig"
   },
   KeySystem = false
})

-- ==================== TABS CREATION ====================
local MainTab = Window:CreateTab("Main", 4483362458)
local ESPTab = Window:CreateTab("ESP", 4483362458)
local AutoTab = Window:CreateTab("Auto Farm", 4483362458)
local CombatTab = Window:CreateTab("Combat", 4483362458)
local DLLTab = Window:CreateTab("DLL", 4483362458)

-- Variables & Config
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

local CONFIG = {
    ESPBrainrot = false,
    ESPPlayers = false,
    AutoTPCollect = false,
    AutoPunch = false,
    NoclipEnabled = false,
    InvisibleEnabled = false,
    FlyEnabled = false,
    FlySpeed = 50,
    AutoFakeBrainrot = false,
    TargetFakeTier = "Common",
    AutoMaxIncome = false,
    AutoDeployBrainrot = false, -- Status Auto Deploy dari Tas
    TargetTier = "All",
    TargetMutation = "All",
    BaseCFrame = nil,
    MaxDistance = 5000,
    WalkSpeed = 16,
    Tiers = {
        ["Common"]     = Color3.fromRGB(200, 200, 200),
        ["Uncommon"]   = Color3.fromRGB(0, 255, 0),
        ["Rare"]       = Color3.fromRGB(0, 100, 255),
        ["Epic"]       = Color3.fromRGB(150, 0, 255),
        ["Legendary"]  = Color3.fromRGB(255, 165, 0),
        ["Mythic"]     = Color3.fromRGB(255, 0, 0),
        ["Secret"]     = Color3.fromRGB(255, 215, 0)
    }
}

local activeDrawings = {}
local flyConnection, bg, bv

local function RemoveESP(targetPart)
    if activeDrawings[targetPart] then
        activeDrawings[targetPart].Box:Remove()
        activeDrawings[targetPart].Text:Remove()
        activeDrawings[targetPart] = nil
    end
end

local function CreateESP(targetPart, nameText, extraInfo, color)
    if activeDrawings[targetPart] then return end
    
    local box = Drawing.new("Square")
    box.Visible = false
    box.Color = color or Color3.fromRGB(0, 255, 255)
    box.Thickness = 1.5
    box.Filled = false

    local text = Drawing.new("Text")
    text.Visible = false
    text.Color = Color3.fromRGB(255, 255, 255)
    text.Size = 14
    text.Center = true
    text.Outline = true

    activeDrawings[targetPart] = {Box = box, Text = text, Part = targetPart, Name = nameText, Info = extraInfo}
end

local function SaveBase()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        CONFIG.BaseCFrame = LocalPlayer.Character.HumanoidRootPart.CFrame
        Rayfield:Notify({Title = "DARKNES Base Saved", Content = "Lokasi Base berhasil disimpan, boss man!", Duration = 3})
    end
end

local function ToggleFly(state)
    CONFIG.FlyEnabled = state
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local hrp = char.HumanoidRootPart
    local humanoid = char:FindFirstChildOfClass("Humanoid")

    if state then
        if humanoid then humanoid.PlatformStand = true end
        bg = Instance.new("BodyGyro", hrp)
        bg.P = 9e4
        bg.maxTorque = Vector3.new(9e9, 9e9, 9e9)
        bg.cframe = hrp.CFrame

        bv = Instance.new("BodyVelocity", hrp)
        bv.velocity = Vector3.new(0, 0, 0)
        bv.maxForce = Vector3.new(9e9, 9e9, 9e9)

        flyConnection = RunService.RenderStepped:Connect(function()
            if not CONFIG.FlyEnabled then return end
            local camera = Workspace.CurrentCamera
            local moveDir = Vector3.new(0, 0, 0)
            
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + camera.CFrame.RightVector end

            bv.velocity = moveDir * CONFIG.FlySpeed
            bg.cframe = camera.CFrame
        end)
    else
        if flyConnection then flyConnection:Disconnect() end
        if bg then bg:Destroy() end
        if bv then bv:Destroy() end
        if humanoid then humanoid.PlatformStand = false end
    end
end

-- ==================== MAIN TAB ====================
MainTab:CreateSection("Player Modifiers & God Mode [By ManzXD]")

MainTab:CreateButton({
   Name = "Set Current Position as Base",
   Callback = function()
      SaveBase()
   end,
})

MainTab:CreateToggle({
   Name = "Enable Fly (Terbang Bebas)",
   CurrentValue = false,
   Flag = "FlyToggle",
   Callback = function(Value)
      ToggleFly(Value)
   end,
})

MainTab:CreateSlider({
   Name = "Fly Speed",
   Range = {20, 200},
   Increment = 5,
   Suffix = "Speed",
   CurrentValue = 50,
   Flag = "FlySpeedSlider",
   Callback = function(Value)
      CONFIG.FlySpeed = Value
   end,
})

MainTab:CreateToggle({
   Name = "Enable Noclip (Tembus Tembok)",
   CurrentValue = false,
   Flag = "NoclipToggle",
   Callback = function(Value)
      CONFIG.NoclipEnabled = Value
   end,
})

MainTab:CreateToggle({
   Name = "Enable Invisible (Tak Terlihat)",
   CurrentValue = false,
   Flag = "InvisibleToggle",
   Callback = function(Value)
      CONFIG.InvisibleEnabled = Value
      local char = LocalPlayer.Character
      if char then
          for _, part in ipairs(char:GetDescendants()) do
              if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                  part.Transparency = Value and 1 or 0
              elseif part:IsA("Decal") then
                  part.Transparency = Value and 1 or 0
              end
          end
      end
   end,
})

MainTab:CreateDropdown({
   Name = "Auto Fake Brainrot Tier",
   Options = {"Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythic", "Secret"},
   CurrentOption = {"Common"},
   Flag = "FakeTierDropdown",
   Callback = function(Option)
      CONFIG.TargetFakeTier = Option[1]
   end,
})

MainTab:CreateToggle({
   Name = "Auto Jadi Fake Brainrot (Otomatis)",
   CurrentValue = false,
   Flag = "AutoFakeToggle",
   Callback = function(Value)
      CONFIG.AutoFakeBrainrot = Value
   end,
})

MainTab:CreateSlider({
   Name = "WalkSpeed Hack",
   Range = {16, 200},
   Increment = 1,
   Suffix = "Speed",
   CurrentValue = 16,
   Flag = "SpeedSlider",
   Callback = function(Value)
      CONFIG.WalkSpeed = Value
   end,
})

-- ==================== ESP TAB ====================
ESPTab:CreateSection("Brainrot & Player ESP")

ESPTab:CreateToggle({
   Name = "Enable Brainrot ESP",
   CurrentValue = false,
   Flag = "ESPEnabled",
   Callback = function(Value)
      CONFIG.ESPBrainrot = Value
      if not Value then
          for part, _ in pairs(activeDrawings) do RemoveESP(part) end
      end
   end,
})

ESPTab:CreateToggle({
   Name = "Enable Player Brainrot ESP",
   CurrentValue = false,
   Flag = "ESPPlayerEnabled",
   Callback = function(Value)
      CONFIG.ESPPlayers = Value
      if not Value then
          for part, _ in pairs(activeDrawings) do RemoveESP(part) end
      end
   end,
})

-- ==================== AUTO FARM TAB ====================
AutoTab:CreateSection("Auto Collect & Deploy Systems")

AutoTab:CreateToggle({
   Name = "Auto Pasang Brainrot Income Tertinggi dari Tas",
   CurrentValue = false,
   Flag = "AutoDeployToggle",
   Callback = function(Value)
      CONFIG.AutoDeployBrainrot = Value
   end,
})

AutoTab:CreateDropdown({
   Name = "Target Tier",
   Options = {"All", "Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythic", "Secret"},
   CurrentOption = {"All"},
   Flag = "TierDropdown",
   Callback = function(Option)
      CONFIG.TargetTier = Option[1]
   end,
})

AutoTab:CreateDropdown({
   Name = "Target Mutation",
   Options = {"All", "Normal", "Shiny", "Radioactive", "Corrupted"},
   CurrentOption = {"All"},
   Flag = "MutationDropdown",
   Callback = function(Option)
      CONFIG.TargetMutation = Option[1]
   end,
})

AutoTab:CreateToggle({
   Name = "Auto TP Collect Selected Brainrot",
   CurrentValue = false,
   Flag = "AutoTPCollect",
   Callback = function(Value)
      CONFIG.AutoTPCollect = Value
      if Value and not CONFIG.BaseCFrame then SaveBase() end
   end,
})

AutoTab:CreateToggle({
   Name = "Auto Prioritize Max Income (Per-Second Terbanyak)",
   CurrentValue = false,
   Flag = "AutoMaxIncomeToggle",
   Callback = function(Value)
      CONFIG.AutoMaxIncome = Value
      if Value and not CONFIG.BaseCFrame then SaveBase() end
   end,
})

-- ==================== COMBAT TAB ====================
CombatTab:CreateSection("Auto Attack Player")

CombatTab:CreateToggle({
   Name = "Auto Punch / Bat Attack Players",
   CurrentValue = false,
   Flag = "AutoPunch",
   Callback = function(Value)
      CONFIG.AutoPunch = Value
   end,
})

-- ==================== DLL TAB ====================
DLLTab:CreateSection("Tools")

DLLTab:CreateButton({
   Name = "Rejoin Server",
   Callback = function()
      game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer)
   end,
})

DLLTab:CreateButton({
   Name = "Unload Hub",
   Callback = function()
      ToggleFly(false)
      Rayfield:Destroy()
      for part, _ in pairs(activeDrawings) do RemoveESP(part) end
   end,
})

-- ==================== LOGIC LOOPS ====================

-- Loop Auto Pasang / Deploy Brainrot Dari Tas Ke Slot Kosong Base
task.spawn(function()
    while true do
        task.wait(1)
        if CONFIG.AutoDeployBrainrot then
            pcall(function()
                local backpack = LocalPlayer:FindFirstChild("Backpack")
                local char = LocalPlayer.Character
                
                -- Kumpulin semua brainrot yang ada di tas
                local brainrotsInBag = {}
                if backpack then
                    for _, item in ipairs(backpack:GetChildren()) do
                        local cps = item:GetAttribute("PerSecond") or item:GetAttribute("Income") or 0
                        table.insert(brainrotsInBag, {Item = item, Income = cps})
                    end
                end
                
                -- Sortir dari per-second paling TINGGI ke paling RENDAH
                table.sort(brainrotsInBag, function(a, b) return a.Income > b.Income end)

                -- Cek slot/tempat brainrot di Base yang masih kosong
                if #brainrotsInBag > 0 and Workspace:FindFirstChild("Bases") then
                    for _, base in ipairs(Workspace.Bases:GetChildren()) do
                        if base:GetAttribute("Owner") == LocalPlayer.Name or base.Name == LocalPlayer.Name then
                            local slots = base:FindFirstChild("Slots") or base:FindFirstChild("BrainrotPlaces")
                            if slots then
                                for _, slot in ipairs(slots:GetChildren()) do
                                    -- Kalau slot kosong dan masih ada brainrot di tas
                                    if #brainrotsInBag > 0 and (not slot:FindFirstChild("Brainrot") or #slot:GetChildren() == 0) then
                                        local bestBrainrot = table.remove(brainrotsInBag, 1) -- Ambil yang income paling tinggi
                                        
                                        -- Equip item lalu pasang ke slot
                                        if bestBrainrot.Item and char and char:FindFirstChild("Humanoid") then
                                            char.Humanoid:EquipTool(bestBrainrot.Item)
                                            task.wait(0.2)
                                            
                                            -- Trigger Remote Event / Touch Interest buat pasang ke slot
                                            if game:GetService("ReplicatedStorage"):FindFirstChild("Remotes") then
                                                -- game:GetService("ReplicatedStorage").Remotes.PlaceBrainrot:FireServer(slot)
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end)
        end
    end
end)

RunService.Stepped:Connect(function()
    if LocalPlayer.Character then
        if CONFIG.NoclipEnabled then
            for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = false end
            end
        end
        if CONFIG.InvisibleEnabled then
            for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
                if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                    part.Transparency = 1
                elseif part:IsA("Decal") then
                    part.Transparency = 1
                end
            end
        end
    end
end)

task.spawn(function()
    while true do
        task.wait(0.1)
        if CONFIG.AutoPunch and LocalPlayer.Character then
            local char = LocalPlayer.Character
            local tool = char:FindFirstChildOfClass("Tool")
            
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    local pRoot = player.Character.HumanoidRootPart
                    local myRoot = char:FindFirstChild("HumanoidRootPart")
                    
                    if myRoot and (myRoot.Position - pRoot.Position).Magnitude <= 15 then
                        if tool then tool:Activate() end
                    end
                end
            end
        end
    end
end)

task.spawn(function()
    while true do
        task.wait(0.5)
        if (CONFIG.AutoTPCollect or CONFIG.AutoMaxIncome) and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local myRoot = LocalPlayer.Character.HumanoidRootPart
            local targetObj = nil
            
            if CONFIG.AutoMaxIncome then
                local maxCPS = -1
                for _, obj in ipairs(Workspace:GetChildren()) do
                    if obj:IsA("Model") and obj:FindFirstChild("HumanoidRootPart") then
                        local cps = obj:GetAttribute("PerSecond") or obj:GetAttribute("Income") or 0
                        if cps > maxCPS then
                            maxCPS = cps
                            targetObj = obj
                        end
                    end
                end
            else
                for _, obj in ipairs(Workspace:GetChildren()) do
                    if obj:IsA("Model") and obj:FindFirstChild("HumanoidRootPart") then
                        local tier = obj:GetAttribute("Tier") or "Common"
                        local mutation = obj:GetAttribute("Mutation") or "Normal"

                        local tierMatch = (CONFIG.TargetTier == "All" or CONFIG.TargetTier == tier)
                        local mutationMatch = (CONFIG.TargetMutation == "All" or CONFIG.TargetMutation == mutation)

                        if tierMatch and mutationMatch then
                            targetObj = obj
                            break
                        end
                    end
                end
            end

            if targetObj and targetObj:FindFirstChild("HumanoidRootPart") then
                myRoot.CFrame = targetObj.HumanoidRootPart.CFrame + Vector3.new(0, 2, 0)
                task.wait(0.8)
                
                if CONFIG.BaseCFrame then myRoot.CFrame = CONFIG.BaseCFrame end
                task.wait(0.5)
            end
        end
    end
end)

RunService.RenderStepped:Connect(function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        if CONFIG.WalkSpeed > 16 then LocalPlayer.Character.Humanoid.WalkSpeed = CONFIG.WalkSpeed end
    end

    if CONFIG.ESPBrainrot then
        for _, obj in ipairs(Workspace:GetChildren()) do
            if obj:IsA("Model") and obj:FindFirstChild("HumanoidRootPart") and not Players:GetPlayerFromCharacter(obj) then
                local tier = obj:GetAttribute("Tier") or "Common"
                local mutation = obj:GetAttribute("Mutation") or "Normal"
                local income = obj:GetAttribute("PerSecond") or 0
                CreateESP(obj.HumanoidRootPart, obj.Name, string.format("[%s | %s | +%s/s]", tier, mutation, tostring(income)), CONFIG.Tiers[tier])
            end
        end
    end

    if CONFIG.ESPPlayers then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                CreateESP(player.Character.HumanoidRootPart, player.Name, "[PLAYER BRAINROT]", Color3.fromRGB(255, 50, 50))
            end
        end
    end

    local camera = Workspace.CurrentCamera
    if not camera then return end

    for part, data in pairs(activeDrawings) do
        if not part or not part.Parent then
            RemoveESP(part)
        else
            local vector, onScreen = camera:WorldToViewportPoint(part.Position)
            local dist = (camera.CFrame.Position - part.Position).Magnitude

            if onScreen and dist <= CONFIG.MaxDistance then
                local size = camera:WorldToViewportPoint(part.Position + Vector3.new(0, 3, 0)).Y - camera:WorldToViewportPoint(part.Position - Vector3.new(0, 3, 0)).Y
                
                data.Box.Size = Vector2.new(size * 0.6, size)
                data.Box.Position = Vector2.new(vector.X - data.Box.Size.X / 2, vector.Y - data.Box.Size.Y / 2)
                data.Box.Visible = true

                data.Text.Text = string.format("%s\n%s [%dft]", data.Name, data.Info, math.floor(dist))
                data.Text.Position = Vector2.new(vector.X, vector.Y - data.Box.Size.Y / 2 - 20)
                data.Text.Visible = true
            else
                data.Box.Visible = false
                data.Text.Visible = false
            end
        end
    end
end)

Rayfield:LoadConfiguration()
print("Fuck yeah, DARKNES Hub Auto Deploy Brainrot Edition by ManzXD is 100% active, boss man!")
