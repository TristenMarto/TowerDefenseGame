extends AnimatedSprite2D

func _ready():
	play("Impact")

func _on_ProjectileImpact_animation_finished() -> void:
	queue_free()
