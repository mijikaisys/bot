local AutoParryHelper = require(path_to_AutoParryHelper) -- Remplacez par le chemin correct
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local hitremote = game.ReplicatedStorage:WaitForChild("HitRemote") -- Remplacez par le nom correct
local reactionDistance = 20 -- Distance de parry initiale
local score = 0 -- Score du bot
local isAlive = true -- Statut de vie du bot

local function hitBall()
    -- Logique pour frapper la balle
    score = score + 1 -- Récompense pour parry
end

local function onDeath()
    isAlive = false
    score = score - 5 -- Punition pour mort
    player.CharacterAdded:Wait()
    character = player.Character or player.CharacterAdded:Wait()
    isAlive = true
end

-- Connecter la fonction de gestion de la mort
player.Character.Humanoid.Died:Connect(onDeath)

-- Boucle principale
while true do
    wait(0.1)

    if not isAlive then continue end -- Si le bot est mort, attendez qu'il respawn

    local ball = AutoParryHelper.FindTargetBall() -- Trouver la balle cible
    if not ball then continue end -- Si aucune balle n'est trouvée, passez à l'itération suivante

    local ballPosition = ball.Position
    local characterPosition = character.PrimaryPart.Position
    local distanceToBall = (ballPosition - characterPosition).magnitude
    local ballVelocity = ball.Velocity.magnitude -- Récupérer la vitesse de la balle

    -- Ajuster la portée de parry en fonction de la vitesse de la balle
    local parryRange = math.clamp(distanceToBall + ballVelocity * 0.5, 10, 30) -- Ajustez les valeurs selon vos besoins

    -- Vérifier si la balle cible le bot
    if AutoParryHelper.IsPlayerTarget(ball) then
        -- Si le bot est ciblé par la balle
        if distanceToBall <= parryRange then
            hitBall() -- Appeler la fonction pour frapper la balle
        else
            character:MoveTo(ballPosition) -- Se déplacer vers la balle
        end
    end
end
