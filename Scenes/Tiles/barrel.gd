extends MeshInstance3D


func _on_area_3d_body_entered(body):
	$"../AudioStreamPlayer".play()
	$"../Planks".emitting = true
	$"../BreakParticle".emitting = true
	$BarrelArea.queue_free()
	visible = false


func _on_planks_finished():
	queue_free()
