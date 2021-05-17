local q = {}

--[[ Queue explanation
	The queue has one entry for every player

	Every player entry has a queue for every type of screenshot,
	with lower indexi being next
]]--

function q.initialize(index)
	global.queue[index] = {}
end

local function getDivisor(index)
	-- rough expected result:
	--  1,  2,  3,  4,  5,  6,  7,  8,  9, 10, 11, 12, 13, 14, 15, 16
	--  1,  2,  2,  2,  4,  4,  4,  4,  8,  8,  8,  8,  8,  8,  8,  8, 16 from there

	local zoomLevel = global.auto[index].zoomLevel
	local divisor
	if zoomLevel == 1 then
		divisor = 1
	elseif zoomLevel < 5 then
		divisor = 2
	elseif zoomLevel < 9 then
		divisor = 4
	elseif zoomLevel < 17 then
		divisor = 8
	else
		divisor = 16
	end
	
	divisor = divisor * (math.sqrt(global.auto[index].splittingFactor))

	if (global.verbose) then
		log("returned divisor " .. divisor .. " from input " .. zoomLevel)
	end

	return divisor
end

local function registerPlayerSingleScreenshots(index)
	for _, surface in pairs(game.surfaces) do
		-- TODO this
	end
end

local function registerPlayerFragmentedScreenshots(index)
	for _, surface in pairs(game.surfaces) do
		local numberOfTiles = getDivisor(index)
		local resX = global.auto[index].resX
		local resY = global.auto[index].resY
		local zoom = global.auto[index].zoom

		-- like calculating zoom, but reverse
		-- cannot take limits from global, as we want the border of the screenshot, not the base
		local rightborder = resX / (zoom * 2 * 32)
		local bottomborder = resY / (zoom * 2 * 32)

		local posXStepsize = rightborder * 2 / numberOfTiles
		local posYStepsize = bottomborder * 2 / numberOfTiles
		
		local temp = {
			res = {x = resX / numberOfTiles, y = resY / numberOfTiles},
			numberOfTiles = numberOfTiles,
			offset = {x=0, y=0},
			startpos = {x = -rightborder + posXStepsize / 2, y = -bottomborder + posYStepsize / 2},
			stepsize = {x = posXStepsize, y = posYStepsize},
			zoom = zoom,
			title = "screenshot" .. game.tick
		}

		if (global.verbose) then
			log("surface:    " .. temp["surface"])
			log("res:        " .. temp["res"].x .. "x" .. temp["res"].y)
			log("numOfTiles: " .. temp["numberOfTiles"])
			log("offset:     " .. temp["offset"].x .. " " .. temp["offset"].y)
			log("startpos:   " .. temp["startpos"].x .. " " .. temp["startpos"].y)
			log("stepsize:   " .. temp["stepsize"].x .. " " .. temp["stepsize"].y)
			log("zoom:       " .. temp["zoom"])
			log("title:      " .. temp["title"])
		end

		table.insert(global.queue.nextScreenshot, temp)
	end
end

-- CHANGE THIS
function q.registerPlayerToQueue(index)
	log("registering player to screenshot list")
	if global.auto[index].singleScreenshot then
		registerPlayerSingleScreenshots(index)
	else
		registerPlayerFragmentedScreenshots(index)
	end

end

-- CHANGE THIS
function q.refreshNextScreenshotTimestamp()
	local closest
	for _, player in pairs(game.connected_players) do
		if global.auto[player.index].doScreenshot then
			local times = math.floor(game.tick / global.auto[player.index].interval)
			local next = global.auto[player.index].interval * (times + 1)
			if closest == nil or next < closest then
				closest = next
			end
		end
	end

	if closest then
		global.queue.nextScreenshotTimestamp = closest
	else
		global.queue.nextScreenshotTimestamp = nil
	end
end

-- DO THIS
function q.remove(fragment)

end

-- DO THIS
function q.getNextStep()

end

-- CHANGE THIS
function q.hasAnyEntries()
	return global.queue.hasAnyEntries
end

function q.hasEntries(index)

end

return q