-- Simple 4x4 matrix for 3d transformations (translation, rotation, scale);
-- provides exactly the methods needed to calculate inverse bind matrices (for b3d -> glTF conversion)
local mat4 = {}
local metatable = {__index = mat4}

function mat4.new(rows)
	assert(#rows == 4)
	for i = 1, 4 do
		assert(#rows[i] == 4)
	end
	return setmetatable(rows, metatable)
end

function mat4.identity()
	return mat4.new{
		{1, 0, 0, 0},
		{0, 1, 0, 0},
		{0, 0, 1, 0},
		{0, 0, 0, 1},
	}
end

-- Matrices can't properly represent translation:
-- => work with 4d vectors, assume w = 1.
function mat4.translation(vec)
	assert(#vec == 3)
	local x, y, z = unpack(vec)
	return mat4.new{
		{1, 0, 0, x},
		{0, 1, 0, y},
		{0, 0, 1, z},
		{0, 0, 0, 1},
	}
end

-- See https://en.wikipedia.org/wiki/Quaternions_and_spatial_rotation
function mat4.rotation(unit_quat)
	assert(#unit_quat == 4)
	local x, y, z, w = unpack(unit_quat) -- TODO (?) assert unit quaternion
	return mat4.new{
		{1 - 2*(y^2 + z^2), 2*(x*y - z*w),     2*(x*z + y*w),      0},
		{2*(x*y + z*w),     1 - 2*(x^2 + z^2), 2*(y*z - x*w),      0},
		{2*(x*z - y*w),     2*(y*z + x*w),     1 - 2*(x^2 + y^2),  0},
		{0,                 0,                 0,                  1},
	}
end

function mat4.scale(vec)
	assert(#vec == 3)
	local x, y, z = unpack(vec)
	return mat4.new{
		{x, 0, 0, 0},
		{0, y, 0, 0},
		{0, 0, z, 0},
		{0, 0, 0, 1},
	}
end

-- Apply `self` to a 4d modlib vector `vec`
function mat4:apply(vec)
	assert(#vec == 4)
	local res = {}
	for i = 1, 4 do
		local sum = 0
		for j = 1, 4 do
			sum = sum + self[i][j] * vec[j]
		end
		res[i] = sum
	end
	return vec.new(res)
end

-- Multiplication: First apply other, then self
--> Matrix product `self * other`
function mat4:multiply(other)
	local res = {}
	for i = 1, 4 do
		res[i] = {}
		for j = 1, 4 do
			local sum = 0 -- dot product of row & col vec
			for k = 1, 4 do
				sum = sum + self[i][k] * other[k][j]
			end
			res[i][j] = sum
		end
	end
	return mat4.new(res)
end

-- Composition: First apply self, then other
function mat4:compose(other)
	return other:multiply(self) -- equivalent to `other * self` in terms of matrix multiplication
end

-- Matrix inversion using Gauss-Jordan elimination
do
	-- Fundamental operations
	local function _swap_rows(mat, i, j)
		mat[i], mat[j] = mat[j], mat[i]
	end
	local function _scale_row(mat, factor, row_idx)
		for i = 1, 4 do
			mat[row_idx][i] = factor * mat[row_idx][i]
		end
	end
	local function _add_row_with_factor(mat, factor, src_row_idx, dst_row_idx)
		assert(src_row_idx ~= dst_row_idx)
		for i = 1, 4 do
			mat[dst_row_idx][i] = mat[dst_row_idx][i] + factor * mat[src_row_idx][i]
		end
	end

	local epsilon = 1e-6 -- small threshold; values below this are considered zero
	function mat4:inverse()
		local inv = mat4.identity() -- inverse matrix: all elimination operations will also be applied to this
		local copy = {} -- copy of `self` the Gaussian elimination is being executed on
		for i = 1, 4 do
			copy[i] = {}
			for j = 1, 4 do
				copy[i][j] = self[i][j]
			end
		end

		-- All operations must be mirrored to the inverse matrix
		local function swap_rows(i, j)
			_swap_rows(copy, i, j)
			_swap_rows(inv, i, j)
		end
		local function scale_row(factor, row_idx)
			_scale_row(copy, factor, row_idx)
			_scale_row(inv, factor, row_idx)
		end
		local function add_with_factor(factor, src_row_idx, dst_row_idx)
			_add_row_with_factor(copy, factor, src_row_idx, dst_row_idx)
			_add_row_with_factor(inv, factor, src_row_idx, dst_row_idx)
		end

		-- Elimination phase
		for col_idx = 1, 4 do
			-- Find a pivot row: Choose the row with the largest absolute component
			local max_row_idx = col_idx
			local max_abs_comp = math.abs(copy[max_row_idx][col_idx])
			for row_idx = col_idx, 4 do
				local cand_comp = math.abs(copy[row_idx][col_idx])
				if cand_comp > max_abs_comp then
					max_row_idx, max_abs_comp = row_idx, cand_comp
				end
			end

			-- Assert that there is a row that has this component "nonzero"
			assert(max_abs_comp >= epsilon, "matrix not invertible!")

			swap_rows(col_idx, max_row_idx) -- swap row to correct position
			-- Eliminate the `col_idx`-th component in all rows *below* the pivot row
			local pivot_value = copy[col_idx][col_idx]
			for row_idx = col_idx + 1, 4 do
				local factor = -copy[row_idx][col_idx] / pivot_value
				add_with_factor(factor, col_idx, row_idx)
				assert(math.abs(copy[row_idx][col_idx]) < epsilon) -- should be eliminated now
			end
		end

		-- Resubstitution phase - pretty much the same but in reverse and without swapping
		for col_idx = 4, 1, -1 do
			local pivot_value = copy[col_idx][col_idx]
			-- Eliminate the `col_idx`-th component in all rows *above* the pivot row
			for row_idx = col_idx - 1, 1, -1 do
				local factor = -copy[row_idx][col_idx] / pivot_value
				add_with_factor(factor, col_idx, row_idx)
				assert(math.abs(copy[row_idx][col_idx]) < epsilon) -- should be eliminated now
			end
			scale_row(1/pivot_value, col_idx) -- normalize row
		end

		-- Done: `copy` should now be the identity matrix <=> `inv` is the inverse.
		return inv
	end
end

return mat4
