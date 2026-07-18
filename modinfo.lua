name = "往生奔赴骨片"
author = "Alan"
version = "1.0.0"
description = "1.往生骨片：玩家死亡生成专属记录骨片，敲碎亡者骨架稳定产出，52%概率额外产出奔赴羁绊骨。右键使用可传送到当初死亡的骨架点位，一次性消耗道具。传送会消耗饥饿与精神，落点为海洋直接传送失败。\n\n2.奔赴羁绊骨片：双人绑定专属道具，仅能存放于身体口袋。两人互相右键对方选择【建立羁绊】，双方口袋自动配对绑定骨；右键骨可无限次无消耗奔赴好友；好友离线、变鬼魂、身处海洋、跨世界传送失败，他人无法使用你的羁绊骨。"
forumthread = ""
api_version = 10
dst_compatible = true
all_clients_require_mod = true
client_only_mod = false
server_filter_tags = {"传送", "骨片", "羁绊", "传送道具"}
priority = 0
configuration_options = {
    {
        name = "Teleport_Hunger_Cost",
        label = "传送饥饿消耗倍率",
        hover = "每次使用往生骨传送扣除饥饿值倍数，0=无消耗",
        options = {
            {description = "无消耗", data = 0},
            {description = "0.25倍", data = 0.25},
            {description = "0.5倍", data = 0.5},
            {description = "1倍", data = 1},
            {description = "2倍", data = 2},
            {description = "4倍", data = 4},
            {description = "8倍", data = 8}
        },
        default = 0.5
    },
    {
        name = "Teleport_Sanity_Cost",
        label = "传送精神消耗倍率",
        hover = "每次使用往生骨传送扣除精神值倍数，0=无消耗",
        options = {
            {description = "无消耗", data = 0},
            {description = "0.25倍", data = 0.25},
            {description = "0.5倍", data = 0.5},
            {description = "1倍", data = 1},
            {description = "2倍", data = 2},
            {description = "4倍", data = 4},
            {description = "8倍", data = 8}
        },
        default = 0.5
    },
    {
        name = "OnlySelfSkeleton",
        label = "仅可使用自身死亡的往生骨",
        hover = "开启后只能使用自己死亡产出的骨，关闭可拾取别人死亡骨传送",
        options = {
            {description = "开启", data = true},
            {description = "关闭", data = false}
        },
        default = true
    },
    {
        name = "BlockRuinsSkeleton",
        label = "地下遗迹骷髅不生成骨片",
        hover = "开启后远古区域打碎骷髅不会产出往生/羁绊骨",
        options = {
            {description = "开启", data = true},
            {description = "关闭", data = false}
        },
        default = true
    }
}