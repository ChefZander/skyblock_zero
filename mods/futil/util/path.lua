function futil.path_concat(...)
	return table.concat({ ... }, DIR_DELIM)
end

function futil.path_split(path)
	return string.split(path, DIR_DELIM, true)
end
