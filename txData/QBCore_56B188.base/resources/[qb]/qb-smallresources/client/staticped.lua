local ped = nil
local pedCoords = vector4(-1916.08, 1388.94, 220.46, 266.47)
local pedModel = GetHashKey('mp_m_bogdangoon')

local function spawnStaticPed()
    if ped and DoesEntityExist(ped) then
        return
    end

    RequestModel(pedModel)
    while not HasModelLoaded(pedModel) do
        Wait(100)
    end

    local spawnZ = pedCoords.z
    local foundGround, groundZ = GetGroundZFor_3dCoord(pedCoords.x, pedCoords.y, pedCoords.z + 5.0, 0)
    if foundGround then
        spawnZ = groundZ
    end

    ped = CreatePed(4, pedModel, pedCoords.x, pedCoords.y, spawnZ, pedCoords.w, false, false)
    SetEntityCoords(ped, pedCoords.x, pedCoords.y, spawnZ, false, false, false, false)
    SetEntityHeading(ped, pedCoords.w)
    SetEntityAsMissionEntity(ped, true, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
    FreezeEntityPosition(ped, true)
    SetEntityInvincible(ped, true)
    SetPedCanRagdoll(ped, false)
    SetPedCanPlayAmbientAnims(ped, false)
    SetPedCanPlayAmbientAnims(ped, false)
    SetPedFleeAttributes(ped, 0, false)
    SetPedCombatAttributes(ped, 0, false)
    SetPedCanBeTargetted(ped, false)
    SetPedKeepTask(ped, true)
    TaskStandStill(ped, -1)
    SetModelAsNoLongerNeeded(pedModel)
end

AddEventHandler('onClientResourceStart', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        spawnStaticPed()
    end
end)

CreateThread(function()
    while true do
        if not ped or not DoesEntityExist(ped) then
            spawnStaticPed()
        end
        Wait(5000)
    end
end)
