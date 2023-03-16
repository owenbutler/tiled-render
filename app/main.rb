
def tick args
  if args.tick_count == 0
    init_state args
    $noise = Noise.new(2000, 4)
  end

  visible_tiles = get_visible_tiles(args, args.state.zoom_level, args.state.x, args.state.y)
  args.outputs.sprites << visible_tiles

  # args.outputs.labels << get_debug_labels(args)
  # args.outputs.debug << args.gtk.framerate_diagnostics_primitives

  num_work = 4
  while num_work > 0 && !$work_queue.empty?
    work_unit = $work_queue.pop()
    process_work work_unit, args
    num_work -= 1
  end

  check_input args
end

def create_tile args, x, y, key
  work_unit = {
    rtkey: key,
    x: x,
    y: y,
    ty: 0,
    tx: 0,
    complete: false,
  }

  rt = args.render_target(work_unit.rtkey)
  rt.clear_before_render = false
  rt.width = 256
  rt.height = 256

  $work_queue << work_unit

  return { x: x, y: y, rtkey: key}
end

def process_work work_unit, args

  SCALE = 0.002
  rt = args.render_target(work_unit.rtkey)
  rt.clear_before_render = false
  rt.width = 256
  rt.height = 256

  num_tiles = 0

  while work_unit.ty < 256
    while work_unit.tx < 256

      noisex = work_unit.x + work_unit.tx
      noisey = work_unit.y + work_unit.ty
      noise_val = $noise.get(noisex * SCALE, noisey * SCALE)

      normalised_noise = ((noise_val + 1) * ($ground_sprites.length / 2)).floor

      tile = $ground_sprites[normalised_noise].clone
      tile.x = work_unit.tx
      tile.y = work_unit.ty

      rt.sprites << tile

      object_chance = rand()
      if object_chance > 0.94
        object_tile = $object_sprites[tile.layer].sample.clone
        object_tile.x = work_unit.tx
        object_tile.y = work_unit.ty
        rt.sprites << object_tile
      end

      work_unit.tx += 16

      num_tiles += 1
    end
    work_unit.ty += 16
    work_unit.tx = 0
  end

  #rt.borders << [0, 0, 256, 256, val, val, val, 255]
  #rt.labels << { x: 128, y: 128, text: key}
  #rt.labels << { x: 128, y: 100, text: val.to_s}

end

$tiles = {}

$work_queue = []

