require 'spec_helper'

describe User do
  before(:each) do
    @attr = {:name => "Example User", :email => "user@example.com"}
  end

  it "should create a new instance given valid attributes" do
    User.create!(@attr)
  end

  it "should require a name" do
    no_name_user = User.new(@attr.merge(:name=>""))
    no_name_user.should_not be_valid
  end

  it "should require an email" do
    no_email_user = User.new(@attr.merge(:email=>""))
    no_email_user.should_not be_valid
  end

  it "should reject too long names" do
    long_name = "a" * 51
    long_name_user = User.new(@attr.merge(:name=>long_name))
    long_name_user.should_not be_valid
  end

  it "should reject invalid email addresses" do
    addresses = %w[user@foo,com user_at_foo.org example.user@foo.]
    addresses.each do |address|
      invalid_email_user = User.new(@attr.merge(:email => address))
      invalid_email_user.should_not be_valid
    end
  end

  it "should reject duplicate email addresses" do
    # Add a user with the email into the DB
    User.create!(@attr)
    duplicate_user = User.new(@attr)
    duplicate_user.should_not be_valid
  end

  it "should reject duplicates with different case" do
    upcase_email = @attr[:email].upcase
    User.create!(@attr.merge(:email => upcase_email))
    dupe_user = User.new(@attr)
    dupe_user.should_not be_valid
  end
end
