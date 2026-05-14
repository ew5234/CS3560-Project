extends Vision

class_name VisionScope

var currentPosition
var scopeCoors = []

func scope():
	return scopeCoors

func getScope(visionType):
	if visionType == "standard":
		return VisionScopeStandard.new()
	elif visionType == "cautious":
		return VisionScopeCautious.new()
	elif visionType == "broad":
		return VisionScopeBroad.new()
	elif visionType == "cone":
		return VisionScopeCone.new()
