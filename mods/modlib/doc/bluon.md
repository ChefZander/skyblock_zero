# Bluon

Binary Lua object notation.

## `new(def)`

```lua
def = {
	aux_is_valid = function(object)
		return is_valid
	end,
	aux_len = function(object)
		return length_in_bytes
	end,
	-- read type byte, stream providing :read(count), map of references -> id
	aux_read = function(type, stream, references)
		... = stream:read(...)
		return object
	end,
	-- object to be written, stream providing :write(text), list of references
	aux_write = function(object, stream, references)
		stream:write(...)
	end
}
```

## `:is_valid(object)`

Returns whether the given object can be represented by the instance as boolean.

## `:len(object)`

Returns the expected length of the object if serialized by the current instance in bytes.

## `:write(object, stream)`

Writes the object to a stream supporting `:write(text)`. Throws an error if invalid.

## `:read(stream)`

Reads a single bluon object from a stream supporting `:read(count)`. Throws an error if invalid bluon.

Checking whether the stream has been fully consumed by doing `assert(not stream:read(1))` is left up to the user.

## Format

Bluon uses a "tagged union" binary format:
Values are stored as a one-byte tag followed by the contents of the union.
For frequently used "constants", only a tag is used.

`nil` is an exception; since it can't appear in tables, it gets no tag.
If the value to be written by Bluon is `nil`, Bluon simply writes *nothing*.

The following is an enumeration of tag numbers, which are assigned *in this order*.

* `false`: 0
* `true`: 1
* Numbers:
  * Constants: 0, nan, +inf, -inf
  * Integers: Little endian:
  	* Unsigned: `U8`, `U16`, `U32`, `U64`
  	* Negative: `-U8`, `-U16`, `-U32`, `-U64`
  * Floats: Little endian `F32`, `F64`
* Strings:
  * Constant: `""`
  * Length is written as unsigned integer according to the tag: `S8`, `S16`, `S32`, `S64`
	* followed by the raw bytes
* Tables:
  * Tags: `M0`, `M8`, `M16`, `M32`, `M64` times `L0`, `L8`, `L16`, `L32`, `L64`
  * `M` is more significant than `L`: The order of the cartesian product is `M0L0`, `M0L1`, ...
  * List and map part count encoded as unsigned integers according to the tag,
    list part count comes first
  * followed by all values in the list part written as Bluon
  * followed by all key-value pairs in the map part written as Bluon
    (first the key is written as Bluon, then the value)
* Reference:
  * Reference ID as unsigned integer: `R8`, `R16`, `R32`, `R64`
  * References a previously encountered table or string by an index:
    All tables and strings are numbered in the order they occur in the Bluon
* Reserved tags:
  * All tags <= 55 are reserved. This gives 200 free tags.

## Features

* Embeddable: Written in pure Lua
* Storage efficient: No duplication of strings or reference-equal tables
* Flexible: Can serialize circular references and strings containing null

## Simple example

```lua
local object = ...
-- Write to file
local file = io.open(..., "wb")
modlib.bluon:write(object, file)
file:close()
-- Write to text
local rope = modlib.table.rope{}
modlib.bluon:write(object, rope)
text = rope:to_text()
-- Read from text
local inputstream = modlib.text.inputstream"\1"
assert(modlib.bluon:read(object, rope) == true)
```

## Advanced example

```lua
-- Serializes all userdata to a constant string:
local custom_bluon = bluon.new{
	aux_is_valid = function(object)
		return type(object) == "userdata"
	end,
	aux_len = function(object)
		return 1 + ("userdata"):len())
	end,
	aux_read = function(type, stream, references)
		assert(type == 100, "unsupported type")
		assert(stream:read(("userdata"):len()) == "userdata")
		return userdata()
	end,
	-- object to be written, stream providing :write(text), list of references
	aux_write = function(object, stream, references)
		assert(type(object) == "userdata")
		stream:write"\100userdata"
	end
}
-- Write to text
local rope = modlib.table.rope{}
custom_bluon:write(userdata(), rope)
assert(rope:to_text() == "\100userdata")
```
