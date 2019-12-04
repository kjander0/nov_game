-- ===TODO===
-- order ground blocks by x plane
-- Is the interesting part the fact that you have to watch both the player and the tiles ahead that are going to be effecting him.
	-- Do we want the mechanic to require you to trial by error find a tempo to the key strokes? (sounds fun)
	-- quick super meatboy respawns (checkpoint)
-- Question! does allowing them to undo inputs make it too easy? (yeah, because you can just spam anything to speed up, then add good inputs later)\
-- One long level with checkpoints
-- right/up to add inputs, left or down to remove
-- add inputs to jump longer
-- add/remove inputs when airborn to change trajectory and maneuvre obstacles
-- add/remove to run fast slow to time moving between traps, etc
-- astronaught soace walk theme?
-- render transparent arrows along tiles
-- handle player moving faster than block size
-- RELATED: set MAX deltatime
	
local TILE_SIZE = 24

local SLOW_TIME_SEC = 0.125

local screen_width = 600
local screen_height = 400
local window_flags = {resizable = true}
love.window.setMode(screen_width, screen_height, window_flags)

local player = {
	width = 24, height = 48,
	pos = {x = 0, y = 0},
	prev_pos = {x = 0, y = 50},
	vel = {x = 0, y = 0},
	accel = {x = 0, y = 0},
	grounded = false,
}

-- 0: empty
-- 1: generic tile
-- 2: forced input buffer tile for ambigious cases
-- 9: player

local block_table = {{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
					 {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
					 {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
					 {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
					 {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
					 {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 0, 0, 0, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
					 {0, 0, 0, 0, 9, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
					 {0, 0, 0, 0, 1, 1, 1, 1, 0, 0, 1, 1, 1, 1, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}}
					 
local input_buffer
local next_input_index
local player_img
local tile_img, forward_img, jump_img

local slow_time = 0

local my_input_column = 0

function love.load()
	input_buffer = find_buffer_tiles()
	next_input_index = 1
	player_img = love.graphics.newImage("player.png")
	tile_img = love.graphics.newImage("tile.png")
	forward_img = love.graphics.newImage("forward.png")
	jump_img = love.graphics.newImage("jump.png")

	love.graphics.setBackgroundColor(0.75, 0.75, 0.87)
	
	for row_index, row in ipairs(block_table) do
		for column_index in ipairs(row) do
			if get_block(column_index, row_index) == 9 then
				player.pos.x, player.pos.y = index_to_pos(column_index, row_index)
				player.pos.x = player.pos.x + player.width/2
			end
		end
	end	
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
	love.graphics.translate(-player.pos.x + screen_width/2, -player.pos.y + screen_height/2)
	love.graphics.setBlendMode("alpha")
	love.graphics.draw(player_img, player.pos.x - player.width/2, player.pos.y - player.height)
		
	for row_index,row in ipairs(block_table) do
		for column_index, tile_val in pairs(row) do
			if tile_val == 1 then
				love.graphics.draw(tile_img, (column_index -1) * TILE_SIZE, (row_index -1) * TILE_SIZE)
			end
		end
	end
	
	local anx, any = index_to_pos(my_input_column, 0)
	
	love.graphics.setColor(1, 0, 0, 1)
	local column_index, row_index = pos_to_index(player.pos.x, player.pos.y - player.height/2)
	for row_offset = -1, 1 do
		for column_offset = -1, 1 do
			local blockx, blocky = index_to_pos(column_index + column_offset, row_index + row_offset)
			--love.graphics.polygon('line',  blockx, blocky, blockx + TILE_SIZE, blocky, blockx +TILE_SIZE, blocky - TILE_SIZE, blockx, blocky - TILE_SIZE)
		end
	end
	
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
	if last_input then
		print(last_input.column_index, player_column_index)
	end
	if player.grounded and last_input and last_input.input == 'jump' and last_input.column_index == player_column_index then
		
		player.vel.y = -200
	end
	
	player.prev_pos.x = player.pos.x
	player.prev_pos.y = player.pos.y


    player.accel.y = 240
	--player.vel.x = player.vel.x + player.accel.x * dt
	player.vel.x = input_count * 30
	player.vel.y = player.vel.y + player.accel.y * dt

	player.pos.x = player.pos.x + player.vel.x * dt

	player.pos.y = player.pos.y + player.vel.y * dt

	-- handle static block collisions
	player.grounded = false
	local player_column_index, player_row_index = pos_to_index(player.pos.x, player.pos.y - player.height/2)
	for row_offset = -1, 1 do
		for column_offset = -1, 1 do
            local block_column_index = player_column_index + column_offset
            local block_row_index = player_row_index + row_offset
			if get_block(block_column_index, block_row_index) == 1 then
                if player_block_overlap(block_column_index, block_row_index) then
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

function love.keyreleased(key)
end
					 
