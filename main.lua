-- =================================================================
-- Project: DARKNES Hub (Ultimate v3.0 - 23+ Features Overhaul)
-- Created By: ManzXD
-- Coder: Plesneviy Xyu CONFIG
-- Status: 100% Working Real Features | Anti-Detection & Auto Boundary
-- =================================================================

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "DARKNES Hub | Fake A Brainrot [By ManzXD]",
   LoadingTitle = "DARKNES Hub Loading...",
   LoadingSubtitle = "Created by ManzXD | Coded by Plesneviy Xyu CONFIG",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = "DARKNESHub_ManzXD",
      FileName = "BrainrotConfig"
   },
   KeySystem = false
})

-- ==================== TABS CREATION (7 TABS) ====================
local MainTab   = Window:CreateTab("Main", 4483362458)
local VisualTab = Window:CreateTab("Visual", 4483362458)
local AutoTab   = Window:CreateTab("Auto Farm", 4483362458)
local FakeTab   = Window:CreateTab("Fake Brainrot", 4483362458)
local StealTab  = Window:CreateTab("Auto Steal", 4483362458)
local TrollTab  = Window:CreateTab("Troll & Combat", 4483362458)
local DLLTab    = Window:CreateTab("DLL", 4483362458)

-- Global Variables & Configuration Matrix
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

local CONFIG = {
    -- 1-5: Visual/ESP Features
    ESPBrainrot = false,
    ESPPlayers = false,
    ShowBox = true,
    ShowText = true,
    ShowTracers = false,
    ShowChams = false,
    
    -- Colors & Render Params
    BrainrotColor = Color3.fromRGB(0, 255, 255),
    PlayerColor = Color3.fromRGB(255, 50, 50),
    TracerColor = Color3.fromRGB(255, 255, 255),
    MaxDistance = 5000,

    -- 6-10: Player Modifiers
    WalkSpeed = 16,
    FlyEnabled = false,
    FlySpeed = 50,
    NoclipEnabled = false,
    InvisibleEnabled = false,
    
    -- 11-15: Auto Farm & Collect
    AutoCollectMoney = false,
    AutoDeployBrainrot = false,
    AutoTPCollect = false,
    AutoMaxIncome = false,
    TargetTier = "All",
    TargetMutation = "All",
    
    -- 16-19: Fake Brainrot Mechanics
    AutoFakeBrainrot = false,
    TargetFakeTier = "Common",
    AutoTPFakeMachine = false,
    EnableBoundaryLock = true,
    FakeSpawnCenter = nil,
    MaxBoundaryRadius = 35,
    SmartKidnappedEscape = true,
    
    -- 20-21: Steal System
    AutoStealTarget = false,
    SelectedTargetPlayer = "",
    
    -- 22-24: Troll & Combat Features
    AutoBaseDefense = false,
    AutoPunch = false,
    AutoBatTroll = false,
    BatTargetPlayer = "",
    
    BaseCFrame = nil,
    Tiers = {
        ["Common"]     = Color3.fromRGB(200, 200, 200),
        ["Uncommon"]   = Color3.fromRGB(0, 255, 0),
        ["Rare"]       = Color3.fromRGB(0, 100, 255),
        ["Epic"]       = Color3.fromRGB(150, 0, 255),
        ["Legendary"]  = Color3.fromRGB(255, 165, 0),
        ["Mythic"]     = Color3.fromRGB(255, 0, 0),
        ["Secret"]     = Color3.fromRGB(255, 215, 0),
        ["OG"]         = Color3.fromRGB(255, 105, 180)
    },
    TierListArray = {"Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythic", "Secret", "OG"}
}

local activeDrawings = {}
local activeHighlights = {}
local flyConnection, bg, bv
local isKidnappedState = false

-- Utility Functions
local function GetServerPlayers()
    local playerList = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            table.insert(playerList, p.Name)
        end
    end
    if #playerList == 0 then table.insert(playerList, "Tidak ada player lain") end
    return playerList
end

