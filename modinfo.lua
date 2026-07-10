return {
    name = "往生奔赴骨片",
    author = "Alan",
    version = "1.00",
    description = "version " .. version ..
"\n敲碎亡者骨架获得往生骨片，有52%概率获得奔赴骨片"
"\n往生骨片：右键传送到亡者骨架区域"
"\n奔赴骨片：右键传送到亡者目前所在区域",

    forumthread = "",

    api_version = 10,

    icon_atlas = "modicon.xml",
    icon = "modicon.tex",

    dst_compatible = true,
    client_only_mod = false,
    all_clients_require_mod = true,

    server_filter_tags = {"bone teleport","soul bond"},

    priority = 0.1,

    configuration_options = {
        {
            name = "Teleport_Hunger_Cost",
            label = "Teleport Hunger Drain",
            options = {
                {description = "No Cost", data = 0},
                {description = "0.25x", data = 0.25},
                {description = "0.5x", data = 0.5},
                {description = "1.0x", data = 1},
                {description = "2.0x", data = 2},
                {description = "4.0x", data = 4},
                {description = "8.0x", data = 8}
            },
            default = 0.5
        },
        {
            name = "Teleport_Sanity_Cost",
            label = "Teleport Sanity Drain",
            options = {
                {description = "No Cost", data = 0},
                {description = "0.25x", data = 0.25},
                {description = "0.5x", data = 0.5},
                {description = "1.0x", data = 1},
                {description = "2.0x", data = 2},
                {description = "4.0x", data = 4},
                {description = "8.0x", data = 8}
            },
            default = 0.5
        },
        {
            name = "OnlySelfSkeleton",
            label = "Only Bind Your Own Skeleton",
            options = {
                {description = "Enable", data = true},
                {description = "Disable", data = false}
            },
            default = true
        },
        {
            name = "BlockRuinsSkeleton",
            label = "Ignore Ruins Skeletons",
            options = {
                {description = "Enable", data = true},
                {description = "Disable", data = false}
            },
            default = true
        }
    }
}