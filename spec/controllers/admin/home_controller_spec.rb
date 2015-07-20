require 'spec_helper'

describe Admin::HomeController do
	describe "GET #index" do
		before :each do
    	admin = FactoryGirl.create(:admin)
			sign_in admin
    end
		context "with params[:sort]" do
			it "params[:sort] is package_type and sort direction is ASC" do
				companies = FactoryGirl.create_list(:care_giver_company, 3)
				get :index, {sort: 'package_type', direction: 'asc'}
				expect(assigns(:care_giver_companies)).to match_array(companies)
			end

			it "params[:sort] is package_type and sort direction is DESC" do
				companies = FactoryGirl.create_list(:care_giver_company, 3)
				get :index, {sort: 'package_type', direction: 'desc'}
				expect(assigns(:care_giver_companies)).to match_array(companies)
			end

			it "params[:sort] is company_type and sort direction is ASC" do
				pending
			end

			it "params[:sort] is company_type and sort direction is DESC" do
				pending
			end


		end


	end

end
