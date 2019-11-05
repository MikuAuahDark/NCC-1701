local math = require("math")
local os = require("os")
local cubicBezier
local interpolate
local timeDt
local isPM = false
local currentHour
local lastHour
local animInterval = 0

-- Function below is used to retrieve timezone offset
local offset
local function getTimeOffset()
	if not offset then
		local h, m, s, d = os.date("%H %M %S %d", 0):match("(%d+) (%d+) (%d+) (%d+)")
		offset = h * 3600 + m * 60 + s
		if d == "31" then
			-- UTC minus offset
			offset = 86400 - offset
		end
	end

	return offset
end

local function lerp(a, b, t)
	return a + (b - a) * t
end

local function getCurrentHour()
	return math.floor(((os.time() + getTimeOffset()) % 86400) / 3600)
end

function Initialize()
	if cubicBezier == nil then
		cubicBezier = dofile(SKIN:MakePathAbsolute("cubic_bezier.lua"))
	end

	-- Material interpolation
	interpolate = cubicBezier(0.4, 0, 0.2, 1):getFunction()
	timeDt = os.clock()
	lastHour = getCurrentHour()
end

function Update()
	local c = os.clock()
	local dt = c - timeDt
	timeDt = c

	currentHour = getCurrentHour()

	if currentHour ~= lastHour and animInterval == 0 then
		animInterval = 0.3
	else
		animInterval = math.max(animInterval - dt, 0)
		if animInterval == 0 then
			lastHour = currentHour
		end
	end

	if lastHour >= 12 and lastHour < 24 and isPM == false then
		SKIN:Bang("!SetOption", "MeterHour", "RotationAngle", "(Rad(-360))")
		isPM = true
	elseif lastHour >= 0 and lastHour < 12 and isPM == true then
		SKIN:Bang("!SetOption", "MeterHour", "RotationAngle", "(Rad(360))")
		isPM = false
	end
	
	local v = currentHour ~= lastHour and lerp(lastHour, currentHour, interpolate((0.3 - animInterval) / 0.3)) or currentHour
	if isPM then
		return 1 - (v / 12) % 1
	else
		return (v / 12) % 1
	end
end
