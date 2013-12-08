-----------------------------------------------------------------------------------------
--
-- level1.lua
--
-----------------------------------------------------------------------------------------

local storyboard = require( "storyboard" )
local scene = storyboard.newScene()
local user
local throwables = {}
local selectedThrowable
--local myText

local beginX
local beginY
local endX
local endY

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

--require( "tilebg" )
--local bg = tileBG("carpet.png", 12, 3)

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

--------------------
--------------------
-- Game Functions --
--------------------
--------------------


------------------------
------------------------
-- Movement Functions --
------------------------
------------------------

local function stopUser()
  user.bodyType = "static"
  user.bodyType = "dynamic"
end

function swipe(event)
  if event.phase == "began" then
    beginX = event.x
    beginY = event.y
  end

  if event.phase == "ended"  then
    endX = event.x
    endY = event.y
    throw()
  end
end

function moveUser:accelerometer(e)
  user.bodyType = "static"
  user.bodyType = "dynamic"
  user.isAwake = true
  user.rotation = 0
  user:applyForce( e.xGravity * 100, -e.yGravity * 100, user.x, user.y )

  if selectedThrowable then
    timer.performWithDelay(100, moveSelectableToUser)
  end
end

function throw()
  if not selectedThrowable then
    return
  end

  local throw = selectedThrowable
  selectedThrowable = nil

  local x = (endX - beginX) / 10
  local y = (endY - beginY) / 10
  throw:applyForce( x, y, throw.x, throw.y )
end

function moveSelectableToUser()
  selectedThrowable.isAwake = true
  selectedThrowable.rotation = 0
  selectedThrowable.x = user.x + 20
  selectedThrowable.y = user.y -20
end

local function onCollision( event )
  if ( event.phase == "began" ) then
    local collision_user
    local collision_desk
    if (event.object1.name == "User") then collision_user = event.object1 end
    if (event.object2.name == "User") then collision_user = event.object2 end
    if (event.object1.name == "Desk") then collision_desk = event.object1 end
    if (event.object2.name == "Desk") then collision_desk = event.object2 end

    if collision_user and collision_desk and (not selectedThrowable) and collision_desk.throwable then
      selectedThrowable = collision_desk.throwable
      collision_desk.throwable = nil
      selectedThrowable:toFront()
      timer.performWithDelay(100, moveSelectableToUser)
    end
  end
end

---------------------
---------------------
-- Setup Functions --
---------------------
---------------------

local function gameListeners(action)
  if(action == 'add') then
    Runtime:addEventListener('accelerometer', moveUser)
    Runtime:addEventListener("touch", swipe)
    Runtime:addEventListener( "collision", onCollision )
  else
  end
end

local function addDesk( x, y, throwable_type )
	local desk = display.newImageRect( "desk.png", 120, 90 )
  desk.name = "Desk"
	desk.x, desk.y = x, y

  left = -60
  right = 55
  top = -45
  bottom = 40

  local material = {density=2, friction=1, bounce=0.1}
  physics.addBody(desk, 'static', material)

  local throwable
  if throwable_type == "paper" then
    throwable = createPaper()
  elseif throwable_type == "rubber" then
    throwable = createRubber()
  elseif throwable_type == "plane" then
    throwable = createPlane()
  elseif throwable_type == "can" then
    throwable = createCan()
  end
  throwable.x = x + 30
  throwable.y = y + 10
  desk.throwable = throwable
end

function createCan()
	local can = display.newImageRect( "can.png", 24, 40)
  can.name = "Can"
  setupThrowable(can)
  return can
end

function createRubber()
	local rubber = display.newImageRect( "rubber.png", 23, 16)
  rubber.name = "Rubber"
  setupThrowable(rubber)
  return rubber
end

function createPlane()
	local plane = display.newImageRect( "plane.png", 32, 26)
  plane.name = "Plane"
  setupThrowable(plane)
  return plane
end

function createPaper()
	local paper = display.newImageRect( "paper.png", 20, 20)
  paper.name = "Paper"
  setupThrowable(paper)
  return paper
end

function setupThrowable(throwable)
  material = {density=0.1, friction=1, bounce=0.1}
  --for k,v in pairs(options) do material[k] = v end

  physics.addBody( throwable, 'dynamic', material)
  throwable.isSensor = true
  throwables[#throwables + 1] = throwable
end

local function addUser( view, x, y )
	user = display.newImageRect( "kid.png", 50, 50)
  user.name = "User"
	user.x = screenW / 2
  user.y = screenH - 20
  physics.addBody( user, 'dynamic', {density=0.1, friction=1, bounce=0.1, radius=18})
end

local function addTeacher( view, x, y )
	teacher = display.newImageRect( "teacher.png", 70, 70)
  teacher.name = "Teacher"
	teacher.x = screenW / 2
  teacher.y = 70
  physics.addBody( teacher, 'dynamic', {density=0.1, friction=1, bounce=0.1, radius=36})
end

local function addRoom()
	local carpet = display.newImageRect( "carpet.png", screenW * 2, screenH * 2)
	carpet.x = 0
  carpet.y = 0

  local tWall = display.newRect(0, 0, screenW * 2, 1)
  local lWall = display.newRect(0, 0, 1, screenH * 2)
  local rWall = display.newRect(screenW, 0, 1, screenH * 2)
  local bWall = display.newRect(0, screenH, screenW * 2, 1)
  physics.addBody(tWall, "static", staticMaterial)
  physics.addBody(lWall, "static", staticMaterial)
  physics.addBody(rWall, "static", staticMaterial)
  physics.addBody(bWall, "static", staticMaterial)

	local whiteboard = display.newImageRect( "whiteboard.png", 300, 10)
	whiteboard.x = screenW / 2
  whiteboard.y = 5
end

-- Called when the scene's view does not exist:
function scene:createScene( event )

  addRoom()
  addDesk( 70, screenH -300, 'plane')
  addDesk( 230, screenH - 300, 'rubber')
  addDesk( 160, screenH - 130, 'can')
  addUser()
  addTeacher()

  gameListeners('add')

  user:applyForce( 5, -100, user.x, user.y )
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
