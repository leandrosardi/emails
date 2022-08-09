module BlackStack
    module Emails
        class Address < Sequel::Model(:eml_address)
            many_to_one :user, :class=>:'BlackStack::MySaaS::User', :key=>:id_user
            many_to_one :shared, :class=>:'BlackStack::MySaaS::Account', :key=>:shared_id_account
            
            # types
            TYPE_GMAIL = 0
            TYPE_YAHOO = 1
            TYPE_HOTMAIL = 2
            
        end # class Address
    end # Emails
end # BlackStack