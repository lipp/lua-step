local step = require'step'

describe('The step module',function()
    it('is a function (and not a table)',function()
        assert.is_table(step)
      end)
    
    local assert_is_step_instance = function(i)
      assert.is_table(i)
      assert.is_function(i.success)
      assert.is_function(i.error)
      assert.is_table(i.context)
      assert.is_table(i.result)
      assert.is_table(i.try)
      assert.is_number(i.index)
    end
    
    it('try / finally works with no error',function(done)
        step.new{
          try = {
            async(function(step)
                assert_is_step_instance(step)
                assert.is_equal(step.index,1)
                step.success(123,'hello')
              end),
            async(function(step,n,s)
                assert_is_step_instance(step)
                assert.is_equal(step.index,2)
                assert.is_equal(n,123)
                assert.is_equal(s,'hello')
                step.context.foo = 'bar'
                step.success('some arg')
              end)
          },
          finally = async(function(step,s)
              assert_is_step_instance(step)
              assert.is_equal(#step.result,2)
              assert.is_same(step.result[1],{123,'hello'})
              assert.is_same(step.result[2],{'some arg'})
              assert.is_same(step.context.foo,'bar')
              assert.is_equal(s,'some arg')
              done()
            end)
        }()
      end)
    
    it('tries can be added async',function(done)
        step.new{
          try = {
            async(function(step)
                assert.is_equal(#step.try,1)
                step.try[2] = async(function(step,n,s)
                    assert.is_equal(#step.try,2)
                    assert_is_step_instance(step)
                    assert.is_equal(n,123)
                    assert.is_equal(s,'hello')
                    assert.is_equal(type(step.success),'function')
                    assert.is_equal(type(step.error),'function')
                    step.success('some arg')
                  end)
                assert.is_equal(type(step.success),'function')
                assert.is_equal(type(step.error),'function')
                step.success(123,'hello')
              end)
          },
          finally = async(function(step,s)
              assert.is_equal(#step.result,2)
              assert.is_same(step.result[1],{123,'hello'})
              assert.is_same(step.result[2],{'some arg'})
              assert_is_step_instance(step)
              assert.is_equal(s,'some arg')
              done()
            end)
        }()
      end)
    
    it('try / finally works with error',function(done)
        local spies = {
          try = {
            spy.new(function(step)
                step.error('terror')
              end),
            spy.new(function()
              end)
          },
          catch = spy.new(async(function(step,err)
                assert_is_step_instance(step)
                assert.is_equal(err,'terror')
            end)),
        }
        step.new{
          try = spies.try,
          catch = spies.catch,
          finally = async(function(step,s)
              assert_is_step_instance(step)
              assert.spy(spies.try[1]).was.called(1)
              assert.spy(spies.try[2]).was_not.called()
              assert.is_nil(s)
              done()
            end)
        }()
      end)
    
    it('try / finally works with unexpected error',function(done)
        local foo = {}
        local spies = {
          try = {
            spy.new(function(step)
                error(foo)
              end),
            spy.new(function()
              end)
          },
        }
        step.new{
          try = spies.try,
          catch = async(function(step,err)
              assert_is_step_instance(step)
              assert.is_same(err,foo)
            end),
          finally = async(function(step)
              assert_is_step_instance(step)
              assert.spy(spies.try[1]).was.called(1)
              assert.spy(spies.try[2]).was_not.called()
              done()
            end)
        }()
      end)
    
    
    
    it('try / catch / finally works with no error',function(done)
        step.new{
          try = {
            async(function(step)
                assert.is_equal(type(step.success),'function')
                assert.is_equal(type(step.error),'function')
                step.success(123,'hello')
              end),
            async(function(step,n,s)
                assert.is_equal(n,123)
                assert.is_equal(s,'hello')
                assert.is_equal(type(step.success),'function')
                assert.is_equal(type(step.error),'function')
                step.success('some arg')
              end)
          },
          catch = async(function(err)
              assert.is_falsy('should not reach here')
            end),
          finally = async(function(step,s)
              assert_is_step_instance(step)
              assert.is_equal(s,'some arg')
              done()
            end)
        }()
      end)
    
    it('try / catch / finally works with error',function(done)
        local spies = {
          try = {
            spy.new(function(step)
                step.error('terror')
              end),
            spy.new(function()
              end)
          },
          catch = async(function(step,err)
              assert_is_step_instance(step)
              assert.is_equal(err,'terror')
            end)
        }
        step.new{
          try = spies.try,
          catch = spies.catch,
          finally = async(function(step,s)
              assert_is_step_instance(step)
              assert.spy(spies.try[1]).was.called(1)
              assert.spy(spies.try[2]).was_not.called()
              assert.is_nil(s)
              done()
            end)
        }()
      end)
    
  end)
