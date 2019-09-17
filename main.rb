require 'ruby2d'

# Set window dimensions
set width: 600, height: 600


module Snake
  
  # Set instance variables, create canvas
  def self.setup
    # Set sizes
    @part_size = 20 # pixels
    @full_size = 27 # parts
    padding = 1.5 * @part_size
    border_width = 0.5 * @part_size
    border_size = @part_size * @full_size
    canvas_size = @part_size * (@full_size - 1)
    # Set speed
    @x_speed = 0
    @y_speed = 0
    # Set extremums
    @max = border_size + padding - @part_size
    @min = padding + border_width

    # Create border
    Square.new(x: padding, y: padding, size: border_size, color: 'orange')
    # Create canvas
    Square.new(x: @min, y: @min, size: canvas_size, color: 'black')
  end


  # Create the snake and place it on random location
  def self.init_snake

    self.setup

    # Get tail coordinates
    rand_x, rand_y = Snake::get_random_cordinates

    # Get distances between tail and border in each direction
    distances = {
      :left => rand_x - @min, :right => @max - rand_x,
      :up   => rand_y - @min, :down  => @max - rand_y }
    # Find the longest distance name
    max_dist = distances.invert.sort.last[1]

    @snake = Array.new
    # Add tail square
    @snake << Square.new(x: rand_x, y: rand_y, size: @part_size, color: 'red')

    # TODO:
    #   - add two more squares to snake, in direction
    #     of the longest distance
    #   - store snake's head into instance variable
  end


  # Get random x and y inside canvas
  def self.get_random_cordinates
    range = (3..@full_size-1)
    x,y = 2.times.map {rand( range) * @part_size }
  end

end


Snake.init_snake

# Show winow
show