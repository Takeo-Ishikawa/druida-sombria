extends Node2D
## Protótipo Web Godot 4.7: quadros pintados com animação de caminhada e gesto.
## Preserva pose neutra independente; frames em assets/frames/walk e ritual.

const WINDOW := Vector2(1100.0, 720.0)
const FRAME_COUNT := 8
const POSE_PATH := "res://assets/pose/druida_pose_neutra.png"
const WALK_PATH := "res://assets/frames/walk/%02d.png"
const RITUAL_PATH := "res://assets/frames/ritual/%02d.png"

var neutral: Sprite2D
var animated: AnimatedSprite2D
var status: Label
var action := "idle"
var previous := "idle"
var clock := 0.0
var gesture_remaining := 0.0
var frames_available := false

func _ready() -> void:
    _stage()
    _pose()
    _animations()
    _controls()
    _set_mode("idle")

func _stage() -> void:
    var backdrop := ColorRect.new()
    backdrop.color = Color("1d2622")
    backdrop.size = WINDOW
    backdrop.z_index = -20
    add_child(backdrop)
    var ground := ColorRect.new()
    ground.position = Vector2(0, 633)
    ground.size = Vector2(1100, 87)
    ground.color = Color("30382e")
    ground.z_index = -10
    add_child(ground)
    var side := ColorRect.new()
    side.position = Vector2(740, 0)
    side.size = Vector2(360, 720)
    side.color = Color("27332d")
    side.z_index = -9
    add_child(side)

func _pose() -> void:
    neutral = Sprite2D.new()
    neutral.name = "PoseNeutra"
    neutral.centered = false
    neutral.position = Vector2(155, 42)
    neutral.scale = Vector2.ONE * 0.47
    if ResourceLoader.exists(POSE_PATH):
        neutral.texture = load(POSE_PATH)
    else:
        # O repositório ainda pode não ter recebido o PNG da pose corrigida.
        var old := AtlasTexture.new()
        old.atlas = load("res://reference/ficha_original.png")
        old.region = Rect2(1035, 61, 414, 367)
        neutral.texture = old
        neutral.scale = Vector2(1.10, 1.55)
        neutral.position = Vector2(135, 91)
    add_child(neutral)

func _animations() -> void:
    animated = AnimatedSprite2D.new()
    animated.name = "AnimacoesPintadas"
    animated.centered = false
    animated.position = Vector2(155, 30)
    animated.scale = Vector2(1.65, 1.56)
    var library := SpriteFrames.new()
    library.add_animation("walk")
    library.set_animation_speed("walk", 9.0)
    library.set_animation_loop("walk", true)
    library.add_animation("ritual")
    library.set_animation_speed("ritual", 8.0)
    library.set_animation_loop("ritual", false)
    frames_available = true
    for i in range(FRAME_COUNT):
        var walk_file := WALK_PATH % i
        var ritual_file := RITUAL_PATH % i
        if not ResourceLoader.exists(walk_file) or not ResourceLoader.exists(ritual_file):
            frames_available = false
            break
        library.add_frame("walk", load(walk_file))
        library.add_frame("ritual", load(ritual_file))
    animated.sprite_frames = library
    animated.animation_finished.connect(_on_animation_finished)
    add_child(animated)

func _controls() -> void:
    var title := Label.new()
    title.text = "DRUIDA SOMBRIA"
    title.position = Vector2(766, 42)
    title.add_theme_font_size_override("font_size", 27)
    add_child(title)
    var subtitle := Label.new()
    subtitle.text = "Godot 4.7 · Estudo de animações pintadas"
    subtitle.position = Vector2(765, 85)
    add_child(subtitle)
    var desc := Label.new()
    desc.text = "Pose neutra, caminhada cíclica e\ngesto ritual de oito quadros.\nTeclas 1, 2, 3 ou Espaço."
    desc.position = Vector2(765, 132)
    add_child(desc)
    var options := [["1 · Pose neutra", "idle"], ["2 · Caminhar", "walk"], ["3 · Gesto ritual", "ritual"]]
    for i in range(options.size()):
        var btn := Button.new()
        btn.text = options[i][0]
        btn.position = Vector2(762, 250 + i * 66)
        btn.size = Vector2(305, 50)
        btn.pressed.connect(_set_mode.bind(options[i][1]))
        add_child(btn)
    status = Label.new()
    status.position = Vector2(765, 491)
    status.add_theme_font_size_override("font_size", 17)
    add_child(status)
    var note := Label.new()
    note.position = Vector2(765, 548)
    note.text = "Estudo 2D quadro a quadro.\nA pose neutra usa arte independente.\nAinda não é rig por ossos."
    add_child(note)

func _set_mode(mode: String) -> void:
    if mode == "ritual":
        if not frames_available:
            status.text = "Envie os 16 PNGs para habilitar as animações"
            return
        previous = action if action != "ritual" else previous
        action = "ritual"
        neutral.visible = false
        animated.visible = true
        animated.play("ritual")
        status.text = "Gesto ritual"
        return
    action = mode
    if mode == "walk" and frames_available:
        neutral.visible = false
        animated.visible = true
        animated.play("walk")
        status.text = "Caminhada · 9 quadros/s"
    else:
        animated.stop()
        animated.visible = false
        neutral.visible = true
        status.text = "Pose neutra" if mode == "idle" else "Faltam sprites: assets/frames/"

func _on_animation_finished() -> void:
    if animated.animation == "ritual":
        _set_mode(previous)

func _unhandled_key_input(event: InputEvent) -> void:
    if event is InputEventKey and event.pressed and not event.echo:
        if event.keycode == KEY_1:
            _set_mode("idle")
        elif event.keycode == KEY_2:
            _set_mode("walk")
        elif event.keycode == KEY_3 or event.keycode == KEY_SPACE:
            _set_mode("ritual")

func _process(delta: float) -> void:
    clock += delta
    if action == "idle":
        # Movimento mínimo: evita a rigidez sem deformar a ilustração inteira.
        neutral.position.y = 42.0 + sin(clock * 1.7) * 1.1
