function futil.file_exists(path)
	local f = io.open(path, "r")
	if f then
		io.close(f)
		return true
	else
		return false
	end
end

function futil.load_file(filename)
	local file = io.open(filename, "r")

	if not file then
		return
	end

	local contents = file:read("*a")

	file:close()

	return contents
end

-- minetest.safe_file_write is apparently unreliable on windows
function futil.write_file(filename, contents)
	local file = io.open(filename, "w")

	if not file then
		return false
	end

	file:write(contents)
	file:close()

	return true
end
