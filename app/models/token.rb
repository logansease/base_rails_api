# == Schema Information
#
# Table name: tokens
#
#  id              :integer         not null, primary key
#  hashed_access_token    :string(255)     not null
#  hashed_refresh_token   :string(255)     not null
#  expires_on      :date            not null
#  refresh_by      :date            not null
#  user_id         :integer         not null

class Token < ActiveRecord::Base
  attr_accessible :hashed_refresh_token, :hashed_access_token, :expires_on, :user_id, :refresh_by, :access_token, :provider
  attr_accessor :refresh_token, :access_token
  belongs_to :user

  validates_presence_of [:hashed_access_token, :user_id, :expires_on,]
  validates_presence_of [:hashed_refresh_token, :refresh_by], :unless => :provider

  before_validation :hash_tokens

  def Token.generate(user)
    t = Token.new
    t.user = user
    t.access_token = SecureRandom.hex
    t.refresh_token = SecureRandom.hex
    t.expires_on = Time.zone.now + 7.days
    t.refresh_by = Time.zone.now + 30.days
    t.save!
    t
  end

  def hash_tokens
    self.hashed_access_token = Digest::SHA2.hexdigest(self.access_token) if access_token
    self.hashed_refresh_token = Digest::SHA2.hexdigest(self.refresh_token) if refresh_token

    #ensure expires on is set, or within 7 days. If not, set to 7 days
    if !self.expires_on or self.expires_on > Time.zone.now + 7.days
      self.expires_on = Time.zone.now + 7.days
    end

  end

  def Token.refresh(refresh_token)

    hashed_refresh_token = Digest::SHA2.hexdigest(refresh_token)
    token = Token.find_by_hashed_refresh_token(hashed_refresh_token)
    if token and token.refresh_by > Time.zone.now

      #TODO for social tokens we need to call the specific provider to refresh the token
      user = token.user
      token.delete
      token = Token.generate(user)
      token
    else
      nil
    end
  end

  def Token.user_for_stored_external_token(access_token, provider)

      hashed_access_token = Digest::SHA2.hexdigest(access_token)
      token = Token.find_by( :hashed_access_token => hashed_access_token, :provider => provider)
      if token and token.expires_on > Time.zone.now
        token.user
      else
        nil
      end

  end

  def Token.user_for_token(access_token)
    hashed_access_token = Digest::SHA2.hexdigest(access_token)
    token = Token.find_by(:hashed_access_token =>hashed_access_token, :provider => nil)
    if token and token.expires_on > Time.zone.now
      token.user
    else
      nil
    end
  end

end

