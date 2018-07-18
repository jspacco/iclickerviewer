class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :omniauthable, :omniauth_providers => [:google_oauth2]

         def self.new_with_session(params, session)
           super.tap do |user|
             if data = session["devise.google_data"] && session["devise.google_data"]["extra"]["raw_info"]
               user.email = data["email"] if user.email.blank?
             end
           end
         end

         def self.from_omniauth(auth)
           where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
             user.email = auth.info.email
             user.password = Devise.friendly_token[0,20]
             user.name = auth.info.name   # assuming the user model has a name
             user.image = auth.info.image # assuming the user model has an image
             user.verification = 0;
           end
         end

  #before_save { self.email = email.downcase }
  #alidates :name, presence: true, length: { maximum: 50 }
  #validates :username, presence: true, length: { maximum: 50 }
  #VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  #validates :email, presence: true, length: { maximum: 255 },
  #                  format: { with: VALID_EMAIL_REGEX },
  #                  uniqueness: { case_sensitive: false }
  #has_secure_password
  #validates :password, presence: true, length: { minimum: 6 }
end
