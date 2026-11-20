extends Node2D
## Godot 4.7: articulated character from transparent painted PNG pieces.
## Skeleton2D / Bone2D provides real transform hierarchy; no mesh skinning yet.

const PIECES := preload("res://scripts/parts.gd")
const CHARACTER_SCALE := 0.95
var skeleton: Skeleton2D
var bones: Dictionary = {}
var bone_pivots: Dictionary = {}
var state: String = "idle"
var attack_progress: float = -1.0
var clock: float = 0.0
var state_label: Label
var character: Node2D

func _ready() -> void:
    _build_background()
    _build_character()
    _build_controls()

func _build_background() -> void:
    var bg := ColorRect.new()
    bg.color = Color("1b211e")
    bg.size = Vector2(1100, 720)
    bg.z_index = -100
    add_child(bg)
    var ground := ColorRect.new()
    ground.color = Color("30352c")
    ground.position = Vector2(0, 637)
    ground.size = Vector2(1100, 83)
    ground.z_index = -99
    add_child(ground)
    var panel := ColorRect.new()
    panel.color = Color("26312b")
    panel.position = Vector2(740, 0)
    panel.size = Vector2(360, 720)
    panel.z_index = -98
    add_child(panel)

func _make_bone(name: String, parent_name: String, pivot: Vector2) -> Bone2D:
    var parent: Node2D = skeleton if parent_name.is_empty() else bones[parent_name]
    var parent_pivot: Vector2 = Vector2.ZERO if parent_name.is_empty() else bone_pivots[parent_name]
    var bone := Bone2D.new()
    bone.name = name
    bone.position = pivot - parent_pivot
    parent.add_child(bone)
    bones[name] = bone
    bone_pivots[name] = pivot
    return bone

func _add_piece(name: String, bone_name: String, z: int, top_left: Vector2, dim: Vector2) -> void:
    var sprite := Sprite2D.new()
    sprite.name = name
    sprite.centered = false
    sprite.texture = load("res://assets/parts/%s.png" % name)
    sprite.position = top_left - bone_pivots[bone_name]
    sprite.scale = dim / sprite.texture.get_size()
    sprite.z_as_relative = false
    sprite.z_index = z
    bones[bone_name].add_child(sprite)

func _build_character() -> void:
    character = Node2D.new()
    character.name = "Druida_Visual"
    character.position = Vector2(50, 12)
    character.scale = Vector2.ONE * CHARACTER_SCALE
    add_child(character)
    skeleton = Skeleton2D.new()
    skeleton.name = "Esqueleto2D"
    character.add_child(skeleton)
    _make_bone("quadril", "", Vector2(270, 352))
    _make_bone("tronco", "quadril", Vector2(270, 258))
    _make_bone("pescoco", "tronco", Vector2(269, 207))
    _make_bone("cabeca", "pescoco", Vector2(270, 149))
    _make_bone("ombro_esq", "tronco", Vector2(201, 253))
    _make_bone("cotovelo_esq", "ombro_esq", Vector2(181, 353))
    _make_bone("ombro_dir", "tronco", Vector2(338, 253))
    _make_bone("cotovelo_dir", "ombro_dir", Vector2(358, 355))
    _make_bone("mao_dir", "cotovelo_dir", Vector2(380, 431))
    _make_bone("coxa_esq", "quadril", Vector2(237, 368))
    _make_bone("joelho_esq", "coxa_esq", Vector2(247, 460))
    _make_bone("pe_esq", "joelho_esq", Vector2(247, 563))
    _make_bone("coxa_dir", "quadril", Vector2(305, 368))
    _make_bone("joelho_dir", "coxa_dir", Vector2(310, 460))
    _make_bone("pe_dir", "joelho_dir", Vector2(310, 563))
    var mapping: Dictionary = {
        "capa_tras":"tronco", "cabelo_tras":"cabeca",
        "canela_esq":"joelho_esq", "pe_esq":"pe_esq", "canela_dir":"joelho_dir", "pe_dir":"pe_dir",
        "coxa_esq":"coxa_esq", "coxa_dir":"coxa_dir", "saia_tras":"quadril", "saia":"quadril",
        "pescoco":"pescoco", "torax":"tronco", "braco_esq":"ombro_esq", "antebraco_esq":"cotovelo_esq",
        "braco_dir":"ombro_dir", "antebraco_dir":"cotovelo_dir", "cabeca":"cabeca",
        "capa_lateral":"tronco", "bolsa":"quadril", "ornamento":"tronco", "cajado":"mao_dir"
    }
    for item in PIECES.LAYOUT:
        var name: String = item[0]
        _add_piece(name, mapping[name], item[3], Vector2(item[1], item[2]), Vector2(item[4], item[5]))

