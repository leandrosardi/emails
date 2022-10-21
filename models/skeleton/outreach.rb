module BlackStack
    module Emails
        class Schedule < Sequel::Model(:eml_schedule)
            many_to_one :user, :class=>:'BlackStack::MySaaS::User', :key=>:id_user
            many_to_one :campaign, :class=>:'BlackStack::Emails::Campaign', :key=>:id_campaign
            many_to_one :address, :class=>:'BlackStack::Emails::Address', :key=>:id_address
            
        end # class UploadLeadsJob
    end # Emails
end # BlackStack