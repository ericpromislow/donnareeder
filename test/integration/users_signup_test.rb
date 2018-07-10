require 'test_helper'

class UsersSignupTest < ActionDispatch::IntegrationTest
  test "happy signup" do
    get signup_path
    assert_no_difference 'User.count' do
      post users_path, params: { user: { name: '',
                                         email: 'user@invalid',
                                         password: 'a',
                                         password_confirmation: 'b',
                                       }
                               }
    end
    assert_template 'users/new'
  end
end
