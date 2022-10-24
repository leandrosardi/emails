module BlackStack
    module Emails
        class UploadLeadsJob < Sequel::Model(:eml_upload_leads_job)
            many_to_one :user, :class=>:'BlackStack::MySaaS::User', :key=>:id_user
            many_to_one :export, :class=>:'Leads::FlExport', :key=>:id_export
            one_to_many :uploadleadsmappings, :class=>:'BlackStack::Emails::UploadLeadsMapping', :key=>:id_upload_leads_job
            one_to_many :uploadleadsrows, :class=>:'BlackStack::Emails::UploadLeadsRow', :key=>:id_upload_leads_job

            # return true if exists at least one row in the table `eml_upload_leads_row` with the same id_upload_leads_job
            def ingested?
                return true if DB["select count(*) as c from eml_upload_leads_row where id_upload_leads_job = '#{self.id.to_guid}'"].first[:c] > 0
                return false
            end

            # insert a records in the table `eml_upload_leads_row`
            # this function cannot be called by more than one process at the same time.
            def ingest(log=nil)
                log = BlackStack::DummyLogger.new if log.nil?
                job = self

                # verify the file has not been already ingested.
                raise 'Job already ingested (totally or partially)' if job.ingested?

                # TODO: vaidate the file has not more than `batchsize` lines.

                # TODO: Do work on the remaining files & directories
                crdbpath = '........' # self.name.gsub(BlackStack::Omnivore.crdb_node_folder, '')    

                # import all files to the database,
                # making the 3 queries below in a single transaction.
                # update the id, id_file of all lines
                log.logs "Ingesting file..."
                DB.execute("
                    truncate table eml_upload_leads_row_aux;
                    import into eml_upload_leads_row_aux (\"line\") DELIMITED data('nodelocal://1/#{crdbpath.to_sql}') with fields_terminated_by=E'\\b', fields_enclosed_by='';
                    update eml_upload_leads_row_aux set id=gen_random_uuid(), id_upload_leads_job='#{self.id.to_sql}';
                    insert into eml_upload_leads_row (id, id_upload_leads_job, \"line\") select id, id_file, value from eml_upload_leads_row_aux;
                    truncate table eml_upload_leads_row_aux;
                ")
                log.done

                # update the number of each line
                log.logs "Updating row numbers (may take some minutes)... "
                rownum = 0
                DB["select id from eml_upload_leads_row where \"line_number\" is null and id_upload_leads_job = '#{self.id.to_guid}'"].all { |r|
                    DB["update eml_upload_leads_row set \"line_number\" = #{rownum.to_s} where id='#{r[:id]}' and \"number\" is null limit 1"].all
                    rownum += 1
                    #print '.'
                }
                log.done
            end # def ingest
        end # class UploadLeadsJob
    end # Emails
end # BlackStack