local step = require'step'

describe('The step module',function()
    it('is a function (and not a table)',function()
        assert.is_equal(type(step),'function')
      end)
    
    it('try / finally works with no error',async,function(done)
        step{
          try = {
            guard(function(callbacks)
                assert.is_equal(type(callbacks.success),'function')
                assert.is_equal(type(callbacks.error),'function')
                callbacks.success(123,'hello')
              end),
            guard(function(n,s,callbacks)
                assert.is_equal(n,123)
                assert.is_equal(s,'hello')
                assert.is_equal(type(callbacks.success),'function')
                assert.is_equal(type(callbacks.error),'function')
                callbacks.success('some arg')
              end)
          },
          finally = guard(function(s)
              assert.is_equal(s,'some arg')
              done()
            end)
        }
      end)
    
    it('try / finally works with error',async,function(done)
        local spies = {
          try = {
            spy.new(function(callbacks)
                callbacks.error('terror')
              end),
            spy.new(function()
              end)
          },
        }
        step{
          try = spies.try,
          finally = guard(function(s)
              assert.spy(spies.try[1]).was.called(1)
              assert.spy(spies.try[2]).was_not.called()
              assert.is_nil(s)
              done()
            end)
        }
      end)
    
    
    
    it('try / catch / finally works with no error',async,function(done)
        step{
          try = {
            guard(function(callbacks)
                assert.is_equal(type(callbacks.success),'function')
                assert.is_equal(type(callbacks.error),'function')
                callbacks.success(123,'hello')
              end),
            guard(function(n,s,callbacks)
                assert.is_equal(n,123)
                assert.is_equal(s,'hello')
                assert.is_equal(type(callbacks.success),'function')
                assert.is_equal(type(callbacks.error),'function')
                callbacks.success('some arg')
              end)
          },
          catch = guard(function(err)
              assert.is_falsy('should not reach here')
            end),
          finally = guard(function(s)
              assert.is_equal(s,'some arg')
              done()
            end)
        }
      end)
    
  end)

it('try / catch / finally works with error',async,function(done)
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
      finally = guard(function(s)
          --                                        assert.spy(spies.try[1]).was.called(1)
          --                                      assert.spy(spies.try[2]).was_not.called()
          --                                    assert.spy(spies.catch).was.called_with('terror')
          assert.is_nil(s)
          done()
        end)
    }
  end)

