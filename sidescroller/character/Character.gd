#warning-ignore-all:unused_class_variable
extends KinematicBody2D
class_name Character

signal state_changed(new_state)

# state management
var current_state: State = null
var states_stack: Array = []

onready var states_map: Dictionary = {}

# character condition
var is_alive: bool = true
var can_attack: bool = true
var gravity_enable: bool = true

# velocity
var velocity: Vector2 = Vector2()
var look_direction: Vector2 = Vector2(1, 0)

# collision/physics states
var is_grounded: bool = false
var is_on_one_way_platform: bool = false
var is_on_wall: bool = false
var snap_enable: bool = false
var knockback_force: Vector2 = Vector2(0, 0)

# combo
var has_set_next_attack: bool = false


func _initialize_state():
	# state change
	for state_node in $States.get_children():
		states_map[state_node.get_name()] = state_node
		state_node.connect('finished', self, '_change_state')

	# default states
	states_stack.push_front(states_map['Idle'])
	current_state = states_stack[0]
	_change_state('Idle')


# update character state
func _change_state(state_name: String) -> void:
	current_state.exit(self)

	if state_name == 'Previous': # previous state
		states_stack.pop_front()
	elif state_name in ['GettingHit']: # pushdown automaton
		states_stack.push_front(states_map[state_name])
	else:
		var new_state = states_map[state_name]
		states_stack[0] = new_state

	current_state = states_stack[0]

	if current_state.get_name() != 'Previous':
		current_state.enter(self)

	emit_signal('state_changed', current_state.get_name())


# on animation finish 
func _on_animation_finished(anim_name: String) -> void:
	current_state._on_animation_finished(anim_name, self)


func _on_death() -> void:
	queue_free()