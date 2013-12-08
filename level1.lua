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
local teacher
local teacherGlow
local alert
local bubble
local teacherActive
local strikes = 0
local life1
local life2
local life3
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

function removeBubble()
  if not bubble then return end
  bubble:removeSelf()
  bubble = nil
end

function moveSelectableToUser()
  selectedThrowable.isAwake = true
  selectedThrowable.rotation = 0
  selectedThrowable.x = user.x + 20
  selectedThrowable.y = user.y - 20
end

function checkForStrike()
  if teacherActive and selectedThrowable then
    strikes = strikes + 1

    if strikes == 1 then
      bubble = display.newImageRect( "caught_you.png", 300, 100 )
      life1.isVisible = false
    elseif strikes == 2 then
      bubble = display.newImageRect( "caught_you.png", 300, 100 )
      life2.isVisible = false
    elseif strikes == 3 then
      life3.isVisible = false
      bubble = display.newImageRect( "detention.png", 300, 100 )
    end

    bubble.x = 150
    bubble.y = 90
    timer.performWithDelay(3000, removeBubble)

    selectedThrowable:removeSelf()
    selectedThrowable = nil
  end
end

function preactivateTeacher()
  teacherGlow.isVisible = true
  timer.performWithDelay(1000, hideTeacherGlow)
  timer.performWithDelay(1000, activateTeacher)
end

function activateTeacher()
  teacherActive = true
  teacherGlow.isVisible = false
  teacher.rotation = 180
  checkForStrike()
  timer.performWithDelay(2000, deactivateTeacher)
end

function deactivateTeacher()
  teacherActive = false
  teacher.rotation = 0
  time = math.random(1000,5000)
  timer.performWithDelay(time, preactivateTeacher)
end

--function moveAlertToTeacher()
  --alert.isAwake = true
  --alert.isVisible = true
  --alert.rotation = 0
  ----alert.x = teacher.x
  --alert.y = teacher.y
--end

--function removeAlert()
  --if not alert then return end
  --alert:removeSelf()
  --alert = nil
--end

--function flashAlert()
  --if not alert then return end
  --alert.isVisible = not alert.isVisible
  --timer.performWithDelay(100, flashAlert)
--end

local function onCollision( event )
  if ( event.phase == "began" ) then
    local collision_user
    local collision_desk
    local collision_teacher
    local collision_throwable
    if (event.object1.name == "User") then collision_user = event.object1 end
    if (event.object2.name == "User") then collision_user = event.object2 end
    if (event.object1.name == "Desk") then collision_desk = event.object1 end
    if (event.object2.name == "Desk") then collision_desk = event.object2 end
    if (event.object1.name == "Teacher") then collision_teacher = event.object1 end
    if (event.object2.name == "Teacher") then collision_teacher = event.object2 end
    if (event.object1.name == "Throwable") then collision_throwable = event.object1 end
    if (event.object2.name == "Throwable") then collision_throwable = event.object2 end

    if collision_user and collision_desk and (not selectedThrowable) and collision_desk.throwable then
      checkForStrike()
      selectedThrowable = collision_desk.throwable
      collision_desk.throwable = nil
      selectedThrowable:toFront()
      timer.performWithDelay(10, moveSelectableToUser)
    end

    if collision_teacher and collision_throwable and (not collision_throwable.ignoreCollisions) then
      bubble = display.newImageRect( "who_threw_that.png", 300, 100 )
      bubble.x = 150
      bubble.y = 90
      timer.performWithDelay(3000, removeBubble)
      --alert = display.newImageRect( "alert.png", 40, 38 )
      --alert.name = "Alert"
      --alert.isVisible = false
      --timer.performWithDelay(10, moveAlertToTeacher)
      --timer.performWithDelay(10, flashAlert)
      --timer.performWithDelay(1500, removeAlert)
      collision_throwable.isVisible = false
      collision_throwable.ignoreCollisions = true
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
    Runtime:addEventListener("collision", onCollision)
  else
  end
end

local function addDesk( x, y, throwable_type )
	local desk = display.newImageRect( "desk.png", 120, 60 )
  desk.name = "Desk"
	desk.x, desk.y = x, y

  left = -60
  right = 55
  top = -45
  bottom = 40

  local material = {density=2, friction=1, bounce=0.1}
  physics.addBody(desk, 'static', material)

  if not throwable_type then return end

  local throwable
  if throwable_type == "paper" then
    throwable = createPaper()
  elseif throwable_type == "rubber" then
    throwable = createRubber()
  elseif throwable_type == "plane" then
    throwable = createPlane()
  elseif throwable_type == "can" then
    throwable = createCan()
  elseif throwable_type == "pen" then
    throwable = createPen()
  elseif throwable_type == "pencil" then
    throwable = createPen()
  elseif throwable_type == "ruler" then
    throwable = createRuler()
  end
  throwable.x = x
  throwable.y = y + 14
  desk.throwable = throwable
