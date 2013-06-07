# About

Un-nest asynchronous control flow.

# Installation

    $ git clone https://github.com/lipp/lua-step.git
    $ cd lua-step
    $ sudo luarocks make

# Build status

[![Build Status](https://travis-ci.org/lipp/lua-step.png?branch=master)](https://travis-ci.org/lipp/lua-step/builds)

# Wrap up

```lua

local step = require'step'

local some_async_action = step.new({
  try = {
    [1] = function(step)
      -- do some async stuff
	  ...
	  -- the first argument to all try functions
	  -- is the step table
      step.success(123,'abc')
    end,
    [2] = function(step,num,str)
      -- arguments to step.success are forwarded to the 
	  -- next function in try list.
      -- so num==123 and str=='abc' 
      -- do some more async stuff
	  ...
	  step.success({1,2,3})
    end,
    [3] = function(step,array)
	  if array[2] == 78 then
	    step.success()
	  else
	    step.error('something went wrong')
	  end
    end,
  },
  catch = function(err)
    -- catch will be called when step.error has been called
	-- or if some error happened (is thrown).
	-- no further try step will be executed.
	print('ERROR',err)
  end,
  finally = function()
    -- finally is called in any case
	cleanup_some_stuff()
  end
})

some_async_action()
```

# API

## The step table (module)

### step.new (function)

Creates a step instance and returns a function which starts execution. Argument `arg` is a table with the following fields:

#### arg.try

An array of functions which should be executed.

#### arg.catch

A function which is called on error, optional.

### arg.finally

A function which is executed either after last try finished or after catch was invoked in casew of error, optional


## The step table (passed to callbacks)

### step.success (function)

Progresses with the next `try` entry or with `finally` if it was the last `try` entry.
All arguments are forwarded to the respective function as additional function arguments.

### step.error (function)

Progresses with the `catch` function and passes the `err` as additional argument to `catch`.
After `catch` has been called, `finally` will be called.

### step.result (array)

Array (table), which holds all results (arguments which have been passed to step.success) for each `try` entry.

### step.index (number)

The currently executed function index inside the `try` array. Useful to manipulate `step.try` at runtime.

### step.try (array)

Array of functions. Try steps can be inserted at runtime, using this array and `step.index`.

```lua
local async_op = step.new({
  try = {
	...
    function(step)
	  -- insert a try step on-the-fly right
	  -- after this step.
	  table.insert(step.try,step.index+1,function(step)
	    ...
	  end)
	end,
    ...
  }
})
```

### step.context (table)

A table which can be freely used to store context between `try` entries and/or `finally` call. Useful for doing cleanup
code in finally, e.g.:

```lua
local async_op = step.new({
  try = {
    [1] = function(step)
	  ...
	end,
    ...
    [3] = function(step)
	  step.context.file = io.open('foo.txt')
	end,
	...
  },
  finally = function(step)
    if step.context.file then
	  step.context.file:close()
    end
  end
})
```

# Examples

See `spec` folder with [busted](https://github.com/Olivine-Labs/busted) tests and `examples` folder for more
examples.

# Motivation

As asynchronous control flow gets more complex readability suffers
greatly. Often the code for a "simple" synchronous sequence of operations got
deeply nested in async programming:

```lua
--------------------
-- sync flow
--------------------
local ok,err = pcall(function()
  a()
  b()
  c()
  print('yup')
end)

if ok then
  ...
else
  ...
end

--------------------
-- becomes
--------------------
local on_error = function() ... end

a({
  success = function()
    b({
      success = function()
        c({
          success = function()
            print('yup')
          end,
          error = on_error
        })
      end,
      error = on_error
    })
  end,
  error = on_error
})
```

Worse, if results or state has to be shared between `a`,`b` and `c`
lots up upvalues are required. A comparison of programming async with
and without lua-step can be found in the `example` folder.

Moreover, programmatically executing async execution steps is hardly possible
without (a mechanism similar to) lua-step.

```lua
--------------------
-- sync flow
--------------------
local exec_steps = read_config()

local ok,err = pcall(function()
  for _,exec_step in ipairs(exec_steps) do
    exec_step()
  end
end

if not ok then
  ...
end

cleanup()

--------------------
-- becomse without lua-step
--------------------

-- ???
-- ???
-- ???

--------------------
-- becomse with lua-step
--------------------
local async_exec_steps = read_config()

local try = async_exec_steps

local exec_all_async_steps = step.new({
  try = async_exec_steps,
  catch = on_error,
  finally = cleanup
})

exec_all_async_steps()
```

lua-step tries to improve readibility and maintainablity of async
control flows.