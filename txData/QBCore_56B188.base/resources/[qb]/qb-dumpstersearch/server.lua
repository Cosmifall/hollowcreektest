local QBCore = exports['qb-core']:GetCoreObject()
local cooldowns = {}
local cooldownDuration = 10 * 60

local function getDumpsterKey(netId, model, x, y, z, heading)
    if tonumber(netId) and tonumber(netId) ~= 0 then
        return ('net:%s'):format(netId)
    end

    return string.format('coord:%s:%s:%s:%s:%s', tostring(model or 0), string.format('%.4f', x), string.format('%.4f', y), string.format('%.4f', z), string.format('%.2f', heading or 0.0))
end

RegisterNetEvent('qb-dumpstersearch:server:requestSearch', function(netId, model, x, y, z, heading)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local key = getDumpsterKey(netId, model, x, y, z, heading)
    local currentTime = os.time()
    local cooldownUntil = cooldowns[key]

    if cooldownUntil and cooldownUntil > currentTime then
        TriggerClientEvent('qb-dumpstersearch:client:cooldownActive', src, cooldownUntil - currentTime)
        return
    end

    cooldowns[key] = currentTime + cooldownDuration
    TriggerClientEvent('qb-dumpstersearch:client:startSearch', src)
end)

RegisterNetEvent('qb-dumpstersearch:server:giveReward', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local gaveAny = false
    local addedItems = {}

    for i = 1, Config.RewardRolls do
        local amount = math.random(Config.RewardAmountMin, Config.RewardAmountMax)
        if amount > 0 then
            local item = Config.RewardItems[math.random(#Config.RewardItems)]
            local success = exports['qb-inventory']:AddItem(src, item, amount, false, false, 'qb-dumpstersearch:server:giveReward')
            if success then
                gaveAny = true
                addedItems[#addedItems + 1] = {
                    name = item,
                    amount = amount,
                }
            end
        end
    end

    if math.random(1, 100) <= Config.RareRewardChance then
        local rareItem = Config.RareRewardItems[math.random(#Config.RareRewardItems)]
        local success = exports['qb-inventory']:AddItem(src, rareItem, 1, false, false, 'qb-dumpstersearch:server:giveReward')
        if success then
            gaveAny = true
            addedItems[#addedItems + 1] = {
                name = rareItem,
                amount = 1,
            }
        end
    end

    if gaveAny then
        TriggerClientEvent('qb-dumpstersearch:client:notifySuccess', src, addedItems)
    end
end)
