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

  def add_authorization_for_facebook(uid, auth_token)
    add_authorization(:facebook, uid, auth_token)
  end

  def add_authorization_for_twitter(uid, auth_token, auth_secret)
    add_authorization(:twitter, uid, auth_token, auth_secret)
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
      authorization = Authorization.get_facebook_user(auth.uid)
      user = authorization.try(:user)

      if signed_in_resource
        unless signed_in_resource == user
          signed_in_resource.add_authorization_for_facebook(auth.uid, auth.credentials.try(:token))
          signed_in_resource.save
        end

        return signed_in_resource
      end

      unless user
        user = User.create(first_name: auth.extra.raw_info.first_name,
                           last_name: auth.extra.raw_info.last_name,
                           email: auth.info.email,
                           password: Devise.friendly_token[0,20])

        user.add_authorization_for_facebook(auth.uid, auth.credentials.try(:token))
      end
      user
    end
  end
end
