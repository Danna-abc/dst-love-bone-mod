return {
    name = "往生奔赴骨片",
    author = "Alan",
    version = "1.00",
    description = "
敲碎亡者骨架稳定获得往生骨片，52%概率额外产出奔赴羁绊骨片

【道具玩法】
1.往生骨片
右键使用，传送到该玩家死亡骨架位置，一次性消耗；
传送会消耗饥饿与精神值，目标为海洋时传送失败。

2.奔赴羁绊骨片
两人互相右键对方建立羁绊，双方口袋各获得一枚绑定骨；
右键骨片无限次传送到绑定好友身边，无任何消耗；
好友离线、变鬼魂、目标在海洋时传送失败。",

    forumthread = "",
    api_version = 10,
    dst_compatible = true,
    client_only_mod = false,
    all_clients_require_mod = true,
    server_filter_tags = {"bone teleport","soul bond"},
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