end

function createCan()
	return setupThrowable(display.newImageRect("can.png", 24, 40))
end

function createRubber()
	return setupThrowable(display.newImageRect("rubber.png", 23, 16))
end

function createPlane()
	return setupThrowable(display.newImageRect("plane.png", 32, 26))
end

function createPaper()
	return setupThrowable(display.newImageRect("paper.png", 20, 20))
end

function createPen()
	return setupThrowable(display.newImageRect("pen.png", 32, 12))
end

function createRuler()
	return setupThrowable(display.newImageRect("rule.png", 37, 20))
end

function createPencil()
	return setupThrowable(display.newImageRect("pencil.png", 31, 10))
end


function setupThrowable(throwable)
  material = {density=0.1, friction=1, bounce=0.1}
  physics.addBody( throwable, 'dynamic', material)
  throwable.name = "Throwable"
  throwable.isSensor = true
  throwables[#throwables + 1] = throwable
  return throwable
end

local function addUser( view, x, y )
	user = display.newImageRect( "kid.png", 50, 50)
  user.name = "User"
	user.x = screenW / 2
  user.y = screenH - 20
  physics.addBody( user, 'dynamic', {density=0.1, friction=1, bounce=0.1, radius=18})
end

local function addTeacher( view, x, y )
	teacherGlow = display.newImageRect( "blutac.png", 80, 80)
	teacherGlow.x = screenW / 4
  teacherGlow.y = 70
  teacherGlow.isVisible = false

	teacher = display.newImageRect( "teacher.png", 70, 70)
  teacher.name = "Teacher"
	teacher.x = screenW / 4
  teacher.y = 70
  physics.addBody( teacher, 'dynamic', {density=0.1, friction=1, bounce=0.1, radius=36})
end

local function addRoom()
	local carpet = display.newImageRect( "carpet.png", screenW * 2, screenH * 2)
	carpet.x = 0
  carpet.y = 0

  local tWall = display.newRect(0, -1, screenW * 2, 1)
  local lWall = display.newRect(-1, 0, 1, screenH * 2)
  local rWall = display.newRect(screenW + 1, 0, 1, screenH * 2)
  local bWall = display.newRect(0, screenH + 1, screenW * 2, 1)
  physics.addBody(tWall, "static", staticMaterial)
  physics.addBody(lWall, "static", staticMaterial)
  physics.addBody(rWall, "static", staticMaterial)
  physics.addBody(bWall, "static", staticMaterial)

	local whiteboard = display.newImageRect( "whiteboard.png", 300, 10)
	whiteboard.x = screenW / 2
  whiteboard.y = 5
end

local function addLives()
	local bg = display.newRoundedRect( 285, 465, 100, 40, 5)
  bg:setFillColor(100, 100, 255, 0.3)

	life1 = display.newImageRect( "kid.png", 20, 20)
	life1.x = 255
  life1.y = 462
	life2 = display.newImageRect( "kid.png", 20, 20)
	life2.x = 280
  life2.y = 462
	life3 = display.newImageRect( "kid.png", 20, 20)
	life3.x = 305
  life3.y = 462
end

-- Called when the scene's view does not exist:
function scene:createScene( event )
  addRoom()
  loadLevel(1)
  addUser()
  addTeacher()
  addLives()

  gameListeners('add')

  deactivateTeacher()

  user:applyForce( 0, -100, user.x, user.y )
end

function loadLevel(id)
  if id == 1 then
    addDesk( 70, 200)
    addDesk( 270, 200, 'rubber')
    addDesk( 160, 330, 'paper')
  elseif id == 2 then
    addDesk( 60, 170, 'plane')
    addDesk( 250, 210, 'pen')
    addDesk( 85, 280)
    addDesk( 70, 380, 'pencil')
  elseif id == 3 then
    addDesk( 70, 170, 'ruler')
    addDesk( 270, 170)
    addDesk( 70, 290, 'pencil')
    addDesk( 270, 280, 'paper')
    addDesk( 70, 400)
  elseif id == 4 then
    addDesk( 70, screenH -300, 'plane')
    addDesk( 230, screenH - 300, 'rubber')
    addDesk( 160, screenH - 130, 'can')
  end
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
