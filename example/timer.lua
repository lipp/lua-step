-- Demonstrates some async control flow
-- with some boring timer.
--
-- To make things a little more interesting, the
-- timer can succeed and fail.
local ev = require'ev'
math.randomseed(os.time())
-- sets up and starts a timer with specified timeout
-- on timeout calls either on_timeout or on_error.
local timer = function(timeout,on_timeout,on_error)
  ev.Timer.new(function()
      local num = math.random(1,100)
      if num % 10  == 0 then
        on_error(tostring(num)..' % 10 == 0')
      else
        on_timeout(num)
      end
    end,timeout):start(ev.Loop.default)
end

return {
  new = timer,
  loop = function()
    ev.Loop.default:loop()
  end
}
