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

    # Place food
    @food = self.place_food

    # Add score text
    @score_text = Text.new("Score: 0", x: padding + 5, y: padding - 20, size: 15, color: 'orange')
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
  # Stop moving if snake hits the border.
  def self.move
    tick = 0
    @speed = 10
    too_low = @min - @part_size
    too_high = @max + 0.5 * @part_size
    @score = 0

    # Update loop
    Ruby2D::Window.update do

      unless @stop
        if tick % @speed == 0
          x = @snake.first.x
          y = @snake.first.y
          # Update cordinates
          x += @x_speed
          y += @y_speed

          # Check if snake will hit itself
          @snake.each{|p| @hit_self = true if p.x == x and p.y == y}

          # Stop if snake hits the border
          if x == too_low or x == too_high or y == too_low or y == too_high or @hit_self
            self.game_over
            @stop = true
            @food.remove
          else
            # Add new part and update colors
            @snake.unshift Square.new(x: x,y: y,size: @part_size, color: 'red')
            @head = @snake.first
            @snake.each {|part| part.color = 'red'}
            @head.color = 'green'
            # Remove the food, lengthen the snake (keep the tail), update score,
            # or just remove the tail.
            if @head.x == @food.x and @head.y == @food.y
              @food.remove
              @food = self.place_food
              @score += 1
              @score_text.text = "Score: #{@score}"
              # Update speed factor
              @speed -= 1 if @score % 5 == 0
            else
              tail = @snake.pop
              tail.remove
            end
            @locked = false
          end
        end

        tick += 1
      end
    end
  end


  # On key press turn the snake:
  # change speed and disabled direction
  def self.turn
    Ruby2D::Window.on :key_down do |event|
      case event.key
      when 'left'
        unless @locked or @left_disabled
          @x_speed = -@part_size; @y_speed = 0;
          @up_disabled = false; @down_disabled = false; @right_disabled = true;
          @locked = true
        end
      when 'right'
        unless @locked or @right_disabled
          @x_speed = @part_size; @y_speed = 0;
          @up_disabled = false; @down_disabled = false; @left_disabled = true;
          @locked = true
        end
      when 'up'
        unless @locked or @up_disabled
          @x_speed = 0; @y_speed = -@part_size;
          @left_disabled = false; @right_disabled = false; @down_disabled = true;
          @locked = true
        end
      when 'down'
        unless @locked or @down_disabled
          @x_speed = 0; @y_speed = @part_size;
          @left_disabled = false; @right_disabled = false; @up_disabled = true;
          @locked = true
        end
      end
    end
  end


  # Called when snake hits the border
  def self.game_over
    sound = Sound.new('Smashing-Yuri_Santana-1233262689.mp3')
    sound.play

    Text.new('Game over!', x: 0.35 * @max, y: 0.5 * @max, size: 40, color: 'red')
    Text.new('Try again?', x: 0.4 * @max, y: 0.6 * @max, size: 30, color: 'orange')

    # Add buttons with text
    yes_box = Rectangle.new(x: 0.415 * @max, y: 0.7 * @max, width: 60, height: 30, color: 'blue')
    Text.new('Yes',x: 0.43 * @max, y: 0.7 * @max, size: 25, color: 'black')
    no_box = Rectangle.new(x: 0.53 * @max, y: 0.7 * @max, width: 60, height: 30, color: 'orange')
    Text.new('No',x: 0.555 * @max, y: 0.7 * @max, size: 25, color: 'black')

    # Color buttons on hover
    Ruby2D::Window.on :mouse_move do |e|
      yes_box.contains?(e.x, e.y) ? yes_box.color = 'green' : yes_box.color = 'blue'
      no_box.contains?(e.x, e.y) ? no_box.color = 'red' : no_box.color = 'orange'
    end

    # On button click reload or close the game
    Ruby2D::Window.on :mouse_down do |e|
      if yes_box.contains?(e.x, e.y)
        Ruby2D::Window.clear
        Snake.init_snake
        @stop = false
        @hit_self = false
        @score = 0
        @speed = 10
      elsif no_box.contains?(e.x, e.y)
        Ruby2D::Window.close
      end
    end
  end


  # Randomly place food. Make sure it's not placed on the snake.
  def self.place_food
    rand_x, rand_y = nil

    if @snake
      loop do
        food_on_snake = false
        rand_x, rand_y = Snake::get_random_cordinates
        @snake.each{|p| food_on_snake = true if p.x == rand_x and p.y == rand_y}
        break if food_on_snake == false
      end
    else
      rand_x, rand_y = Snake::get_random_cordinates
    end

    return Square.new(x: rand_x, y: rand_y, size: @part_size, color: 'blue')
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