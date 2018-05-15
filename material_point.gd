extends Node

var position
var velocity          = Vector3( 0.0, 0.0, 0.0 )
var previous_position = Vector3( 0.0, 0.0, 0.0 )
var gravity           = Vector3( 0.0, 0.0, 0.0 )
var viscosity         = Vector3( 0.0, 0.0, 0.0 )
var zero_tolerance    = 0.00001

var mass      = 1.0
var mu        = 1.0 # 1./mass
var O         = 0.0

var is_static = false
onready var point = $"point"
onready var arrow = $"point/arrow"
onready var arrowhead  = $"point/arrowhead"
onready var grz = $"../../grz"
var up = Vector3(0.0,1.0,0.0)
var right = Vector3(1.0,0.0,0.0)

func _ready():
	# setting velocity
	velocity = Vector3(0, 0, 0)#0.01*Vector3(2*randf()-1.0,randf(),2*randf()-1.0)
	
	# setting positions
	#position = point.translation
	previous_position = position - velocity * get_physics_process_delta_time()
	point.global_translate(position)
	
	# setting color
	var mat = SpatialMaterial.new()
	mat.albedo_color = Color(randf(),randf(),randf())
	mat.set_metallic(0.0)
	mat.set_specular(0.0)
	point.set_surface_material(0,mat)
	arrow.set_surface_material(0,mat)
	arrowhead.set_surface_material(0,mat)

var iter = 0

func _physics_process(delta):
	if !is_static:
		
		var is_Collisin = false
		var force = force(delta)
		
		var faces = grz.mesh.get_faces ()
		for i in range(0, faces.size(), 3):
			var p1 = faces[i]
			var p2 = faces[i+1]
			var p3 = faces[i+2]
			var v1 = p2 - p1
			var v2 = p3 - p1
			var n = v1.cross(v2)
			var alfa = (-1 * n).dot(p1)
			var distans = (n.dot(position) + alfa) / n.length()
			if distans < 0:
				var normal = n.normalized()
				#if ((p2 - p1).cross((position - p1))).dot(n) >= 0 && \
				#	((p1 - p3).cross((position - p3))).dot(n) >= 0 && \
				#	((p3 - p2).cross((position - p2))).dot(n) >= 0 :
				var velocityPro = ((velocity.dot(normal)) / normal.length_squared()) * normal
				velocity -= (1 + 0.6) * velocityPro
				var reactForce = ((force.dot(normal)) / normal.length_squared()) * normal
				force -= reactForce
				is_Collisin = true
						
		if is_Collisin:
			euler(delta, force)
		else:
			verlet(delta)
		
		#var length = (position - sphere.position).length()
		#if (sphere.radius - (length - 0.1)) >= zero_tolerance:
		#	var normal = (position - sphere.position).normalized()
		#	var velocityPro = ((velocity.dot(normal)) / normal.length_squared()) * normal
		#	velocity -= (1 + O) * velocityPro
		#	var force = force(delta)
		#	var reactForce = ((force.dot(normal)) / normal.length_squared()) * normal
		#	force -= reactForce
		#	
		#	euler(delta, force)
		#else:
		#	verlet(delta)
		#	if iter == 100:
		#		iter = 0
		#	else:
		#		iter+=1
		

func _process(delta):
	if !is_static:
		point.translation = position
		arrow.scale = Vector3(0.2,10.0*velocity.length(),0.2)
		arrow.translation = Vector3(0.0,10.0*velocity.length(),0.0)
		arrowhead.translation = Vector3(0.0,20.0*velocity.length(),0.0)
		var axis = up.cross(velocity.normalized())
		var angle = acos(up.dot(velocity.normalized()))
		if axis.length() > 1e-3:
			point.global_rotate(axis.normalized(),angle)
		up = velocity.normalized()

func set_velocity(v):
	velocity          = v
	previous_position = position - velocity * get_physics_process_delta_time()

func set_mass(m):
	mass = m
	mu   = pow( m, -1.0 )

func euler(delta,f=force(delta)):
	velocity += f * mu * delta
	previous_position = position
	position += velocity * delta

func verlet(delta,f=force(delta)):
	var new_position  = 2 * position - previous_position + f * mu * pow( delta , 2.0 )
	previous_position = position
	position          = new_position
	velocity          = ( position - previous_position ) / delta
	
func force(delta):
	#var distance = position - self.sphere.position
	#gravity = Vector3(0,-0.1,0)
	#if distance.length() > 0.02:
	#	gravity = -self.mass*distance*pow(distance.length(),-3)
	#	viscosity = -0.4*self.velocity
	#if distance.length() > 10:
	##		viscosity *= 2
		#else:
		#	gravity *= 10
	return gravity #+ viscosity 

func radius():
	return self.get_physics_process_delta_time()*self.velocity.length() + zero_tolerance
