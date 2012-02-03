system.activate( "multitouch" )

local frames =
{
	{ x=0, y=35, w=10, h=460 },
	{ x=310, y=35, w=10, h=460 },
	{ x=200, y=35, w=10, h=460 },
	{ x=0, y=35, w=320, h=10 },
	{ x=0, y=470, w=320, h=10 },
}

local l_beads = {}
local r_beads = {}
local l_abacus_config = {rows=10, cols=5, x=15, o=0, y=50, w=25, h=35, r=12, dx=30, dy=42, x_limit=195}
local r_abacus_config = {rows=10, cols=2, x=215, o=35, y=50, w=25, h=35, r=12, dx=30, dy=42, x_limit=305}

local function push(bead, new_x)
	local dx = new_x - bead.x
	if dx > 0 then
		if bead.right == -1 then
			if new_x > (bead.config.x_limit - bead.config.w / 2) then
				return bead.config.x_limit - bead.config.w / 2
			else
				return new_x
			end
		else
			local push_right = bead.config.dx - (bead.arr[bead.right].x - new_x)
			if push_right > 0 then
				bead.arr[bead.right].x = push(bead.arr[bead.right], bead.arr[bead.right].x + dx) 
				if (bead.arr[bead.right].x - new_x) < bead.config.dx then
					return bead.arr[bead.right].x - bead.config.dx
				else
					return new_x
				end
			else
				return new_x
			end
		end
	else
		if bead.left == -1 then
			if new_x < (bead.config.x + bead.config.w / 2) then
				return bead.config.x + bead.config.w / 2
			else
				return new_x
			end
		else
			local push_left = bead.config.dx - (new_x - bead.arr[bead.left].x)
			if push_left > 0 then
				bead.arr[bead.left].x = push(bead.arr[bead.left], bead.arr[bead.left].x + dx) 
				if (new_x - bead.arr[bead.left].x) < bead.config.dx then
					return bead.config.dx + bead.arr[bead.left].x
				else
					return new_x
				end
			else
				return new_x
			end
		end
		return new_x
	end
end

local function onTouch( event )
	local t = event.target

	local phase = event.phase
	if "began" == phase then
		-- Make target the top-most object
		local parent = t.parent
		parent:insert( t )
		display.getCurrentStage():setFocus( t, event.id )

		-- Spurious events can be sent to the target, e.g. the user presses 
		-- elsewhere on the screen and then moves the finger over the target.
		-- To prevent this, we add this flag. Only when it's true will "move"
		-- events be sent to the target.
		t.isFocus = true

		-- Store initial position
		t.x0 = event.x - t.x
		t.y0 = event.y - t.y
	elseif t.isFocus then
		if "moved" == phase then
			-- Make object move (we subtract t.x0,t.y0 so that moves are
			-- relative to initial grab point, rather than object "snapping").
			t.x = push(t, event.x - t.x0)			
--			t.y = event.y - t.y0
		elseif "ended" == phase or "cancelled" == phase then
			display.getCurrentStage():setFocus( t, nil )
			t.isFocus = false
		end
	end

	-- Important to return true. This tells the system that the event
	-- should not be propagated to listeners of any objects underneath.
	return true
end

for _,item in ipairs( frames ) do
	local frame_color = { red=255, green=255, blue=255 }
	local frame = display.newRect( item.x, item.y, item.w, item.h)
	frame:setFillColor( frame_color.red, frame_color.green, frame_color.blue )
	frame.strokeWidth = 1
	frame:setStrokeColor( frame_color.red, frame_color.green, frame_color.blue, 255 )
end

local function setup_beads(config, beads)
	for row = 1, config.rows do
		for col = 1, config.cols do
			local n = row * config.cols + col
			beads[n] = display.newRoundedRect( config.x + config.o + (col - 1) * config.dx, 
						config.y + (row - 1) * config.dy, 
						config.w, config.h , config.r )
			beads[n]:setFillColor( 255, 255, 255 )
			beads[n]:setStrokeColor( 200, 200, 200, 255 )
			beads[n].strokeWidth = 3
			if col == 1 then
				beads[n].left = -1 
			else
				beads[n].left = n - 1 
			end
			if col == config.cols then
				beads[n].right = -1 
			else
				beads[n].right = n + 1 
			end
			beads[n].n = n
			beads[n].config = config
			beads[n].arr = beads
			-- Make the button instance respond to touch events
			beads[n]:addEventListener( "touch", onTouch )
		end
	end
end

setup_beads(l_abacus_config, l_beads)
setup_beads(r_abacus_config, r_beads)
