-- =================================================================
-- Project: DARKNES Hub (Ultimate Advanced Edition)
-- Created By: ManzXD
-- Coder: Plesneviy Xyu CONFIG
-- Status: 100% Fixed, All Features Integrated & Optimized!
-- =================================================================

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "DARKNES Hub | Fake A Brainrot [By ManzXD]",
   LoadingTitle = "DARKNES Hub Advanced Loading...",
   LoadingSubtitle = "Created by ManzXD | Coded by Plesneviy Xyu CONFIG",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = "DARKNESHub_ManzXD",
      FileName = "BrainrotConfig"
   },
   KeySystem = false
})

-- ==================== TABS CREATION ====================
local MainTab   = Window:CreateTab("Main", 4483362458)
local VisualTab = Window:CreateTab("Visual", 4483362458)
local AutoTab   = Window:CreateTab("Auto Farm", 4483362458)
local FakeTab   = Window:CreateTab("Fake Brainrot", 4483362458) -- Tab Baru Khusus Fake & Smart Kidnapped
local StealTab  = Window:CreateTab("Auto Steal", 4483362458)
local CombatTab = Window:CreateTab("Combat", 4483362458)
local DLLTab    = Window:CreateTab("DLL", 4483362458)

-- Variables & Config
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

local CONFIG = {
    -- Visual / ESP Config
    ESPBrainrot = false,
    ESPPlayers = false,
    ShowBox = true,
    ShowText = true,
    ShowTracers = false,
    ShowChams = false,
    
    -- Color Settings
    BrainrotColor = Color3.fromRGB(0, 255, 255),
    PlayerColor = Color3.fromRGB(255, 50, 50),
    TracerColor = Color3.fromRGB(255, 255, 255),
    
    -- Gameplay Config
    AutoCollectMoney = false,
    AutoTPCollect = false,
    AutoPunch = false,
    AutoBaseDefense = false,
    AutoStealTarget = false,
    SelectedTargetPlayer = "",
    NoclipEnabled = false,
    InvisibleEnabled = false,
    FlyEnabled = false,
    FlySpeed = 50,
    
    -- Fake Brainrot & Kidnapped Counter Config
    AutoFakeBrainrot = false,
    TargetFakeTier = "Common", -- Bisa "Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythic", "Secret", atau "Random"
    SmartKidnappedEscape = true,
    
    AutoMaxIncome = false,
    AutoDeployBrainrot = false,
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
    },
    TierListArray = {"Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythic", "Secret"}
}

local activeDrawings = {}
local activeHighlights = {}
local flyConnection, bg, bv
local isKidnappedState = false

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
    for part, _ in pairs(activeDrawings) do
        RemoveESP(part)
    end
    for model, hl in pairs(activeHighlights) do
        hl:Destroy()
        activeHighlights[model] = nil
    end
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

-- ==================== VISUAL TAB ====================
VisualTab:CreateSection("ESP Master Toggles")

VisualTab:CreateToggle({
   Name = "Enable Brainrot ESP",
   CurrentValue = false,
   Flag = "ESPBrainrotToggle",
   Callback = function(Value)
      CONFIG.ESPBrainrot = Value
      if not Value then ClearAllVisuals() end
   end,
})

VisualTab:CreateToggle({
   Name = "Enable Player ESP",
   CurrentValue = false,
   Flag = "ESPPlayerToggle",
   Callback = function(Value)
      CONFIG.ESPPlayers = Value
      if not Value then ClearAllVisuals() end
   end,
})

VisualTab:CreateSection("Visual Customization")

VisualTab:CreateToggle({
   Name = "Show 2D Boxes",
   CurrentValue = true,
   Flag = "ShowBoxToggle",
   Callback = function(Value)
      CONFIG.ShowBox = Value
   end,
})

VisualTab:CreateToggle({
   Name = "Show Names & Distance Text",
   CurrentValue = true,
   Flag = "ShowTextToggle",
   Callback = function(Value)
      CONFIG.ShowText = Value
   end,
})

VisualTab:CreateToggle({
   Name = "Show Tracers (Garis Penunjuk)",
   CurrentValue = false,
   Flag = "ShowTracersToggle",
   Callback = function(Value)
      CONFIG.ShowTracers = Value
   end,
})

VisualTab:CreateToggle({
   Name = "Show Chams / Highlight (Glow Body)",
   CurrentValue = false,
   Flag = "ShowChamsToggle",
   Callback = function(Value)
      CONFIG.ShowChams = Value
      if not Value then
          for model, hl in pairs(activeHighlights) do
              hl:Destroy()
              activeHighlights[model] = nil
          end
      end
   end,
})