$ground_sprites = [
  {x: 0, y:0, w: 16, h: 16, source_w: 16, source_h: 16, path: "sprites/MiniWorldSprites/Ground/Shore.png", source_x: 80, layer: :water},
  {x: 0, y:0, w: 16, h: 16, source_w: 16, source_h: 16, path: "sprites/MiniWorldSprites/Ground/Shore.png", source_x: 80, layer: :water},
  {x: 0, y:0, w: 16, h: 16, source_w: 16, source_h: 16, path: "sprites/MiniWorldSprites/Ground/Shore.png", source_x: 64, layer: :water},
  {x: 0, y:0, w: 16, h: 16, source_w: 16, source_h: 16, path: "sprites/MiniWorldSprites/Ground/Shore.png", source_x: 64, layer: :water},
  {x: 0, y:0, w: 16, h: 16, source_w: 16, source_h: 16, path: "sprites/MiniWorldSprites/Ground/Shore.png", source_x: 48, layer: :water},
  {x: 0, y:0, w: 16, h: 16, source_w: 16, source_h: 16, path: "sprites/MiniWorldSprites/Ground/Shore.png", source_x: 32, layer: :water},
  {x: 0, y:0, w: 16, h: 16, source_w: 16, source_h: 16, path: "sprites/MiniWorldSprites/Ground/Shore.png", source_x: 16, layer: :water},
  {x: 0, y:0, w: 16, h: 16, source_w: 16, source_h: 16, path: "sprites/MiniWorldSprites/Ground/Shore.png", source_x: 0, layer: :shore},
  {x: 0, y:0, w: 16, h: 16, source_w: 16, source_h: 16, path: "sprites/MiniWorldSprites/Ground/Shore.png", source_x: 0, layer: :shore},
  {x: 0, y:0, w: 16, h: 16, source_w: 16, source_h: 16, path: "sprites/MiniWorldSprites/Ground/Shore.png", source_x: 0, layer: :shore},
  {x: 0, y:0, w: 16, h: 16, source_w: 16, source_h: 16, path: "sprites/MiniWorldSprites/Ground/TexturedGrass.png", source_x: 0, layer: :grass},
  {x: 0, y:0, w: 16, h: 16, source_w: 16, source_h: 16, path: "sprites/MiniWorldSprites/Ground/TexturedGrass.png", source_x: 16, layer: :grass},
  {x: 0, y:0, w: 16, h: 16, source_w: 16, source_h: 16, path: "sprites/MiniWorldSprites/Ground/TexturedGrass.png", source_x: 32, layer: :grass},
  {x: 0, y:0, w: 16, h: 16, source_w: 16, source_h: 16, path: "sprites/MiniWorldSprites/Ground/TexturedGrass.png", source_x: 0, source_y: 16, layer: :grass},
  {x: 0, y:0, w: 16, h: 16, source_w: 16, source_h: 16, path: "sprites/MiniWorldSprites/Ground/TexturedGrass.png", source_x: 16, source_y: 16, layer: :grass},
  {x: 0, y:0, w: 16, h: 16, source_w: 16, source_h: 16, path: "sprites/MiniWorldSprites/Ground/TexturedGrass.png", source_x: 32, source_y: 16, layer: :grass},
  {x: 0, y:0, w: 16, h: 16, source_w: 16, source_h: 16, path: "sprites/MiniWorldSprites/Ground/DeadGrass.png", source_x: 0, layer: :deadgrass},
  {x: 0, y:0, w: 16, h: 16, source_w: 16, source_h: 16, path: "sprites/MiniWorldSprites/Ground/DeadGrass.png", source_x: 16, layer: :deadgrass},
  {x: 0, y:0, w: 16, h: 16, source_w: 16, source_h: 16, path: "sprites/MiniWorldSprites/Ground/DeadGrass.png", source_x: 32, layer: :deadgrass},
  {x: 0, y:0, w: 16, h: 16, source_w: 16, source_h: 16, path: "sprites/MiniWorldSprites/Ground/DeadGrass.png", source_x: 0, source_y: 16, layer: :deadgrass},
  {x: 0, y:0, w: 16, h: 16, source_w: 16, source_h: 16, path: "sprites/MiniWorldSprites/Ground/DeadGrass.png", source_x: 16, source_y: 16, layer: :deadgrass},
  {x: 0, y:0, w: 16, h: 16, source_w: 16, source_h: 16, path: "sprites/MiniWorldSprites/Ground/DeadGrass.png", source_x: 32, source_y: 16, layer: :deadgrass},
  # {x: 0, y:0, w: 16, h: 16, source_w: 16, source_h: 16, path: "sprites/MiniWorldSprites/Ground/Grass.png", source_x: 16},
  # {x: 0, y:0, w: 16, h: 16, source_w: 16, source_h: 16, path: "sprites/MiniWorldSprites/Ground/Grass.png", source_x: 32},
  # {x: 0, y:0, w: 16, h: 16, source_w: 16, source_h: 16, path: "sprites/MiniWorldSprites/Ground/Grass.png", source_x: 48},
  # {x: 0, y:0, w: 16, h: 16, source_w: 16, source_h: 16, path: "sprites/MiniWorldSprites/Ground/Grass.png", source_x: 64},
  {x: 0, y:0, w: 16, h: 16, source_w: 16, source_h: 16, path: "sprites/MiniWorldSprites/Ground/Winter.png", source_x: 80, layer: :mountain},
  {x: 0, y:0, w: 16, h: 16, source_w: 16, source_h: 16, path: "sprites/MiniWorldSprites/Ground/Winter.png", source_x: 80, layer: :mountain},
  {x: 0, y:0, w: 16, h: 16, source_w: 16, source_h: 16, path: "sprites/MiniWorldSprites/Ground/Winter.png", source_x: 80, layer: :mountain},
  {x: 0, y:0, w: 16, h: 16, source_w: 16, source_h: 16, path: "sprites/MiniWorldSprites/Ground/Winter.png", source_x: 64, layer: :snow},
  {x: 0, y:0, w: 16, h: 16, source_w: 16, source_h: 16, path: "sprites/MiniWorldSprites/Ground/Winter.png", source_x: 64, layer: :snow},
  {x: 0, y:0, w: 16, h: 16, source_w: 16, source_h: 16, path: "sprites/MiniWorldSprites/Ground/Winter.png", source_x: 64, layer: :snow},
  {x: 0, y:0, w: 16, h: 16, source_w: 16, source_h: 16, path: "sprites/MiniWorldSprites/Ground/Winter.png", source_x: 64, layer: :snow},
  {x: 0, y:0, w: 16, h: 16, source_w: 16, source_h: 16, path: "sprites/MiniWorldSprites/Ground/Winter.png", source_x: 64, layer: :snow},
  {x: 0, y:0, w: 16, h: 16, source_w: 16, source_h: 16, path: "sprites/MiniWorldSprites/Ground/Winter.png", source_x: 64, layer: :snow},
  {x: 0, y:0, w: 16, h: 16, source_w: 16, source_h: 16, path: "sprites/MiniWorldSprites/Ground/Winter.png", source_x: 64, layer: :snow},
  {x: 0, y:0, w: 16, h: 16, source_w: 16, source_h: 16, path: "sprites/MiniWorldSprites/Ground/Winter.png", source_x: 64, layer: :snow},
]

