local hudVisible = false
local fuelResource = nil
local lastVehicleData = nil
local spawnTriggered = false
local spawnAt = 0
local lastDead = false
local frameworkDead = false
local minimapHidden = false

-- Variables para cachear y evitar saturar el bus NUI
local lastHealthVal = -1
local lastArmourVal = -1
local lastInVehicle = false
local cachedFood = -1
local cachedThirst = -1
local lastFoodSent = -1
local lastThirstSent = -1
local lastMicState = nil

local ESX = nil
local hasSeatbeltModule = false
local cachedJob = 'Civilian'
local cachedGrade = ''
local cachedCash = '$0'
local cachedBank = '$0'
local cachedId = '0'

-- Cachear recursos al arrancar
local function detectResources()
    if GetResourceState('ox_fuel') == 'started' then
        fuelResource = 'ox_fuel'
    elseif GetResourceState('LegacyFuel') == 'started' then
        fuelResource = 'LegacyFuel'
    end
    hasSeatbeltModule = GetResourceState('esx_cruisecontrol') == 'started'
end

CreateThread(function()
    detectResources()
    while not fuelResource or not hasSeatbeltModule do
        Wait(10000)
        detectResources()
    end
end)

CreateThread(function()
    while not ESX do
        if GetResourceState('es_extended') == 'started' then
            pcall(function()
                ESX = exports['es_extended']:getSharedObject()
            end)
            if not ESX then
                TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
            end
        end
        Wait(500)
    end
    detectResources()
end)

-- Helper para logs condicionales
local function log(msg)
    if Config and Config.Debug then
        print(msg)
    end
end

local function hideMinimap()
    if not minimapHidden then
        DisplayRadar(false)
        minimapHidden = true
        log('[aka-hud] Minimap OCULTADO')
    end
end

local function showMinimap()
    if minimapHidden then
        DisplayRadar(true)
        minimapHidden = false
        log('[aka-hud] Minimap MOSTRADO')
    end
end

local function resetHUD(reason)
    hudVisible = false
    spawnTriggered = false
    spawnAt = 0
    lastDead = false
    frameworkDead = false
    lastHealthVal = -1
    lastArmourVal = -1
    lastInVehicle = false
    cachedFood = -1
    cachedThirst = -1
    lastFoodSent = -1
    lastThirstSent = -1
    lastMicState = nil
    lastVehicleData = nil
    SendNUIMessage({ action = 'hide' })
    hideMinimap()
    log('[aka-hud] Reset HUD por: ' .. tostring(reason))
end

-- === EVENTOS DEL FRAMEWORK ===

-- Evento de spawn original de ESX
RegisterNetEvent('esx:onPlayerSpawn')
AddEventHandler('esx:onPlayerSpawn', function()
    spawnTriggered = true
    spawnAt = GetGameTimer()
    frameworkDead = false
    log('[aka-hud] Evento esx:onPlayerSpawn recibido. spawnTriggered = true, spawnAt = ' .. spawnAt)
end)

-- Evento de muerte original de ESX
RegisterNetEvent('esx:onPlayerDeath')
AddEventHandler('esx:onPlayerDeath', function(data)
    frameworkDead = true
    log('[aka-hud] Evento esx:onPlayerDeath recibido. frameworkDead = true')
end)

-- Sincronización extra mediante cambios en PlayerData
RegisterNetEvent('esx:setPlayerData')
AddEventHandler('esx:setPlayerData', function(key, val)
    if key == 'isDead' then
        frameworkDead = val
        log('[aka-hud] esx:setPlayerData - isDead modificado a: ' .. tostring(val))
    elseif key == 'player' and val and val.isDead ~= nil then
        frameworkDead = val.isDead
        log('[aka-hud] esx:setPlayerData - player.isDead modificado a: ' .. tostring(val.isDead))
    end
end)

