module BlackStack
    module Emails
        class Link < Sequel::Model(:eml_link)
            many_to_one :campaign, :class=>:'BlackStack::Emails::Campaign', :key=>:id_campaign
        end # class Address
    end # Emails
end # BlackStack