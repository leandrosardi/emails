module BlackStack
    module Emails
        class Gmail < Sequel::Model(:eml_gmail)
            many_to_one :user, :class=>:'BlackStack::MySaaS::User', :key=>:id_user
            many_to_one :shared, :class=>:'BlackStack::MySaaS::Account', :key=>:shared_id_account        
        end # class
    end # Emails
end # BlackStack