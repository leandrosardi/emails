module BlackStack
    module Emails
        class UploadLeadsRow < Sequel::Model(:eml_upload_leads_row)
            many_to_one :uploadleadsjob, :class=>:'BlackStack::Emails::UploadLeadsJob', :key=>:id_upload_leads_job
            
            def to_hash
                ret = {}
                row = self
                job = row.job
                vals = row.line.split("\t")
                ret['datas'] = []
                i = 0
                vals.each { |val|
                    # get the mapping definition
                    m = job.mappings.select { |m| m.column == i }.first
                    # map the value to the lead
                    if m.data_type.to_i == Leads::FlData::TYPE_CUSTOM
                        # create the data
                        d = Leads::FlData.new
                        d.id = guid
                        d.id_lead = self.id
                        d.type = m.data_type
                        d.value = val
                        d.custom_field_name = m.custom_field_name
                        d.save
                    elsif m.data_type.to_i == Leads::FlData::TYPE_COMPANY_NAME                       
                        self.stat_company_name = val
                    elsif (
                        m.data_type.to_i == Leads::FlData::TYPE_FIRST_NAME ||
                        m.data_type.to_i == Leads::FlData::TYPE_LAST_NAME
                    )
                        fname_mapping = job.mappings.select { |m| m.data_type.to_i == Leads::FlData::TYPE_FIRST_NAME }.first
                        lname_mapping = job.mappings.select { |m| m.data_type.to_i == Leads::FlData::TYPE_LAST_NAME }.first
                        fname = vals[fname_mapping.column]
                        lname = vals[lname_mapping.column]
                        self.name = "#{fname} #{lname}"
                    elsif m.data_type.to_i == Leads::FlData::TYPE_LOCATION
                        self.stat_location_name = val
                    elsif m.data_type.to_i == Leads::FlData::TYPE_INDUSTRY
                        self.stat_industry_name = val
                    elsif ( 
                        m.data_type.to_i == Leads::FlData::TYPE_PHONE ||
                        m.data_type.to_i == Leads::FlData::TYPE_EMAIL ||
                        m.data_type.to_i == Leads::FlData::TYPE_FACEBOOK ||
                        m.data_type.to_i == Leads::FlData::TYPE_TWITTER ||
                        m.data_type.to_i == Leads::FlData::TYPE_LINKEDIN
                    )
                        # create the data
                        d = Leads::FlData.new
                        d.id = guid
                        d.id_lead = self.id
                        d.type = m.data_type
                        d.value = val
                        d.save
                    end
                    # increase the cell counter
                    i += 1
                }
                ret 
            end # def to_hash

            def verify_email_addresses(log=nil)
                log = BlackStack::DummyLogger.new if log.nil?
                # find all the mappings for an email address
                log.logs "Getting list of email mappings... "
                mappings = self.uploadleadsjob.uploadleadsmappings.select { |m| m.data_type == 20 } # Leads::FlData::TYPE_EMAIL }.all
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
                end

                # TODO: validate format of standard fields on each rowverify email address

                # validate the email is verified
                raise 'Invalid email addresses' if !self.verify_email_addresses(l)

                # create the lead object
                l = BlackStack::Emails::FlLead.new(self.to_hash)
                l.id = guid
                l.id_user = row.uploadleadsjob.id_user
                l.public = false # TODO: parametrize this in the form
                l.id_upload_leads_job = row.uploadleadsjob.id
                l.id_upload_leads_row = row.id

                # map from eml_upload_leads_row to fl_lead
                l.map_from_upload_leads_row(row, l)

                # save the lead
                l.save
            end # def import
        end # class UploadLeadsRow
    end # Emails
end # BlackStack