VisualTab:CreateSlider({
   Name = "Max Render Distance",
   Range = {500, 10000},
   Increment = 250,
   Suffix = "Studs",
   CurrentValue = 5000,
   Flag = "MaxDistSlider",
   Callback = function(Value)
      CONFIG.MaxDistance = Value
   end,
})

-- ==================== AUTO FARM TAB ====================
AutoTab:CreateSection("Auto Collect Money & Deploy Systems")

AutoTab:CreateToggle({
   Name = "Auto Collect All Money (Ambil Uang Otomatis)",
   CurrentValue = false,
   Flag = "AutoCollectMoneyToggle",
   Callback = function(Value)
      CONFIG.AutoCollectMoney = Value
   end,
})

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

-- ==================== FAKE BRAINROT TAB (NEW & ADVANCED) ====================
FakeTab:CreateSection("Fake Brainrot & Smart Kidnapped Counter")

FakeTab:CreateDropdown({
   Name = "Pilih Tier Fake Brainrot",
   Options = {"Random", "Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythic", "Secret"},
   CurrentOption = {"Common"},
   Flag = "FakeTierDropdown",
   Callback = function(Option)
      CONFIG.TargetFakeTier = Option[1]
   end,
})

FakeTab:CreateToggle({
   Name = "Aktifkan Auto Fake Brainrot (Gerak AI Asli)",
   CurrentValue = false,
   Flag = "AutoFakeToggle",
   Callback = function(Value)
      CONFIG.AutoFakeBrainrot = Value
   end,
})

FakeTab:CreateToggle({
   Name = "Smart Counter-Steal Jika Diculik Player Lain",
   CurrentValue = true,
   Flag = "SmartKidnappedToggle",
   Callback = function(Value)
      CONFIG.SmartKidnappedEscape = Value
   end,
})

-- ==================== AUTO STEAL TAB ====================
StealTab:CreateSection("Target Selector & Steal System")

local PlayerDropdown = StealTab:CreateDropdown({
   Name = "Pilih Username Target (Server)",
   Options = GetServerPlayers(),
   CurrentOption = {GetServerPlayers()[1]},
   Flag = "TargetPlayerDropdown",
   Callback = function(Option)
      CONFIG.SelectedTargetPlayer = Option[1]
   end,
})

StealTab:CreateButton({
   Name = "Refresh List Player Server",
   Callback = function()
      PlayerDropdown:Refresh(GetServerPlayers())
      Rayfield:Notify({Title = "DARKNES Hub", Content = "List player berhasil di-refresh!", Duration = 2})
   end,
})

StealTab:CreateToggle({
   Name = "Auto Steal Brainrot (Prioritas CPS Tinggi)",
   CurrentValue = false,
   Flag = "AutoStealToggle",
   Callback = function(Value)
      CONFIG.AutoStealTarget = Value
      if Value and not CONFIG.BaseCFrame then SaveBase() end
   end,
})

-- ==================== COMBAT TAB ====================
CombatTab:CreateSection("Base Defense & Attack")

CombatTab:CreateToggle({
   Name = "Auto Defense (Pukul Musuh Yang Masuk Base)",
   CurrentValue = false,
   Flag = "AutoBaseDefenseToggle",
   Callback = function(Value)
      CONFIG.AutoBaseDefense = Value
      if Value and not CONFIG.BaseCFrame then SaveBase() end
   end,
})

CombatTab:CreateToggle({
   Name = "Auto Punch Players",
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
      ClearAllVisuals()
      Rayfield:Destroy()
   end,
})

-- ==================== LOGIC LOOPS (ADVANCED) ====================

