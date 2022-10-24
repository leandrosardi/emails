module BlackStack
    module Emails
        class FlLead < Leads::FlLead
            # map from an UploadLeadsRow object to this lead
            def map_from_upload_leads_row(row, log=nil)
                log = BlackStack::DummyLogger if log.nil?
                job = row.job
                vals = row.line.split("\t")

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
            end
        end # class FlLead
    end # module Emails
end # module Leads
