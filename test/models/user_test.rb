require 'test_helper'

class UserTest < ActiveSupport::TestCase
  def setup
    @user = User.new(name:"Donna Reed", email:'donnareed@jtt.com', password:'precious', password_confirmation: 'precious')
    @user_no_name = User.new
    @user_no_email = User.new(name: "no email")
    @user_dup = @user.dup
  end

  test 'should be valid' do
    assert @user.valid?
  end

  test 'blank name should not be valid' do
    assert_not @user_no_name.valid?
  end

  test 'no email should not be valid' do
    assert_not @user_no_email.valid?
  end

  test 'names must be short' do
    @user.name = 'a' * (User::MAX_NAME_LENGTH + 1)
    assert_not @user.valid?
  end

  test 'email addresses must be short' do
    @user.email = 'a' * (User::MAX_EMAIL_LENGTH + 1)
    assert_not @user.valid?
  end

  test 'email addresses must meet a minimal standard' do
    valid_addresses = %w[user@example.com USER@foo.COM A_US-ER@foo.bar.org
                         first.last@foo.jp alice+bob@baz.cn]
    valid_addresses.each do |valid_address|
      @user.email = valid_address
      assert @user.valid?, "#{valid_address.inspect} should be valid"
    end
    invalid_addresses = %w[user@example,com user_at_foo.org user.name@example.
                           foo@bar_baz.com foo@bar+baz.com]
    invalid_addresses.each do |invalid_address|
      @user.email = invalid_address
      assert_not @user.valid?, "#{invalid_address.inspect} should be invalid"
    end
  end

  test 'names must be unique' do
    @user.save!
    assert_equal @user.email, @user_dup.email
    assert_not @user_dup.valid?
  end

  test 'same name ok' do
    user_dup = @user.dup
    @user.save!
    user_dup.email = 'other@french.com'
    assert user_dup.valid?
  end
  
  test 'same email with diff case not ok' do
    user_dup = @user.dup
    @user.save!
    user_dup.email = @user.email.upcase
    assert_not user_dup.valid?
  end
  
  test 'password must have a confirmation' do
    user = User.new(name:'fReD', email:'fReD@x.dOot', password:'precious')
    assert_not user.valid?
  end
  
  test 'password must match confirmation' do
    user = User.new(name:'fReD', email:'fReD@x.dOot', password:'precious', password_confirmation:'waldo')
    assert_not user.valid?
  end

  test 'saving should downcase email' do
    user = User.new(name:'fReD', email:'fReD@x.dOot', password:'precious', password_confirmation:'precious')
    assert user.valid?
    assert_equal user.name, 'fReD'
    assert_equal user.email, 'fReD@x.dOot'
    user.save
    assert_equal user.name, 'fReD'
    assert_equal user.email, 'fred@x.doot'
  end
  
  test 'password must be long enough' do
    pwd = 'f4E*'
    user = User.new(name:'fReD', email:'fReD@x.dOot', password:pwd, password_confirmation:pwd)
    assert_not user.valid?
  end

  test 'authenticated? should return false for a user with no remember digest' do
    assert_not @user.authenticated?('')
  end
end
