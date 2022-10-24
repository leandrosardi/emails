module BlackStack
    module Emails
        class UploadLeadsRow < Sequel::Model(:eml_upload_leads_row)
            many_to_one :uploadleadsjob, :class=>:'BlackStack::Emails::UploadLeadsJob', :key=>:id_upload_leads_job
            
            def verify_email_addresses(log=nil)
                log = BlackStack::DummyLogger.new if log.nil?
                # find all the mappings for an email address
                log.logs "Getting list of email mappings... "
                mappings = self.job.mappings.select { |m| m.data_type == Leads::FlData::TYPE_EMAIL }.all
                log.logf "done (#{mappings.size})"

                mappings.each { |m|
                    # get the email address from the row
                    email = self.split("\t")[m.column_number]
                    # validate the email address
                    log.logs "Validating email address #{email}... "
                    if BlackStack::Emails::FlLead.verify_email_address(email)
                        log.yes
                        return true
                    else
                        log.no
                    end 
                }
                return false
            end

            def import(log=nil)
                log = BlackStack::DummyLogger.new if log.nil?
                row = self
                job = row.uploadleadsjob
                
                # validate number of columns on each row
                l.logs "Validate number of columns... "
                if (row.split("\t").size != colcount)
                    l.logf "error (#{row.split("\t").size} != #{colcount})"
                    raise 'Invalid number of columns'
                end

                # TODO: validate format of standard fields on each rowverify email address

                # validate the email is verified
                raise 'Invalid email address' if !self.verify_email_addresses(l)

                # create the lead object
                l = BlackStack::Emails::FlLead.new
                l.id = guid
                l.id_user = row.job.id_user
                l.public = false # TODO: parametrize this in the form
                l.id_upload_leads_job = row.job.id
                l.id_upload_leads_row = row.id

                # map from eml_upload_leads_row to fl_lead
                l.map_from_upload_leads_row(row, l)

                # save the lead
                l.save
            end # def import
        end # class UploadLeadsRow
    end # Emails
end # BlackStack