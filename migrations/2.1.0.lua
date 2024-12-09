--[[
With surface support the fields for auto screenshots became tables,
with surface indexi being the index in the table. This migration script
should fix precisely that
]]--
if storage.auto then
    for index, player in pairs(storage.auto) do
        if storage.auto[index].doScreenshot ~= nil then
            if not storage.auto[index].doSurface then
                storage.auto[index].doSurface = {nauvis = storage.auto[index].doScreenshot}
            end
            storage.auto[index].doScreenshot = nil
        end
        if type(storage.auto[index].zoom) == "number" then
            storage.auto[index].zoom = {}
        end
        if type(storage.auto[index].zoomLevel) == "number" then
            storage.auto[index].zoomLevel = nil
        end
    end
end