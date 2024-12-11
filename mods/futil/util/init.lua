futil.dofile("util", "bisect")
futil.dofile("util", "class")
futil.dofile("util", "coalesce")
futil.dofile("util", "exception")
futil.dofile("util", "file")
futil.dofile("util", "http")
futil.dofile("util", "list")
futil.dofile("util", "math")
futil.dofile("util", "matrix")
futil.dofile("util", "memoization")
futil.dofile("util", "memory")
futil.dofile("util", "path")
futil.dofile("util", "predicates")
futil.dofile("util", "string")
futil.dofile("util", "table")

futil.dofile("util", "equals") -- depends on table
futil.dofile("util", "functional") -- depends on table
futil.dofile("util", "iterators") -- depends on functional
futil.dofile("util", "random") -- depends on math
futil.dofile("util", "regex") -- depends on exception
futil.dofile("util", "selection") -- depends on table, math
futil.dofile("util", "time") -- depends on math
futil.dofile("util", "limiters") -- depends on functional
