class User < ApplicationRecord
  MAX_NAME_LENGTH = 100
  MAX_EMAIL_LENGTH = 256
  MIN_PASSWORD_LENGTH = 8
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates(:name, presence:true, length: {maximum: MAX_NAME_LENGTH})
  validates(:email, presence:true, length: {maximum: MAX_EMAIL_LENGTH}, uniqueness:{ case_sensitive: false},
            format: { with: VALID_EMAIL_REGEX})
  # This line is needed even with presence of 'has_secure_password'
  validates(:password, presence:true, length: {minimum: MIN_PASSWORD_LENGTH}, allow_nil: true)
  validates_presence_of :password_confirmation, on: :create

  before_save do
    email.downcase!
  end

  has_secure_password

  attr_accessor :remember_token

  def User.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST : BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end

  def User.new_token
    SecureRandom.urlsafe_base64
  end

  def remember
    self.remember_token = User.new_token
    update_attribute(:remember_digest, User.digest(self.remember_token))
  end

  def authenticated?(remember_token)
    remember_digest &&
      BCrypt::Password.new(remember_digest).is_password?(remember_token)
  end

  def forget
    update_attribute(:remember_digest, nil)
  end
  
end
