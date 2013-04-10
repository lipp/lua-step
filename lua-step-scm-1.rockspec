package = "lua-step"
version = "scm-1"

source = {
   url = "git://github.com/lipp/lua-step.git",
}

description = {
   summary = "Un-nesting asynchronous control flow",
   homepage = "http://github.com/lipp/lua-step",
   license = "MIT/X11",
}

dependencies = {
   "lua >= 5.1",
}

build = {
  type = 'none',
  install = {
    lua = {
      ['step'] = 'src/step.lua',
    }
  }
}

