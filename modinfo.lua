return {
    name = "往生奔赴骨片",
    author = "Alan",
    version = "1.00",
    description = "版本 " .. "1.00" .. "\n" ..
                  "敲碎亡者骨架稳定获得往生骨片，52%概率额外产出奔赴羁绊骨片\n\n" ..
                  "【道具玩法】\n" ..
                  "1.往生骨片\n" ..
                  "右键使用，传送到该玩家死亡骨架位置，一次性消耗；\n" ..
                  "模组设置可开启「仅传送自身骨架」，关闭后全玩家通用所有往生骨；\n" ..
                  "传送会消耗设置好的饥饿与精神值，目标为海洋时传送失败。\n\n" ..
                  "2.奔赴羁绊骨片\n" ..
                  "两人互相右键对方建立羁绊，双方口袋各获得一枚绑定骨；\n" ..
                  "右键骨片无限次传送到绑定好友身边，无任何消耗；\n" ..
                  "好友离线、变鬼魂、目标在海洋时传送失败。\n\n" ..
                  "【模组设置】\n" ..
                  "1.传送饥饿消耗倍率：无消耗 / 0.25x / 0.5x / 1x / 2x / 4x / 8x（默认0.5）\n" ..
                  "2.传送精神消耗倍率：无消耗 / 0.25x / 0.5x / 1x / 2x / 4x / 8x（默认0.5）\n" ..
                  "3.仅能使用自己骨架产出的往生骨：开关\n" ..
                  "4.地下遗迹骷髅不生成往生骨：开关",
    forumthread = "",
    api_version = 10,
    icon_atlas = "modicon.xml",
    icon = "modicon.tex",
    dst_compatible = true,
    client_only_mod = false,
    all_clients_require_mod = true,
    server_filter_tags = {"bone teleport", "soul bond"},
    priority = 0.1,
    configuration_options = {
        {
            name = "Teleport_Hunger_Cost",
            label = "传送饥饿消耗倍率",
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
            label = "仅能使用自己的往生骨",
            options = {
                {description = "开启", data = true},
                {description = "关闭", data = false}
            },
            default = true
        },
        {
            name = "BlockRuinsSkeleton",
            label = "遗迹骷髅不生成往生骨",
            options = {
                {description = "开启", data = true},
                {description = "关闭", data = false}
            },
            default = true
        }
    }
}