-- === DETECCIÓN DE RESTART DEL RESOURCE ===
-- Si el resource se reinicia (ensure) con el jugador ya activo,
-- esx:onPlayerSpawn no volverá a dispararse. Detectamos ese caso aquí.
AddEventHandler('onClientResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end

    -- Esperar un momento para que el NUI y el CEF se inicialicen
    Wait(500)

    local ped = PlayerPedId()
    if DoesEntityExist(ped) and not IsEntityDead(ped) and NetworkIsPlayerActive(PlayerId()) then
        spawnTriggered = true
        spawnAt = GetGameTimer()
        frameworkDead = false
        log('[aka-hud] onClientResourceStart: Jugador ya activo, activando spawn gate')
    end
end)

-- === PROTECCIÓN MULTICHARACTER ===

RegisterNetEvent('um-ronin-multicharacter:client:openUI')
AddEventHandler('um-ronin-multicharacter:client:openUI', function()
    resetHUD('um-ronin-multicharacter:client:openUI')
end)

RegisterNetEvent('um-ronin-multicharacter:client:logout')
AddEventHandler('um-ronin-multicharacter:client:logout', function()
    resetHUD('um-ronin-multicharacter:client:logout')
end)

-- === INFO BOXES: Job, Money, Bank, ID ===

