local math = require("math")
local os = require("os")
local cubicBezier
local interpolate
local timeDt
local isPM = false
local kind
local currentValue
local lastValue
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

local function getValue()
	if kind == "Minute" then
		return math.floor(((os.time() + getTimeOffset()) % 3600) / 60)
	else
		return ((os.time() + getTimeOffset()) % 60)
	end
end

function Initialize()
	if cubicBezier == nil then
		cubicBezier = dofile(SKIN:MakePathAbsolute("cubic_bezier.lua"))
	end

	-- Material interpolation
	interpolate = cubicBezier(0.4, 0, 0.2, 1):getFunction()
	timeDt = os.clock()
	kind = SELF:GetOption("Type")
	lastValue = getValue()
end

function Update()
	local c = os.clock()
	local dt = c - timeDt
	timeDt = c

	currentValue = getValue()
	if currentValue ~= lastValue and animInterval == 0 then
		animInterval = 0.3
	else
		animInterval = math.max(animInterval - dt, 0)
		if animInterval == 0 then
			lastValue = currentValue
		end
	end

	local v = currentValue ~= lastValue and lerp(lastValue, currentValue, interpolate((0.3 - animInterval) / 0.3)) or currentValue
	return v / 60
end
