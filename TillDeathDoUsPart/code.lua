--[[
 ## Till Death do Us Part 'code.lua'

 This is the main 'code.lua' file that runs the entire game. It's responsible for 
 loading in all the game code, managing the game's scenes and calculation of physics

 Made in Pixel Vision 8
]]


-- Global Environment Variables --
local mode = {"title","game","end"} --Different Scenes to hold different objects
local currentScreen = "" -- Current scene player will see

-- Calculate the time for animation handling
local frame = 1
local totalFrames = 8 --Variable for total animation frames
local delay = 100 
local time = 100 

local UNIVERSALSPEED = 1
local HORIZONTALOFFSET = 200 --pixel offset to instantiate object off screen
local CAMERASCREEN = NewPoint()

-- Different Attributes of the objects in the game such as x & y position and
-- file name for the sprites
local tree1 = {
  fileName = 'tree1',
  x = 200,
  y = 37,
  randomRange = 200,
}
local tree2 = {
  fileName = 'tree2',
  x = 250,
  y = 40,
  randomRange = 300,
}
local floor1 = {
  fileName = 'flooring',
  x = 0,
  y = -66,
  randomRange = 225
}
local floor2 = {
  fileName = 'flooring',
  x = 200,
  y = -66,
  randomRange = 225
}
local cloud1 = {
  fileName = 'cloud',
  x = 100,
  y = -20,
  randX = 80,
  randS = 2,
}
local cloud2 = {
  fileName = 'cloud',
  x = 200,
  y = -40,
  randX = 10,
  randS = 1.5,
}
local cloud3 = {
  fileName = 'cloud',
  x = 150,
  y = -50,
  randX = 55,
  randS = 2,
}
local graveStone = {
  fileName = 'cemetry',
  x = 0,
  y = 85 ,
  randX = 25,
  randS = 1,
}

-- Highscore tracker
local highscore = 0

-- Storing the objects in a list and a counter
local parallaxGList = {tree1,tree2,floor1,floor2}
local parallaxSList = {cloud1,cloud2,cloud3,graveStone}
local parallaxGNumber = 4

-- Declaring the list for the player and obstacles to instantiate
local player = {}
local obstacles = {}

-- Boolean Variable to check the state of music playing in the scene
local isPlaying = 0

--[[ The 'Init()' function is part of the game's lifecycle and called when the 
game starts. We'll use this function to configure the player initial values, 
declaring the first scene to be played and collection of the display size 
for optimization so we don't run the 'Display()' function every time.
]]--
function Init()
-- Player initial setup
  player = {
    x = 50,
    y = 80,
    ySpeed = 0,
    inAir = false,
    gravSecond = 1.5,
    isFalling = false;
    isSliding =  false;
    isStillSliding = true;
  }

  CAMERASCREEN = Display()
  currentScreen = "title"
end

--[[ The 'Update()' function is part of the game's lifecycle. The engine calls 
'Update()' on every frame before drawing anything to the display. It accepts
one arguement, 'timeDelta', which is the difference in milliseconds since the last
frame.
]]--
function Update(timeDelta)

-- Initial If-Else branch to check for the current scene displaying on the screen
-- to the user. It will only run the code in it's branch. Currently on title Screen
  if currentScreen == mode[1] then
    --Title Scene Code
    highscore = 0
    PlayMusic(0)
    BackgroundColor( 0 )

    -- Checks for the button input for the Up arrow key to continue to the next scene
    -- Play sound and Stop the current song
    if Button( 0, 1 ) then
      currentScreen = mode[2]
      PlaySound(2)
      StopSong()
    end
  -- If-Else branch for the game screen
  elseif currentScreen == mode[2] then
    --Game Scene Code
    PlayMusic(math.random(1,3))
    time = time + timeDelta
      if(time > delay) then
        time = 0 
        frame = frame + 1
        highscore = highscore + 1
        if (frame > totalFrames) then
          frame = 1
          player.isSliding = false
        end
      end

  -- Run all the functions for player input, Player collision detection, Instantiating and Destroying objects
    ButtonPressed()
    PlayerCollider()
    SpawnObstacle()
    DestroyObstacle(false)

  -- For loop to traverse the list of parallax background objects
  -- and run the different functions to calculate the object's position on the screen
    for i = 1, parallaxGNumber do
      ParallaxGround(parallaxGList[i],parallaxGList[i].randomRange)
      ParallaxSky(parallaxSList[i],parallaxSList[i].randX,parallaxSList[i].randS)
    end

    --On player collision, it will lead to the end game screen
    -- Play sound and Stop the current song
    for index, value in ipairs(obstacles) do
      if (CollisionDetection(PlayerCollider(), value)) then
        currentScreen = mode[3]
        StopSong()
      end
    end

  -- If-Else branch for the end screen
  elseif currentScreen == mode[3] then
    --End Scene Code
    time = time + timeDelta
    totalFrames = 12
    if(time > delay) then
      time = 0 
      frame = frame + 1
      if (frame > totalFrames) then 
        frame = 1
      end
    end
    PlayMusic(0)
    -- Checks for the button input for the Up arrow key to restart the game to title screen
    -- Play sound and Stop the current song
    if Button( 0, 1 ) then
      DestroyObstacle(true)
      totalFrames = 8
      currentScreen = mode[1]
    end
  end
