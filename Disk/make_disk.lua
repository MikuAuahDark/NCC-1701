local disks = {...}

local diskBase = [[
[Rainmeter]
Update=10000
BackgroundMode=1
SkinWidth=240
#SkinHeight=64

[Metadata]
Name=DiskBase
Author=MikuAuahDark
Information=...
Version=1.0

[MeasureShowProperties]
Measure=Script
ScriptFile=Properties.lua

[BaseStringStyle]
FontFace=Big Shoulders Text
FontSize=16
FontColor=255,255,255,255
InlineSetting=Shadow | 0 | 0 | 0.75 | 0,0,0,255
AccurateText=1
AntiAlias=1
]]

local diskPattern = [[
[MeasureUDSLetter${L}]
Measure=FreeDiskSpace
Drive=${L}:
InvertMeasure=1

[MeasureDSTotalLetter${L}]
Measure=FreeDiskSpace
Drive=${L}:
Total=1

[MeasurePercentDSLetter${L}]
Measure=Calc
Formula=Floor((MeasureUDSLetter${L} / MeasureDSTotalLetter${L}) * 100)

[MeterLetter${L}]
Meter=String
MeterStyle=BaseStringStyle
MeasureName=MeasurePercentDSLetter${L}
X=232
Y=${Y8}
StringAlign=RightTop
SolidColor=0,0,0,1
LeftMouseUpAction=[!CommandMeasure "MeasureShowProperties" "ShowDiskProperties('${L}')"]
Text=%1% ${L}:

[MeterStringDSAvail${L}]
Meter=String
MeterStyle=BaseStringStyle
MeasureName=MeasureUDSLetter${L}
MeasureName2=MeasureDSTotalLetter${L}
X=8
Y=${Y8}
AutoScale=1
Text=%1/%2

[MeterBorderLetter${L}]
Meter=Shape
UpdateDivider=-1
Shape=Rectangle 4,${Y4},232,56,8,8 | Fill Color 0,0,0,0 | StrokeWidth 2 | Stroke Color 0,0,0,127

[MeterBarDSLetter${L}]
Meter=Bar
MeasureName=MeasureUDSLetter${L}
X=4
Y=${Y38}
W=232
H=12
BarColor=0,0,0,128
SolidColor=0,0,0,0
BarOrientation=Horizontal
Flip=1
]]

print(diskBase)
for i, v in ipairs(disks) do
	local config = {
		L = v:sub(1, 1):upper(),
		Y4 = (i - 1) * 64 + 4,
		Y8 = (i - 1) * 64 + 8,
		Y38 = (i - 1) * 64 + 38
	}
	print((diskPattern:gsub("%${([A-Z0-9_]+)}", function(n)
		return config[n]
	end)))
end
