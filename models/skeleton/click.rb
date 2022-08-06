module BlackStack
    module Emails
        class Click < Sequel::Model(:eml_click)
            many_to_one :delivery, :class=>:'BlackStack::Emails::Delivery', :key=>:id_delivery
            many_to_one :link, :class=>:'BlackStack::Emails::Link', :key=>:id_link
        end # class Click
    end # Emails
end # BlackStack