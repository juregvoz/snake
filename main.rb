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
    # Find direction of the longest distance
    direction = distances.invert.sort.last[1]

    @snake = Array.new
    # Add tail square
    @snake << Square.new(x: rand_x, y: rand_y, size: @part_size, color: 'red')

    # Lengthen snake
    self.init_lengthen(rand_x, rand_y, direction)

    @head = @snake.first
    @head.color = 'green'
  end
    

  # Lengthen snake for two parts, based on
  # cordinates and direction
  def self.init_lengthen(x, y, direction)

    2.times do
      case direction
      when :left
        x -= @part_size
        @x_speed = -@part_size
        @right_disbled = true
      when :right
        x += @part_size
        @x_speed = @part_size
        @left_disbled = true
      when :up
        y -= @part_size
        @y_speed = -@part_size
        @down_disbled = true
      when :down
        y += @part_size
        @y_speed = @part_size
        @up_disbled = true
      end

      @snake.unshift Square.new(x: x, y: y, size: @part_size, color: 'red')
    end
  end


  # Move snake based on its speed, by adding and removing parts.
  def self.move
    tick = 0
    speed = 10

    # Update loop
    Ruby2D::Window.update do

      if tick % speed == 0
        x = @snake.first.x
        y = @snake.first.y

        @snake.unshift Square.new(x: x += @x_speed,y: y += @y_speed,size: @part_size, color: 'red')
      
        @snake.each {|part| part.color = 'red'}
        @snake.first.color = 'green'
        tail = @snake.pop
        tail.remove
      end

      tick += 1
    end
  end


  # On key press turn the snake:
  # change speed and disabled direction
  def self.turn
    Ruby2D::Window.on :key_down do |event|
      case event.key
      when 'left'
        unless @left_disabled
          @x_speed = -@part_size; @y_speed = 0;
          @up_disabled = false; @down_disabled = false; @right_disabled = true;
        end
      when 'right'
        unless @right_disabled
          @x_speed = @part_size; @y_speed = 0;
          @up_disabled = false; @down_disabled = false; @left_disabled = true;
        end
      when 'up'
        unless @up_disabled
          @x_speed = 0; @y_speed = -@part_size;
          @left_disabled = false; @right_disabled = false; @down_disabled = true;
        end
      when 'down'
        unless @down_disabled
          @x_speed = 0; @y_speed = @part_size;
          @left_disabled = false; @right_disabled = false; @up_disabled = true;
        end
      end
    end
  end


  # Get random x and y inside canvas
  def self.get_random_cordinates
    range = (3..@full_size-5)
    x,y = 2.times.map {rand( range) * @part_size }
  end

end


Snake.init_snake
Snake.move
Snake.turn

# Show winow
show