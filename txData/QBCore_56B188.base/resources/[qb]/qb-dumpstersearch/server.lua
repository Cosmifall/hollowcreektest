local QBCore = exports['qb-core']:GetCoreObject()
local dumpsterCooldowns = {}
local mailboxCooldowns = {}

local function getDumpsterCooldownDuration()
    return tonumber(Config.DumpsterCooldownDuration)
        or tonumber(Config.CooldownDuration)
        or 10 * 60
end

local function getMailboxCooldownDuration()
    return tonumber(Config.MailboxCooldownDuration)
        or tonumber(Config.CooldownDuration)
        or getDumpsterCooldownDuration()
end

local function getEntityKey(netId, model, x, y, z, heading)
    if tonumber(netId) and tonumber(netId) ~= 0 then
        return ('net:%s'):format(netId)
    end

    return string.format('coord:%s:%s:%s:%s:%s', tostring(model or 0), string.format('%.4f', x), string.format('%.4f', y), string.format('%.4f', z), string.format('%.2f', heading or 0.0))
end

local function addRewards(src, commonItems, rareItems, rolls, minAmount, maxAmount, rareChance, reason)
    local gaveAny = false
    local addedItems = {}

    for i = 1, rolls do
        local amount = math.random(minAmount, maxAmount)
        if amount > 0 then
            local item = commonItems[math.random(#commonItems)]
            local success = exports['qb-inventory']:AddItem(src, item, amount, false, false, reason)
            if success then
                gaveAny = true
                addedItems[#addedItems + 1] = {
                    name = item,
                    amount = amount,
                }
            end
        end
    end

    if #rareItems > 0 and math.random(1, 100) <= rareChance then
        local rareItem = rareItems[math.random(#rareItems)]
        local success = exports['qb-inventory']:AddItem(src, rareItem, 1, false, false, reason)
        if success then
            gaveAny = true
            addedItems[#addedItems + 1] = {
                name = rareItem,
                amount = 1,
            }
        end
    end

    return gaveAny, addedItems
end

RegisterNetEvent('qb-dumpstersearch:server:requestSearch', function(netId, model, x, y, z, heading)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local key = getEntityKey(netId, model, x, y, z, heading)
    local currentTime = os.time()
    local cooldownUntil = dumpsterCooldowns[key]

    if cooldownUntil and cooldownUntil > currentTime then
        TriggerClientEvent('qb-dumpstersearch:client:cooldownActive', src, cooldownUntil - currentTime)
        return
    end

    dumpsterCooldowns[key] = currentTime + getDumpsterCooldownDuration()
    TriggerClientEvent('qb-dumpstersearch:client:startSearch', src)
end)

RegisterNetEvent('qb-dumpstersearch:server:requestMailboxSearch', function(netId, model, x, y, z, heading)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    if not Player.Functions.GetItemByName(Config.MailboxRequiredItem) then
        TriggerClientEvent('qb-dumpstersearch:client:noLockpick', src)
        return
    end

    local key = getEntityKey(netId, model, x, y, z, heading)
    local currentTime = os.time()
    local cooldownUntil = mailboxCooldowns[key]

    if cooldownUntil and cooldownUntil > currentTime then
        TriggerClientEvent('qb-dumpstersearch:client:mailboxCooldownActive', src, cooldownUntil - currentTime)
        return
    end

    local breakChance = tonumber(Config.MailboxLockpickBreakChance) or 0
    if breakChance > 0 and math.random(1, 100) <= breakChance then
        local removed = exports['qb-inventory']:RemoveItem(src, Config.MailboxRequiredItem, 1, false, 'qb-dumpstersearch:server:requestMailboxSearch')
        if not removed then
            TriggerClientEvent('qb-dumpstersearch:client:noLockpick', src)
            return
        end

        TriggerClientEvent('qb-dumpstersearch:client:mailboxLockpickBroke', src)
    end

    mailboxCooldowns[key] = currentTime + getMailboxCooldownDuration()
    TriggerClientEvent('qb-dumpstersearch:client:startMailboxSearch', src)
end)

RegisterNetEvent('qb-dumpstersearch:server:giveReward', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local gaveAny, addedItems = addRewards(
        src,
        Config.RewardItems,
        Config.RareRewardItems,
        Config.RewardRolls,
        Config.RewardAmountMin,
        Config.RewardAmountMax,
        Config.RareRewardChance,
        'qb-dumpstersearch:server:giveReward'
    )

    if gaveAny then
        TriggerClientEvent('qb-dumpstersearch:client:notifySuccess', src, addedItems)
    end
end)

RegisterNetEvent('qb-dumpstersearch:server:giveMailboxReward', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local gaveAny, addedItems = addRewards(
        src,
        Config.MailboxRewardItems,
        Config.MailboxRareRewardItems,
        Config.MailboxRewardRolls,
        Config.MailboxRewardAmountMin,
        Config.MailboxRewardAmountMax,
        Config.MailboxRareRewardChance,
        'qb-dumpstersearch:server:giveMailboxReward'
    )

    if gaveAny then
        TriggerClientEvent('qb-dumpstersearch:client:notifySuccess', src, addedItems)
    end
end)
