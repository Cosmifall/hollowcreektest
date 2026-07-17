Config = {}

Config.UseTarget = GetConvar('UseTarget', 'false') == 'true'
Config.SearchDuration = 4000
Config.SearchAnimation = {
    dict = 'amb@prop_human_bum_bin@idle_b',
    anim = 'idle_d'
}
Config.DumpsterModels = {
    'prop_dumpster_01a',
    'prop_dumpster_02a',
    'prop_dumpster_02b',
    'prop_dumpster_3a',
    'prop_dumpster_3step',
    'prop_dumpster_4a',
    'prop_dumpster_4b',
    'prop_cs_dumpster_01a',
    'prop_cs_dumpster_lidl',
    'prop_cs_dumpster_lidr',
    'p_dumpster_t',
    'prop_snow_dumpster_01'
}

Config.RewardItems = {
    'plastic',
    'metalscrap',
    'copper',
    'aluminum',
    'aluminumoxide',
    'iron',
    'ironoxide',
    'steel',
    'rubber',
    'glass'
}

Config.RareRewardItems = {
    'pistol_ammo',
    'weapon_pistol'
}

Config.RareRewardChance = 5 -- percent (5%)
Config.RewardRolls = 8
Config.RewardAmountMin = 1
Config.RewardAmountMax = 4
