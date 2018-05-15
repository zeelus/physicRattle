extends MeshInstance

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

var position = Vector3(0, 0, 0)
var mass = 100.0
const gravityConst = 0.01


func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass

func _process(delta):
	self.position = self.translation

