module BlackStack
    module Emails
        class UploadLeadsJob < Sequel::Model(:eml_upload_leads_job)
            many_to_one :user, :class=>:'BlackStack::MySaaS::User', :key=>:id_user
            many_to_one :export, :class=>:'Leads::FlExport', :key=>:id_export
            one_to_many :uploadleadsmappings, :class=>:'BlackStack::Emails::UploadLeadsJobMapping', :key=>:id_upload_leads_job
            one_to_many :uploadleadsrows, :class=>:'BlackStack::Emails::UploadLeadsJobRows', :key=>:id_upload_leads_job
        end # class UploadLeadsJob
    end # Emails
end # BlackStack