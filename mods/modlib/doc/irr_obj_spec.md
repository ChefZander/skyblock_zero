# Minetest Wavefront `.obj` file format specification

Minetest Wavefront `.obj` is a subset of [Wavefront `.obj`](http://paulbourke.net/dataformats/obj/).

It is inferred from the [Minetest Irrlicht `.obj` reader](https://github.com/minetest/irrlicht/blob/master/source/Irrlicht/COBJMeshFileLoader.cpp).

`.mtl` files are not supported since Minetest's media loading process ignores them due to the extension.

## Lines / "Commands"

Irrlicht only looks at the first characters needed to tell commands apart (imagine a prefix tree of commands).

Superfluous parameters are ignored.

Numbers are formatted as either:

* Float: An optional minus sign (`-`), one or more decimal digits, followed by the decimal dot (`.`) then again one or more digits
* Integer: An optional minus sign (`-`) followed by one or more decimal digits

Indexing starts at one. Indices are formatted as integers. Negative indices relative to the end of a buffer are supported.

* Comments: `# ...`; unsupported commands are silently ignored as well
* Groups: `g <name>` or `usemtl <name>`
  * Subsequent faces belong to a new group / material, no matter the supplied names
  * Each group gets their own material (texture); indices are determined by order of appearance
  * Empty groups (groups without faces) are ignored
* Vertices (all numbers): `v <x> <y> <z>`, global to the model
* Texture Coordinates (all numbers): `vt <x> <y>`, global to the model
* Normals (all numbers): `vn <x> <y> <z>`, global to the model
* Faces (all vertex/texcoord/normal indices); always local to the current group:
  * `f <v1> <v2> <v3>`
  * `f <v1>/<t1> <v2>/<t2> ... <vn>/<tn>`
  * `f <v1>//<n1> <v2>/<n2> ... <vn>/<nn>`
  * `f <v1>/<t1>/<n1> <v2>/<t2>/<n2> ... <vn>/<tn>/<nn>`

## Coordinate system orientation ("handedness")

Vertex & normal X-coordinates are inverted ($x' = -x$);
texture Y-coordinates are inverted as well ($y' = 1 - y$).

## Example

```obj
# A simple 2³ cube centered at the origin; each face receives a separate texture / tile
# no care was taken to ensure "proper" texture orientation
v -1 -1 -1
v -1 -1 1
v -1 1 -1
v -1 1 1
v 1 -1 -1
v 1 -1 1
v 1 1 -1
v 1 1 1
vn -1 0 0
vn 0 -1 0
vn 0 0 -1
vn 1 0 0
vn 0 1 0
vn 0 0 1
vt 0 0
vt 1 0
vt 0 1
vt 1 1
g negative_x
f 1/1/1 3/3/1 2/2/1 4/4/1
g negative_y
f 1/1/2 5/3/2 2/2/2 6/4/2
g negative_z
f 1/1/3 5/3/3 3/2/3 7/4/3
g positive_x
f 5/1/4 7/3/4 2/2/4 8/4/4
g positive_y
f 3/1/5 7/3/5 4/2/5 8/4/5
g positive_z
f 2/1/6 6/3/6 4/2/6 8/4/6
```