$object_sprites = {
  water: [
    {x: 0, y:0, w: 16, h: 16, source_w: 16, source_h: 16, path: "sprites/MiniWorldSprites/Animals/MarineAnimals.png", source_x: 0, source_y: 0},
    {x: 0, y:0, w: 16, h: 16, source_w: 16, source_h: 16, path: "sprites/MiniWorldSprites/Animals/MarineAnimals.png", source_x: 16, source_y: 0},
    {x: 0, y:0, w: 16, h: 16, source_w: 16, source_h: 16, path: "sprites/MiniWorldSprites/Animals/MarineAnimals.png", source_x: 32, source_y: 0},
    {x: 0, y:0, w: 16, h: 16, source_w: 16, source_h: 16, path: "sprites/MiniWorldSprites/Animals/MarineAnimals.png", source_x: 48, source_y: 0},
    {x: 0, y:0, w: 16, h: 16, source_w: 16, source_h: 16, path: "sprites/MiniWorldSprites/Animals/MarineAnimals.png", source_x: 64, source_y: 0},
    {x: 0, y:0, w: 16, h: 16, source_w: 16, source_h: 16, path: "sprites/MiniWorldSprites/Animals/MarineAnimals.png", source_x: 0, source_y: 16},
    {x: 0, y:0, w: 16, h: 16, source_w: 16, source_h: 16, path: "sprites/MiniWorldSprites/Animals/MarineAnimals.png", source_x: 16, source_y: 16},
    {x: 0, y:0, w: 16, h: 16, source_w: 16, source_h: 16, path: "sprites/MiniWorldSprites/Animals/MarineAnimals.png", source_x: 32, source_y: 16},
    {x: 0, y:0, w: 16, h: 16, source_w: 16, source_h: 16, path: "sprites/MiniWorldSprites/Animals/MarineAnimals.png", source_x: 48, source_y: 16},
    {x: 0, y:0, w: 16, h: 16, source_w: 16, source_h: 16, path: "sprites/MiniWorldSprites/Animals/MarineAnimals.png", source_x: 64, source_y: 16},
    {x: 0, y:0, w: 16, h: 16, source_w: 16, source_h: 16, path: "sprites/MiniWorldSprites/Animals/MarineAnimals.png", source_x: 0, source_y: 32},
    {x: 0, y:0, w: 16, h: 16, source_w: 16, source_h: 16, path: "sprites/MiniWorldSprites/Animals/MarineAnimals.png", source_x: 16, source_y: 32},
    {x: 0, y:0, w: 16, h: 16, source_w: 16, source_h: 16, path: "sprites/MiniWorldSprites/Animals/MarineAnimals.png", source_x: 32, source_y: 32},
    {x: 0, y:0, w: 16, h: 16, source_w: 16, source_h: 16, path: "sprites/MiniWorldSprites/Animals/MarineAnimals.png", source_x: 48, source_y: 32},
    {x: 0, y:0, w: 16, h: 16, source_w: 16, source_h: 16, path: "sprites/MiniWorldSprites/Animals/MarineAnimals.png", source_x: 64, source_y: 32},
    {x: 0, y:0, w: 16, h: 16, source_w: 16, source_h: 16, path: "sprites/MiniWorldSprites/Animals/MarineAnimals.png", source_x: 0, source_y: 48},
    {x: 0, y:0, w: 16, h: 16, source_w: 16, source_h: 16, path: "sprites/MiniWorldSprites/Animals/MarineAnimals.png", source_x: 16, source_y: 48},
    {x: 0, y:0, w: 16, h: 16, source_w: 16, source_h: 16, path: "sprites/MiniWorldSprites/Animals/MarineAnimals.png", source_x: 32, source_y: 48},
    {x: 0, y:0, w: 16, h: 16, source_w: 16, source_h: 16, path: "sprites/MiniWorldSprites/Animals/MarineAnimals.png", source_x: 48, source_y: 48},
    {x: 0, y:0, w: 16, h: 16, source_w: 16, source_h: 16, path: "sprites/MiniWorldSprites/Animals/MarineAnimals.png", source_x: 64, source_y: 48},
  ],
  shore: [
    {x: 0, y:0, w: 16, h: 16, source_w: 16, source_h: 16, path: "sprites/MiniWorldSprites/Nature/CoconutTrees.png", source_x: 0},
    {x: 0, y:0, w: 16, h: 16, source_w: 16, source_h: 16, path: "sprites/MiniWorldSprites/Nature/CoconutTrees.png", source_x: 16},
    {x: 0, y:0, w: 16, h: 16, source_w: 16, source_h: 16, path: "sprites/MiniWorldSprites/Nature/CoconutTrees.png", source_x: 32},
    {x: 0, y:0, w: 16, h: 16, source_w: 16, source_h: 16, path: "sprites/MiniWorldSprites/Nature/CoconutTrees.png", source_x: 64},
    {x: 0, y:0, w: 16, h: 16, source_w: 16, source_h: 16, path: "sprites/MiniWorldSprites/Nature/CoconutTrees.png", source_x: 80},
    {x: 0, y:0, w: 16, h: 16, source_w: 16, source_h: 16, path: "sprites/MiniWorldSprites/Nature/CoconutTrees.png", source_x: 96},
  ],
  grass: [
    {x: 0, y:0, w: 16, h: 16, source_w: 16, source_h: 16, path: "sprites/MiniWorldSprites/Nature/Trees.png", source_x: 0},
    {x: 0, y:0, w: 16, h: 16, source_w: 16, source_h: 16, path: "sprites/MiniWorldSprites/Nature/Trees.png", source_x: 16},
    {x: 0, y:0, w: 16, h: 16, source_w: 16, source_h: 16, path: "sprites/MiniWorldSprites/Nature/Trees.png", source_x: 32},
    {x: 0, y:0, w: 16, h: 16, source_w: 16, source_h: 16, path: "sprites/MiniWorldSprites/Nature/Trees.png", source_x: 64},
    {x: 0, y:0, w: 16, h: 16, source_w: 16, source_h: 16, path: "sprites/MiniWorldSprites/Nature/Wheatfield.png", source_x: 0},
    {x: 0, y:0, w: 16, h: 16, source_w: 16, source_h: 16, path: "sprites/MiniWorldSprites/Nature/Wheatfield.png", source_x: 16},
    {x: 0, y:0, w: 16, h: 16, source_w: 16, source_h: 16, path: "sprites/MiniWorldSprites/Nature/Wheatfield.png", source_x: 32},
    {x: 0, y:0, w: 16, h: 16, source_w: 16, source_h: 16, path: "sprites/MiniWorldSprites/Nature/Wheatfield.png", source_x: 64},
  ],
  deadgrass: [
    {x: 0, y:0, w: 16, h: 16, source_w: 16, source_h: 16, path: "sprites/MiniWorldSprites/Nature/DeadTrees.png", source_x: 0},
    {x: 0, y:0, w: 16, h: 16, source_w: 16, source_h: 16, path: "sprites/MiniWorldSprites/Nature/DeadTrees.png", source_x: 16},
    {x: 0, y:0, w: 16, h: 16, source_w: 16, source_h: 16, path: "sprites/MiniWorldSprites/Nature/DeadTrees.png", source_x: 32},
    {x: 0, y:0, w: 16, h: 16, source_w: 16, source_h: 16, path: "sprites/MiniWorldSprites/Nature/DeadTrees.png", source_x: 64},
  ],
  mountain: [
    {x: 0, y:0, w: 16, h: 16, source_w: 16, source_h: 16, path: "sprites/MiniWorldSprites/Nature/Rocks.png", source_x: 0},
    {x: 0, y:0, w: 16, h: 16, source_w: 16, source_h: 16, path: "sprites/MiniWorldSprites/Nature/Rocks.png", source_x: 16},
    {x: 0, y:0, w: 16, h: 16, source_w: 16, source_h: 16, path: "sprites/MiniWorldSprites/Nature/Rocks.png", source_x: 32},
    {x: 0, y:0, w: 16, h: 16, source_w: 16, source_h: 16, path: "sprites/MiniWorldSprites/Nature/Rocks.png", source_x: 0, source_y: 48},
    {x: 0, y:0, w: 16, h: 16, source_w: 16, source_h: 16, path: "sprites/MiniWorldSprites/Nature/Rocks.png", source_x: 16, source_y: 48},
    {x: 0, y:0, w: 16, h: 16, source_w: 16, source_h: 16, path: "sprites/MiniWorldSprites/Nature/Rocks.png", source_x: 32, source_y: 48},
  ],
  snow: [
    {x: 0, y:0, w: 16, h: 16, source_w: 16, source_h: 16, path: "sprites/MiniWorldSprites/Nature/WinterDeadTrees.png", source_x: 32},
    {x: 0, y:0, w: 16, h: 16, source_w: 16, source_h: 16, path: "sprites/MiniWorldSprites/Nature/WinterDeadTrees.png", source_x: 64},
    {x: 0, y:0, w: 16, h: 16, source_w: 16, source_h: 16, path: "sprites/MiniWorldSprites/Nature/WinterTrees.png", source_x: 16},
    {x: 0, y:0, w: 16, h: 16, source_w: 16, source_h: 16, path: "sprites/MiniWorldSprites/Nature/WinterTrees.png", source_x: 32},
    {x: 0, y:0, w: 16, h: 16, source_w: 16, source_h: 16, path: "sprites/MiniWorldSprites/Nature/WinterTrees.png", source_x: 48},
    {x: 0, y:0, w: 16, h: 16, source_w: 16, source_h: 16, path: "sprites/MiniWorldSprites/Nature/PineTrees.png", source_x: 32},
  ],
}

