module BlackStack
    module Emails
        class Schedule < Sequel::Model(:eml_schedule)
            many_to_one :user, :class=>:'BlackStack::MySaaS::User', :key=>:id_user
            many_to_one :campaign, :class=>:'BlackStack::Emails::Campaign', :key=>:id_campaign
            

        end # class UploadLeadsJob
    end # Emails
end # BlackStack