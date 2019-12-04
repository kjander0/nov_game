local TILE_SIZE = 24

local SLOW_TIME_SEC = 0.125

local screen_width = 600
local screen_height = 400
local window_flags = {resizable = true}
love.window.setMode(screen_width, screen_height, window_flags)

local player = {
	width = 23, height = 48,
	pos = {x = 0, y = 0},
	prev_pos = {x = 0, y = 50},
	vel = {x = 0, y = 0},
	accel = {x = 0, y = 0},
	grounded = false,
}

-- 0: empty
-- 1: generic tile
-- 3: spike
-- 8: finish
-- 9: player

local block_table = {{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
					 {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
					 {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 0, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
					 {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 3, 3, 3, 3, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
					 {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
					 {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 3, 3, 3, 3, 3, 3, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
					 {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 0, 0, 0, 1, 1, 1, 1, 1, 0, 1, 0, 1, 0, 1, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
					 {0, 0, 0, 0, 9, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
					 {0, 0, 0, 0, 1, 1, 1, 1, 0, 0, 1, 1, 1, 1, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 8, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
					 {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
					 {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
					 {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
					 {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
					 {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
					 {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
					 {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}}
				 
local input_buffer
local next_input_index
local player_img
local tile_img, forward_img, jump_img, goal_img

local slow_time = 0

local my_input_column = 0

local win

function reset()
	win = false
	input_buffer = find_buffer_tiles()
	next_input_index = 1
	
	-- set player position
	for row_index, row in ipairs(block_table) do
		for column_index in ipairs(row) do
			if get_block(column_index, row_index) == 9 then
				player.pos.x, player.pos.y = index_to_pos(column_index, row_index)
				player.pos.x = player.pos.x + player.width/2
				player.prev_pos.x = player.pos.x
				player.prev_pos.y = player.pos.y
			end
		end
	end
	player.grounded = false
	player.vel.x = 0
	player.vel.y = 0
end

function love.load()
	love.graphics.setBackgroundColor(0.75, 0.75, 0.87)
	
	player_img = love.graphics.newImage("player.png")
	tile_img = love.graphics.newImage("tile.png")
	forward_img = love.graphics.newImage("forward.png")
	jump_img = love.graphics.newImage("jump.png")
	goal_img = love.graphics.newImage("goal.png")
	spike_img = love.graphics.newImage("spike.png")
	
	reset()
end

function absolute(a)
	if a < 0 then
		a = a * -1
	end
	return a
end

-- returned buffer is indexed by column
function find_buffer_tiles()
	local buffer_tiles = {}
	local found_tile = false
	for column_index=1,#block_table[1] do
		for row_index=#block_table, 1, -1 do
			if get_block(column_index, row_index) == 1 then
				found_tile = true
			else
				if found_tile then
					table.insert(buffer_tiles, {column_index = column_index, row_index = row_index, input=nil})
					found_tile = false
					break
				end
			end
		end
	end
	return buffer_tiles
end



function love.resize(width, height)
	screen_width = width
	screen_height = height
end

function get_block(column_index, row_index)
	local row = block_table[row_index]
	if not row then
		return 0
	end
	local val = row[column_index]
	if not val then
		return 0
	end
	return val
end

function pos_to_index(x, y)
	local column_index = math.floor(x/TILE_SIZE) + 1
	local row_index = math.floor(y/TILE_SIZE) + 1
	return column_index, row_index
end

function index_to_pos(column_index, row_index)
	return (column_index-1) * TILE_SIZE, row_index * TILE_SIZE
end

function love.draw()
	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.translate(-player.pos.x + screen_width/2, -player.pos.y + screen_height/2)
	love.graphics.setBlendMode("alpha")
	love.graphics.draw(player_img, player.pos.x - player.width/2, player.pos.y - player.height)
		
	for row_index,row in ipairs(block_table) do
		for column_index, tile_val in pairs(row) do
			if tile_val == 1 then
				love.graphics.draw(tile_img, (column_index -1) * TILE_SIZE, (row_index -1) * TILE_SIZE)
			elseif tile_val == 8 and not win then
				love.graphics.draw(goal_img, (column_index -1) * TILE_SIZE, (row_index -1) * TILE_SIZE)
			elseif tile_val == 3 then
				love.graphics.draw(spike_img, (column_index -1) * TILE_SIZE, (row_index -1) * TILE_SIZE)
			end
		end
	end
	
	
	
	-- love.graphics.setColor(1, 0, 0, 1)
	-- local column_index, row_index = pos_to_index(player.pos.x, player.pos.y - player.height/2)
	-- for row_offset = -1, 1 do
		-- for column_offset = -1, 1 do
			-- local blockx, blocky = index_to_pos(column_index + column_offset, row_index + row_offset)
			--love.graphics.polygon('line',  blockx, blocky, blockx + TILE_SIZE, blocky, blockx +TILE_SIZE, blocky - TILE_SIZE, blockx, blocky - TILE_SIZE)
		-- end
	-- end
	
	love.graphics.setColor(1, 1, 0, 1)
	for _, input in ipairs(input_buffer) do
		if input.input ~= nil then
			local blockx, blocky = index_to_pos(input.column_index, input.row_index)
			if input.input ==  'move' then
				love.graphics.draw(forward_img, blockx, blocky)
			elseif input.input == 'jump' then
				love.graphics.draw(jump_img, blockx, blocky)
			end
		end
	end
	
	love.graphics.origin()
	love.graphics.setColor(0.1, 0.2, 0.1, 1)
	if win then
		love.graphics.print("Win, nice!", screen_width/2, 0, 0, 1.5, 1.5)
	end
	love.graphics.print("right: forward\nup: jump\nr: reset", 10, screen_height-50, 0, 1, 1)
	love.graphics.setColor(1, 1, 1, 1)	
end

function player_block_overlap(column_index, row_index)
	local blockx, blocky = index_to_pos(column_index, row_index)

    if player.pos.y > blocky - TILE_SIZE and player.pos.y - player.height < blocky then
        if player.pos.x + player.width/2 > blockx and player.pos.x - player.width/2 < blockx + TILE_SIZE then
            return true
        end
    end
    return false
end

function get_block_neighbours(column_index, row_index)
    top = get_block(column_index, row_index - 1)
    bottom = get_block(column_index, row_index + 1)
    left = get_block(column_index - 1, row_index)
    right = get_block(column_index + 1, row_index)
    return top, bottom, left, right
end


function love.update(dt)
	if win == true then
		return
	end
	
	if slow_time > 0 then
		slow_time = slow_time - dt
		return
	end
	
	if slow_time < 0 then
		slow_time = 0
	end
	
	-- compute player speed and check for jump inputs
	local player_column_index, player_row_index = pos_to_index(player.pos.x - player.width/2, player.pos.y - player.height/2)
	local last_input
	local input
	local input_count = 0
	repeat
		input = input_buffer[next_input_index - 1 - input_count]
		last_input = input
		if not input or not input.input or player_column_index >= input.column_index then
			break
		end
		input_count = input_count + 1
	until false
	if player.grounded and last_input and last_input.input == 'jump' then
		local last_input_x, last_input_y = index_to_pos(last_input.column_index, last_input.row_index)
		if last_input.column_index == player_column_index and absolute(last_input_y - player.pos.y) < 5 then
			player.vel.y = -200
		end
	end
	
	player.prev_pos.x = player.pos.x
	player.prev_pos.y = player.pos.y


    player.accel.y = 240
	player.vel.x = input_count * 30
	player.vel.y = player.vel.y + player.accel.y * dt

	player.pos.x = player.pos.x + player.vel.x * dt

	player.pos.y = player.pos.y + player.vel.y * dt
	
	if player.pos.y > (#block_table + 5) * TILE_SIZE then
		reset()
	end

	-- handle static block collisions
	player.grounded = false
	local player_column_index, player_row_index = pos_to_index(player.pos.x, player.pos.y - player.height/2)
	for row_offset = -1, 1 do
		for column_offset = -1, 1 do
            local block_column_index = player_column_index + column_offset
            local block_row_index = player_row_index + row_offset
			local block_type = get_block(block_column_index, block_row_index)
			if block_type ~= 0 then
                if player_block_overlap(block_column_index, block_row_index) then
					if block_type == 8 then
						win = true
						return
					elseif block_type == 3 then
						reset()
						return
					end
                    local top, bottom, left, right = get_block_neighbours(block_column_index, block_row_index)
	                local blockx, blocky = index_to_pos(block_column_index, block_row_index)
                    if player.vel.y > 0 and top ~= 1 then
                        if player.prev_pos.y <= blocky - TILE_SIZE then -- if was above previously
                            player.vel.y = 0
                            player.pos.y = blocky - TILE_SIZE
                            player.grounded = true
                        end
                    elseif player.vel.y < 0 and bottom ~= 1 then
                        if player.prev_pos.y - player.height >= blocky then
                            player.vel.y = 0
                            player.pos.y = blocky + player.height
                        end
					end
                    if player.vel.x > 0 and left ~= 1 then
                        if player.prev_pos.x + player.width/2 <= blockx then
                            player.pos.x = blockx - player.width/2
                            player.vel.x = 0
                        end
                    elseif player.vel.x < 0 and right ~= 1 then
                        if player.prev_pos.x - player.width/2 >= blockx + TILE_SIZE then
                            player.pos.x = blockx + TILE_SIZE + player.width/2
                            player.vel.x = 0
                        end
                    end
                end
			end
		end
	end
end

function love.keypressed(key)
	local input_type = nil
    --if key == 'a' or key == 'left' then
    --    input_type = 'undo'
    if key == 'd' or key == 'right' then
        input_type = 'move'
    elseif key == 'w' or key == 'up' then
        input_type = 'jump'
	elseif key == 'r' then
		reset()
		return
    else
		return
	end
	
	local player_index, _ = pos_to_index(player.pos.x, player.pos.y - player.height/2)
	
	local next_input
	repeat
		next_input = input_buffer[next_input_index]
		if not next_input then
			return
		end
		next_input_index = next_input_index + 1
	until next_input.column_index > player_index
	
	next_input.input = input_type
	slow_time = SLOW_TIME_SEC
end				 