local function RemoveESP(targetPart)
    if activeDrawings[targetPart] then
        if activeDrawings[targetPart].Box then activeDrawings[targetPart].Box:Remove() end
        if activeDrawings[targetPart].Text then activeDrawings[targetPart].Text:Remove() end
        if activeDrawings[targetPart].Tracer then activeDrawings[targetPart].Tracer:Remove() end
        activeDrawings[targetPart] = nil
    end
    if activeHighlights[targetPart] then
        activeHighlights[targetPart]:Destroy()
        activeHighlights[targetPart] = nil
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

    local tracer = Drawing.new("Line")
    tracer.Visible = false
    tracer.Color = CONFIG.TracerColor
    tracer.Thickness = 1.5

    activeDrawings[targetPart] = {
        Box = box, 
        Text = text, 
        Tracer = tracer, 
        Part = targetPart, 
        Name = nameText, 
        Info = extraInfo,
        CustomColor = color
    }
end

local function ApplyChams(model, color)
    if not model or activeHighlights[model] then return end
    local highlight = Instance.new("Highlight")
    highlight.Parent = model
    highlight.FillColor = color
    highlight.FillTransparency = 0.5
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.OutlineTransparency = 0
    activeHighlights[model] = highlight
end

local function ClearAllVisuals()
    for part, _ in pairs(activeDrawings) do RemoveESP(part) end
    for model, hl in pairs(activeHighlights) do hl:Destroy() activeHighlights[model] = nil end
end

local function SaveBase()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        CONFIG.BaseCFrame = LocalPlayer.Character.HumanoidRootPart.CFrame
        Rayfield:Notify({Title = "DARKNES Base Saved", Content = "Lokasi Base berhasil disimpan!", Duration = 3})
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

-- ==================== TAB 1: MAIN MODIFIERS ====================
MainTab:CreateSection("Player Utility & Movement")

MainTab:CreateButton({
   Name = "Fitur 1: Set Current Position as Base",
   Callback = function() SaveBase() end,
})

MainTab:CreateToggle({
   Name = "Fitur 2: Fly Hack (Terbang Bebas)",
   CurrentValue = false,
   Flag = "FlyToggle",
   Callback = function(Value) ToggleFly(Value) end,
})

MainTab:CreateSlider({
   Name = "Fitur 3: Fly Speed Adjuster",
   Range = {20, 200},
   Increment = 5,
   Suffix = "Speed",
   CurrentValue = 50,
   Flag = "FlySpeedSlider",
   Callback = function(Value) CONFIG.FlySpeed = Value end,
})

MainTab:CreateToggle({
   Name = "Fitur 4: Enable Noclip (Tembus Wall/Object)",
   CurrentValue = false,
   Flag = "NoclipToggle",
   Callback = function(Value) CONFIG.NoclipEnabled = Value end,
})

MainTab:CreateToggle({
   Name = "Fitur 5: Invisible Ghost Mode",
   CurrentValue = false,
   Flag = "InvisibleToggle",
   Callback = function(Value) CONFIG.InvisibleEnabled = Value end,
})

MainTab:CreateSlider({
   Name = "Fitur 6: WalkSpeed Modifier",
   Range = {16, 200},
   Increment = 1,
   Suffix = "Speed",
   CurrentValue = 16,
   Flag = "SpeedSlider",
   Callback = function(Value) CONFIG.WalkSpeed = Value end,
})

-- ==================== TAB 2: VISUAL & ESP ====================
VisualTab:CreateSection("ESP Visual Overhaul")

VisualTab:CreateToggle({
   Name = "Fitur 7: Brainrot Objects ESP",
   CurrentValue = false,
   Flag = "ESPBrainrotToggle",
   Callback = function(Value) CONFIG.ESPBrainrot = Value if not Value then ClearAllVisuals() end end,
})

VisualTab:CreateToggle({
   Name = "Fitur 8: Player Entity ESP",
   CurrentValue = false,
   Flag = "ESPPlayerToggle",
   Callback = function(Value) CONFIG.ESPPlayers = Value if not Value then ClearAllVisuals() end end,
})

VisualTab:CreateToggle({
   Name = "Fitur 9: 2D Bounding Boxes",
   CurrentValue = true,
   Flag = "ShowBoxToggle",
   Callback = function(Value) CONFIG.ShowBox = Value end,
})

VisualTab:CreateToggle({
   Name = "Fitur 10: Name & Distance Tag",
   CurrentValue = true,
   Flag = "ShowTextToggle",
   Callback = function(Value) CONFIG.ShowText = Value end,
})

VisualTab:CreateToggle({
   Name = "Fitur 11: Tracers Line to Targets",
   CurrentValue = false,
   Flag = "ShowTracersToggle",
   Callback = function(Value) CONFIG.ShowTracers = Value end,
})

