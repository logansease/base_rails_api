class ExternalAuthProvider < ActiveRecord::Base

  belongs_to :user


  def ExternalAuthProvider.fb_id_for fb_token
    #call graph api /me/fields=id, return id
    request_path = "https://graph.facebook.com/v2.6/me?fields=id&access_token=#{fb_token}"

      response = open(request_path).read
      json = JSON.parse(response)

      #read id from response
      json["id"]
  end

  def ExternalAuthProvider.external_id_for_token(access_token, provider)
    if provider == PROVIDER_FACEBOOK
      ExternalAuthProvider.fb_id_for access_token
    end
  end

  def ExternalAuthProvider.user_for_token token,provider

    #first look for the given token and provider combo, where not expired.
    user = Token.user_for_stored_external_token token, provider

    #if not found then find the external id for the token, then load the record for that id and return the user.
    ## and then add the token
    if !user
      provider_id = ExternalAuthProvider.external_id_for_token token,provider
      provider = ExternalAuthProvider.find_by(:provider_id => provider_id, :provider_type => provider)
      if provider
        user = provider.user
        new_token = Token.new
        new_token.access_token = token
        new_token.provider = provider
        new_token.user = user
        new_token.save!
      end

    end

    #return the user
    user

  end

end