-- 1. Auto Collect Money Loop
task.spawn(function()
    while true do
        task.wait(0.5)
        if CONFIG.AutoCollectMoney then
            pcall(function()
                for _, obj in ipairs(Workspace:GetDescendants()) do
                    if obj:IsA("BasePart") and (obj.Name == "Money" or obj.Name == "Cash" or obj.Name == "Coin" or obj:GetAttribute("IsMoney")) then
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

-- 2. Auto Fake Brainrot & Smart Kidnapped Counter System
task.spawn(function()
    local fakeMoveTimer = 0
    local targetWanderPos = nil

    while true do
        task.wait(0.2)
        pcall(function()
            local char = LocalPlayer.Character
            if not char or not char:FindFirstChild("HumanoidRootPart") or not char:FindFirstChildOfClass("Humanoid") then return end
            local hrp = char.HumanoidRootPart
            local hum = char:FindFirstChildOfClass("Humanoid")

            -- Cek apakah user sedang berada di base player lain (Diculik / Kidnapped)
            if CONFIG.SmartKidnappedEscape and CONFIG.BaseCFrame and not isKidnappedState then
                local distFromMyBase = (hrp.Position - CONFIG.BaseCFrame.Position).Magnitude
                -- Jika jarak dari base sendiri > 60 stud dan tidak dekat dengan origin map, berarti sedang di base orang lain!
                if distFromMyBase > 60 then
                    isKidnappedState = true
                    Rayfield:Notify({Title = "DARKNES Alert", Content = "Terdeteksi diculik ke base musuh! Melakukan Counter-Steal...", Duration = 3})

                    -- Cari base terdekat saat ini (base musuh)
                    local enemyBase = nil
                    local shortestDist = math.huge
                    if Workspace:FindFirstChild("Bases") then
                        for _, base in ipairs(Workspace.Bases:GetChildren()) do
                            local baseCenter = base:FindFirstChild("PrimaryPart") or base:FindFirstChildOfClass("BasePart")
                            if baseCenter then
                                local d = (hrp.Position - baseCenter.Position).Magnitude
                                if d < shortestDist and base:GetAttribute("Owner") ~= LocalPlayer.Name then
                                    shortestDist = d
                                    enemyBase = base
                                end
                            end
                        end
                    end

                    -- Ambil Brainrot paling bagus di base musuh tersebut
                    if enemyBase then
                        local bestBrainrot = nil
                        local maxCPS = -1
                        for _, item in ipairs(enemyBase:GetDescendants()) do
                            if item:IsA("Model") and item:FindFirstChild("HumanoidRootPart") then
                                local cps = item:GetAttribute("PerSecond") or item:GetAttribute("Income") or 0
                                if cps >= maxCPS then
                                    maxCPS = cps
                                    bestBrainrot = item
                                end
                            end
                        end

                        -- Teleport ambil brainrot musuh
                        if bestBrainrot and bestBrainrot:FindFirstChild("HumanoidRootPart") then
                            hrp.CFrame = bestBrainrot.HumanoidRootPart.CFrame + Vector3.new(0, 2, 0)
                            task.wait(0.5)
                        end
                    end

                    -- Langsung kabur kembali ke base sendiri
                    hrp.CFrame = CONFIG.BaseCFrame
                    task.wait(0.5)
                    isKidnappedState = false
                end
            end

            -- Auto Fake Brainrot Simulation (Bergerak otomatis seolah-olah Brainrot Asli)
            if CONFIG.AutoFakeBrainrot and not isKidnappedState then
                -- Set atribut/tanda visual fake tier jika game mendeteksinya
                local activeTier = CONFIG.TargetFakeTier
                if activeTier == "Random" then
                    activeTier = CONFIG.TierListArray[math.random(1, #CONFIG.TierListArray)]
                end
                char:SetAttribute("Tier", activeTier)
                char:SetAttribute("IsBrainrot", true)

                -- Simulasi AI wandering (bergerak perlahan keliling map agar mirip NPC/Brainrot asli)
                fakeMoveTimer = fakeMoveTimer + 0.2
                if not targetWanderPos or fakeMoveTimer >= 8 then
                    fakeMoveTimer = 0
                    local randomOffset = Vector3.new(math.random(-40, 40), 0, math.random(-40, 40))
                    targetWanderPos = hrp.Position + randomOffset
                end

                if targetWanderPos then
                    hum:MoveTo(targetWanderPos)
                end
            end
        end)
    end
end)

-- 3. RenderStepped for Visuals/ESP & WalkSpeed
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
                else
                    data.Box.Visible = false
                end

                if CONFIG.ShowText then
                    data.Text.Text = string.format("%s\n%s [%dft]", data.Name, data.Info, math.floor(dist))
                    data.Text.Position = Vector2.new(vector.X, vector.Y - data.Box.Size.Y / 2 - 20)
                    data.Text.Visible = true
                else
                    data.Text.Visible = false
                end

                if CONFIG.ShowTracers then
                    data.Tracer.From = Vector2.new(viewportSize.X / 2, viewportSize.Y)
                    data.Tracer.To = Vector2.new(vector.X, vector.Y)
                    data.Tracer.Color = data.CustomColor
                    data.Tracer.Visible = true
                else
                    data.Tracer.Visible = false
                end
            else
                data.Box.Visible = false
                data.Text.Visible = false
                data.Tracer.Visible = false
            end
        end
    end
end)

-- 4. Auto Deploy Brainrot Loop
task.spawn(function()
    while true do
        task.wait(1)
        if CONFIG.AutoDeployBrainrot then
            pcall(function()
                local backpack = LocalPlayer:FindFirstChild("Backpack")
                local char = LocalPlayer.Character
                local brainrotsInBag = {}
                if backpack then
                    for _, item in ipairs(backpack:GetChildren()) do
                        local cps = item:GetAttribute("PerSecond") or item:GetAttribute("Income") or 0
                        table.insert(brainrotsInBag, {Item = item, Income = cps})
                    end
                end
                table.sort(brainrotsInBag, function(a, b) return a.Income > b.Income end)

                if #brainrotsInBag > 0 and Workspace:FindFirstChild("Bases") then
                    for _, base in ipairs(Workspace.Bases:GetChildren()) do
                        if base:GetAttribute("Owner") == LocalPlayer.Name or base.Name == LocalPlayer.Name then
                            local slots = base:FindFirstChild("Slots") or base:FindFirstChild("BrainrotPlaces")
                            if slots then
                                for _, slot in ipairs(slots:GetChildren()) do
                                    if #brainrotsInBag > 0 and (not slot:FindFirstChild("Brainrot") or #slot:GetChildren() == 0) then
                                        local bestBrainrot = table.remove(brainrotsInBag, 1)
                                        if bestBrainrot.Item and char and char:FindFirstChild("Humanoid") then
                                            char.Humanoid:EquipTool(bestBrainrot.Item)
                                            task.wait(0.2)
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

-- 5. Auto Base Defense Loop
task.spawn(function()
    while true do
        task.wait(0.1)
        if CONFIG.AutoBaseDefense and CONFIG.BaseCFrame and LocalPlayer.Character then
            local char = LocalPlayer.Character
            local myRoot = char:FindFirstChild("HumanoidRootPart")
            local tool = char:FindFirstChildOfClass("Tool")
            
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    local pRoot = player.Character.HumanoidRootPart
                    local distToBase = (pRoot.Position - CONFIG.BaseCFrame.Position).Magnitude
                    if distToBase <= 30 then
                        if myRoot and tool then
                            myRoot.CFrame = pRoot.CFrame * CFrame.new(0, 0, 2)
                            tool:Activate()
                        end
                    end
                end
            end
        end
    end
end)

-- 6. Auto Steal Target Loop
task.spawn(function()
    while true do
        task.wait(0.6)
        if CONFIG.AutoStealTarget and CONFIG.SelectedTargetPlayer ~= "" and CONFIG.SelectedTargetPlayer ~= "Tidak ada player lain" and LocalPlayer.Character then
            local myRoot = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if not myRoot then break end

            pcall(function()
                local targetBase = nil
                if Workspace:FindFirstChild("Bases") then
                    for _, base in ipairs(Workspace.Bases:GetChildren()) do
                        if base:GetAttribute("Owner") == CONFIG.SelectedTargetPlayer or base.Name == CONFIG.SelectedTargetPlayer then
                            targetBase = base
                            break
                        end
                    end
                end

                if targetBase then
                    local slots = targetBase:FindFirstChild("Slots") or targetBase:FindFirstChild("BrainrotPlaces") or targetBase
                    local targetBrainrots = {}

                    for _, item in ipairs(slots:GetDescendants()) do
                        if item:IsA("Model") and item:FindFirstChild("HumanoidRootPart") then
                            local cps = item:GetAttribute("PerSecond") or item:GetAttribute("Income") or 0
                            table.insert(targetBrainrots, {Obj = item, Income = cps})
                        end
                    end

                    table.sort(targetBrainrots, function(a, b) return a.Income > b.Income end)

                    for _, target in ipairs(targetBrainrots) do
                        if not CONFIG.AutoStealTarget then break end
                        if target.Obj and target.Obj:FindFirstChild("HumanoidRootPart") then
                            myRoot.CFrame = target.Obj.HumanoidRootPart.CFrame + Vector3.new(0, 2, 0)
                            task.wait(0.6)
                            if CONFIG.BaseCFrame then myRoot.CFrame = CONFIG.BaseCFrame end
                            task.wait(0.4)
                        end
                    end
                end
            end)
        end
    end
end)

-- 7. Noclip & Invisible Loop
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

-- 8. Auto Punch Loop
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

-- 9. Auto TP Collect & Max Income Loop
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

Rayfield:LoadConfiguration()
print("DARKNES Hub Ultimate Advanced Edition by ManzXD loaded successfully!")
