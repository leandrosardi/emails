module BlackStack
    module Emails
        class UploadLeadsRow < Sequel::Model(:eml_upload_leads_row)
            many_to_one :uploadleadsjob, :class=>:'BlackStack::Emails::UploadLeadsJob', :key=>:id_upload_leads_job
            
            def to_hash
                h = {}
                row = self
                job = row.uploadleadsjob
                vals = row.line.split("\t")
                h['datas'] = []
                i = 0
                vals.each { |val|
                    # 
                    val.strip!
                    # get the mapping definition
                    m = job.uploadleadsmappings.select { |m| m.column == i }.first
                    # map the value to the lead
                    if m.data_type.to_i == BlackStack::LeadsData::TYPE_CUSTOM
                        h['datas'] << { 'type' => m.data_type, 'custom_field_name' => m.custom_field_name, 'value' => val }
                    elsif m.data_type.to_i == BlackStack::LeadsData::TYPE_COMPANY_NAME                       
                        h['company'] = { 'name' => val }
                    elsif (
                        m.data_type.to_i == BlackStack::LeadsData::TYPE_FIRST_NAME ||
                        m.data_type.to_i == BlackStack::LeadsData::TYPE_LAST_NAME
                    )
                        fname_mapping = job.uploadleadsmappings.select { |m| m.data_type.to_i == BlackStack::LeadsData::TYPE_FIRST_NAME }.first
                        lname_mapping = job.uploadleadsmappings.select { |m| m.data_type.to_i == BlackStack::LeadsData::TYPE_LAST_NAME }.first
                        fname = vals[fname_mapping.column]
                        lname = vals[lname_mapping.column]
                        h['name']  = "#{fname} #{lname}"
                    elsif m.data_type.to_i == BlackStack::LeadsData::TYPE_LOCATION
                        h['location']  = val
                    elsif m.data_type.to_i == BlackStack::LeadsData::TYPE_INDUSTRY
                        h['industry'] = val
                    elsif ( 
                        m.data_type.to_i == BlackStack::LeadsData::TYPE_PHONE ||
                        m.data_type.to_i == BlackStack::LeadsData::TYPE_EMAIL ||
                        m.data_type.to_i == BlackStack::LeadsData::TYPE_FACEBOOK ||
                        m.data_type.to_i == BlackStack::LeadsData::TYPE_TWITTER ||
                        m.data_type.to_i == BlackStack::LeadsData::TYPE_LINKEDIN
                    )
                        # create the data
                        h['datas'] << { 'type' => m.data_type, 'value' => val }
                    end
                    # increase the cell counter
                    i += 1
                }
                h
            end # def to_hash

            def verify_email_addresses(log=nil)
                log = BlackStack::DummyLogger.new if log.nil?
                # find all the mappings for an email address
                log.logs "Getting list of email mappings... "
                mappings = self.uploadleadsjob.uploadleadsmappings.select { |m| m.data_type == BlackStack::LeadsData::TYPE_EMAIL }
                log.logf "done (#{mappings.size})"

                mappings.each { |m|
                    # get the email address from the row
                    email = self.line.split("\t")[m.column]
                    # validate the email address
                    log.logs "Validating email address #{email}... "
                    if BlackStack::Emails.verify(email)
                        log.yes
                        return true
                    else
                        log.no
                    end 
                }
                return false
            end

            def import(colcount, l=nil)
                l = BlackStack::DummyLogger.new if l.nil?
                row = self
                job = row.uploadleadsjob
                
                # validate number of columns on each row
                l.logs "Validate number of columns... "
                if row.line.split("\t").size != colcount
                    l.logf "error (#{row.split("\t").size} != #{colcount})"
                    raise 'Invalid number of columns'
                else
                    l.done
                end

                # TODO: validate format of standard fields on each rowverify email address

                # validate the email is verified
                raise 'Invalid email addresses' if !self.verify_email_addresses(l)

                # create the lead object
                # save the lead
                l = BlackStack::Leads::Lead.new(self.to_hash)
                l.id = guid
                l.id_user = row.uploadleadsjob.id_user
                l.public = false # TODO: parametrize this in the form
                l.id_upload_leads_job = row.uploadleadsjob.id
                l.id_upload_leads_row = row.id
                l.save
            end # def import
        end # class UploadLeadsRow
    end # Emails
end # BlackStack