# API Documentation

## Quick Links

- [`axis`](#axis)
- [`options`](#options)
- [`shape`](#shape)
- [`vizlib.colors`](#vizlibcolors)
- [`vizlib.default_color`](#vizlibdefault_color)
- [`vizlib.select_color()`](#vizlibselect_color)
- [`vizlib.random_color()`](#vizlibrandom_color)
- [`vizlib.erase_shape(shape)`](#vizliberase_shapeshape)
- [`vizlib.draw_point(pos, options)`](#vizlibdraw_pointpos-options)
- [`vizlib.draw_circle(pos, radius, axis, options)`](#vizlibdraw_circlepos-radius-axis-options)
- [`vizlib.draw_sphere(pos, radius, options)`](#vizlibdraw_spherepos-radius-options)
- [`vizlib.draw_line(pos1, pos2, options)`](#vizlibdraw_linepos1-pos2-options)
- [`vizlib.draw_square(pos, radius, axis, options)`](#vizlibdraw_squarepos-radius-axis-options)
- [`vizlib.draw_cube(pos, radius, options)`](#vizlibdraw_cubepos-radius-options)
- [`vizlib.draw_area(pos1, pos2, options)`](#vizlibdraw_areapos1-pos2-options)


## Data Types

#### **`axis`**

A string consisting of either "x", "y" or "z". Required by certain drawing functions. Must be lower case. 

#### **`options`**

A table of values used to set shape options when passed to a drawing function. All values are optional.

**Values**
- `color` - String. The color of the shape. Defaults to `vizlib.default_color`.
- `infinite` - Boolean. If true, the shape will never expire. By default the shape will expire after 10 seconds.
- `player` - String or player object. If set, only the specified player will see the shape.
- `time` - The time it takes for the shape to expire. This was by skyblock_zero.

#### **`shape`**

A table of values defining a created shape. Returned from all drawing functions.

**Values**
- `name` - String. The player name, if a player was specified upon creation.
- `expiry` - The time this shape will expire, if not infinite. Can be compared to `os.time()`.
- `ids` - Table. The IDs for the particle spawners this shape is made of.


## Colors

#### **`vizlib.colors`**

Provides a list of 24 colors, sorted by hue. Each value is a table containing two values:
- `name` - The name of the color, in lowercase.
- `hex` - The RGB hex code for the color, including the `#` prefix.

#### **`vizlib.default_color`**

The default color for shapes if no color is specified upon creation.

Value is set by the [`vizlib_default_color`](settingtypes.txt) setting.

#### **`vizlib.select_color()`**

Selects a random color from `vizlib.colors`.

**Returns**
- A hex color code, including the `#` prefix.

#### **`vizlib.random_color()`**

Generates a completely random color.

**Returns**
- A hex color code, including the `#` prefix.


## Utility

#### **`vizlib.erase_shape(shape)`**

Removes a shape from the world.

Useful for removing shapes created with `options.infinite = true`.

**Arguments**
- `shape` - The shape to be removed.


## Drawing

#### **`vizlib.draw_point(pos, options)`**

Draws a point (one slightly bigger particle).

**Arguments**
- `pos` - Vector. The position of the point.
- `options` - Table. See [`options`](#options) above.

#### **`vizlib.draw_circle(pos, radius, axis, options)`**

Draws an approximate circle on a particular axis.

**Arguments**
- `pos` - Vector. The position of the center of the circle.
- `radius` - Number. The radius of the circle.
- `axis` - String. See [`axis`](#axis) above. The axis the circle will be positioned perpendicular to.
- `options` - Table. See [`options`](#options) above.

#### **`vizlib.draw_sphere(pos, radius, options)`**

Draws an approximate sphere.

**Arguments**
- `pos` - Vector. The position of the center of the sphere.
- `radius` - Number. The radius of the sphere.
- `options` - Table. See [`options`](#options) above.

#### **`vizlib.draw_line(pos1, pos2, options)`**

Draws a line from `pos1` to `pos2`.

**Arguments**
- `pos1` - Vector. The starting point of the line.
- `pos2` - Vector. The ending point of the line.
- `options` - Table. See [`options`](#options) above.

#### **`vizlib.draw_square(pos, radius, axis, options)`**

Draws a square on a particular axis.

**Arguments**
- `pos` - Vector. The position of the center of the square.
- `radius` - Number. The distance from the center to the edge of the square.
- `axis` - String. See [`axis`](#axis) above. The axis the square will be positioned perpendicular to.
- `options` - Table. See [`options`](#options) above.

#### **`vizlib.draw_cube(pos, radius, options)`**

Draws a cube.

**Arguments**
- `pos` - Vector. The position of the center of the cube.
- `radius` - Number. The distance from the center to the side of the cube.
- `options` - Table. See [`options`](#options) above.

#### **`vizlib.draw_area(pos1, pos2, options)`**

Draws a rectangular cuboid between `pos1` and `pos2`.

**Arguments**
- `pos1` - Vector. The first corner of the area.
- `pos2` - Vector. The second corner of the area.
- `options` - Table. See [`options`](#options) above.
