local correctResXList = {15360, 7680, 3840, 1920, 1280}
if storage.auto then
    for index, player in pairs(storage.auto) do
        if correctResXList[player.resolution_index] ~= player.resX then
            storage.auto[index].resolution_index = player.resolution_index + 1
        end
    end
end