require 'spec_helper'

describe User do
  before(:each) do
    @attr = {:name => "Example User", :email => "user@example.com",
      :password => "foobar", :password_confirmation => "foobar"}
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

  describe "password_validations" do
    
    it "should require a password" do
      user = User.new(@attr.merge(:password => "", :password_confirmation => ""))
      user.should_not be_valid
    end
    
    it "should require a matching password confirmation" do
      user = User.new(@attr.merge(:password_confirmation => "barfoo"))
      user.should_not be_valid
    end

    it "should reject short passwords" do
      short = "aaaaa"
      user = User.new(@attr.merge(:password => short, :password_confirmation => short))
      user.should_not be_valid
    end

    it "should reject long passwords" do
      long = "a" * 41
      user = User.new(@attr.merge(:password => long, :password_confirmation => long))
      user.should_not be_valid
    end
  end
  
  describe "password_encryption" do
    before(:each) do
      @user = User.create!(@attr)
    end

    it "should have an encrypted password attribute" do
      @user.should respond_to(:encrypted_password)
    end

    it "should set the encrypted password" do
      @user.encrypted_password.should_not be_blank
    end

    describe "has_password? method" do
      it "should be true if passwords match" do
        @user.has_password?(@attr[:password]).should be_true
      end

      it "should be false if the passwords do not match" do
        @user.has_password?("jalla").should be_false
      end
    end

    describe "authenticate method" do
      it "should return nil on mismatch" do
        wrong_pw_user = User.authenticate(@attr[:email], "wrongpassword")
        wrong_pw_user.should be_nil
      end

      it "should return nil for an email with no user" do
        no_user = User.authenticate("invalid@email.com", @attr[:password])
        no_user.should be_nil
      end

      it "should return the user if match" do
        a_user = User.authenticate(@attr[:email], @attr[:password])
        a_user.should == @user
      end
    end
  end
end
