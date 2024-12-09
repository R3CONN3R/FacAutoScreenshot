local l = require("logger")

local tracker = {}

function tracker.initializeSurface(surface)
	storage.tracker[surface] = {}
	tracker.evaluateLimitsOfSurface(surface)
end

function tracker.on_surface_renamed(event)
	if storage.tracker[event.old_name] then
		storage.tracker[event.new_name] = storage.tracker[event.old_name]
		storage.tracker[event.old_name] = nil
	end
end

local function hasEntities(chunk, surface)
	local count = surface.count_entities_filtered{
		area=chunk.area,
		force="player",
		limit=1
	}
	return (count ~= 0)
end

function tracker.evaluateLimitsOfSurface(surface_index)
	log(l.info("Evaluating surface: " .. surface_index))
	
	local surface = game.surfaces[surface_index];
	local tchunk = nil;
	local rchunk = nil;
	local bchunk = nil;
	local lchunk = nil;
	
	for chunk in surface.get_chunks() do
		if hasEntities(chunk, surface) then
			if (tchunk == nil) then
				tchunk = chunk
				rchunk = chunk
				bchunk = chunk
				lchunk = chunk
			end
			
			if chunk.y < tchunk.y then
				tchunk = chunk
			elseif chunk.y > bchunk.y then
				bchunk = chunk
			end
			
			if chunk.x > rchunk.x then
				rchunk = chunk
			elseif chunk.x < lchunk.x then
				lchunk = chunk
			end
		end
	end
	
	-- if no blocks have been placed yet
	if tchunk == nil then
		log(l.info("tchunk is nil"))
		storage.tracker[surface_index].limitX = 64
		storage.tracker[surface_index].limitY = 64
		storage.tracker[surface_index].minX = -64
		storage.tracker[surface_index].maxX = 64
		storage.tracker[surface_index].minY = -64
		storage.tracker[surface_index].maxY = 64
	else
		storage.tracker[surface_index].minX = lchunk.area.left_top.x
		storage.tracker[surface_index].maxX = rchunk.area.right_bottom.x
		storage.tracker[surface_index].minY = tchunk.area.left_top.y
		storage.tracker[surface_index].maxY = bchunk.area.right_bottom.y

		if l.doD then log(l.debug("storage.tracker[", surface_index, "].minX: ", storage.tracker[surface_index].minX)) end
		if l.doD then log(l.debug("storage.tracker[", surface_index, "].maxX: ", storage.tracker[surface_index].maxX)) end
		if l.doD then log(l.debug("storage.tracker[", surface_index, "].minY: ", storage.tracker[surface_index].minY)) end
		if l.doD then log(l.debug("storage.tracker[", surface_index, "].maxY: ", storage.tracker[surface_index].maxY)) end

		local top = math.abs(tchunk.area.left_top.y)
		local right = math.abs(rchunk.area.right_bottom.x)
		local bottom = math.abs(bchunk.area.right_bottom.y)
		local left =  math.abs(lchunk.area.left_top.x)

		if l.doD then log(l.debug("top: ", top)) end
		if l.doD then log(l.debug("right: ", right)) end
		if l.doD then log(l.debug("bottom: ", bottom)) end
		if l.doD then log(l.debug("left: ", left)) end
		
		if (top > bottom) then
			storage.tracker[surface_index].limitY = top
		else
			storage.tracker[surface_index].limitY = bottom
		end
		
		if (left > right) then
			storage.tracker[surface_index].limitX = left
		else
			storage.tracker[surface_index].limitX = right
		end

		if l.doD then log(l.debug("limitX: ", storage.tracker[surface_index].limitX)) end
		if l.doD then log(l.debug("limitY: ", storage.tracker[surface_index].limitY)) end
	end
end

local function evaluateLimitsFromMinMax(surface)
	if l.doD then log(l.debug("evaluate limits from min max")) end

	if math.abs(storage.tracker[surface].minX) > storage.tracker[surface].maxX then
		storage.tracker[surface].limitX =  math.abs(storage.tracker[surface].minX)
	else
		storage.tracker[surface].limitX = storage.tracker[surface].maxX
	end
	
	if math.abs(storage.tracker[surface].minY) > storage.tracker[surface].maxY then
		storage.tracker[surface].limitY = math.abs(storage.tracker[surface].minY)
	else
		storage.tracker[surface].limitY = storage.tracker[surface].maxY
	end
end

function tracker.checkForMinMaxChange()
	local didSomethingChange = false
	for _, surface in pairs(game.surfaces) do
		if storage.tracker[surface.name].minMaxChanged then
			evaluateLimitsFromMinMax(surface.name)
			storage.tracker[surface.name].minMaxChanged = false
			didSomethingChange = true
		end
	end
	return didSomethingChange
end

function tracker.evaluateMinMaxFromPosition(pos, surface)
	if l.doD then log(l.debug("Evaluate min max on surface ", surface, " from position: ", pos.x, "x", pos.y)) end
	
	if pos.x < storage.tracker[surface].minX then
		storage.tracker[surface].minX = pos.x
	elseif pos.x > storage.tracker[surface].maxX then
		storage.tracker[surface].maxX = pos.x
	end
	
	if pos.y < storage.tracker[surface].minY then
		storage.tracker[surface].minY = pos.y
	elseif pos.y > storage.tracker[surface].maxY then
		storage.tracker[surface].maxY = pos.y
	end

	if l.doD then log(l.debug("storage.tracker[", surface, "].minX = ", storage.tracker[surface].minX)) end
	if l.doD then log(l.debug("storage.tracker[", surface, "].maxX = ", storage.tracker[surface].maxX)) end
	if l.doD then log(l.debug("storage.tracker[", surface, "].minY = ", storage.tracker[surface].minY)) end
	if l.doD then log(l.debug("storage.tracker[", surface, "].maxY = ", storage.tracker[surface].maxY)) end
	
	storage.tracker[surface].minMaxChanged = true
end

function tracker.breaksCurrentLimits(pos, surface)
	if l.doD then log(l.debug("breakscurrentLimits on surface ", surface, ": pos: ", pos.x, "x", pos.y)) end

	return (pos.x < storage.tracker[surface].minX or
	pos.x > storage.tracker[surface].maxX or
	pos.y < storage.tracker[surface].minY or
	pos.y > storage.tracker[surface].maxY)
end

return tracker