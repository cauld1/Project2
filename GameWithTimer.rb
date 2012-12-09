require "rubygems"
require "wx"
include Wx

class GameWithTimer < Wx::Frame
  
  def initialize()

    @obstacles = Array.new()
    #frame = Wx::Frame.new(nil, -1, "Test Frame")
    super(nil, :title => "Project2", :size => [500, 500])
    show()
    
    #create the drop down menus and add them to the frame
    menuBar = Wx::MenuBar.new()
    option1 = Wx::Menu.new()
    option1.append(Wx::ID_ANY, "Open\tAlt-O", "Open File")
    option1.append(Wx::ID_ANY, "Close\tAlt-C", "Close File")
    menuBar.append(option1, "File")
    self.menu_bar = menuBar
    
    #create the timer and start it
    timer = Wx::Timer.new(self, 25)
    evt_timer(25) { game_loop }
    timer.start(25)
    @addNewObstacle = 0
    
    #set the minimum and maximum size of the frame (to keep it constant)
    self.set_max_size(Wx::Size.new(500, 500))
    self.set_min_size(Wx::Size.new(500, 500))
    
    @myimage = ImageObject.new(200, 378, "face.png") 
    
    evt_paint { on_paint_screen() }
    evt_key_down {|e| on_press(e) }
  end
  
  def on_press(evt) 
    code = evt.get_key_code()
    
    #adjust the position of the player
    if code == K_UP
      #@myimage.y -= 4
    elsif code == K_RIGHT
      @myimage.x += 4
    elsif code == K_DOWN
      #@myimage.y += 4
    elsif code == K_LEFT
      @myimage.x -= 4
    end
    on_paint_screen()
  end
  
  def on_paint_screen()
    paint do |dc|
      dc.clear
      dc.draw_bitmap(@myimage.image(), @myimage.x(), @myimage.y(), false)
      @obstacles.each() { |item| 
          dc.draw_bitmap(item.image(), item.x(), item.y(), false)
      }
    end
  end
  
  def game_loop()
    
    #only create a new falling obstacle every so often (not every method call)
    @addNewObstacle += 1
    if(@addNewObstacle == 25)
      @addNewObstacle = 0
      
      #create a random x-value for the new image within the screen
      randomX = Random.rand(0..404)
      @obstacles.push(ImageObject.new(randomX, -100, "obstacle.png"))
        
      #loop through each ImageObject and change its position 
      #p @obstacles
    end
    @obstacles.each() { |item| item.y += 2 }
    on_paint_screen()    
  end 
end

class ImageObject
  attr_accessor :x, :y, :image
  
  def initialize(xVal, yVal, imageName)
    @x = xVal
    @y = yVal
    @image = Wx::Bitmap.new(Wx::Image.new(imageName))
  end
end 

class MyApp < Wx::App
  def on_init()
     GameWithTimer.new()
  end
end

MyApp.new.main_loop()


#Notes:
#-add transparency layer to the obstacle image
#-unit collision - end the game if player is hit
#-remove obstacles from the array if they fall off the screen (way off the screen so
#   that the removal isn't visible)
#-drop down menu options - restarting and quitting the game
#-score? - add to score whenever an obstacle is removed from the array