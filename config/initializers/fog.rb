CarrierWave.configure do |config|
  config.fog_credentials = {
      :provider               => 'AWS',                        # required
      :aws_access_key_id      => '',                        # required
      :aws_secret_access_key  => '',                        # required
      :region                 => 'us-east-1',                  # optional, defaults to 'us-east-1'
  }
  config.storage = :fog
  config.fog_directory  = 'qmenu'                     # required
  config.fog_public     = true                                   # optional, defaults to true
  config.fog_attributes = {'Cache-Control'=>'max-age=315576000'}  # optional, defaults to {}
end