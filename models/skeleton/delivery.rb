module BlackStack
    module Emails
        class Delivery < Sequel::Model(:eml_delivery)
            many_to_one :job, :class=>:'BlackStack::Emails::Job', :key=>:id_job
            many_to_one :lead, :class=>:'Leads::FlLead', :key=>:id_lead
        end # class Delivery
    end # Emails
end # BlackStack