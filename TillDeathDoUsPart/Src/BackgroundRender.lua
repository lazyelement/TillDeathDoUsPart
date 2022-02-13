BackgroundRender = {}
BackgroundRender.__index = BackgroundRender




--One point for ea moving background object
local bg = NewPoint()

function Init()
 screen = Display()
 bg.x = 200
 bg.y = 0
end

function BackgroundRender:Update(timeDelta)
  MovingBackground(bg)
end

function Draw()
  -- Redraw the display
  RedrawDisplay()
  DrawMetaSprite("tree1",bg.x,bg.y,false,false,DrawMode.Sprite)
end

--Horizontal Sprite coordinate Scroller
function MovingBackground(obj,maxRangeY)
  obj.x = obj.x - speed
  if obj.x < 0 - horizontalOffset then 
    obj.x = obj.x + screen.x + horizontalOffset
    obj.y = math.random(0,maxRangeY) --key in the object variance
  end
end