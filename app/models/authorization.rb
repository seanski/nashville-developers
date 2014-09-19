class Authorization < ActiveRecord::Base
  belongs_to :user

  scope :facebook, -> { for_provider(:facebook) }
  scope :twitter, -> { for_provider(:twitter) }
  scope :linkedin, -> { for_provider(:linkedin) }
  scope :for_provider, ->(provider) { where(provider: provider) }
  scope :with_user, -> { includes(:user) }
  scope :for_user, ->(user) { where(user_id: user) }
  scope :for_uid, ->(provided_id) { where(provided_id: provided_id) }


  class << self
    def get_facebook_user(external_id)
      get_user(:facebook, external_id)
    end

    def get_twitter_user(external_id)
      get_user(:twitter, external_id)
    end

    def get_linkedin_user(external_id)
      get_user(:linkedin, external_id)
    end

    def get_user(provider, external_id)
      for_provider(provider).with_user.for_uid(external_id).first
    end    

    def get_facebook_token_for_user(user)
      facebook.for_user(user).first.try(:token)
    end

    def get_twitter_token_for_user(user)
      twitter.for_user(user).first.try(:token)
    end

    def get_linkedin_token_for_user(user)
      linkedin.for_user(user).first.try(:token)
    end
  end
end