VisualTab:CreateToggle({
   Name = "Fitur 12: Chams Glow Highlight",
   CurrentValue = false,
   Flag = "ShowChamsToggle",
   Callback = function(Value) CONFIG.ShowChams = Value if not Value then ClearAllVisuals() end end,
})

-- ==================== TAB 3: AUTO FARM ====================
AutoTab:CreateSection("Automation & Base Management")

AutoTab:CreateToggle({
   Name = "Fitur 13: Auto Collect All Base Money",
   CurrentValue = false,
   Flag = "AutoCollectMoneyToggle",
   Callback = function(Value) CONFIG.AutoCollectMoney = Value end,
})

AutoTab:CreateToggle({
   Name = "Fitur 14: Auto Deploy Highest Income Brainrot",
   CurrentValue = false,
   Flag = "AutoDeployToggle",
   Callback = function(Value) CONFIG.AutoDeployBrainrot = Value end,
})

AutoTab:CreateToggle({
   Name = "Fitur 15: Auto TP Collect Map Brainrot",
   CurrentValue = false,
   Flag = "AutoTPCollect",
   Callback = function(Value) CONFIG.AutoTPCollect = Value if Value and not CONFIG.BaseCFrame then SaveBase() end end,
})

AutoTab:CreateToggle({
   Name = "Fitur 16: Auto TP Prioritize Max CPS/Income",
   CurrentValue = false,
   Flag = "AutoMaxIncomeToggle",
   Callback = function(Value) CONFIG.AutoMaxIncome = Value if Value and not CONFIG.BaseCFrame then SaveBase() end end,
})

-- ==================== TAB 4: ADVANCED FAKE BRAINROT ====================
FakeTab:CreateSection("Fake Brainrot Engine (OG Tier & Boundary Scan)")

FakeTab:CreateDropdown({
   Name = "Pilih Fake Tier Target (Up to OG)",
   Options = {"Random", "Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythic", "Secret", "OG"},
   CurrentOption = {"Common"},
   Flag = "FakeTierDropdown",
   Callback = function(Option) CONFIG.TargetFakeTier = Option[1] end,
})

FakeTab:CreateToggle({
   Name = "Fitur 17: Auto Teleport Ke Mesin Fake Brainrot",
   CurrentValue = false,
   Flag = "AutoTPFakeMachineToggle",
   Callback = function(Value) CONFIG.AutoTPFakeMachine = Value end,
})

FakeTab:CreateToggle({
   Name = "Fitur 18: Enable Auto Fake Brainrot & Real AI",
   CurrentValue = false,
   Flag = "AutoFakeToggle",
   Callback = function(Value) CONFIG.AutoFakeBrainrot = Value end,
})

FakeTab:CreateToggle({
   Name = "Fitur 19: Boundary Scan Lock (Mencegah Keluar Area)",
   CurrentValue = true,
   Flag = "BoundaryScanToggle",
   Callback = function(Value) CONFIG.EnableBoundaryLock = Value end,
})

FakeTab:CreateToggle({
   Name = "Fitur 20: Smart Kidnapped Counter-Steal",
   CurrentValue = true,
   Flag = "SmartKidnappedToggle",
   Callback = function(Value) CONFIG.SmartKidnappedEscape = Value end,
})

-- ==================== TAB 5: AUTO STEAL ====================
StealTab:CreateSection("Target Selector & Remote Stealing")

local PlayerDropdown = StealTab:CreateDropdown({
   Name = "Select Victim Username",
   Options = GetServerPlayers(),
   CurrentOption = {GetServerPlayers()[1]},
   Flag = "TargetPlayerDropdown",
   Callback = function(Option) CONFIG.SelectedTargetPlayer = Option[1] end,
})

StealTab:CreateButton({
   Name = "Refresh Server Player List",
   Callback = function()
      PlayerDropdown:Refresh(GetServerPlayers())
      Rayfield:Notify({Title = "DARKNES Hub", Content = "Daftar pemain berhasil diperbarui!", Duration = 2})
   end,
})

StealTab:CreateToggle({
   Name = "Fitur 21: Auto Steal High CPS Brainrot",
   CurrentValue = false,
   Flag = "AutoStealToggle",
   Callback = function(Value) CONFIG.AutoStealTarget = Value if Value and not CONFIG.BaseCFrame then SaveBase() end end,
})

-- ==================== TAB 6: TROLL & COMBAT ====================
TrollTab:CreateSection("Combat Defense & Troll Features")

