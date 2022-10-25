module BlackStack
    module Emails
        class Tag < Sequel::Model(:eml_tag)
            many_to_one :user, :class=>:'BlackStack::MySaaS::User', :key=>:id_user
        end # class Tag
    end # Emails
end # BlackStack