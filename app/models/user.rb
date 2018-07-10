class User < ApplicationRecord
  MAX_NAME_LENGTH = 100
  MAX_EMAIL_LENGTH = 256
  MIN_PASSWORD_LENGTH = 8
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates(:name, presence:true, length: {maximum: MAX_NAME_LENGTH})
  validates(:email, presence:true, length: {maximum: MAX_EMAIL_LENGTH}, uniqueness:{ case_sensitive: false},
            format: { with: VALID_EMAIL_REGEX})
  # This line is needed even with presence of 'has_secure_password'
  validates(:password, presence:true, length: {minimum: MIN_PASSWORD_LENGTH})
  validates_presence_of :password_confirmation, on: :create

  before_save do
    email.downcase!
  end

  has_secure_password
end