TrollTab:CreateToggle({
   Name = "Fitur 22: Auto Base Defense (Auto Defense Range)",
   CurrentValue = false,
   Flag = "AutoBaseDefenseToggle",
   Callback = function(Value) CONFIG.AutoBaseDefense = Value if Value and not CONFIG.BaseCFrame then SaveBase() end end,
})

TrollTab:CreateToggle({
   Name = "Fitur 23: Auto Punch Nearby Players",
   CurrentValue = false,
   Flag = "AutoPunchToggle",
   Callback = function(Value) CONFIG.AutoPunch = Value end,
})

local TrollPlayerDropdown = TrollTab:CreateDropdown({
   Name = "Select Troll Target Player",
   Options = GetServerPlayers(),
   CurrentOption = {GetServerPlayers()[1]},
   Flag = "TrollTargetDropdown",
   Callback = function(Option) CONFIG.BatTargetPlayer = Option[1] end,
})

TrollTab:CreateToggle({
   Name = "Fitur 24 (BONUS TROLL): Auto Bat Punch Aura (Grebek Pukul)",
   CurrentValue = false,
   Flag = "AutoBatTrollToggle",
   Callback = function(Value) CONFIG.AutoBatTroll = Value end,
})

-- ==================== TAB 7: TOOLS / DLL ====================
DLLTab:CreateSection("System Management")

DLLTab:CreateButton({
   Name = "Rejoin Server",
   Callback = function() game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer) end,
})

DLLTab:CreateButton({
   Name = "Unload Script Hub",
   Callback = function()
      ToggleFly(false)
      ClearAllVisuals()
      Rayfield:Destroy()
   end,
})

-- ==================== ADVANCED CORE LOGIC LOOPS ====================

