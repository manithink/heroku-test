module AuthenticateMacro
  include Warden::Test::Helpers

  # for use in request specs
  def sign_in_as_a_user user
    login_as user
  end
end