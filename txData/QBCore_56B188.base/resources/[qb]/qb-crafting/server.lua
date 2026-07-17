local QBCore = exports['qb-core']:GetCoreObject({ 'Functions' })
local sharedItems = exports['qb-core']:GetShared('Items')

local placedBenches = {}
local benchPickupDistance = 3.0
local persistenceKey = 'qb-crafting:placedBenches'

-- Functions

local function GetOwnerKey(src, player)
    if player and player.PlayerData then
        if player.PlayerData.citizenid and player.PlayerData.citizenid ~= '' then
            return player.PlayerData.citizenid
        end
        if player.PlayerData.license and player.PlayerData.license ~= '' then
            return player.PlayerData.license
        end
    end
    return tostring(src)
end

local function SavePlacedBenches()
    SetResourceKvp(persistenceKey, json.encode(placedBenches))
end

local function BroadcastPlacedBenches()
    TriggerClientEvent('qb-crafting:client:restorePlacedBenches', -1, placedBenches)
end

local function LoadPlacedBenches()
    local saved = GetResourceKvpString(persistenceKey)
    if saved and saved ~= '' then
        local ok, decoded = pcall(function()
            return json.decode(saved)
        end)
        if ok and type(decoded) == 'table' then
            placedBenches = decoded
        end
    end
end

local function GetPlayerPlacements(src)
    local Player = exports['qb-core']:GetPlayer(src)
    if not Player then return nil end
    local ownerKey = GetOwnerKey(src, Player)
    return placedBenches[ownerKey] or {}
end

local function IncreasePlayerXP(source, xpGain, xpType)
    local Player = exports['qb-core']:GetPlayer(source)
    if Player then
        Player.AddRep(xpType, xpGain)
        if Player.PlayerData and Player.PlayerData.metadata then
            Player.PlayerData.metadata['rep'] = Player.PlayerData.metadata['rep'] or {}
            Player.PlayerData.metadata['rep'][xpType] = Player.GetRep(xpType)
        end
        TriggerClientEvent('QBCore:Notify', source, string.format(Lang:t('notifications.xpGain'), xpGain, xpType), 'success')
    end
end

-- Callbacks

QBCore.Functions.CreateCallback('crafting:getPlayerInventory', function(source, cb)
    local player = exports['qb-core']:GetPlayer(source)
    if player then
        cb(player.PlayerData.items)
    else
        cb({})
    end
end)

QBCore.Functions.CreateCallback('crafting:getPlayerRep', function(source, cb)
    local player = exports['qb-core']:GetPlayer(source)
    if player then
        cb(player.GetRep('craftingrep') or 0)
    else
        cb(0)
    end
end)

-- Events
RegisterServerEvent('qb-crafting:server:removeMaterials', function(itemName, amount)
    local src = source
    local Player = exports['qb-core']:GetPlayer(src)
    if Player then
        exports['qb-inventory']:RemoveItem(src, itemName, amount, false, 'qb-crafting:server:removeMaterials')
        TriggerClientEvent('qb-inventory:client:ItemBox', src, sharedItems[itemName], 'remove')
    end
end)

RegisterNetEvent('qb-crafting:server:removeCraftingTable', function(benchType)
    local src = source
    local Player = exports['qb-core']:GetPlayer(src)
    if not Player then return end
    exports['qb-inventory']:RemoveItem(src, benchType, 1, false, 'qb-crafting:server:removeCraftingTable')
    TriggerClientEvent('qb-inventory:client:ItemBox', src, sharedItems[benchType], 'remove')
    TriggerClientEvent('QBCore:Notify', src, Lang:t('notifications.tablePlace'), 'success')
end)

RegisterNetEvent('qb-crafting:server:registerCraftingTable', function(benchType, coords, heading)
    local src = source
    local Player = exports['qb-core']:GetPlayer(src)
    if not Player then return end

    local ownerKey = GetOwnerKey(src, Player)
    placedBenches[ownerKey] = placedBenches[ownerKey] or {}
    placedBenches[ownerKey][benchType] = {
        coords = {
            x = coords.x,
            y = coords.y,
            z = coords.z
        },
        heading = heading,
        placedAt = GetGameTimer()
    }
    SavePlacedBenches()
    BroadcastPlacedBenches()
end)

QBCore.Functions.CreateCallback('qb-crafting:server:canPickupCraftingTable', function(source, cb, benchType, coords)
    local src = source
    local Player = exports['qb-core']:GetPlayer(src)
    if not Player then
        cb(false)
        return
    end

    local ownerKey = GetOwnerKey(src, Player)
    local ownerPlacements = placedBenches[ownerKey]
    if not ownerPlacements or not ownerPlacements[benchType] then
        cb(false)
        return
    end

    local placement = ownerPlacements[benchType]
    local placementCoords = placement.coords
    if type(placementCoords) == 'table' then
        placementCoords = vector3(placementCoords.x or 0.0, placementCoords.y or 0.0, placementCoords.z or 0.0)
    end
    local distance = #(vector3(coords.x, coords.y, coords.z) - placementCoords)
    if distance > benchPickupDistance then
        cb(false)
        return
    end

    ownerPlacements[benchType] = nil
    if not next(ownerPlacements) then
        placedBenches[ownerKey] = nil
    end

    SavePlacedBenches()
    cb(true)
end)

RegisterNetEvent('qb-crafting:server:addCraftingTable', function(benchType)
    local src = source
    local Player = exports['qb-core']:GetPlayer(src)
    if not Player then return end
    if not exports['qb-inventory']:AddItem(src, benchType, 1, false, false, 'qb-crafting:server:addCraftingTable') then return end
    TriggerClientEvent('qb-inventory:client:ItemBox', src, sharedItems[benchType], 'add')
end)

RegisterNetEvent('qb-crafting:server:requestPlacedBenches', function()
    local src = source
    TriggerClientEvent('qb-crafting:client:restorePlacedBenches', src, placedBenches)
end)

RegisterNetEvent('qb-crafting:server:receiveItem', function(craftedItem, requiredItems, amountToCraft, xpGain, xpType)
    local src = source
    local Player = exports['qb-core']:GetPlayer(src)
    if not Player then return end
    local canGive = true
    for _, requiredItem in ipairs(requiredItems) do
        if not exports['qb-inventory']:RemoveItem(src, requiredItem.item, requiredItem.amount, false, 'qb-crafting:server:receiveItem') then
            canGive = false
            return
        end
        TriggerClientEvent('qb-inventory:client:ItemBox', src, sharedItems[requiredItem.item], 'remove')
    end
    if canGive then
        if not exports['qb-inventory']:AddItem(src, craftedItem, amountToCraft, false, false, 'qb-crafting:server:receiveItem') then return end
        TriggerClientEvent('qb-inventory:client:ItemBox', src, sharedItems[craftedItem], 'add')
        TriggerClientEvent('QBCore:Notify', src, string.format(Lang:t('notifications.craftMessage'), sharedItems[craftedItem].label), 'success')
        IncreasePlayerXP(src, xpGain, xpType)
    end
end)

-- Items

for benchType, v in pairs(Config) do
    if type(v) == 'table' then
        QBCore.Functions.CreateUseableItem(benchType, function(source)
            TriggerClientEvent('qb-crafting:client:useCraftingTable', source, benchType)
        end)
    end
end

LoadPlacedBenches()

CreateThread(function()
    Wait(1000)
    BroadcastPlacedBenches()
end)
