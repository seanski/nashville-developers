class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :omniauthable

  searchkick word_start: [:skills, :roles, :first_name, :last_name, :email], suggest: [:skills]

  has_many :authorizations
  has_many :user_roles
  has_many :roles, through: :user_roles
  has_many :user_skills
  has_many :skills, through: :user_skills

  scope :non_admin, -> { joins(:roles).where.not(roles: { name: 'admin' }) }
  scope :admin, -> { joins(:roles).where(roles: { name: 'admin'}) }

  scope :by_search, ->(term) {
    query = %Q(
               lower(users.first_name) LIKE :query
               OR lower(users.last_name) LIKE :query
               OR lower(users.email) LIKE :query
               OR lower(roles.name) LIKE :query
               OR lower(skills.name) LIKE :query
              )

    joins('LEFT JOIN user_roles ON user_roles.user_id = users.id')
    .joins('LEFT JOIN roles ON roles.id = user_roles.role_id')
    .joins('LEFT JOIN user_skills ON user_skills.user_id = users.id')
    .joins('LEFT JOIN skills ON skills.id = user_skills.skill_id')
    .where(query, { query: "%#{term.downcase}%" }).uniq
  }

  scope :roleless, -> {
    joins('LEFT JOIN user_roles ON user_roles.user_id = users.id')
    .joins('LEFT JOIN roles ON roles.id = user_roles.role_id')
    .where(roles: { name: nil })
  }

  scope :staff, -> { joins(:roles).where('roles.name = ? OR roles.name = ?', 'staff', 'admin') }

  def full_name
    "#{first_name} #{last_name}"
  end

  def facebook_token
    @facebook_token ||= self.authorizations.get_facebook_token_for_user(self)
  end

  def twitter_token
    @twitter_token ||= self.authorizations.get_twitter_token_for_user(self)
  end

  def linkedin_token
    @linkedin_token ||= self.authorizations.get_linkedin_token_for_user(self)
  end

  def add_authorization_for_facebook(uid, auth_token)
    add_authorization(:facebook, uid, auth_token)
  end

  def add_authorization_for_twitter(uid, auth_token, auth_secret)
    add_authorization(:twitter, uid, auth_token, auth_secret)
  end

  def add_authorization_for_linkedin(uid, auth_token)
    add_authorization(:linkedin, uid, auth_token)
  end

  def add_authorization(provider, uid, auth_token, auth_secret = nil)
    self.authorizations.build(provider: provider, provided_id: uid, token: auth_token, secret: auth_secret)
  end

  def has_role?(role_name)
    roles.select { |role| role.name == role_name }.any?
  end

  def search_data
    {
      first_name: first_name,
      last_name: last_name,
      email: email,
      skills: skills.map(&:name),
      roles: roles.map(&:name)
    }
  end

  class << self
    def find_or_create_by_facebook_oauth(auth, signed_in_resource = nil)
      find_or_create_by_oauth(:facebook, auth, signed_in_resource) do |auth|
        {
          first_name: auth.extra.raw_info.first_name,
          last_name: auth.extra.raw_info.last_name,
          email: auth.info.email
        }
      end
    end

    def find_or_create_by_linkedin_oauth(auth, signed_in_resource = nil)
      find_or_create_by_oauth(:linkedin, auth, signed_in_resource) do |auth|
        {
          first_name: auth.extra.raw_info.first_name,
          last_name: auth.extra.raw_info.last_name,
          email: auth.info.email
        }
      end
    end


    def find_or_create_by_twitter_oauth(auth, signed_in_resource = nil)
      find_or_create_by_oauth(:twitter, auth, signed_in_resource) do |auth|
        first_name, last_name = auth.info.name.split(" ")

        { 
          first_name: first_name,
          last_name: last_name,
          email: "random#{rand(5000)}@random.com"
        }
      end
    end

    protected

    def find_or_create_by_oauth(provider, auth, signed_in_resource = nil, &block)
      authorization = Authorization.get_user(provider, auth.uid)
      user = authorization.try(:user)

      if signed_in_resource
        unless signed_in_resource == user
          signed_in_resource.add_authorization(provider, auth.uid, auth.credentials.try(:token))
          signed_in_resource.save
        end

        return signed_in_resource
      end

      unless user
        if user = User.where(email: auth.info.email).first
          user.add_authorization(provider, auth.uid, auth.credentials.try(:token))
        end
      end

      unless user
        params = block.call(auth)
        params.merge! password: Devise.friendly_token[0, 20]
        user = User.create(params)

        user.add_authorization(provider, auth.uid, auth.credentials.try(:token))
      end
      
      user
    end    
  end
end
