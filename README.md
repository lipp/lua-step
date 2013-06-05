# About

Un-nest and simplify asynchronous control flow.

# Usage

See spec folder with busted tests.

# Installation

    $ git clone https://github.com/lipp/lua-step.git
    $ cd lua-step
    $ sudo luarocks make

# Build status

[![Build Status](https://travis-ci.org/lipp/lua-step.png?branch=master)](https://travis-ci.org/lipp/lua-step/builds)

# Doc

```lua

local step = require'step'

step({
  try = {
    [1] = function(callbacks)
      -- do some async stuff
	  ...
	  -- the first argument to all try functions
	  -- is the callbacks table
      callbacks.success(123,'abc')
    end,
    [2] = function(callbacks,num,str)
      -- arguments to callbacks.success are forwarded to the 
	  -- next function in try list.
      -- so num==123 and str=='abc' 
      -- do some more async stuff
	  ...
	  callbacks.success({1,2,3})
    end,
    [3] = function(callbacks,array)
	  if array[2] == 78 then
	    callbacks.success()
	  else
	    callbacks.error('something went wrong')
	  end
    end,
  },
  catch = function(err)
    -- catch will be called when callbacks.error has been called
	-- or if some error happened (is thrown).
	-- no further try step will be executed.
	print('ERROR',err)
  end,
  finally = function()
    -- finally is called in any case
	cleanup_some_stuff()
  end
})
```
