

# == Schema Information
#
# Table name: users
#
#  id                 :integer         not null, primary key
#  name               :string(255)
#  email              :string(255)
#  created_at         :datetime
#  updated_at         :datetime
#  encrypted_password :string(255)
#  salt               :string(255)
#  admin              :boolean         default(FALSE)
#  fb_user_id         :integer
#


require 'spec_helper'

describe User do
                  
  before(:each) do
     @attr = { :name => "Example User", 
               :email => "lsease@gmail.com", 
               :password => "password", 
               :password_confirmation => "password",
               :fb_user_id => 1}
  end
  
  it "should create a new instance with valid attr" do
     User.create!(@attr)
  end   
  
  it "should require a name" do
     no_name_user = User.new(@attr.merge(:name => "")) 
     no_name_user.should_not be_valid
  end
  
    it "should require email" do
     no_em_user = User.new(@attr.merge(:email => "")) 
     no_em_user.should_not be_valid
  end  
  
  it "should reject long names" do
     long_name = "a" * 51
     long_name_user = User.new(@attr.merge(:name => long_name))
     long_name_user.should_not be_valid
  end      
  
  it "should accept valid email" do
      addresses = %w[user@foo.com THE_USER@foo.bar.org first.Last@Foo.Jp]
      addresses.each do |address|
         valid_user = User.new(@attr.merge(:email => address))   
         valid_user.should be_valid
      end
  end
  
  it "should reject invalid email" do
      addresses = %w[user@foo,com THE_USER_at_foo.bar.org first.last@foo.]
      addresses.each do |address|
         invalid_user = User.new(@attr.merge(:email => address))   
         invalid_user.should_not be_valid
      end
  end   
  
  it "should reject dup emails" do
     User.create!(@attr)
     user_dup = User.new(@attr)
     user_dup.should_not be_valid
  end       
  
  it "should reject dup emails diff case" do
     User.create!(@attr)                                   
     upcase_email = @attr[:email].upcase
     user_dup = User.new(@attr.merge(:email => upcase_email))
     user_dup.should_not be_valid
  end   
  
  describe "passwords" do     
    
    before(:each) do
      @user = User.new(@attr)
     end
    
    it "should have a password attribute" do
       @user.should respond_to(:password)
    end   
    
    it "should have a password conf attribute" do
       @user.should respond_to(:password_confirmation)
    end
    
  end   
  
  describe "password validation" do
     it "should require a password" do
        User.new(@attr.merge(:password => "", :password_confirmation => "")).
          should_not be_valid
     end    
     
     it "should require a matching password conf" do
        User.new(@attr.merge( :password_confirmation => "invalid")).
          should_not be_valid
     end
           
     it "should reject short password" do
        short = "a" * 5
        hash = @attr.merge(:password => short, :password_confirmation => short)
        User.new(hash).should_not be_valid
     end     
     
     it "should reject long password" do
        long = "a" * 41
        hash = @attr.merge(:password => long, :password_confirmation => long)
        User.new(hash).should_not be_valid
     end
     
  end    
  
  describe "password encryption" do
     before(:each) do
      @user = User.create!(@attr)
     end    
     
     it "should have a salt" do
        @user.should respond_to(:salt)
     end
          
     it "should have an encry pass attr" do
        @user.should respond_to(:encrypted_password)
     end      
     
     it "should set the encry pass attr" do
        @user.encrypted_password.should_not be_blank
     end   
     
     describe "has password method" do
       it "should exist" do
          @user.should respond_to(:has_password?)
       end
       
       it "should return true if match" do
          @user.has_password?(@attr[:password]).should be_true        
       end      
       
       it "should return false if match" do
          @user.has_password?(@attr["invalid"]).should be_false        
       end
       
     end
          
     describe "authenticate method" do        
       
        it "should respond to auth" do
           User.should respond_to(:authenticate)
        end
       
        it "should return nil on email/pass mismatch" do
           User.authenticate(@attr[:email], "wrongpass").should be_nil
        end               
        
        it "should return nil on no user" do
           User.authenticate("barfoo", @attr[:password])
        end   
        
        it "should return user if matched" do
           auth = User.authenticate(@attr[:email], @attr[:password])
           auth.should == @user 
        end
        
     end    
     
  end   
  
  describe "fb id attribute" do
    before(:each) do
      @user = User.create!(@attr)
    end
    
    it "should respond to fb_id" do
      @user.should respond_to(:fb_user_id)
    end
    
    it "should be able to link to a new fb user" do
      @user.fb_user_id = 1
      @user.save!
      @user.reload
      @user.fb_user_id.should == 1;
    end
    
    it "should be able to unlink from a fb user" do
      @user.fb_user_id = 1
      @user.save!
      @user.fb_user_id = nil
      @user.save!
      @user.fb_user_id.should  be_nil
    end
    
  end
  
  describe "admin attribute" do
     
    before(:each) do
       @user = User.create!(@attr)
    end                          
    
    it "should respond to admin" do
       @user.should respond_to(:admin)
    end   
    
    it "should should be false by default" do
        @user.should_not be_admin 
        #or @user.admin?.should_not be_true
    end
    
    it "should be convertible to admin" do
        @user.toggle!(:admin)    #.toggle converts false to true, ! writes to db     
        @user.should be_admin
    end
    
    
  end   
  
  describe "password assoc" do
     before(:each) do
        @user = User.create(@attr)
     end                         

  end  

  
end
