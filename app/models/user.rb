
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

class User < ActiveRecord::Base      
  attr_accessor  :password, :fb_access_token  #defines new getter and setter

  attr_accessible :name, :email, :password, :password_confirmation

  #validation
  email_reg_ex = /\A[\w+\-.]+@[a-z\d.]+\.[a-z]+\z/i
  
  validates :name, :presence => true,
                    :length => { :maximum => 50 }
  validates :email, :presence => true,  
                    :format => { :with => email_reg_ex},
                    :uniqueness => { :case_sensitive => false}
  
  validates :password, :presence => true,
                       :confirmation => true,
                       :length => { :within => 6..40 },
                       unless: Proc.new { |c| c.id.present? and !c.password.present? }
                       
  before_save :encrypt_password

  has_many :answers
  has_many :tokens
  has_many :external_auth_providers

  #relationships
  has_many :relationships
  has_many :question_relationships, -> { where target_type: RELATIONSHIP_TYPE_QUESTION }, :dependent => :destroy,
           :foreign_key => "user_id",
           :class_name => "Relationship"
  has_many :favorite_questions,:through => :question_relationships, :source => :followed_questions

  #serialization, remove the user password
  # Exclude password info from json output.
  def serializable_hash(options={})
      options[:except] ||= [ :password, :email,:encrypted_password, :salt]
      options[:methods] ||= [ :image_url ]
    super options
  end


   ## or class << self
   ## def authenticate(       
  def User.authenticate(email, submitted_password)
     user = User.find_by_email(email); 
      
     (user && user.has_password?(submitted_password)) ? user : nil
       
  end                  
  
  def User.authenticate_with_salt(id, cookie_salt)
     user = find_by_id(id)
     (user && user.salt == cookie_salt) ? user : nil
  end
           
  def has_password?(submitted_password)
     encrypted_password == encrypt(submitted_password)
  end    


  def activate (key)
    if key == salt
      self.update_attribute( :activated, true)
    end
  end

  def random_password
    self.password= Digest::SHA1.hexdigest("--#{Time.now.to_s}----")[0,12]
    self.password_confirmation = self.password
  end

  #facebook helpers

  def fb_user_id= fb_id
    # if not already set to another user, then create a new link
    if(!ExternalAuthProvider.where(:provider_type => PROVIDER_FACEBOOK).where.not(:user_id => self.id).empty?)
      ExternalAuthProvider ext = ExternalAuthProvider.new
      ext.user = self
      ext.provider_type = PROVIDER_FACEBOOK
      ext.provider_id = fb_id
    else
      raise "Facebook ID Already Assigned"
    end
  end

  def fb_user_id
    # load providers for user and get id
    e = ExternalAuthProvider.where(:provider_type => PROVIDER_FACEBOOK).where(:user_id => self.id)
    if !e.empty?
      e.first.provider_id
    end
  end

  def User.find_by_fb_user_id fb_id
    # load providers by user
    e = ExternalAuthProvider.where(:provider_type => PROVIDER_FACEBOOK).where(:provider_id => fb_id)
    if !e.empty?
      e.first.user
    end
  end

  def fb_connections
    User.joins(:external_auth_providers).where("provider_id in (?) and provider_type = ?",self.fb_friend_ids, PROVIDER_FACEBOOK)
  end

  def fb_friend_ids

    begin
      graph = Koala::Facebook::API.new(self.fb_access_token)
      results = graph.get_connections('me', 'friends?fields=installed')
    rescue Exception  => e
      results = []
      puts "An error occurred, #{e}"
    end

    #for each id, insert to fb_friends, fb_id, id
    friends = []
    results.each do |result|
       friends << result["id"]
    end

    friends
  end

  def User.with_token token,provider
    if(provider)
      ExternalAuthProvider.user_for_token token,provider
    else
      Token.user_for_token token
    end
  end

  def User.from_fb_token access_token
    graph = Koala::Facebook::API.new(access_token)
    result = graph.get_object("me", :fields => "name,id,email" )
    user = User.new
    user.name = result["name"] || result[:name]
    user.email = result["email"] || result[:email]

    puts "fb: #{user} from #{result}"

    user
  end

  def User.from_external_token access_token, provider
    if provider == PROVIDER_FACEBOOK and access_token
      User.from_fb_token access_token
    end
  end

  def image_url
    if self.fb_user_id
      "http://graph.facebook.com/#{self.fb_user_id}/picture?type=large"
    end
  end

  private


    def encrypt_password      
       self.salt = make_salt if new_record?
       if(self.password && !password.blank?)
        self.encrypted_password = encrypt(self.password)
       end
    end        
    
    def encrypt(string)
       secure_hash("#{salt}--#{string}")
    end  
                
    def make_salt
       secure_hash("#{Time.now.utc}--#{password}")
    end
    
    def secure_hash(string)
       Digest::SHA2.hexdigest(string)
    end         
  
end








