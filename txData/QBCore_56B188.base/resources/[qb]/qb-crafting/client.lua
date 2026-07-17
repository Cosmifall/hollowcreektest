local QBCore = exports['qb-core']:GetCoreObject({ 'Functions' })
local sharedItems = exports['qb-core']:GetShared('Items')

-- Functions

local function CraftItem(craftedItem, requiredItems, amountToCraft, xpEarned, xpType)
    QBCore.Functions.TriggerCallback('crafting:getPlayerInventory', function(inventory)
        local hasAllMaterials = true
        for _, reqItem in pairs(requiredItems) do
            local itemAmount = 0
            for _, invItem in pairs(inventory) do
                if invItem.name == reqItem.item then
                    itemAmount = invItem.amount
                    break
                end
            end
            if itemAmount < reqItem.amount then
                hasAllMaterials = false
                QBCore.Functions.Notify(string.format(Lang:t('notifications.notenoughMaterials')) .. amountToCraft .. 'x ' .. sharedItems[craftedItem].label, 'error')
                break
            end
        end
        if hasAllMaterials then
            QBCore.Functions.Progressbar('crafting_item', 'Crafting ' .. sharedItems[craftedItem].label, (math.random(2000, 5000) * amountToCraft), false, true, {
                disableMovement = true,
                disableCarMovement = true,
                disableMouse = false,
                disableCombat = true,
            }, {
                animDict = 'mini@repair',
                anim = 'fixing_a_player',
                flags = 16,
            }, {}, {}, function()
                TriggerServerEvent('qb-crafting:server:receiveItem', craftedItem, requiredItems, amountToCraft, xpEarned, xpType)
            end)
        else
            QBCore.Functions.Notify(string.format(Lang:t('notifications.notenoughMaterials')), 'error')
        end
    end)
end

local function CraftAmount(craftedItem, requiredItems, xpGain, xpType)
    local dialog = exports['qb-input']:ShowInput({
        header = string.format(Lang:t('menus.entercraftAmount')),
        submitText = 'Confirm',
        inputs = {
            {
                type = 'number',
                name = 'amount',
                label = 'Amount',
                text = 'Enter Amount',
                isRequired = true
            },
        },
    })
    if dialog and tonumber(dialog.amount) then
        local amount = tonumber(dialog.amount)
        if amount > 0 then
            local multipliedItems = {}
            for _, reqItem in ipairs(requiredItems) do
                multipliedItems[#multipliedItems + 1] = {
                    item = reqItem.item,
                    amount = reqItem.amount * amount
                }
            end
            CraftItem(craftedItem, multipliedItems, amount, xpGain * amount, xpType)
        else
            QBCore.Functions.Notify(string.format(Lang:t('notifications.invalidAmount')), 'error')
        end
    else
        QBCore.Functions.Notify(string.format(Lang:t('notifications.invalidInput')), 'error')
    end
end

