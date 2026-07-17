Config = {}

Config.UseTarget = GetConvar('UseTarget', 'false') == 'true'
Config.SearchDuration = 4000
Config.DumpsterSearchDuration = 4000
Config.MailboxSearchDuration = 4000
Config.DumpsterCooldownDuration = 600 -- Time in seconds each dumpster is locked after being searched (default: 10 minutes)
Config.MailboxCooldownDuration = 600 -- Time in seconds each mailbox is locked after being searched (default: 10 minutes)
Config.SearchAnimation = {
    dict = 'amb@prop_human_bum_bin@idle_b',
    anim = 'idle_d'
}

Config.MailboxRequiredItem = 'lockpick'
Config.MailboxLockpickBreakChance = 15 -- percent chance (100% = always break, 0% = never break)

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

Config.MailboxModels = {
    'prop_postbox_01a',
    'prop_postbox_ss_01a',
    'prop_letterbox_01',
    'prop_letterbox_02',
    'prop_letterbox_03',
    'prop_letterbox_04'
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

Config.MailboxRewardItems = {
    'plastic',
    'metalscrap',
    'copper',
    'rubber'
}

Config.MailboxRareRewardItems = {
    'trojan_usb',
    'advancedlockpick'
}

Config.RareRewardChance = 5 -- percent (5%)
Config.RewardRolls = 6
Config.RewardAmountMin = 2
Config.RewardAmountMax = 4

Config.MailboxRareRewardChance = 10 -- percent (10%)
Config.MailboxRewardRolls = 1
Config.MailboxRewardAmountMin = 1
Config.MailboxRewardAmountMax = 2
