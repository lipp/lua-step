-- Demonstrates some async control flow
-- with some boring timer NOT using lua-step.
--
-- Significant differences to lua-step variant:
--   + Deeper nested
--   + more upvalues
--
-- To make things a little more interesting, the
-- timer can succeed and fail.

local timer = require'timer'

local results = {}
local foo

local wrap_up = function()
  if #results == 3 then
    print('(All timers happy)')
  else
    print('(Not all timers happy)')
  end
  if #results > 0 then
    print('Random Nums:')
    for i,result in ipairs(results) do
      print('Timer',i,result)
    end
  end
  if foo then
    print('Hey, nice foo',foo)
  end
  print('Good bye')
end

local on_error = function(err)
  print('previous timer failed with:'..err)
  wrap_up()
end

timer.new(0.1,function(num)
    results[1] = num
    print('previous timer passed "'..num..'"')
    timer.new(0.1,function(num)
        results[2] = num
        foo = 'bar'
        print('previous timer passed "'..num..'"')
        timer.new(0.1,function(num)
            results[3] = num
            wrap_up()
          end,on_error)
      end,on_error)
  end,on_error)

timer.loop()