func _build_controls() -> void:
    var heading := Label.new()
    heading.text = "DRUIDA SOMBRIA"
    heading.position = Vector2(763, 45)
    heading.add_theme_font_size_override("font_size", 28)
    add_child(heading)
    var subtitle := Label.new()
    subtitle.text = "Estudo de rig 2D • Godot 4.7"
    subtitle.position = Vector2(763, 83)
    add_child(subtitle)
    var description := Label.new()
    description.text = "Arte pintada separada em camadas.\nSkeleton2D + Bone2D com animação\nprocedural experimental."
    description.position = Vector2(763, 125)
    add_child(description)
    var buttons: Array = [
        ["1  •  Repouso", "idle"], ["2  •  Caminhada", "walk"], ["3  •  Gesto ritual", "ritual"]
    ]
    for i in range(buttons.size()):
        var button := Button.new()
        button.text = buttons[i][0]
        button.position = Vector2(760, 243 + i * 68)
        button.size = Vector2(300, 51)
        button.pressed.connect(_on_mode.bind(buttons[i][1]))
        add_child(button)
    state_label = Label.new()
    state_label.text = "Animação: repouso"
    state_label.position = Vector2(764, 484)
    state_label.add_theme_font_size_override("font_size", 17)
    add_child(state_label)
    var note := Label.new()
    note.text = "Versão de teste. Alguns encaixes\nainda exigem retoque artístico.\nA caminhada é realizada no lugar."
    note.position = Vector2(763, 561)
    add_child(note)

func _on_mode(mode: String) -> void:
    if mode == "ritual":
        attack_progress = 0.0
        state_label.text = "Animação: gesto ritual"
    else:
        state = mode
        state_label.text = "Animação: caminhada" if mode == "walk" else "Animação: repouso"

func _unhandled_key_input(event: InputEvent) -> void:
    if event is InputEventKey and event.pressed and not event.echo:
        if event.keycode == KEY_1:
            _on_mode("idle")
        elif event.keycode == KEY_2:
            _on_mode("walk")
        elif event.keycode == KEY_3 or event.keycode == KEY_SPACE:
            _on_mode("ritual")

func _process(delta: float) -> void:
    clock += delta
    for b in bones.values():
        b.rotation = 0.0
    var breath := sin(clock * 1.8)
    var walk := state == "walk"
    var s := sin(clock * 5.7)
    bones["tronco"].rotation = 0.009 * breath
    bones["cabeca"].rotation = -0.014 * breath
    bones["ombro_esq"].rotation = 0.013 * breath + (0.09 * s if walk else 0.0)
    bones["ombro_dir"].rotation = -0.011 * breath + (-0.07 * s if walk else 0.0)
    bones["cotovelo_esq"].rotation = -0.02 * breath
    bones["cotovelo_dir"].rotation = 0.025 * breath
    bones["coxa_esq"].rotation = 0.12 * s if walk else 0.0
    bones["coxa_dir"].rotation = -0.12 * s if walk else 0.0
    bones["joelho_esq"].rotation = 0.08 * maxf(0.0, -s) if walk else 0.0
    bones["joelho_dir"].rotation = 0.08 * maxf(0.0, s) if walk else 0.0
    bones["pe_esq"].rotation = -0.07 * s if walk else 0.0
    bones["pe_dir"].rotation = 0.07 * s if walk else 0.0
    character.position.y = 12.0 + (3.0 * sin(clock * 11.4) if walk else 1.3 * breath)
    if attack_progress >= 0.0:
        attack_progress += delta / 0.9
        var wave := sin(minf(attack_progress, 1.0) * PI)
        bones["ombro_dir"].rotation = -0.33 * wave
        bones["cotovelo_dir"].rotation = -0.19 * wave
        bones["mao_dir"].rotation = 0.14 * wave
        bones["tronco"].rotation = -0.025 * wave
        if attack_progress >= 1.0:
            attack_progress = -1.0
            state_label.text = "Animação: caminhada" if walk else "Animação: repouso"
