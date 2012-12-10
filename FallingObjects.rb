require "rubygems"
require "wx"

include Wx

class FallingObjects < Wx::Frame
  def initialize()

    #NOTES:
    #player image is 64x64
    #obstacle image is 48x48

    #create the frame & set min/max size
    super(nil, :title => "Project2", :size => [500, 500])
    self.set_max_size(Wx::Size.new(500, 500))
    self.set_min_size(Wx::Size.new(500, 500))
    show()

    #create the drop down menus and add them to the frame
    menuBar = Wx::MenuBar.new()
    option1 = Wx::Menu.new()
    option1.append(100, "Restart Game", "Restart")
    option1.append(Wx::ID_EXIT, "Exit Game", "Exit")
    option2 = Wx::Menu.new()
    option2.append(Wx::ID_ABOUT, "About Game", "About")
    menuBar.append(option1, "File")
    menuBar.append(option2, "About")
    self.menu_bar = menuBar

    start_game()

    evt_timer(25) { game_loop() }      #event handler for timer
    evt_paint { on_paint_screen() }    #event handler for painting
    evt_key_down {|e| on_press(e) }    #event handler for key presses
    evt_menu(Wx::ID_ABOUT, :on_about)  #event handler for about menu option
    evt_menu(100, :start_game)  #event handler for restart menu option
    evt_menu(Wx::ID_EXIT, :on_exit)    #event handler for exit menu option
  end

  #method that runs the game. Updates positions and checks for collisions
  def game_loop()
    playerX = @player.x()
    playerXmax = playerX + 60
    playerY = @player.y()
    playerYmax = playerY + 60

    #update position of each obstacle, check for collisions, repaint
    @obstacles.each() {
      |item|

      #update position
      item.y += item.speed()

      #check for collision
      if((item.x() >= playerX && item.x() <= playerXmax) || ((item.x() + 45)) >= playerX && ((item.x() + 45) <= playerXmax))
        if((item.y() >= playerY && item.y() <= playerYmax) || ((item.y() + 45)) >= playerY && ((item.y() + 45) <= playerYmax))
          @collision = true
        end
      end

      #remove obstacle if it's offscreen; also increment score
      if(item.y() >= 500)
        @obstacles.delete(item)
        @score += 1
      end
    }

    #create a new obstacle every 9/10 of a second (25 executions of this method)
    @addNewObstacle += 1
    if(@addNewObstacle == 25)
      randomX = rand(0..404)
      randomSpeed = rand(1..3)
      @obstacles.push(ImageObject.new(randomX, -100, "obstacle.png", randomSpeed))
      @addNewObstacle = 0
    end
    on_paint_screen()
  end

  #method for painting to the screen. Double buffered to reduce flickering
  def on_paint_screen()
    paint_buffered do |dc|

      dc.set_text_foreground(Wx::BLUE)
      dc.set_brush(Wx::LIGHT_GREY_BRUSH)

      if(!@collision)
        dc.draw_rectangle(-5, -5, 500, 500)

        dc.draw_bitmap(@player.image(), @player.x(), @player.y(), false)
        @obstacles.each() {
          |item|
          dc.draw_bitmap(item.image(), item.x(), item.y(), false)
        }
        dc.draw_text("Score: #{@score}", 350, 15)
      else
        dc.draw_rectangle(-5, -5, 500, 500)
        dc.draw_text("Game over", 200, 200)
        dc.draw_text("Score: #{@score}", 200, 215)
        @timer.stop
      end
    end
  end

  #method that handles key presses and updates player position accordingly
  def on_press(evt)
    code = evt.get_key_code()

    #adjust player position
    if(code == K_UP && @player.y() > 0)
      @player.y -= @player.speed()
    elsif(code == K_RIGHT)
      @player.x += @player.speed()
    elsif(code == K_DOWN && @player.y() <= 376)
      @player.y += @player.speed()
    elsif code == K_LEFT
      @player.x -= @player.speed()
    end
    
    #move to the opposite side if player starts going off screen
    if(@player.x < 0)
      @player.x = 418
    elsif(@player.x + 76 >= 500)
      @player.x = 0
    end
    
    #repaint the screen
    update()
  end

  #method that is called when the "about" option is selected. Shows game information
  def on_about()
    Wx::about_box( :name       => "Falling obstacle game",
    :version    => '1.0',
    :developers => ['Chad Auld', 'Shahriar Darafsheh', 'Robbie Ginsburg'] )
  end

  #method to reset instance variables to start-of-game state
  def start_game()
    #stop the timer if it already exists (game was restarted mid-game)
    if(@timer != nil)
      @timer.stop
    end

    @timer = Wx::Timer.new(self, 25)
    @timer.start(25)
    @addNewObstacle = 0
    @score = 0
    @collision = false
    @obstacles = Array.new()
    @player = ImageObject.new(200, 378, "face.png", 6)
  end

  #method to close the game (called by the exit menu option)
  def on_exit()
    self.destroy()
  end
end

#OOP: class representing a falling object (obstacle)
class ImageObject
  attr_accessor :x, :y, :image, :speed
  def initialize(xVal, yVal, imageName, speed)
    @x = xVal
    @y = yVal
    @image = Wx::Bitmap.new(Wx::Image.new(imageName))
    @speed = speed
  end
end

class MyApp < Wx::App
  def on_init()
    FallingObjects.new()
  end
end

MyApp.new.main_loop()