local function OpenCraftingMenu(benchType)
    local PlayerData = QBCore.Functions.GetPlayerData()
    local benchConfig = Config[benchType]
    local xpType = benchConfig and benchConfig.xpType or 'craftingrep'
    local recipes = {}

    if benchConfig and benchConfig.recipe then
        recipes = { benchConfig.recipe }
    elseif benchConfig and benchConfig.recipes then
        recipes = benchConfig.recipes
    end

    local currentXP = PlayerData.metadata[xpType] or 0

    QBCore.Functions.TriggerCallback('crafting:getPlayerInventory', function(inventory)
        local craftableItems = {}
        local nonCraftableItems = {}
        for _, recipe in pairs(recipes) do
            local canCraft = true
            local itemsText = ''
            for _, reqItem in pairs(recipe.requiredItems) do
                local hasItem = false
                for _, invItem in pairs(inventory) do
                    if invItem.name == reqItem.item and invItem.amount >= reqItem.amount then
                        hasItem = true
                        break
                    end
                end
                local itemLabel = sharedItems[reqItem.item].label
                itemsText = itemsText .. ' x' .. tostring(reqItem.amount) .. ' ' .. itemLabel .. '<br>'
                if not hasItem then
                    canCraft = false
                end
            end
            itemsText = string.sub(itemsText, 1, -5)

            local xpReady = currentXP >= recipe.xpRequired
            local menuItem = {
                header = sharedItems[recipe.item].label,
                txt = itemsText .. '<br><br>Requires ' .. tostring(recipe.xpRequired) .. ' ' .. xpType .. ' XP',
                icon = Config.ImageBasePath .. sharedItems[recipe.item].image,
                params = {
                    isAction = true,
                    event = function()
                        if not xpReady then
                            QBCore.Functions.Notify('You do not have the required crafting reputation for this recipe.', 'error')
                            return
                        end
                        CraftAmount(recipe.item, recipe.requiredItems, recipe.xpGain, xpType)
                    end,
                    args = {}
                },
                disabled = not canCraft or not xpReady
            }
            if canCraft and xpReady then
                craftableItems[#craftableItems + 1] = menuItem
            else
                nonCraftableItems[#nonCraftableItems + 1] = menuItem
            end
        end
        local menuItems = {
            {
                header = string.format(Lang:t('menus.header')),
                icon = 'fas fa-drafting-compass',
                isMenuHeader = true,
            }
        }
        for _, item in ipairs(craftableItems) do
            menuItems[#menuItems + 1] = item
        end
        for _, item in ipairs(nonCraftableItems) do
            menuItems[#menuItems + 1] = item
        end
        exports['qb-menu']:openMenu(menuItems)
    end)
end

local function PickupBench(benchType, benchEntity)
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local propHash = Config[benchType].object
    local entity = benchEntity or GetClosestObjectOfType(playerCoords, 3.0, propHash, false, false, false)

    if DoesEntityExist(entity) then
        QBCore.Functions.TriggerCallback('qb-crafting:server:canPickupCraftingTable', function(canPickup)
            if not canPickup then
                QBCore.Functions.Notify(Lang:t('notifications.pickupBench') or 'You do not own this bench', 'error')
                return
            end

            DeleteEntity(entity)
            TriggerServerEvent('qb-crafting:server:addCraftingTable', benchType)
            QBCore.Functions.Notify(string.format(Lang:t('notifications.pickupBench')), 'success')
        end, benchType, GetEntityCoords(entity))
    end
end

local function AddBenchTarget(entity, benchType)
    exports['qb-target']:AddTargetEntity(entity, {
        options = {
            {
                icon = 'fas fa-tools',
                label = string.format(Lang:t('menus.header')),
                action = function()
                    OpenCraftingMenu(benchType)
                end
            },
            {
                event = 'crafting:pickupWorkbench',
                icon = 'fas fa-hand-rock',
                label = string.format(Lang:t('menus.pickupworkBench')),
                action = function()
                    PickupBench(benchType, entity)
                end,
            }
        },
        distance = 2.5
    })
end

local function SpawnCraftingBench(benchType, placement)
    if not Config[benchType] then return end

    local coords = placement.coords
    local benchEntity = CreateObject(Config[benchType].object, coords.x, coords.y, coords.z, true, true, true)
    if not DoesEntityExist(benchEntity) then return end

    SetEntityHeading(benchEntity, placement.heading or 0.0)
    PlaceObjectOnGroundProperly(benchEntity)
    AddBenchTarget(benchEntity, benchType)
end

-- Events

RegisterCommand('craftingrep', function()
    QBCore.Functions.TriggerCallback('crafting:getPlayerRep', function(rep)
        QBCore.Functions.Notify('Your crafting reputation is: ' .. tostring(rep), 'primary')
    end)
end, false)

RegisterNetEvent('qb-crafting:client:useCraftingTable', function(benchType)
    local playerPed = PlayerPedId()
    local coordsP = GetOffsetFromEntityInWorldCoords(playerPed, 0.0, 1.0, 1.0)
    local playerHeading = GetEntityHeading(PlayerPedId())
    local itemHeading = playerHeading - 90
    local workbench = CreateObject(Config[benchType].object, coordsP, true, true, true)
    if itemHeading < 0 then itemHeading = 360 + itemHeading end
    SetEntityHeading(workbench, itemHeading)
    PlaceObjectOnGroundProperly(workbench)
    TriggerServerEvent('qb-crafting:server:removeCraftingTable', benchType)
    TriggerServerEvent('qb-crafting:server:registerCraftingTable', benchType, GetEntityCoords(workbench), GetEntityHeading(workbench))
    AddBenchTarget(workbench, benchType)
end)

RegisterNetEvent('qb-crafting:client:restorePlacedBenches', function(placedBenches)
    if not placedBenches then return end

    for ownerKey, ownerPlacements in pairs(placedBenches) do
        if type(ownerPlacements) == 'table' then
            for benchType, placement in pairs(ownerPlacements) do
                if type(placement) == 'table' and placement.coords then
                    SpawnCraftingBench(benchType, placement)
                end
            end
        end
    end
end)

CreateThread(function()
    while not LocalPlayer.state.isLoggedIn do
        Wait(500)
    end
    Wait(1000)
    TriggerServerEvent('qb-crafting:server:requestPlacedBenches')
end)
