local isRunning = false -- Player's current running state
local RainSlowRunSpeed = Config.RainSlowRunSpeed  -- Slow jogging speed
local SnowSlowRunSpeed = Config.SnowSlowRunSpeed  -- Slow jogging speed
local isLimping = false -- Player's current limping state
local isBlurry = false -- Player's current vision blur state

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(500) -- Updates every 0.5 seconds

        -- Retrieves the current rain and snow levels
        local rainLevel = GetRainLevel()
        local snowLevel = GetSnowLevel()
        local playerPed = PlayerPedId() -- Gets the player ped

        -- Checks if rain level is above the set threshold
        if rainLevel > Config.RainLevel then
            -- Checks if the player is running or sprinting
            local isPedRunning = IsPedRunning(playerPed)
            local isPedSprinting = IsPedSprinting(playerPed)

            if (isPedRunning or isPedSprinting) and not isRunning then
                -- If the player is running or sprinting, switch to slow jogging
                -- print("[INFO] Rain level high, switching to slow jogging.")
                SetEntityMaxSpeed(playerPed, RainSlowRunSpeed) -- Sets slow jogging speed
                isRunning = true
            end
        elseif snowLevel > Config.SnowLevel then
            -- Checks if the player is running or sprinting
            local isPedRunning = IsPedRunning(playerPed)
            local isPedSprinting = IsPedSprinting(playerPed)

            if (isPedRunning or isPedSprinting) and not isRunning then
                -- If the player is running or sprinting, switch to slow jogging
                -- print("[INFO] Snow level high, switching to slow jogging.")
                SetEntityMaxSpeed(playerPed, SnowSlowRunSpeed) -- Sets slow jogging speed
                isRunning = true
            end
        else
            -- If both rain and snow levels are below their respective thresholds, restore normal speed
            if isRunning then
                -- print("[INFO] Rain and Snow level normal, switching back to normal running.")
                SetEntityMaxSpeed(playerPed, 10.0) -- Restores normal running speed (10.0 is GTA V default max speed)
                isRunning = false
            end
        end
    end
end)

-- Thread to manage limp animation and vision blur based on health
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(500) -- Updates every 0.5 seconds

        local playerPed = PlayerPedId()
        local health = GetEntityHealth(playerPed)

        -- Display the player's current health in the console
        -- print("[INFO] Player Health: " .. health)

        -- Check if health is below 50% of max health (100)
        if health < Config.LimpingHealth and not isLimping then
            -- Apply limp animation if health is below threshold
            RequestAnimSet("move_m@injured") -- Load injured movement animation set
            while not HasAnimSetLoaded("move_m@injured") do
                Citizen.Wait(100)
            end
            SetPedMovementClipset(playerPed, "move_m@injured", 1.0) -- Apply limp animation
            isLimping = true

            -- Apply vision blur effect
            if not isBlurry then
                StartScreenEffect("DeathFailNeutralIn", 0, true) -- Applies a visual blur effect
                isBlurry = true
            end
        elseif health >= Config.LimpingHealth and isLimping then
            -- Restore normal movement if health is above threshold
            ResetPedMovementClipset(playerPed, 1.0) -- Reset to normal movement
            isLimping = false

            -- Remove vision blur effect
            if isBlurry then
                StopScreenEffect("DeathFailNeutralIn") -- Removes the visual blur effect
                isBlurry = false
            end
        end
    end
end)
