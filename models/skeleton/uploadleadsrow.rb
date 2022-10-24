module BlackStack
    module Emails
        class UploadLeadsRow < Sequel::Model(:eml_upload_leads_row)
            many_to_one :uploadleadsjob, :class=>:'BlackStack::Emails::UploadLeadsJob', :key=>:id_upload_leads_job
            
        end # class UploadLeadsJob
    end # Emails
end # BlackStack