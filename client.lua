local ESX = nil

local function log(msg)
    if Config and Config.Debug then
        print('[aka-notify] ' .. msg)
    end
end

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
    log('ESX obtenido')
end)

-- ======================================================
-- EXPORT: ShowNotification
-- ======================================================
exports('ShowNotification', function(message, notificationType, options)
    local actionText = notificationType == "success" and "Éxito" or
                       notificationType == "error" and "Error" or
                       notificationType == "warning" and "Advertencia" or
                       notificationType == "info" and "Información" or
                       notificationType == "main" and "Sistema" or
                       "Notificación"
    local data = {
        action = "notification",
        itemLabel = message,
        label = actionText,
        type = notificationType or "info"
    }
    if options then
        if options.icon then data.icon = options.icon end
        if options.title then data.label = options.title end
        if options.duration then data.duration = options.duration end
        if options.color then data.color = options.color end
    end
    SendNUIMessage(data)
end)

-- ======================================================
-- EVENTO: aka-notify:notification
-- ======================================================
AddEventHandler("aka-notify:notification", function(message, notificationType, options)
    exports['aka-notify']:ShowNotification(message, notificationType, options)
end)

-- ======================================================
-- INTERCEPT ESX.ShowNotification con color por tipo
-- ======================================================
local function detectTypeFromMessage(msg)
    local lower = msg:lower()
    if lower:find("error") or lower:find("err") or lower:find("~r~") then return "error" end
    if lower:find("exito") or lower:find("éxito") or lower:find("success") or lower:find("~g~") then return "success" end
    if lower:find("advertencia") or lower:find("warning") or lower:find("~y~") then return "warning" end
    if lower:find("informacion") or lower:find("info") or lower:find("~b~") then return "info" end
    if lower:find("sistema") or lower:find("main") then return "main" end
    return "info"
end

CreateThread(function()
    while not ESX do Wait(500) end
    pcall(function()
        local originalShowNotification = ESX.ShowNotification
        ESX.ShowNotification = function(message)
            local detectedType = detectTypeFromMessage(message)
            local cleanMsg = message:gsub('~[%w_]-~', '')
            exports['aka-notify']:ShowNotification(cleanMsg, detectedType)
            log('ESX.ShowNotification interceptado: ' .. tostring(cleanMsg))
        end
        log('ESX.ShowNotification overrideado')
    end)
    pcall(function()
        local originalAdvanced = ESX.ShowAdvancedNotification
        ESX.ShowAdvancedNotification = function(sender, subject, msg, textureDict, textureName, flash, saveToBrief, hudColorIndex)
            local detectedType = "info"
            if hudColorIndex then
                local hudColorMap = { [2] = "error", [3] = "success", [5] = "warning", [4] = "info", [6] = "main" }
                detectedType = hudColorMap[hudColorIndex] or "info"
            end
            local title = subject or "Notificación"
            exports['aka-notify']:ShowNotification(msg, detectedType, { title = title })
            log('ESX.ShowAdvancedNotification interceptado: ' .. tostring(msg))
        end
        log('ESX.ShowAdvancedNotification overrideado')
    end)
end)

-- ======================================================
-- NOTIFICACIONES ITEMBOX (origen_inventory)
-- ======================================================
RegisterNetEvent("inventory:client:ItemBox", function(itemDef, label)
    if not itemDef or not label then return end
    local data = {
        action = "notification",
        itemName = itemDef.name,
        itemLabel = itemDef.label or itemDef.name,
        label = label,
        type = "item"
    }
    if itemDef.color then data.color = itemDef.color end
    SendNUIMessage(data)
end)

-- ======================================================
-- COMANDO DE PRUEBA
-- ======================================================
RegisterCommand('testnotif', function(_, args)
    local t = (args[1] or "item"):lower()
    if t == "item" then
        SendNUIMessage({
            action = "notification",
            itemName = "water",
            itemLabel = "Agua",
            label = "Usaste",
            type = "item"
        })
    elseif t == "color" and args[2] then
        exports['aka-notify']:ShowNotification('Notificación con color ' .. args[2], 'info', { color = args[2], title = 'Color Custom' })
    elseif t == "all" then
        exports['aka-notify']:ShowNotification('Operación exitosa', 'success')
        Wait(100)
        exports['aka-notify']:ShowNotification('Ocurrió un error', 'error')
        Wait(100)
        exports['aka-notify']:ShowNotification('Cuidado con eso', 'warning')
        Wait(100)
        exports['aka-notify']:ShowNotification('Información importante', 'info')
        Wait(100)
        exports['aka-notify']:ShowNotification('Mensaje del sistema', 'main')
        Wait(100)
        exports['aka-notify']:ShowNotification('Color personalizado', 'info', { color = '#ff8800', title = 'Custom' })
    else
        exports['aka-notify']:ShowNotification('Notificación de prueba: ' .. t, t)
    end
end, false)