local function formatMoney(amount)
    if not amount then return '$0' end
    local formatted = tostring(math.floor(amount))
    local k = 3
    while #formatted > k do
        formatted = formatted:sub(1, #formatted - k) .. ',' .. formatted:sub(#formatted - k + 1)
        k = k + 4
    end
    return '$' .. formatted
end

local function sendInfo()
    SendNUIMessage({
        action = 'setInfo',
        job = cachedJob,
        grade = cachedGrade,
        cash = cachedCash,
        bank = cachedBank,
        id = cachedId,
    })
end

-- Hook into ESX player data changes
AddEventHandler('esx:setPlayerData', function(key, val)
    if key == 'job' and val then
        cachedJob = val.label or val.name or 'Civilian'
        cachedGrade = (val.grade_label and val.grade_label ~= '') and val.grade_label or ''
        sendInfo()
    elseif key == 'money' then
        cachedCash = formatMoney(val)
        sendInfo()
    elseif key == 'accounts' and val then
        for _, acc in ipairs(val) do
            if acc.name == 'bank' then
                cachedBank = formatMoney(acc.money)
                sendInfo()
                break
            end
        end
    end
end)

-- Obtener ID del jugador
CreateThread(function()
    while not ESX do Wait(500) end
    -- Send initial info once ESX is ready
    local playerData = ESX.GetPlayerData()
    if playerData then
        if playerData.job then
            cachedJob = playerData.job.label or playerData.job.name or 'Civilian'
            cachedGrade = (playerData.job.grade_label and playerData.job.grade_label ~= '') and playerData.job.grade_label or ''
        end
        if playerData.money then cachedCash = formatMoney(playerData.money) end
        if playerData.accounts then
            for _, acc in ipairs(playerData.accounts) do
                if acc.name == 'bank' then cachedBank = formatMoney(acc.money) break end
            end
        end
    end
    cachedId = tostring(GetPlayerServerId(PlayerId()))
    sendInfo()
end)

-- === COMIDA Y SED VÍA esx_status (push) ===
AddEventHandler('esx_status:onTick', function(statuses)
    if not statuses then return end
    for _, status in pairs(statuses) do
        if status.name == 'hunger' then
            cachedFood = math.floor(status.percent or ((status.val / 1000000) * 100))
        elseif status.name == 'thirst' then
            cachedThirst = math.floor(status.percent or ((status.val / 1000000) * 100))
        end
    end
end)

local function getFuel(vehicle)
    if not fuelResource then return 0 end
    if fuelResource == 'ox_fuel' then
        return math.floor(GetVehicleFuelLevel(vehicle))
    else
        return math.floor(exports[fuelResource]:GetFuel(vehicle))
    end
end

-- === HILO PRINCIPAL ===

CreateThread(function()
    while true do
        Wait(200)

        local ped = PlayerPedId()

        -- Reset por pérdida de ped
        if not DoesEntityExist(ped) then
            if hudVisible then
                resetHUD('Pérdida de existencia del ped')
            else
                hideMinimap()
            end
            goto continue
        end

        -- === SPAWN GATE ===
        if not hudVisible then
            if spawnTriggered then
                local now = GetGameTimer()
                local timeSinceSpawn = now - spawnAt

                -- Log detallado del gate (evitando formateos costosos en producción)
                if Config and Config.Debug then
                    log(string.format('[aka-hud] Gate Check - pedExists: %s | nativeDead: %s | health: %s | fadedIn: %s | active: %s | elapsed: %s ms',
                        tostring(DoesEntityExist(ped)),
                        tostring(IsEntityDead(ped) or IsPedFatallyInjured(ped) or GetEntityHealth(ped) <= 101),
                        GetEntityHealth(ped),
                        tostring(IsScreenFadedIn()),
                        tostring(NetworkIsPlayerActive(PlayerId())),
                        timeSinceSpawn
                    ))
                end

                if DoesEntityExist(ped)
                    and not IsEntityDead(ped)
                    and not IsPedFatallyInjured(ped)
                    and GetEntityHealth(ped) > 101
                    and IsScreenFadedIn()
                    and NetworkIsPlayerActive(PlayerId())
                    and timeSinceSpawn >= 3000
                then
                    hudVisible = true
                    SendNUIMessage({ action = 'show', hudColor = Config and Config.HudColor or 'purple' })
                    -- Enviar estado inicial del vehículo tras superar el gate
                    local inVehicle = IsPedInAnyVehicle(ped, false)
                    SendNUIMessage({ action = 'setVehicle', inVehicle = inVehicle })
                    lastInVehicle = inVehicle
                    log('[aka-hud] SPAWN GATE superado - Mostrando HUD')
                end
            end

            -- Si sigue oculto, forzar minimapa oculto y saltar lógica
            if not hudVisible then
                hideMinimap()
                goto continue
            end
        end

        -- === DETECCION DE MUERTE ROBUSTA ===
        local rawHealth = GetEntityHealth(ped)
        local health = math.max(0, rawHealth - 100)
        local armour = GetPedArmour(ped)

        -- 1. Capa Nativa
        local nativeDead = IsEntityDead(ped) or IsPedFatallyInjured(ped) or rawHealth <= 101

        -- 2. Capa Framework (Eventos + State Bags)
        local stateIsDead = false
        if LocalPlayer and LocalPlayer.state then
            if LocalPlayer.state.isDead == true or LocalPlayer.state.dead == true then
                stateIsDead = true
            end
        end

        local currentFrameworkDead = frameworkDead or stateIsDead
        local effectiveDead = nativeDead or currentFrameworkDead

        -- Log periódico de depuración (evitando formateos costosos en producción)
        if Config and Config.Debug then
            log(string.format('[aka-hud] Loop Tick - rawHealth: %d | health: %d | nativeDead: %s | frameworkDead: %s | stateIsDead: %s | esxDead: %s | effectiveDead: %s | hudVisible: %s',
                rawHealth,
                health,
                tostring(nativeDead),
                tostring(frameworkDead),
                tostring(stateIsDead),
                tostring(esxDead),
                tostring(effectiveDead),
                tostring(hudVisible)
            ))
        end

        -- === FLUJO DE VIDA / MUERTE ===
        if effectiveDead and not lastDead then
            -- Vivo -> Muerto
            SendNUIMessage({ action = 'death', health = 0, armour = armour })
            lastHealthVal = 0
            lastArmourVal = armour
            log('[aka-hud] NUI -> DEATH enviado (salud 0%)')
        elseif not effectiveDead and lastDead then
            -- Muerto -> Vivo
            SendNUIMessage({ action = 'revive', health = health, armour = armour })
            lastHealthVal = health
            lastArmourVal = armour
            log('[aka-hud] NUI -> REVIVE enviado con salud: ' .. health)
        elseif not effectiveDead then
            -- Vivo y estable -> setHealth únicamente si cambiaron los valores
            if health ~= lastHealthVal or armour ~= lastArmourVal then
                SendNUIMessage({ action = 'setHealth', health = health, armour = armour })
                lastHealthVal = health
                lastArmourVal = armour
                log('[aka-hud] NUI -> setHealth enviado con salud: ' .. health .. ' | escudo: ' .. armour)
            end
        end

        lastDead = effectiveDead

        -- === ACTUALIZACION INDEPENDIENTE DE ARMADURA ===
        if armour ~= lastArmourVal then
            SendNUIMessage({ action = 'setArmour', armour = armour })
            lastArmourVal = armour
        end

        -- === COMIDA Y SED (esx_status vía evento onTick) ===
        if not effectiveDead then
            if cachedFood ~= -1 and cachedThirst ~= -1 then
                local food = math.max(0, math.min(100, cachedFood))
                local thirst = math.max(0, math.min(100, cachedThirst))

                if food ~= lastFoodSent or thirst ~= lastThirstSent then
                    SendNUIMessage({ action = 'setStatus', food = food, thirst = thirst })
                    lastFoodSent = food
                    lastThirstSent = thirst
                end
            end
        end

        -- === DETECCIÓN DE VOZ (PTT: control 249 = INPUT_PUSH_TO_TALK) ===
        local isTalking = IsControlPressed(0, 249)

        if not isTalking and LocalPlayer and LocalPlayer.state then
            isTalking = LocalPlayer.state.isTalking == true or LocalPlayer.state.talking == true
        end

        local micState = isTalking and 'talking' or 'muted'

        if micState ~= lastMicState then
            SendNUIMessage({ action = 'setMic', state = micState })
            lastMicState = micState
        end

        -- === MINIMAPA DINÁMICO & DESPLAZAMIENTO NUI ===
        local veh = GetVehiclePedIsIn(ped, false)
        local inVehicle = veh and veh ~= 0
        if inVehicle ~= lastInVehicle then
            SendNUIMessage({ action = 'setVehicle', inVehicle = inVehicle })
            lastInVehicle = inVehicle
        end

        if inVehicle then
            showMinimap()

            local speed = math.floor(GetEntitySpeed(veh) * 3.6)
            local gear = GetVehicleCurrentGear(veh)
            local rpm = GetVehicleCurrentRpm(veh)
            local fuel = getFuel(veh)

            local seatbelt = false
            if hasSeatbeltModule then
                seatbelt = exports['esx_cruisecontrol']:isSeatbeltOn()
            end

            local hasNitro = GetVehicleMod(veh, 40) ~= -1

            if not lastVehicleData
                or speed ~= lastVehicleData.speed
                or gear ~= lastVehicleData.gear
                or rpm ~= lastVehicleData.rpm
                or fuel ~= lastVehicleData.fuel
                or seatbelt ~= lastVehicleData.seatbelt
                or hasNitro ~= lastVehicleData.hasNitro
            then
                lastVehicleData = { speed = speed, gear = gear, rpm = rpm, fuel = fuel, seatbelt = seatbelt, hasNitro = hasNitro }
                SendNUIMessage({ action = 'setVehicleData', show = true, speed = speed, unit = 'KM/H', gear = gear, rpm = rpm, fuel = fuel, seatbelt = seatbelt, hasNitro = hasNitro })
            end
        else
            hideMinimap()
            if lastVehicleData then
                SendNUIMessage({ action = 'setVehicleData', show = false })
                lastVehicleData = nil
            end
        end

        ::continue::
    end
end)
