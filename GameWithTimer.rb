require "rubygems"
require "wx"
include Wx

class DrawingTimerTest < Wx::Frame
  
  def initialize()

    @obstacles = Array.new()
    #frame = Wx::Frame.new(nil, -1, "Test Frame")
    super(nil, :title => "Basic Frame", :size => [400, 300])
    show()
    menuBar = Wx::MenuBar.new()
    option1 = Wx::Menu.new()
    option1.append(Wx::ID_ANY, "Open\tAlt-O", "Open File")
    option1.append(Wx::ID_ANY, "Close\tAlt-C", "Close File")
    menuBar.append(option1, "&File")
    self.menu_bar = menuBar
    
    timer = Wx::Timer.new(self, 500)
    evt_timer(500) { draw_obstacle }
    timer.start(500)
    @addNewObstacle = 0
    
    #set the min and max size -> this will give a constant x value for random number generation
    self.set_max_size(Wx::Size.new(500, 300))
    
    image = Wx::Image.new('face.png') 
    @myimage = Wx::Bitmap.new(image) 
    @x = 50
    @y = 50 
    
    evt_paint { on_paint_player }
    evt_key_down {|e| on_press(e) }
  end
  
  def on_press(evt) 
    code = evt.get_key_code()
    if code == K_UP
      @y -= 3
    elsif code == K_RIGHT
      @x += 3
    elsif code == K_DOWN
      @y += 3
    elsif code == K_LEFT
      @x -= 3
    else 
      print code
      #@myimage = Wx::Bitmap.new(Wx::Image.new('face.jpg')) 
    end
    
    on_paint_player
   
    print @x 
    print @y
    puts ""
  end
  
  def on_paint_player
    paint do |dc|
      dc.clear
      dc.draw_bitmap(@myimage, @x, @y, false) 
    end
  end
  
  def draw_obstacle
    puts "in the timer method"
    @addNewObstacle += 1
    if(@addNewObstacle == 5)
      @addNewObstacle = 0
      @obstacles.push(Obstacle.new(50))
    end    
  end
end

class Obstacle < Wx::Image
  #self =Wx::Image.new('obstacle.png')
   
  
  #constructor for Obstacle
  def initialize(xStartValue)
    @x = xStartValue
    @y = 0
    super("obstacle.png") 
    @obstacleImage = Wx::Bitmap.new(self)
  end
  
  #setter for y value
  def y_value=(value)
    @y = value
  end
    
  #getter for y value
  def y_value
      return @y
  end
  
  #getter for image
  def get_image
      return @obstacleImage
  end
  
  #getter for x value
  def x_value
    return @x
  end  
end

class MyApp < Wx::App
  def on_init()
     DrawingTimerTest.new()
  end
end

MyApp.new.main_loop()