module BlackStack
    module Emails
        class Job < Sequel::Model(:eml_job)
            many_to_one :campaign, :class=>:'BlackStack::Emails::Campaign', :key=>:id_campaign
            one_to_many :deliveries, :class=>:'BlackStack::Emails::Delivery', :key=>:id_job
        end # class Address
    end # Emails
end # BlackStack