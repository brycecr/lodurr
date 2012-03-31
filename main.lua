local edges = {}
local nodes = {}
local objects = {}

function processfile (src)
	for line in string.gmatch (src, "..-[\n$]") do
		table.insert (nodes, #nodes)
		table.insert (edges, {})
		local i = 0
		for char in string.gmatch (line, "(%d)[ \n]") do
			i = i + 1
			if char ~= '0' then
				table.insert(edges[#edges], i) 
			end
		end
	end
end

function love.load ()
	contents = love.filesystem.read (arg[2] or "graph.txt")

	processfile (contents)

	world = love.physics.newWorld (0,0,800,800)
	world:setGravity(0, 0)
	world:setMeter(64)
	world:setCallbacks (add, nil, remove)

	objects.ground = {}
	objects.ground.body = love.physics.newBody (world, 800/2, 775, 0, 0)
	objects.ground.shape = love.physics.newRectangleShape (objects.ground.body, 0,0,800,10,0)
	objects.leftWall = {}
	objects.leftWall.body = love.physics.newBody (world, 0, 0, 0, 0)
	objects.leftWall.shape = love.physics.newRectangleShape (objects.leftWall.body, 0,0,10,2000,0)
	objects.rightWall = {}
	objects.rightWall.body = love.physics.newBody (world, 800, 775, 0, 0)
	objects.rightWall.shape = love.physics.newRectangleShape (objects.rightWall.body, 0,0,10,2000,0)
	objects.topWall = {}
	objects.topWall.body = love.physics.newBody (world, 0, 0, 0, 0)
	objects.topWall.shape = love.physics.newRectangleShape (objects.topWall.body, 0,0,2000,10,0)
	
	objects.mouse = {}
	objects.mouse.body = love.physics.newBody (world, 0, 0, 0, 0)
	objects.mouse.shape = love.physics.newCircleShape (objects.mouse.body, 5)
	objects.mouse.shape:setSensor (true)
	objects.mouse.shape:setData ("mouse")

	local angle = 2 * math.pi / (#nodes)
	for i,v in ipairs(nodes) do
		table.insert(objects, {})
		objects[i].body = love.physics.newBody(world, 
			100 * math.cos (angle*(i-1)) + 800/2, 652/2 + 100 * math.sin (angle*(i-1)), 15, 0)
		objects[i].shape = love.physics.newCircleShape(objects[i].body, 0, 0, 20)
		objects[i].shape:setData (i)
	end

	joints = {}
	for i,v in ipairs (edges) do
		for k,u in ipairs (v) do
			if i ~= u then
				oi = objects[i].body
				ou = objects[u].body
				local joint = love.physics.newDistanceJoint (oi, ou, oi:getX(), oi:getY(), ou:getX(), ou:getY())
				joint:setDamping (.5)
				joint:setFrequency (4)
				table.insert (joints, joint)
			end
		end
	end
		
	love.graphics.setMode (800, 800, false, true, 0)
	love.graphics.setBackgroundColor (255, 255, 255)

	--love.mouse.setGrab (true)
end

function add (a, b, coll)
	if a == "mouse" then
		if b then
			selected = b
			objects[b].shape = love.physics.newCircleShape (objects[b].body, 0, 0, objects[b].shape:getRadius () + 4)
		end	
	end
end
			
function remove (a, b, coll)
	if a == "mouse" then
		if b then
			selected = nil
			objects[b].shape = love.physics.newCircleShape (objects[b].body, 0, 0, objects[b].shape:getRadius () - 4)
		end	
	end
end

function persist (a, b, coll) 
end



function love.update (dt)

	objects.mouse.body:setPosition (love.mouse.getPosition())

	if j then
		j:setTarget (love.mouse:getPosition())
	end
	if love.mouse.isDown ("l") and addMode and floating then
			objects[#objects].body:setPosition (love.mouse.getPosition ())
			floating = false
			table.insert (edges, {})
		--	addMode = false
	elseif love.mouse.isDown ("l") and selected then
		if addMode then
			oi = objects[#objects].body
			ou = objects[selected].body
			local joint = love.physics.newDistanceJoint (oi, ou, oi:getX(), oi:getY(), ou:getX(), ou:getY())
			joint:setDamping (.5)
			joint:setFrequency (4)
			table.insert (joints, joint)
		else
               if j then j:destroy () end
			j = love.physics.newMouseJoint (objects[selected].body, love.mouse:getPosition())
		end
	elseif love.mouse.isDown ("r") then
		if j then j:destroy () end
		j = nil
	end

	if floating then
		objects[#objects].body:setPosition (love.mouse.getPosition ())
	end


	world:update (dt)

	if love.keyboard.isDown("right") then 
   		objects[2].body:applyForce(400, 0)
  	elseif love.keyboard.isDown("left") then 
		objects[2].body:applyForce(-400, 0)
  	elseif love.keyboard.isDown("up") then 
    	objects[2].body:setY(0, -200)
  	elseif love.keyboard.isDown("down") then
  		objects[2].body:applyForce(0, 200)
        elseif love.keyboard.isDown ("q") then
		love.event.push ("q")
	elseif love.keyboard.isDown (" ") then
		world:stop ()
	elseif love.keyboard.isDown ("a") then
		if not addMode then
			floating = true
			addMode = true
			
			local i = #objects + 1
			objects[i] = {}
			objects[i].body = love.physics.newBody(world, 0, 0, 15, 0)
			objects[i].shape = love.physics.newCircleShape(objects[i].body, 0, 0, 20)
			objects[i].shape:setData (i)
		end
	elseif love.keyboard.isDown ("d") then
		addMode = false
		floating = false
  	end

end

function love.draw ()
	--[[
	love.graphics.setColor (155, 160, 14)
	love.graphics.polygon ("fill", objects.ground.shape:getPoints())
	love.graphics.polygon ("fill", objects.leftWall.shape:getPoints())
	love.graphics.polygon ("fill", objects.topWall.shape:getPoints())
	love.graphics.polygon ("fill", objects.rightWall.shape:getPoints())
	--]]

	if addMode then
		love.graphics.setColor (225, 47, 14)
		love.graphics.setLineWidth (20)
		love.graphics.rectangle ("line", 0, 0, 800, 800)
	end
	love.graphics.setColor (0, 0, 0)
	love.graphics.setLineWidth (2)
	for i,v in ipairs (joints) do
		love.graphics.line (v:getAnchors())
	end
	for i,v in ipairs (objects) do
		love.graphics.setColor (225, 47, 14)
		love.graphics.circle ("line", v.body:getX(), v.body:getY(), v.shape:getRadius() + 1, 20)
		love.graphics.setColor (255, 255, 255)
		love.graphics.circle ("fill", v.body:getX(), v.body:getY(), v.shape:getRadius(), 20)
	end
end
