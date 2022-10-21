module BlackStack
    module Emails
        class UploadLeadsJob < Sequel::Model(:eml_upload_leads_job)
            many_to_one :user, :class=>:'BlackStack::MySaaS::User', :key=>:id_user
            many_to_one :export, :class=>:'Leads::FlExport', :key=>:id_export
            

        end # class UploadLeadsJob
    end # Emails
end # BlackStack