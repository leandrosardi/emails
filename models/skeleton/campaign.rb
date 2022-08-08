module BlackStack
    module Emails
        class Campaign < Sequel::Model(:eml_campaign)
            many_to_one :user, :class=>:'BlackStack::MySaaS::User', :key=>:id_user
            many_to_one :export, :class=>:'Leads::FlExport', :key=>:id_export      
            one_to_many :jobs, :class=>:'BlackStack::Emails::Job', :key=>:id_campaign
            
            # types of email campaigns: text or html
            TYPE_TEXT = 0
            TYPE_HTML = 1

            # statuses of email campaigns: draft, sent, etc.
            STATUS_DRAFT = 0
            STATUS_SENT = 1
            STATUS_ERROR = 2
        end # class Address
    end # Emails
end # BlackStack