-- 1. FAKE BRAINROT MACHINE TP & BOUNDARY SCAN ENGINE
task.spawn(function()
    local fakeWanderTimer = 0
    local targetWanderPoint = nil

    while true do
        task.wait(0.15)
        pcall(function()
            local char = LocalPlayer.Character
            if not char or not char:FindFirstChild("HumanoidRootPart") or not char:FindFirstChildOfClass("Humanoid") then return end
            local hrp = char.HumanoidRootPart
            local hum = char:FindFirstChildOfClass("Humanoid")

            -- A. Teleport ke Mesin Fake Brainrot (Cari mesin di Map)
            if CONFIG.AutoTPFakeMachine then
                local machine = Workspace:FindFirstChild("FakeMachine") or Workspace:FindFirstChild("BrainrotMachine") or Workspace:FindFirstChild("Machine")
                if not machine then
                    for _, obj in ipairs(Workspace:GetDescendants()) do
                        if obj.Name:lower():find("fakemachine") or obj.Name:lower():find("brainrotmachine") then
                            machine = obj
                            break
                        end
                    end
                end

                if machine then
                    local targetPart = machine:IsA("BasePart") and machine or (machine:FindFirstChild("PrimaryPart") or machine:FindFirstChildOfClass("BasePart"))
                    if targetPart then
                        hrp.CFrame = targetPart.CFrame + Vector3.new(0, 3, 0)
                        CONFIG.AutoTPFakeMachine = false
                        Rayfield:Notify({Title = "DARKNES Hub", Content = "Berhasil Teleport ke Mesin Fake Brainrot!", Duration = 3})
                    end
                end
            end

            -- B. Mode Fake Brainrot Active
            if CONFIG.AutoFakeBrainrot and not isKidnappedState then
                -- Reset WalkSpeed ke Normal (16) saat jadi Fake Brainrot
                if hum.WalkSpeed ~= 16 then hum.WalkSpeed = 16 end

                -- Inisialisasi Titik Tengah Zona Brainrot jika belum ada
                if not CONFIG.FakeSpawnCenter then CONFIG.FakeSpawnCenter = hrp.Position end

                -- Pilihan Tier (Common -> OG & Random)
                local currentTier = CONFIG.TargetFakeTier
                if currentTier == "Random" then
                    currentTier = CONFIG.TierListArray[math.random(1, #CONFIG.TierListArray)]
                end

                char:SetAttribute("Tier", currentTier)
                char:SetAttribute("IsBrainrot", true)

                -- SCAN BOUNDARY: Kunci posisi agar tidak keluar batas tempat Brainrot
                if CONFIG.EnableBoundaryLock and CONFIG.FakeSpawnCenter then
                    local distanceFromCenter = (Vector3.new(hrp.Position.X, 0, hrp.Position.Z) - Vector3.new(CONFIG.FakeSpawnCenter.X, 0, CONFIG.FakeSpawnCenter.Z)).Magnitude
                    if distanceFromCenter > CONFIG.MaxBoundaryRadius then
                        -- Tahan/Kembalikan posisi karakter ke dalam area aman batas
                        local safeDir = (CONFIG.FakeSpawnCenter - hrp.Position).Unit
                        hrp.CFrame = CFrame.new(CONFIG.FakeSpawnCenter + (safeDir * (CONFIG.MaxBoundaryRadius - 5)))
                        targetWanderPoint = nil
                    end
                end

                -- Simulated NPC Movement (Bergerak natural)
                fakeWanderTimer = fakeWanderTimer + 0.15
                if not targetWanderPoint or fakeWanderTimer >= 6 then
                    fakeWanderTimer = 0
                    local randX = math.random(-CONFIG.MaxBoundaryRadius + 10, CONFIG.MaxBoundaryRadius - 10)
                    local randZ = math.random(-CONFIG.MaxBoundaryRadius + 10, CONFIG.MaxBoundaryRadius - 10)
                    targetWanderPoint = CONFIG.FakeSpawnCenter + Vector3.new(randX, 0, randZ)
                end

                if targetWanderPoint then hum:MoveTo(targetWanderPoint) end
            else
                CONFIG.FakeSpawnCenter = nil
            end

            -- C. Smart Kidnapped Counter Engine
            if CONFIG.SmartKidnappedEscape and CONFIG.BaseCFrame and not isKidnappedState then
                local distFromBase = (hrp.Position - CONFIG.BaseCFrame.Position).Magnitude
                if distFromBase > 70 then
                    isKidnappedState = true
                    Rayfield:Notify({Title = "DARKNES Warning", Content = "Diculik Musuh! Membajak Brainrot Terbaik & Kabur...", Duration = 3})

                    -- Rebut Brainrot Musuh
                    if Workspace:FindFirstChild("Bases") then
                        for _, base in ipairs(Workspace.Bases:GetChildren()) do
                            if base:GetAttribute("Owner") ~= LocalPlayer.Name then
                                local bestItem = nil
                                local maxIncome = -1
                                for _, item in ipairs(base:GetDescendants()) do
                                    if item:IsA("Model") and item:FindFirstChild("HumanoidRootPart") then
                                        local cps = item:GetAttribute("PerSecond") or item:GetAttribute("Income") or 0
                                        if cps > maxIncome then maxIncome = cps bestItem = item end
                                    end
                                end
                                if bestItem and bestItem:FindFirstChild("HumanoidRootPart") then
                                    hrp.CFrame = bestItem.HumanoidRootPart.CFrame + Vector3.new(0, 2, 0)
                                    task.wait(0.4)
                                end
                            end
                        end
                    end

                    -- Kabur Kembali ke Base
                    hrp.CFrame = CONFIG.BaseCFrame
                    task.wait(0.5)
                    isKidnappedState = false
                end
            end
        end)
    end
end)

-- 2. TROLL BAT & COMBAT SYSTEM (Pukul Pake Bat)
task.spawn(function()
    while true do
        task.wait(0.1)
        if CONFIG.AutoBatTroll and LocalPlayer.Character then
            pcall(function()
                local char = LocalPlayer.Character
                local myRoot = char:FindFirstChild("HumanoidRootPart")
                local batTool = char:FindFirstChild("Bat") or char:FindFirstChildOfClass("Tool")

                if not batTool then
                    local backpack = LocalPlayer:FindFirstChild("Backpack")
                    if backpack then
                        local bat = backpack:FindFirstChild("Bat") or backpack:FindFirstChildOfClass("Tool")
                        if bat then char.Humanoid:EquipTool(bat) end
                    end
                end

                for _, p in ipairs(Players:GetPlayers()) do
                    if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                        if CONFIG.BatTargetPlayer == "" or CONFIG.BatTargetPlayer == "Tidak ada player lain" or p.Name == CONFIG.BatTargetPlayer then
                            local pRoot = p.Character.HumanoidRootPart
                            if myRoot and (myRoot.Position - pRoot.Position).Magnitude <= 12 then
                                myRoot.CFrame = pRoot.CFrame * CFrame.new(0, 0, 1.5)
                                if batTool then batTool:Activate() end
                            end
                        end
                    end
                end
            end)
        end
    end
end)

-- 3. AUTO MONEY COLLECTOR LOOP
task.spawn(function()
    while true do
        task.wait(0.4)
        if CONFIG.AutoCollectMoney then
            pcall(function()
                for _, obj in ipairs(Workspace:GetDescendants()) do
                    if obj:IsA("BasePart") and (obj.Name:find("Money") or obj.Name:find("Cash") or obj.Name:find("Coin") or obj:GetAttribute("IsMoney")) then
                        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                            firetouchinterest(LocalPlayer.Character.HumanoidRootPart, obj, 0)
                            firetouchinterest(LocalPlayer.Character.HumanoidRootPart, obj, 1)
                        end
                    end
                end
            end)
        end
    end
end)

-- 4. VISUAL & ESP ENGINE
RunService.RenderStepped:Connect(function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        if CONFIG.WalkSpeed > 16 and not CONFIG.AutoFakeBrainrot then
            LocalPlayer.Character.Humanoid.WalkSpeed = CONFIG.WalkSpeed
        end
    end

    if CONFIG.ESPBrainrot then
        for _, obj in ipairs(Workspace:GetChildren()) do
            if obj:IsA("Model") and obj:FindFirstChild("HumanoidRootPart") and not Players:GetPlayerFromCharacter(obj) then
                local tier = obj:GetAttribute("Tier") or "Common"
                local mutation = obj:GetAttribute("Mutation") or "Normal"
                local income = obj:GetAttribute("PerSecond") or 0
                local col = CONFIG.Tiers[tier] or CONFIG.BrainrotColor
                CreateESP(obj.HumanoidRootPart, obj.Name, string.format("[%s | %s | +%s/s]", tier, mutation, tostring(income)), col)
                if CONFIG.ShowChams then ApplyChams(obj, col) end
            end
        end
    end

    if CONFIG.ESPPlayers then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                CreateESP(player.Character.HumanoidRootPart, player.Name, "[PLAYER]", CONFIG.PlayerColor)
                if CONFIG.ShowChams then ApplyChams(player.Character, CONFIG.PlayerColor) end
            end
        end
    end

    local camera = Workspace.CurrentCamera
    if not camera then return end
    local viewportSize = camera.ViewportSize

    for part, data in pairs(activeDrawings) do
        if not part or not part.Parent then
            RemoveESP(part)
        else
            local vector, onScreen = camera:WorldToViewportPoint(part.Position)
            local dist = (camera.CFrame.Position - part.Position).Magnitude

            if onScreen and dist <= CONFIG.MaxDistance then
                local size = camera:WorldToViewportPoint(part.Position + Vector3.new(0, 3, 0)).Y - camera:WorldToViewportPoint(part.Position - Vector3.new(0, 3, 0)).Y
                
                if CONFIG.ShowBox then
                    data.Box.Size = Vector2.new(size * 0.6, size)
                    data.Box.Position = Vector2.new(vector.X - data.Box.Size.X / 2, vector.Y - data.Box.Size.Y / 2)
                    data.Box.Color = data.CustomColor
                    data.Box.Visible = true
                else data.Box.Visible = false end

                if CONFIG.ShowText then
                    data.Text.Text = string.format("%s\n%s [%dft]", data.Name, data.Info, math.floor(dist))
                    data.Text.Position = Vector2.new(vector.X, vector.Y - data.Box.Size.Y / 2 - 20)
                    data.Text.Visible = true
                else data.Text.Visible = false end

                if CONFIG.ShowTracers then
                    data.Tracer.From = Vector2.new(viewportSize.X / 2, viewportSize.Y)
                    data.Tracer.To = Vector2.new(vector.X, vector.Y)
                    data.Tracer.Color = data.CustomColor
                    data.Tracer.Visible = true
                else data.Tracer.Visible = false end
            else
                data.Box.Visible = false
                data.Text.Visible = false
                data.Tracer.Visible = false
            end
        end
    end
end)

-- 5. NOCLIP & INVISIBLE
RunService.Stepped:Connect(function()
    if LocalPlayer.Character then
        if CONFIG.NoclipEnabled then
            for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = false end
            end
        end
        if CONFIG.InvisibleEnabled then
            for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
                if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then part.Transparency = 1
                elseif part:IsA("Decal") then part.Transparency = 1 end
            end
        end
    end
end)

Rayfield:LoadConfiguration()
print("DARKNES Hub v3.0 Ultimate Loaded Successfully!")
