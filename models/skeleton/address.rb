module BlackStack
    module Emails
        class Address < Sequel::Model(:eml_address)
            many_to_one :user, :class=>:'BlackStack::MySaaS::User', :key=>:id_user
            many_to_one :shared, :class=>:'BlackStack::MySaaS::Account', :key=>:shared_id_account        
        end # class Address
    end # Emails
end # BlackStack