def get_visible_tiles args, zoom, xpos, ypos
  visible_tiles = []

  unzoomed_x_left = xpos - (1280/2)
  unzoomed_y_bottom = ypos - (720/2)

  zoomed_x_left = unzoomed_x_left / zoom
  zoomed_y_bottom = unzoomed_y_bottom / zoom

  y = zoomed_y_bottom.to_i - (zoomed_y_bottom.to_i % 256)
  yupper = zoomed_y_bottom + (720 / zoom) + (256 * zoom)
  while y < yupper

    x = zoomed_x_left.to_i - (zoomed_x_left.to_i % 256)
    xupper = zoomed_x_left + (1280 / zoom) + (256 * zoom)
    while x < xupper
      key = "#{x}_#{y}"
      if $tiles.key?(key)
        tile = $tiles[key]
      else
        tile = create_tile(args, x, y, key)
        $tiles[key] = tile
      end

      visible_tiles << convert_tile_to_screen(tile, zoom, xpos, ypos)

      x += 256
    end

    y += 256
  end

 #  args.outputs.borders << [unzoomed_x_left, unzoomed_y_bottom, 1280, 720, 255, 0, 0]

  return visible_tiles
end

def convert_tile_to_screen tile, zoom, xpos, ypos
  tile_to_screen_x = 1280 / 2 + tile.x * zoom
  tile_to_screen_y = 720 / 2 + tile.y * zoom
  return {
    x: tile_to_screen_x - xpos,
    y: tile_to_screen_y - ypos,
    w: 256 * zoom,
    h: 256 * zoom,
    path: tile.rtkey,
  }
