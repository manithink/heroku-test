require 'spec_helper'

describe CareGiverCompany do

  describe "validation" do
    context "Company Name validation" do
      it "has a valid factory" do
        FactoryGirl.build(:care_giver_company).should be_valid
      end

      it "is invalid without a company_name" do
        FactoryGirl.build(:care_giver_company, company_name: "").should_not be_valid
      end

      it "is invalid with a company_name 'Farcare'" do
        FactoryGirl.build(:care_giver_company, company_name: "Farcare").should_not be_valid
      end

      it "is invalid without a company_name length less than 3 chars" do
        FactoryGirl.build(:care_giver_company, company_name: "co").should_not be_valid
      end

      it "is invalid without a company_name length greater than 40 chars" do
        FactoryGirl.build(:care_giver_company, company_name: "GHSDFHGSFGGHGGGJHGJHGJHGSHDFHSGFSJHDGFLJH").should_not be_valid
      end
    end
  end

  it "is invalid without pcgc_country" do
    FactoryGirl.build(:care_giver_company, pcgc_country: "").should_not be_valid
  end

  it "is not valid without pcgc_state" do
    FactoryGirl.build(:care_giver_company, pcgc_state: "").should_not be_valid
  end

  it "is not valid without address_1" do
    FactoryGirl.build(:care_giver_company, address_1: "").should_not be_valid
  end

  it "is not valid without city" do
    FactoryGirl.build(:care_giver_company, city: "").should_not be_valid
  end

  it "is not valid without zip" do
    FactoryGirl.build(:care_giver_company, zip: "").should_not be_valid
  end

  it "is not valid without phone" do
    FactoryGirl.build(:care_giver_company, phone: "").should_not be_valid
  end

  it "is not valid without a numeric phone no" do
    FactoryGirl.build(:care_giver_company, phone: "dd").should_not be_valid
  end

  it "is not valid without a phone no with less than 10 chars" do
    FactoryGirl.build(:care_giver_company, phone: "5546546").should_not be_valid
  end

  it "is not valid with fax with chars" do
    FactoryGirl.build(:care_giver_company, fax: "ddd").should_not be_valid
  end

  it "is not valid year_founded with non numeric chars" do
    FactoryGirl.build(:care_giver_company, year_founded: "df").should_not be_valid
  end

  it "is not valid without year_founded without 4 numbers" do
    FactoryGirl.build(:care_giver_company, year_founded: "454555").should_not be_valid
  end

  it "is not valid without admin_first_name" do
    FactoryGirl.build(:care_giver_company, admin_first_name: "").should_not be_valid
  end

  it "is not valid without admin_last_name" do
    FactoryGirl.build(:care_giver_company, admin_last_name: "").should_not be_valid
  end

  it "is not valid without admin_phone" do
    FactoryGirl.build(:care_giver_company, admin_phone: "").should_not be_valid
  end

  it "is not valid without numeric admin_phone" do
    FactoryGirl.build(:care_giver_company, admin_phone: "654sdsd").should_not be_valid
  end

  it "is not valid without admin_phone with 10 or more numbers" do
    FactoryGirl.build(:care_giver_company, admin_phone: "65466").should_not be_valid
  end

  it "is not valid without package_type_id" do
    FactoryGirl.build(:care_giver_company,package_type_id: "").should_not be_valid
  end

  it "is not valid without subscription_type_id" do
    FactoryGirl.build(:care_giver_company,subscription_type_id: "").should_not be_valid
  end

  it "is not valid without company_type_id" do
    FactoryGirl.build(:care_giver_company,company_type_id: "").should_not be_valid
  end

  it "is not valid without valid website" do
    FactoryGirl.build(:care_giver_company,website: "fhgshfgs").should_not be_valid
  end

  it "is not valid without valid alt_email" do
    FactoryGirl.build(:care_giver_company,alt_email: "fhgshfgs@").should_not be_valid
  end

end
