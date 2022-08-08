module BlackStack
    module Emails
        class Unsubscribe < Sequel::Model(:eml_unsubscribe)
            many_to_one :delivery, :class=>:'BlackStack::Emails::Delivery', :key=>:id_delivery
        end # class Unsubscribe
    end # Emails
end # BlackStack