end

--[[
The `Draw()` function is part of the game's life cycle. It is called after 
`Update()` and is where all of our draw calls should go.
Text are using the 'DrawText()' function
Sprites are using the 'DrawMetaSprite()' function

We use the Drawmode enum to specify which pixel is in 
the forefront and in the background.
]]--
function Draw()

  ---- We can use the `RedrawDisplay()` method to clear the screen
  RedrawDisplay()

-- If-Else branch for the Title screen
  if currentScreen ==  mode[1] then
    DrawMetaSprite("spikes",5,5 ,false,false,DrawMode.SpriteAbove)
    --Draw Title Scene Code
    DrawMetaSprite("title01",5,10)
    DrawMetaSprite("mainpage",5,-15)
    DrawText( "Up Arrow to jump", 41, 118, DrawMode.SpriteAbove, "medium", 15, -3 )
    DrawText( "Down Arrow to slide", 31, 125, DrawMode.SpriteAbove, "medium", 15, -3 )
  
  -- If-Else branch for the game screen
  elseif currentScreen == mode[2] then
    --Draw Game Scene Code
    Clear()
    -- Check for the different boolean values for the player to decide which
    -- Animation to run.
    if player.inAir or player.isFalling then
      DrawMetaSprite("NewPlayerJump"..frame,player.x,player.y,false,false,DrawMode.UI)
    elseif player.isSliding and not player.isStillSliding then
      for i = 1, 3, 1 do
        DrawMetaSprite("NewPlayerSlide"..i,player.x,player.y,false,false,DrawMode.UI)
      end
    elseif player.isSliding and player.isStillSliding then
      DrawMetaSprite("NewPlayerSlide"..4,player.x,player.y,false,false,DrawMode.UI)
    elseif not player.isSliding and player.isStillSliding then
      for i = 4, 8, 1 do
        DrawMetaSprite("NewPlayerSlide"..i,player.x,player.y,false,false,DrawMode.UI)
      end
      player.isStillSliding = false
    else
      DrawMetaSprite("NewPlayerRun"..frame,player.x,player.y,false,false,DrawMode.UI)
    end
    
    --Drawing of the different parallax object scrolling sprites.
    for i = 1, parallaxGNumber
   do
      DrawMetaSprite( parallaxGList[i].fileName, parallaxGList[i].x, parallaxGList[i].y, false, false, DrawMode.Sprite)
      DrawMetaSprite( parallaxSList[i].fileName, parallaxSList[i].x, parallaxSList[i].y, false, false, DrawMode.SpriteAbove)
    end
  --Drawing of the different obstacles and their animation
    for index, value in ipairs(obstacles) do
      if value[2] == 1 then
        DrawMetaSprite("spike",value[1].x - 2,value[1].y - 7 ,false,false,DrawMode.SpriteAbove)
      else 
        DrawMetaSprite("NewObjectEye"..frame,value[1].x - 13 ,value[1].y - 8,false,false,DrawMode.SpriteAbove)
      end
      value[1].x = value[1].x - 1
    end
    DrawText( "Score: ".. highscore, 5, 5, DrawMode.SpriteAbove, "medium", 15, -3 )

  -- If-Else branch for the End screen 
  elseif currentScreen == mode[3] then
    --Draw End Scene Code
    DrawMetaSprite("Ending"..frame,CAMERASCREEN.x/2,CAMERASCREEN.y/2 - 14)
    DrawMetaSprite("bridge", 0, -75)
    DrawMetaSprite("flooring", 0,-120)
    DrawText("Game Over", 18, 13,DrawMode.SpriteAbove,"large",15,-1)
    DrawText( "Score: ".. highscore, 20, 19, DrawMode.SpriteAbove, "medium", 15, -3 )
    DrawText( "Press esc to exit", 20, 25, DrawMode.SpriteAbove, "small", 15, -3 )
    DrawText( "Up to restart", 20, 30, DrawMode.SpriteAbove, "small", 15, -3 )
  end
