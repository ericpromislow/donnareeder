require 'test_helper'

class UsersSignupTest < ActionDispatch::IntegrationTest
  test "signup fails with no name" do
    get signup_path
    assert_no_difference 'User.count' do
      post signup_path, params: { user: { name: '',
                                         email: 'user@invalid',
                                         password: 'a',
                                         password_confirmation: 'b',
                                       }
                               }
    end
    assert_template 'users/new'
    assert_select 'div#error_explanation'
    assert_select 'div.field_with_errors'
  end
  
  test "happy signup" do
    get signup_path
    assert_difference 'User.count', 1 do
      pwd = 'a' * 12
      post signup_path, params: { user: { name: 'ferd',
                                          email: 'user@valid.com',
                                          password: pwd,
                                          password_confirmation: pwd,
                                        }
                                }
    end
    follow_redirect!
    assert_template 'users/show'
    assert flash.key?(:success)
  end
end
