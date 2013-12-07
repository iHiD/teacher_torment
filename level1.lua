-----------------------------------------------------------------------------------------
--
-- level1.lua
--
-----------------------------------------------------------------------------------------

local storyboard = require( "storyboard" )
local scene = storyboard.newScene()
local user
--local myText

local moveUser = {}
staticMaterial = {density=2, friction=1, bounce=0.1}

-- include Corona's "physics" library
local physics = require "physics"
physics.start()
physics.pause()
--physics.setDrawMode( "hybrid" )
physics.setGravity(0, 0)
--physics.setScale(50)

system.setAccelerometerInterval( 100 )

require( "tilebg" )
local bg = tileBG("carpet.png", 60, 48)

--------------------------------------------

-- forward declarations and other locals
local screenW, screenH, halfW = display.contentWidth, display.contentHeight, display.contentWidth*0.5

-----------------------------------------------------------------------------------------
-- BEGINNING OF YOUR IMPLEMENTATION
--
-- NOTE: Code outside of listener functions (below) will only be executed once,
--		 unless storyboard.removeScene() is called.
--
-----------------------------------------------------------------------------------------

local function gameListeners(action)
  if(action == 'add') then
    Runtime:addEventListener('accelerometer', moveUser)
  else
  end
end

local function stopUser()
  user.bodyType = "static"
  user.bodyType = "dynamic"
end

function moveUser:accelerometer(e)
  stopUser()
  --myText.text = e.xGravity
  user.isAwake = true
  user:applyForce( e.xGravity * 100, -e.yGravity * 100, user.x, user.y )
  --timer.performWithDelay(2000, stopUser)
  --physics.setGravity( ( 9.8 * e.xGravity ), ( -9.8 * e.yGravity ) )
end

local function addDesk( x, y )
	local desk = display.newImageRect( "desk.png", 160, 80 )
	desk.x, desk.y = x, y

  left = -43
  right = 77
  top = 0
  bottom = 30

  local shape = {left,top, right,top, right,bottom, left,bottom}
  local material = {density=2, friction=1, bounce=0.1, shape=shape}
  physics.addBody(desk, 'static', material)

	local throwable = display.newImageRect( "paper.png", 20, 20)
	throwable.x = x + 30
  throwable.y = y + 10
  physics.addBody( throwable, 'static', {density=0.1, friction=1, bounce=0.1, radius=36})
end

local function addUser( view, x, y )
	user = display.newImageRect( "kid.png", 50, 50)
	user.x = screenW / 2
  user.y = screenH - 20
  physics.addBody( user, 'dynamic', {density=0.1, friction=1, bounce=0.1, radius=18})
end

local function addTeacher( view, x, y )
	teacher = display.newImageRect( "teacher.png", 100, 70)
	teacher.x = screenW / 2
  teacher.y = 70
  physics.addBody( teacher, 'dynamic', {density=0.1, friction=1, bounce=0.1, radius=36})
end

local function addWalls()
  local tWall = display.newRect(0, 0, screenW * 2, 1)
  local lWall = display.newRect(0, 0, 1, screenH * 2)
  local rWall = display.newRect(screenW, 0, 1, screenH * 2)
  local bWall = display.newRect(0, screenH, screenW * 2, 1)
  physics.addBody(tWall, "static", staticMaterial)
  physics.addBody(lWall, "static", staticMaterial)
  physics.addBody(rWall, "static", staticMaterial)
  physics.addBody(bWall, "static", staticMaterial)
end

-- Called when the scene's view does not exist:
function scene:createScene( event )

  addWalls()
  addDesk( 70, screenH -250)
  addDesk( 230, screenH - 250)
  addDesk( 130, screenH - 130)
  addUser()
  addTeacher()

  --myText = display.newText( "hello", 130, 30, native.systemFontBold, 12 )
  --myText:setFillColor( 1, 0, 0 )

  gameListeners('add')

  --moveUser:accelerometer({xGravity=100, yGravity=100})
  --moveUser:accelerometer({xGravity=100, yGravity=100})
end


-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
	physics.start()
end

-- Called when scene is about to move offscreen:
function scene:exitScene( event )
	physics.stop()
end

-- If scene's view is removed, scene:destroyScene() will be called just prior to:
function scene:destroyScene( event )
	package.loaded[physics] = nil
	physics = nil
end

-----------------------------------------------------------------------------------------
-- END OF YOUR IMPLEMENTATION
-----------------------------------------------------------------------------------------

-- "createScene" event is dispatched if scene's view does not exist
scene:addEventListener( "createScene", scene )

-- "enterScene" event is dispatched whenever scene transition has finished
scene:addEventListener( "enterScene", scene )

-- "exitScene" event is dispatched whenever before next scene's transition begins
scene:addEventListener( "exitScene", scene )

-- "destroyScene" event is dispatched before view is unloaded, which can be
-- automatically unloaded in low memory situations, or explicitly via a call to
-- storyboard.purgeScene() or storyboard.removeScene().
scene:addEventListener( "destroyScene", scene )

-----------------------------------------------------------------------------------------

return scene
