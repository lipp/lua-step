local step = require'step'

describe('The step module',function()
    it('is a function (and not a table)',function()
        assert.is_equal(type(step),'function')
      end)
    
    it('try / finally works with no error',function(done)
        step{
          try = {
            async(function(callbacks)
                assert.is_equal(type(callbacks.success),'function')
                assert.is_equal(type(callbacks.error),'function')
                callbacks.success(123,'hello')
              end),
            async(function(callbacks,n,s)
                assert.is_equal(n,123)
                assert.is_equal(s,'hello')
                assert.is_equal(type(callbacks.success),'function')
                assert.is_equal(type(callbacks.error),'function')
                callbacks.success('some arg')
              end)
          },
          finally = async(function(s)
              assert.is_equal(s,'some arg')
              done()
            end)
        }
      end)
    
    it('tries can be added async',function(done)
        local try
        try = {
          async(function(callbacks)
              try[2] = async(function(callbacks,n,s)
                  assert.is_equal(n,123)
                  assert.is_equal(s,'hello')
                  assert.is_equal(type(callbacks.success),'function')
                  assert.is_equal(type(callbacks.error),'function')
                  callbacks.success('some arg')
                end)
              assert.is_equal(type(callbacks.success),'function')
              assert.is_equal(type(callbacks.error),'function')
              callbacks.success(123,'hello')
            end)
        }
        step{
          try = try,
          finally = async(function(s)
              assert.is_equal(s,'some arg')
              done()
            end)
        }
      end)
    
    it('try / finally works with error',function(done)
        local spies = {
          try = {
            spy.new(function(callbacks)
                callbacks.error('terror')
              end),
            spy.new(function()
              end)
          },
          catch = spy.new(function(err) end),
        }
        step{
          try = spies.try,
          catch = spies.catch,
          finally = async(function(s)
              assert.spy(spies.try[1]).was.called(1)
              assert.spy(spies.try[2]).was_not.called()
              assert.spy(spies.catch).was.called_with('terror')
              assert.is_nil(s)
              done()
            end)
        }
      end)
    
    it('try / finally works with unexpected error',function(done)
        local foo = {}
        local spies = {
          try = {
            spy.new(function(callbacks)
                error(foo)
              end),
            spy.new(function()
              end)
          },
        }
        step{
          try = spies.try,
          catch = async(function(err)
              assert.is_same(err,foo)
            end),
          finally = async(function(s)
              assert.spy(spies.try[1]).was.called(1)
              assert.spy(spies.try[2]).was_not.called()
              assert.is_nil(s)
              done()
            end)
        }
      end)
    
    
    
    it('try / catch / finally works with no error',function(done)
        step{
          try = {
            async(function(callbacks)
                assert.is_equal(type(callbacks.success),'function')
                assert.is_equal(type(callbacks.error),'function')
                callbacks.success(123,'hello')
              end),
            async(function(callbacks,n,s)
                assert.is_equal(n,123)
                assert.is_equal(s,'hello')
                assert.is_equal(type(callbacks.success),'function')
                assert.is_equal(type(callbacks.error),'function')
                callbacks.success('some arg')
              end)
          },
          catch = async(function(err)
              assert.is_falsy('should not reach here')
            end),
          finally = async(function(s)
              assert.is_equal(s,'some arg')
              done()
            end)
        }
      end)
    
    it('try / catch / finally works with error',function(done)
        local spies = {
          try = {
            spy.new(function(callbacks)
                callbacks.error('terror')
              end),
            spy.new(function()
              end)
          },
          catch = spy.new(function()
            end)
        }
        step{
          try = spies.try,
          catch = spies.catch,
          finally = async(function(s)
              assert.spy(spies.try[1]).was.called(1)
              assert.spy(spies.try[2]).was_not.called()
              assert.spy(spies.catch).was.called_with('terror')
              assert.is_nil(s)
              done()
            end)
        }
      end)
    
  end)
