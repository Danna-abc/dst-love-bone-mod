GLOBAL.AddPrefabPostInit("shallowgrave", function(inst)
    inst:ListenForEvent("workfinished", IndependentSpawnBones)
end)