local ffi = require("ffi")
local Kernel32 = ffi.load("Kernel32")
local t
local checkData = 0
local powerSafer

ffi.cdef[[
typedef struct _SYSTEM_POWER_STATUS {
	uint8_t ACLineStatus;
	uint8_t BatteryFlag;
	uint8_t BatteryLifePercent;
	uint8_t SystemStatusFlag;
	uint32_t BatteryLifeTime;
	uint32_t BatteryFullLifeTime;
} SYSTEM_POWER_STATUS, *LPSYSTEM_POWER_STATUS;
int __stdcall GetSystemPowerStatus(LPSYSTEM_POWER_STATUS lpSystemPowerStatus);
]]

local function updatePowerStatus()
	return Kernel32.GetSystemPowerStatus(t) > 0
end

local function updateMeasures()
	local isPowerSave = t.SystemStatusFlag == 1

	if isPowerSave == true and powerSafer == false then
		SKIN:Bang("!SetOption", "MeterBattery", "FontColor", "160,255,160,255")
		SKIN:Bang("!SetOption", "MeterBatteryStatus", "FontColor", "160,255,160,255")
		powerSafer = true
	elseif isPowerSave == false and powerSafer == true then
		SKIN:Bang("!SetOption", "MeterBattery", "FontColor", "255,255,255,255")
		SKIN:Bang("!SetOption", "MeterBatteryStatus", "FontColor", "255,255,255,255")
		powerSafer = false
	end

	if t.BatteryFlag == 255 then
		return "Unknown"
	elseif bit.band(t.BatteryFlag, 128) > 0 then
		return "None"
	end

	local charging = t.ACLineStatus == 1
	if t.BatteryLifePercent <= 20 then
		return "Low"
	elseif t.BatteryLifePercent <= 65 then
		return "Normal"
	elseif t.BatteryLifePercent == 100 and charging then
		return "Full"
	else
		return "High"
	end
end

function Initialize()
	t = ffi.new("SYSTEM_POWER_STATUS")
	checkData = tonumber(SELF:GetOption("Status", "0"))
	powerSafer = false

	if checkData == 1 then
		if updatePowerStatus() == false then
			print("Error calling GetSystemPowerStatus")
		end
		updateMeasures()
	end
end

function Update()
	if updatePowerStatus() == false then
		print("Error calling GetSystemPowerStatus")
		return 100
	end

	if checkData == 1 then
		local a, b = updateMeasures()
		if b then
			return string.format("%s (%s)", a, b)
		else
			return a
		end
	elseif bit.band(t.BatteryFlag, 128) > 0 then
		return 1
	elseif checkData == 2 then
		if t.ACLineStatus == 0 then
			return "Battery"
		elseif t.ACLineStatus == 1 then
			return "AC"
		else
			return "Unknown"
		end
	else
		return math.min(t.BatteryLifePercent, 100) / 100
	end
end
