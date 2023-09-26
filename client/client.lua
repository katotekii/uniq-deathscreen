local function onPlayerDeath()
    local killername = nil
    TriggerEvent('uniq-deathscreen:client:setDeathStatus', true)
    SendNUIMessage({type = "show", status = true})
    SetNuiFocus(true, true)

    local PedKiller = GetPedSourceOfDeath(PlayerPedId())
    local killerid = NetworkGetPlayerIndexFromPed(PedKiller)

    if IsEntityAVehicle(PedKiller) and IsEntityAPed(GetVehiclePedIsIn(PedKiller, -1)) and IsPedAPlayer(GetPedInVehicleSeat(PedKiller, -1)) then
        killerid = NetworkGetPlayerIndexFromPed(GetPedInVehicleSeat(PedKiller, -1))
    end

    if (killerid == -1) then
        killername = Config.Translation.Suicide
    elseif (killerid == nil) then
        killername = Config.Translation.Unknown
    elseif (killerid ~= -1) then

        if Config.UseRPName then
            TriggerServerEvent('uniq-deathscreen:server:getRPName', GetPlayerServerId(killerid))
        else
            killername = GetPlayerName(killerid)
        end
    end

    SendNUIMessage({type = 'setUPValues', killer = killername, timer = Config.Timer})
end

RegisterNetEvent('uniq-deathscreen:client:onPlayerDeath', onPlayerDeath)

RegisterNetEvent('uniq-deathscreen:client:getRPName')
AddEventHandler('uniq-deathscreen:client:getRPName', function(name)
    SendNUIMessage({type = 'setUPValues', killer = name, timer = Config.Timer})
end)

local function HideUI()
    SendNUIMessage({type = "show", status = false})
    SetNuiFocus(false, false)
end

RegisterNetEvent('uniq-deathscreen:client:hide_ui', HideUI)

if GetResourceState('es_extended'):find('start') then
    AddEventHandler('esx:onPlayerDeath', onPlayerDeath)
    AddEventHandler('esx:onPlayerSpawn', HideUI)
elseif GetResourceState('qb-core'):find('start') then
    RegisterNetEvent('QBCore:Player:SetPlayerData', function(data)
        if (data.metadata.isdead or data.metadata.inlaststand) then
            onPlayerDeath()
        else
            HideUI()
        end
    end)
end

RegisterNuiCallback("accept_to_die", function(data)
    SendNUIMessage({type = "show", status = false})
    SetNuiFocus(false, false)
    TriggerEvent('uniq-deathscreen:client:remove_revive')
    if Config.Framework == 'esx' then
        Core.TriggerServerCallback("uniq-deathscreen:server:removeMoney")
        Core.ShowNotification((Config.Translation.MoneyRemoved):format(Config.PriceForDead))
    elseif Config.Framework == 'qbcore' then
        Core.Functions.TriggerCallback("uniq-deathscreen:server:removeMoney")
        Core.Functions.Notify((Config.Translation.MoneyRemoved):format(Config.PriceForDead), 'primary', 5000)
    end
end)

RegisterNuiCallback("call_emergency", function(data)
    SendDistressSignal()
end)

RegisterNuiCallback("time_expired", function(data)
    SetNuiFocus(false, false)
    TriggerEvent('uniq-deathscreen:client:remove_revive')
end)
