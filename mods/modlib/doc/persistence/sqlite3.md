# SQLite3 Database Persistence

Uses a SQLite3 database to persistently store a Lua table. Obtaining it is a bit trickier, as it requires access to the `lsqlite3` library, which may be passed:

```lua
local modlib_sqlite3 = persistence.sqlite3(require"lsqlite3")
```

(assuming `require` is that of an insecure environment if Minetest is used)

Alternatively, if you are not running Minetest, mod security is disabled, you have (temporarily) provided `require` globally, or added `modlib` to `secure.trusted_mods`, you can simply do the following:

```lua
local modlib_sqlite3 = persistence.sqlite3()
```

Modlib will then simply call `require"lsqlite3"` for you.

Then, you can proceed to create a new database:

```lua
local database = persistence.modlib_sqlite3.new(mod.get_resource"database.test.sqlite3", {})
-- Create or load
database:init()
-- Use it
database:set_root("key", {nested = true})
database:close()
```

It uses a similar API to Lua log files:

* `new(filename, root)` - without `reference_strings` however (strings aren't referenced currently)
* `init`
* `set`
* `set_root`
* `rewrite`
* `close`

The advantage over Lua log files is that the SQlite3 database keeps disk usage minimal. Unused tables are dropped from the database immediately through reference counting. The downside of this is that this, combined with the overhead of using SQLite3, of course takes time, making updates on the SQLite3 database slower than Lua log file updates (which just append to an append-only file).
As simple and fast reference counting doesn't handle cycles, an additional `collectgarbage` stop-the-world method performing a full garbage collection on the database is provided which is called during `init`.
The method `defragment_ids` should not have to be used in practice (if it has to be, it happens automatically) and should be used solely for debugging purposes (neater IDs).
