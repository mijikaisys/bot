getgenv().autoparry = true

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local VirtualManager = game:GetService("VirtualInputManager")
local localPlayer = Players.LocalPlayer
local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local parry_helper = loadstring(game:HttpGet("https://raw.githubusercontent.com/TripleScript/TripleHub/main/helper_.lua"))()

local opponent = nil -- Variable pour stocker l'adversaire
local jumpCooldown = 1 -- Temps d'attente entre les sauts du bot
local lastJumpTime = 0 -- Temps du dernier saut
local ero = false
local moveSpeed = 16 -- Vitesse de déplacement du bot
local baseSafetyDistance = 40 -- Distance de sécurité de base

-- Fonction pour détecter l'adversaire
local function findOpponent()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= localPlayer and player.Character then
            return player.Character
        end
    end
end

-- Fonction pour gérer le saut
local function jump()
    if tick() - lastJumpTime > jumpCooldown then
        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        lastJumpTime = tick() -- Mettre à jour le temps du dernier saut
    end
end

-- Fonction pour déplacer le bot vers une position tout en maintenant une distance de sécurité
local function moveTowards(targetPosition)
    local direction = (targetPosition - character.PrimaryPart.Position).unit
    local distanceToTarget = (targetPosition - character.PrimaryPart.Position).magnitude

    -- Calculer la distance de sécurité en fonction de la vitesse de la balle
    local par = parry_helper.FindTargetBall()
    local ballSpeed = 0
    if par and par:IsA("Ball") then
        ballSpeed = par.AssemblyLinearVelocity.Magnitude
    end

    -- Ajuster la distance de sécurité en fonction de la vitesse de la balle
    local requiredDistance = baseSafetyDistance + (ballSpeed / 2) -- Ajustez le facteur selon vos besoins

    -- Si la distance au cible est inférieure à la distance requise, déplacer le bot à la distance requise
    if distanceToTarget < requiredDistance then
        humanoid:Move(-direction * moveSpeed) -- Reculez
    else
        humanoid:Move(direction * moveSpeed) -- Avancez
    end
end

-- Boucle principale pour surveiller les mouvements de l'adversaire et gérer l'autoparry
task.spawn(function()
    RunService.PreRender:Connect(function()
        if not getgenv().autoparry then 
            return 
        end

        opponent = findOpponent() -- Trouver l'adversaire à chaque étape du rendu

        if opponent and opponent:FindFirstChild("Humanoid") then
            local opponentHumanoid = opponent.Humanoid
            local opponentJumping = opponentHumanoid:GetState() == Enum.HumanoidStateType.Jumping

            -- Si l'adversaire est en train de sauter, le bot décide de sauter aussi
            if opponentJumping and tick() - lastJumpTime > jumpCooldown then
                jump()
            end

            -- Déplacez le bot en maintenant une distance de sécurité
            moveTowards(opponent.PrimaryPart.Position)
        end

        local par = parry_helper.FindTargetBall()
        if not par then 
            return 
        end

        local hat = par.AssemblyLinearVelocity
        if par:FindFirstChild('zoomies') then 
            hat = par.zoomies.VectorVelocity
        end

        local i = par.Position
        local j = localPlayer.Character.PrimaryPart.Position
        local kil = (j - i).Unit
        local l = localPlayer:DistanceFromCharacter(i)
        local m = kil:Dot(hat.Unit)
        local n = hat.Magnitude

        if m > 0 then
            local o = l - 5
            local p = o / n

            if parry_helper.IsPlayerTarget(par) and p <= 0.55 and not ero then
                VirtualManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
                wait(0.01)
                ero = true
            end
        else
            ero = false
        end
    end)
end)
