GLOBAL.AddPrefabPostInit("skeleton", function(inst)
    inst:ListenForEvent("entityremove", function()
        if inst.owner_userid and not inst._bones_spawned then
            IndependentSpawnBones(inst)
        end
    end)
end)