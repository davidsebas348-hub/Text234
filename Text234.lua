-- ===== SERVICES =====
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local VirtualInputManager = game:GetService("VirtualInputManager")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

-- ===== TOGGLE =====
if _G.AUTO_Q_WALL_CONN then
    _G.AUTO_Q_WALL_CONN:Disconnect()
    _G.AUTO_Q_WALL_CONN = nil
    return
end

-- ===== FUNCIONES =====

-- Obtener objetos objetivo (modelos o partes) del jugador
local function getTargets()
    local liveFolder = Workspace:FindFirstChild("Live")
    if not liveFolder then return {} end
    local targets = {}

    for _, obj in ipairs(liveFolder:GetChildren()) do
        if obj:IsA("Model") then
            if obj:FindFirstChild("HumanoidRootPart") and obj.Name ~= LocalPlayer.Name then
                table.insert(targets, obj)
            end
        elseif obj:IsA("BasePart") then
            table.insert(targets, obj)
        end
    end

    return targets
end

-- Obtener modelo del jugador
local function getMyModel()
    local liveFolder = Workspace:FindFirstChild("Live")
    if not liveFolder then return nil end
    return liveFolder:FindFirstChild(LocalPlayer.Name)
end

-- Simular tecla Q
local function pressQ()
    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Q, false, game)
    task.wait(0.1)
    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Q, false, game)
end

-- Detectar pared delante usando "cajón"
local function isWallAhead()
    local character = LocalPlayer.Character
    if not character then return false end
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return false end

    local boxSize = Vector3.new(10, 10, 10)
    local boxCFrame = rootPart.CFrame * CFrame.new(0, 0, boxSize.Z/2 + 2)

    local params = OverlapParams.new()
    params.FilterType = Enum.RaycastFilterType.Blacklist
    params.FilterDescendantsInstances = {character}

    local parts = Workspace:GetPartBoundsInBox(boxCFrame, boxSize, params)

    for _, part in ipairs(parts) do
        if part:IsA("BasePart") then
            return true
        end
    end

    return false
end

-- ===== LOOP PRINCIPAL =====
_G.AUTO_Q_WALL_CONN = RunService.Heartbeat:Connect(function()
    local myModel = getMyModel()
    if not myModel then return end

    -- Contar RecentM1Hit
    local recentM1Hits = 0
    for _, child in ipairs(myModel:GetChildren()) do
        if child.Name == "RecentM1Hit" then
            recentM1Hits += 1
        end
    end

    -- Chequear pared y cualquier target (model o part) delante
    local targets = getTargets()
    if recentM1Hits == 4 then
        for _, target in ipairs(targets) do
            if isWallAhead() then
                pressQ()
                break
            end
        end
    end
end)
