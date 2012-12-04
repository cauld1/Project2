require "rubygems"
require "wx"
include Wx


class Drawing < Wx::Frame
  
  def initialize()
    #frame = Wx::Frame.new(nil, -1, "Test Frame")
    super(nil, -1, "Test Frame")
    show
    image = Wx::Image.new('face.png') 
    @myimage = Wx::Bitmap.new(image) 
    @x = 50
    @y = 50 
    
    evt_paint { on_paint }
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
    
    on_paint
   
    print @x 
    print @y
    puts ""
  end
  
  def on_paint
    paint do |dc|
      dc.clear
      dc.draw_bitmap(@myimage, @x, @y, false)
    end
  end
end

class MyApp < Wx::App
  def on_init()
     Drawing.new
  end
end

MyApp.new.main_loop()