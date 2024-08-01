extends PanelContainer

@onready var property_container = %VBoxContainer

var property
var frames_per_second : String

# Called when the node enters the scene tree for the first time.
func _ready():
	Global.debug = self # Set global reference to self in Global Singleton
	
	visible = false # Hides the debug panel upon loading

func _process(delta):
	if visible: # Gets the framerate when the Debug menu is show
		frames_per_second = "%.2f" % (1.0/delta) # Gets fps every frame
	Global.debug.add_property("FPS", frames_per_second, 0)

func _input(event): # Toggles the debug panel
	if event.is_action_pressed("debug"):
		visible = !visible

func add_property(title : String, value, order): # Can be called to add new debug property
	var target
	target = property_container.find_child(title, true, false) # Try to find label with same name
	if !target: # If there is no current label for node
		target = Label.new() # Creates new label node
		property_container.add_child(target) # Add new node to VBox container as child
		target.name = title # Set name to title
		target.text = target.name + ": " + str(value)
	elif visible: # Only displays info when the Debug is visible
		target.text = title + ": " + str(value)
		property_container.move_child(target, order)
