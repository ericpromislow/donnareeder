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
  has_many :nodes, dependent: :destroy

  attr_accessor :remember_token, :activation_token, :reset_token

  before_create :create_activation_digest

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

  def authenticated?(attribute, token)
    digest = send("#{attribute}_digest")
    digest && BCrypt::Password.new(digest).is_password?(token)
  end

  def activate
    update_columns(activated: true, activated_at: Time.zone.now)
  end

  def send_activation_email
    UserMailer.account_activation(self).deliver_now
  end

  def clear_reset_info
    update_columns(reset_digest: nil, reset_sent_at: 0)
  end

  def create_reset_digest
    self.reset_token = User.new_token
    update_attribute(:reset_digest, User.digest(self.reset_token))
    update_attribute(:reset_sent_at, Time.zone.now)
  end
  
  def password_reset_expired?
    reset_sent_at < 2.hours.ago
  end

  def send_password_reset_email
    UserMailer.password_reset(self).deliver_now
  end

  def forget
    update_attribute(:remember_digest, nil)
  end

  private

  def create_activation_digest
    self.activation_token  = User.new_token
    self.activation_digest = User.digest(activation_token)
  end
  
end
