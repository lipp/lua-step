-- Demonstrates some async control flow
-- with some boring timer using lua-step.
--
-- To make things a little more interesting, the
-- timer can succeed and fail.

local timer = require'timer'
local step = require'step'

local tricky_timer_stuff = step.new({
    try = {
      [1] = function(step)
        timer.new(0.1,step.success,step.error)
      end,
      [2] = function(step,num)
        step.context.foo = 'bar'
        print('previous timer passed "'..num..'" to step.success')
        timer.new(0.1,step.success,step.error)
      end,
      [3] = function(step,num)
        print('previous timer passed "'..num..'" to step.success')
        timer.new(0.1,step.success,step.error)
      end,
    },
    catch = function(step,err)
      print('previous timer failed with:'..err)
    end,
    finally = function(step)
      if #step.result == 3 then
        print('(All timers happy)')
      else
        print('(Not all timers happy)')
      end
      if #step.result > 0 then
        print('Random Nums:')
        for i,result in ipairs(step.result) do
          print('Timer',i,result[1])
          -- the arguments passed to step.success
          -- are stored (as array) in step.result[i]
          -- to be referred to later
        end
      end
      if step.context.foo then
        print('Hey, nice foo',step.context.foo)
      end
      print('Good bye')
    end
})

tricky_timer_stuff()
timer.loop()
