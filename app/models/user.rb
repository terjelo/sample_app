# == Schema Information
# Schema version: 20101002212245
#
# Table name: users
#
#  id         :integer         not null, primary key
#  name       :string(255)
#  email      :string(255)
#  created_at :datetime
#  updated_at :datetime
#

require 'digest'

class User < ActiveRecord::Base
  attr_accessor :password
  attr_accessible :name, :email, :password, :password_confirmation

  validates_confirmation_of :password
  validates_presence_of :password
  validates_length_of :password, :within => 6..40

  EmailRegex = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

  validates_presence_of :name, :email
  validates_length_of :name, :maximum => 50
  validates_format_of :email, :with => EmailRegex
  validates_uniqueness_of :email, :case_sensitive => false

  before_save :encrypt_password

  # Check if the users password matches submitted pw
  def has_password?(submitted_pw)
    self.encrypted_password == encrypt(submitted_pw)
  end
  
  def self.authenticate(email, submitted_pw)
    user = find_by_email(email)
    return nil if user.nil?
    return user if user.has_password?(submitted_pw)
  end

  private

  def encrypt_password
    self.salt = make_salt
    self.encrypted_password = encrypt(password)
  end

  def encrypt(string)
    secure_hash("#{salt}#{string}")
  end

  def make_salt
    secure_hash("#{Time.now.utc}#{password}")
  end

  def secure_hash(string)
    Digest::SHA2.hexdigest(string)
  end
end
