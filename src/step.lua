local tinsert = table.insert

local try_catch_finally_executer = function(options)
  local try_index = 0
  local tries = options.try
  local self = {}
  local clean = function()
    self.result = nil
    self.context = nil
    self.try = nil
    self = nil
  end
  self.success = function(...)
    self.result[try_index] = {...}
    try_index = try_index + 1
    self.index = try_index
    local tryf = tries[try_index]
    if tryf then
      local args = {self,...}
      local ok,err = pcall(tryf,self,...)
      if not ok then
        self.error(err)
      end
    else
      if options.finally then
        local ok,err = pcall(options.finally,self,...)
        clean()
        if not ok then
          print('lua-step finally function failed:',err)
        end
      end
    end
  end
  self.error = function(...)
    if options.catch then
      local ok,err = pcall(options.catch,self,...)
      if not ok then
        print('lua-step catch function failed:',err)
      end
    end
    if options.finally then
      local ok,err = pcall(options.finally,self)
      clean()
      if not ok then
        print('lua-step finally function failed:',err)
      end
    end
  end
  self.context = {}
  self.result = {}
  self.try = tries
  return self.success
end

local new = function(config)
  local executer
  if config.try and (config.catch or config.finally) then
    executer = try_catch_finally_executer(config)
  end
  if not executer then
    error('lua-step invalid config')
  end
  return executer
end

return {
  new = new
}