end

--[[
A way to instantiate objects and offset them off-screen to create
an Endless background with different speeds to have a sense of movement
]]--
function ParallaxGround(obj,randx)
  obj.x = obj.x - UNIVERSALSPEED
  if obj.x < 0 - HORIZONTALOFFSET then 
    obj.x = obj.x + CAMERASCREEN.x + randx
  end
end

--[[
A way to instantiate objects and offset them off-screen to create
an Endless background with different speeds to have a sense of movement
]]--
function ParallaxSky(obj,randX,randS)
  obj.x = obj.x - randS
  if obj.x < 0 - HORIZONTALOFFSET then 
    obj.x = obj.x + CAMERASCREEN.x + HORIZONTALOFFSET + randX
  end
end

--[[
Function to check the different button inputs for the player
to control the movement of the player sprite in game. 
]]--
function ButtonPressed()
  if (Button(Buttons.Up, InputState.Down) and player.y >= 80 and not player.inAir) then -- Are we on the ground?
    player.ySpeed = -45 -- Make us add a negative, to move up
    player.inAir = true
    PlaySound(0)
  end

  PlayerJumping()

  if(Button(Buttons.Down, InputState.Down) and not player.isSliding and not player.inAir and not player.isFalling) then -- Are we on the ground?
    player.isSliding = true
  elseif Button(Buttons.Down, InputState.Down) and player.isSliding then
    player.isStillSliding = true
  elseif Button(Buttons.Down, InputState.Released) and (player.isSliding or player.isStillSliding) then
    player.isSliding = false
  end
end

--[[
Different conditions to check for the player position on the screen and have 
booleans value for the different checks in the code.
]]--
function PlayerJumping()
  if (player.inAir and player.ySpeed < 0) then
    player.y = player.y - player.gravSecond
    player.ySpeed = player.ySpeed + player.gravSecond
  elseif (player.inAir and player.ySpeed == 0) then
    player.ySpeed = 45
    player.isFalling = true
    player.inAir = false
  end

  if (player.isFalling and player.ySpeed > 0) then
    player.y = player.y + player.gravSecond
    player.ySpeed = player.ySpeed - player.gravSecond
  elseif (player.isFalling and player.ySpeed == 0) then
    player.isFalling = false
  end
end

--[[
Creates the player collider using the 'NewRect()' function. Will draw a rect behind the scenes
to use for the collision detection.
]]--
function PlayerCollider()
  local originalHitbox = NewRect( player.x + 11, player.y + 9, 11 , 16)
  if (player.isSliding) then
    originalHitbox = NewRect( player.x + 11, player.y + 13, 11 , 8)
  end
  return originalHitbox
end

--[[
Checks the collision between two objects and returns a bool value.
Check by comparing the coordinate value of both objects and their size.
]]--
function CollisionDetection(obj1,obj2)
  if obj1.x+obj1.Width > obj2[1].x and obj1.x < obj2[1].x + obj2[1].Width and obj1.y + obj1.Height > obj2[1].y and obj1.y < obj2[1].y + obj2[1].Height then
    return true
  else
    return false
  end
end

--[[
Spawns objects with a random type to indicate whether it is a ground or flying obstacle.
Adds the obstactes into a table for organization and keeping of attributes such as
coordinate values and type of the obstacles.
]]--
function SpawnObstacle()
  local obstacleType = #obstacles == 0 and 1 or math.random(2)
  local obstacle

  if obstacleType == 1 then -- 1. Spike type obstacle
    obstacle = {NewRect( 0, 0, 5, 7 ), obstacleType}
    obstacle[1].y = 100
  elseif obstacleType == 2 then -- 2. Flying type obstacle
    obstacle = {NewRect( 0, 0, 5, 7 ), obstacleType}
    obstacle[1].y = math.random(65,86)
  end

  if #obstacles == 0 then
    obstacle[1].x = Display().x
    table.insert(obstacles, obstacle)
  elseif #obstacles == 1 then
    obstacle[1].x = math.random(Display().x + 30, Display().x + 70)
    table.insert(obstacles, obstacle)
  end
end

--[[
Removes objects once they have gone off screen.
]]--
function DestroyObstacle(isEnd)
  for index, value in ipairs(obstacles) do
    if (value[1].x < 0) then
      table.remove(obstacles, 1)
    end
  end
  if (isEnd) then
    for i=1, #obstacles do
      obstacles[i] = nil
    end
  end
end

--[[
Music Check to play a song in the Music Chip if there isn't anything playing now
]]--
function PlayMusic(id)
  isPlaying = SongData().playing
  if isPlaying == 0 then
    PlaySong( id, false)
  end
end