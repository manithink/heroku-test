require 'spec_helper'

describe 'User' do
  before { visit new_user_session_path }
  subject { page }

  describe 'admin should be able to login' do
    before do
      user = FactoryGirl.create(:admin)
      fill_in 'login_email', with: user.email
      fill_in 'user_password', with: user.password
      click_on 'Login'
    end
    it { current_path.should == admin_home_index_path}
  end

  describe 'pcga should be able to login' do
    before do
      user = FactoryGirl.create (:pcga)
      fill_in 'login_email', with: user.email
      fill_in 'user_password', with: user.password
      click_on 'Login'
    end
    it { current_path.should == pcga_home_index_path}
    it { expect(page).to have_content("Signed in successfully.") }
  end

  describe 'pcg should be able to login' do
    before do
      user = FactoryGirl.create (:pcg)
      fill_in 'login_email', with: user.email
      fill_in 'user_password', with: user.password
      click_on 'Login'
    end
    it { current_path.should == pcg_home_index_path}
  end

  describe 'fcg should be able to login' do
    before do
      user = FactoryGirl.create (:fcg)
      fill_in 'login_email', with: user.email
      fill_in 'user_password', with: user.password
      click_on 'Login'
   	end
    it { current_path.should == fcg_home_index_path}
  end

  describe 'should not be able to login with wrong password' do
   	before do
      user = FactoryGirl.create (:user)
      fill_in 'login_email', with: user.email
      fill_in 'user_password', with: "invalidpassword"
      click_on 'Login'
    end
    it { should have_content('Invalid email or password.')}
  end

end