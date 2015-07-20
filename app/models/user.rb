class User < ActiveRecord::Base
  rolify
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
    :recoverable, :rememberable, :trackable, :validatable, :confirmable
  validates :email, :presence => true
  validates :password, :presence => true, :confirmation => true

  has_one :care_giver_company
  has_one :care_giver
  has_one :care_client


  def active_for_authentication?
    if self.has_role? :admin
         super && approved?
    elsif  self.has_role? :pcga
        super && approved?
    else
      super && approved? && current_pcgc.isActive?
    end
  end

  def current_pcgc
    if self.has_role? :pcg
      self.care_giver.care_giver_company
    elsif self.has_role? :fcg
      self.care_client.care_giver_company
    end
  end

   def confirm!
    super
    # send_reset_password_instructions
  end

  def get_login_validation_alert(password)
    return "Incorrect password!" unless valid_password?(password)
    return "Not Activated yet!" unless active_for_authentication?
  end


end