end

def init_state args
  state = args.state

  state.zoom_level = 1
  state.x = 0
  state.y = 0
end

def check_input args
  check_zoom args
  check_movement args
end

def check_zoom args

  mouse = args.inputs.mouse

  scroll_wheel = mouse.wheel
  if scroll_wheel
    sd = scroll_wheel.y
    if sd < 0
      args.state.zoom_level *= 0.90
    else
      args.state.zoom_level *= 1.1
    end
  end
end

def check_movement args
  move_speed = 10.0 / args.state.zoom_level / args.state.zoom_level
  move_speed = move_speed.lesser(10.0)
  inputs = args.inputs
  args.state.x += move_speed if inputs.right
  args.state.x -= move_speed if inputs.left
  args.state.y += move_speed if inputs.up
  args.state.y -= move_speed if inputs.down
end


def get_debug_labels args
  s = args.state
  [
    {
      x: 20,
      y: 20,
      text: "z: #{s.zoom_level}, x: #{s.x}, y: #{s.y}",
    }
  ]
end


class Noise

  SIN = 0.479425538604203
  COS = 0.877582561890372

  # primes and gradients from https://github.com/Auburn/FastNoiseLite/blob/master/JavaScript/FastNoiseLite.js
  PRIME_X = 501125321
  PRIME_Y = 1136930381
  GRADIENTS =
    [
      0.130526192220052, 0.99144486137381, 0.38268343236509, 0.923879532511287, 0.608761429008721, 0.793353340291235, 0.793353340291235, 0.608761429008721,
      0.923879532511287, 0.38268343236509, 0.99144486137381, 0.130526192220051, 0.99144486137381, -0.130526192220051, 0.923879532511287, -0.38268343236509,
      0.793353340291235, -0.60876142900872, 0.608761429008721, -0.793353340291235, 0.38268343236509, -0.923879532511287, 0.130526192220052, -0.99144486137381,
      -0.130526192220052, -0.99144486137381, -0.38268343236509, -0.923879532511287, -0.608761429008721, -0.793353340291235, -0.793353340291235, -0.608761429008721,
      -0.923879532511287, -0.38268343236509, -0.99144486137381, -0.130526192220052, -0.99144486137381, 0.130526192220051, -0.923879532511287, 0.38268343236509,
      -0.793353340291235, 0.608761429008721, -0.608761429008721, 0.793353340291235, -0.38268343236509, 0.923879532511287, -0.130526192220052, 0.99144486137381,
      0.130526192220052, 0.99144486137381, 0.38268343236509, 0.923879532511287, 0.608761429008721, 0.793353340291235, 0.793353340291235, 0.608761429008721,
      0.923879532511287, 0.38268343236509, 0.99144486137381, 0.130526192220051, 0.99144486137381, -0.130526192220051, 0.923879532511287, -0.38268343236509,
      0.793353340291235, -0.60876142900872, 0.608761429008721, -0.793353340291235, 0.38268343236509, -0.923879532511287, 0.130526192220052, -0.99144486137381,
      -0.130526192220052, -0.99144486137381, -0.38268343236509, -0.923879532511287, -0.608761429008721, -0.793353340291235, -0.793353340291235, -0.608761429008721,
      -0.923879532511287, -0.38268343236509, -0.99144486137381, -0.130526192220052, -0.99144486137381, 0.130526192220051, -0.923879532511287, 0.38268343236509,
      -0.793353340291235, 0.608761429008721, -0.608761429008721, 0.793353340291235, -0.38268343236509, 0.923879532511287, -0.130526192220052, 0.99144486137381,
      0.130526192220052, 0.99144486137381, 0.38268343236509, 0.923879532511287, 0.608761429008721, 0.793353340291235, 0.793353340291235, 0.608761429008721,
      0.923879532511287, 0.38268343236509, 0.99144486137381, 0.130526192220051, 0.99144486137381, -0.130526192220051, 0.923879532511287, -0.38268343236509,
      0.793353340291235, -0.60876142900872, 0.608761429008721, -0.793353340291235, 0.38268343236509, -0.923879532511287, 0.130526192220052, -0.99144486137381,
      -0.130526192220052, -0.99144486137381, -0.38268343236509, -0.923879532511287, -0.608761429008721, -0.793353340291235, -0.793353340291235, -0.608761429008721,
      -0.923879532511287, -0.38268343236509, -0.99144486137381, -0.130526192220052, -0.99144486137381, 0.130526192220051, -0.923879532511287, 0.38268343236509,
      -0.793353340291235, 0.608761429008721, -0.608761429008721, 0.793353340291235, -0.38268343236509, 0.923879532511287, -0.130526192220052, 0.99144486137381,
      0.130526192220052, 0.99144486137381, 0.38268343236509, 0.923879532511287, 0.608761429008721, 0.793353340291235, 0.793353340291235, 0.608761429008721,
      0.923879532511287, 0.38268343236509, 0.99144486137381, 0.130526192220051, 0.99144486137381, -0.130526192220051, 0.923879532511287, -0.38268343236509,
      0.793353340291235, -0.60876142900872, 0.608761429008721, -0.793353340291235, 0.38268343236509, -0.923879532511287, 0.130526192220052, -0.99144486137381,
      -0.130526192220052, -0.99144486137381, -0.38268343236509, -0.923879532511287, -0.608761429008721, -0.793353340291235, -0.793353340291235, -0.608761429008721,
      -0.923879532511287, -0.38268343236509, -0.99144486137381, -0.130526192220052, -0.99144486137381, 0.130526192220051, -0.923879532511287, 0.38268343236509,
      -0.793353340291235, 0.608761429008721, -0.608761429008721, 0.793353340291235, -0.38268343236509, 0.923879532511287, -0.130526192220052, 0.99144486137381,
      0.130526192220052, 0.99144486137381, 0.38268343236509, 0.923879532511287, 0.608761429008721, 0.793353340291235, 0.793353340291235, 0.608761429008721,
      0.923879532511287, 0.38268343236509, 0.99144486137381, 0.130526192220051, 0.99144486137381, -0.130526192220051, 0.923879532511287, -0.38268343236509,
      0.793353340291235, -0.60876142900872, 0.608761429008721, -0.793353340291235, 0.38268343236509, -0.923879532511287, 0.130526192220052, -0.99144486137381,
      -0.130526192220052, -0.99144486137381, -0.38268343236509, -0.923879532511287, -0.608761429008721, -0.793353340291235, -0.793353340291235, -0.608761429008721,
      -0.923879532511287, -0.38268343236509, -0.99144486137381, -0.130526192220052, -0.99144486137381, 0.130526192220051, -0.923879532511287, 0.38268343236509,
      -0.793353340291235, 0.608761429008721, -0.608761429008721, 0.793353340291235, -0.38268343236509, 0.923879532511287, -0.130526192220052, 0.99144486137381,
      0.38268343236509, 0.923879532511287, 0.923879532511287, 0.38268343236509, 0.923879532511287, -0.38268343236509, 0.38268343236509, -0.923879532511287,
      -0.38268343236509, -0.923879532511287, -0.923879532511287, -0.38268343236509, -0.923879532511287, 0.38268343236509, -0.38268343236509, 0.923879532511287,
    ]

  def initialize(seed = 1337, octaves = 3)
    @seed = seed
    @octaves = octaves
  end

  def get(pos_x, pos_y) # fbm
    v = 0
    a = 0.5
    i = 0
    while i < @octaves
      v += a * noise(pos_x, pos_y)
      r_x, r_y = rotate(pos_x * 2, pos_y * 2)
      pos_x = r_x + 100
      pos_y = r_y + 100
      a *= 0.5
      i += 1
    end
    v
  end

  def noise(x, y)
    i_x = x.floor
    i_y = y.floor
    f_x = fract(x)
    f_y = fract(y)

    # Four corners in 2D of a tile
    a = gradient(i_x, i_y)
    b = gradient(i_x + 1, i_y)
    c = gradient(i_x, i_y + 1)
    d = gradient(i_x + 1, i_y + 1)

    # Smooth Interpolation
    # Cubic Hermine Curve
    u_x = f_x * f_x * (3 - 2 * f_x)
    u_y = f_y * f_y * (3 - 2 * f_y)

    # Mix 4 corners percentages
    mix(a, b, u_x) + (c - a) * u_y * (1.0 - u_x) + (d - b) * u_x * u_y
  end

  def rotate(x, y)
    [COS * x + SIN * y, -SIN * x + COS * y]
  end

  def gradient(x, y)
    i = (@seed ^ (x * PRIME_X) ^ (y * PRIME_Y)).to_i % 255
    GRADIENTS[i]
  end

  def fract(num)
    num - num.floor
  end

  def mix(x, y, a)
    x * (1 - a) + y * a
  end
end