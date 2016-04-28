require 'rails'
require 'json'

module ApplicationHelper

  def check_for_json_content_type
    if request.headers["Content-Type"] == 'application/json'
      request.format = :json
    end
  end

  def get_request_as_json params, param_key
    if request.headers["Content-Type"] == 'application/json'
      params[:format] = 'json'
      request.format = :json
    end

    if params[:format] == 'json'
      if request.body.length > 0
      params = ActiveSupport::JSON.decode(request.body.read)
      params.symbolize_keys
      end
    else
      params[param_key]
    end
  end

  def facebook_logo
       image_tag("facebook_logo.png", :alt => "Facebook login", :class => "logo", :width => 17, :height => 17)
  end

  def base64_url_decode(str)
       str += '=' * (4 - str.length.modulo(4))
       Base64.decode64(str.tr('-_','+/'))
     end


    def encrypt(unencrypted, key)
        c = OpenSSL::Cipher.new("aes-128-cbc")
        c.encrypt
        c.key = key
        e = c.update(unencrypted)
        e << c.final
        return e
    end

    def decrypt2(encrypted_attr, key)
        c = OpenSSL::Cipher::Cipher.new("aes-128-cbc")
        c.decrypt
        c.key = key
        d = c.update(encrypted_attr)
        d << c.final
        return d
    end

    def respond_with_errors(error_hash)
      errors = ''
      error_hash.each do |key, array|
        array.each do |message|
          errors = errors + key.capitalize.to_s + ' ' + message + '. '
        end
      end
      response.status = 400

      {:success => false, :result => errors }

    end
end
