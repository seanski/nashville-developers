module OAuth
  OAUTH_YAML = YAML.load_file(Rails.root.join("config/oauth.yml"))[Rails.env]
  module Facebook
    mattr_accessor :config, :app_id, :secret
    begin
      self.config = OAUTH_YAML["facebook"]
      self.app_id = self.config['app_id']
      self.secret = self.config['secret_key']
    rescue Exception => e
      self.config = "NOT SET!"
      self.app_id = "NOT SET!"
      self.secret = "NOT SET!"
    end
  end

  module Twitter
    mattr_accessor :config, :app_id, :secret
    begin
      self.config = OAUTH_YAML["twitter"]
      self.app_id = self.config['app_id']
      self.secret = self.config['secret_key']
    rescue Exception => e
      self.config = "NOT SET!"
      self.app_id = "NOT SET!"
      self.secret = "NOT SET!"
    end
  end
end