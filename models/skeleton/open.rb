module BlackStack
    module Emails
        class Open < Sequel::Model(:eml_open)
            many_to_one :delivery, :class=>:'BlackStack::Emails::Delivery', :key=>:id_delivery
        end # class Open
    end # Emails
end # BlackStack