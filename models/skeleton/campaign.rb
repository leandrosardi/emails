module BlackStack
    module Emails
        class Campaign < Sequel::Model(:eml_campaign)
            many_to_one :user, :class=>:'BlackStack::MySaaS::User', :key=>:id_user
            many_to_one :export, :class=>:'Leads::FlExport', :key=>:id_export      
            one_to_many :jobs, :class=>:'BlackStack::Emails::Job', :key=>:id_campaign      
        end # class Address
    end # Emails
end # BlackStack