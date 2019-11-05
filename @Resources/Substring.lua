function Initialize()
end

function Update()
	local target = SELF:GetOption("MeasureName")
	if target == "" then
		return ""
	end

	local start = tonumber(SELF:GetOption("Start")) or 1
	local stop = tonumber(SELF:GetOption("Stop")) or start
	
	if stop > start then
		return ""
	end

	return SKIN:GetMeasure(target):GetStringValue():sub(start, stop)
end
