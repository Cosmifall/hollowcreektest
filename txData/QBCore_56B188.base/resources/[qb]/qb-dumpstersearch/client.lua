local QBCore = exports['qb-core']:GetCoreObject()
local searching = false
local hasRegisteredTarget = false

local function loadAnimDict(dict)
    if not HasAnimDictLoaded(dict) then
        RequestAnimDict(dict)
        while not HasAnimDictLoaded(dict) do
            Wait(0)
        end
    end
end

local function playSearchAnim()
    loadAnimDict(Config.SearchAnimation.dict)
    TaskPlayAnim(PlayerPedId(), Config.SearchAnimation.dict, Config.SearchAnimation.anim, 8.0, 8.0, -1, 50, 0, false, false, false)
end

local function stopSearchAnim()
    ClearPedTasks(PlayerPedId())
end

local function startSearch()
    if searching then return end
    searching = true

    playSearchAnim()

    QBCore.Functions.Progressbar('dumpster_search', Lang:t('progress.searching'), Config.SearchDuration, false, true, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true,
    }, {}, {}, {}, function()
        TriggerServerEvent('qb-dumpstersearch:server:giveReward')
        stopSearchAnim()
        searching = false
    end, function()
        QBCore.Functions.Notify(Lang:t('notify.failed'), 'error')
        stopSearchAnim()
        searching = false
    end)
end

RegisterNetEvent('qb-dumpstersearch:client:notifySuccess', function(items)
    local message = Lang:t('notify.success')
    if items and #items > 0 then
        local formatted = {}
        for _, item in ipairs(items) do
            table.insert(formatted, string.format('%s x%s', item.name, item.amount))
        end
        message = string.format('%s (%s)', message, table.concat(formatted, ', '))
    end
    QBCore.Functions.Notify(message, 'success')
end)

RegisterNetEvent('qb-dumpstersearch:client:cooldownActive', function(secondsLeft)
    QBCore.Functions.Notify(('This dumpster is still locked for %s seconds.'):format(secondsLeft), 'error')
end)

RegisterNetEvent('qb-dumpstersearch:client:startSearch', function()
    startSearch()
end)

CreateThread(function()
    if not Config.UseTarget then return end

    if not hasRegisteredTarget then
        exports['qb-target']:AddTargetModel(Config.DumpsterModels, {
            options = {
                {
                    icon = 'fa-solid fa-trash',
                    label = Lang:t('target.search'),
                    action = function(entity)
                        if searching then return end
                        local coords = GetEntityCoords(entity)
                        local heading = GetEntityHeading(entity)
                        local netId = 0

                        if entity and DoesEntityExist(entity) and NetworkGetEntityIsNetworked(entity) then
                            local success, networkId = pcall(NetworkGetNetworkIdFromEntity, entity)
                            if success and networkId then
                                netId = networkId
                            end
                        end

                        TriggerServerEvent('qb-dumpstersearch:server:requestSearch', netId, GetEntityModel(entity), coords.x, coords.y, coords.z, heading)
                    end,
                },
            },
            distance = 2.5,
        })
        hasRegisteredTarget = true
    end
end)
