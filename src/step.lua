local tinsert = table.insert

local try_catch_finally_executer = function(options)
  local try_index = 0
  local tries = options.try
  local callbacks = {}
  callbacks.success = function(...)
    try_index = try_index + 1
    local tryf = tries[try_index]
    if tryf then
      local args = {...}
      tinsert(args,callbacks)
      local ok,err = {tryf(unpack(args))}
      if not ok then
        callbacks.error(err)
      end
    elseif options.finally then
      local ok,err = pcall(options.finally,...)
      if not ok then
        print('lua-step finally function failed:',err)
      end
    end
  end
  callbacks.error = function(...)
    if options.catch then
      local ok,err = pcall(options.catch,...)
      if not ok then
        print('lua-step catch function failed:',err)
      end
    end
    if options.finally then
      local ok,err = pcall(options.finally)
      if not ok then
        print('lua-step finally function failed:',err)
      end
    end
  end
  return callbacks.success
end

local step = function(config)
  local executer
  if config.try and (config.catch or config.finally) then
    executer = try_catch_finally_executer(config)
  end
  if not executer then
    error('invalid step config')
  end
  executer()
end

return step
