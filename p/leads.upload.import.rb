# MySaaS Emails - Import Ingested CSV of Leads
# Copyright (C) 2022 ExpandedVenture, LLC.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# You may not use this file except in compliance with the License.
#
# Authors: Leandro Daniel Sardi (https://github.com/leandrosardi)
#
# This process insert rows into the table eml_upload_leads_row.
# 

# load gem and connect database
require 'mysaas'
require 'lib/stubs'
require 'config'
require 'version'
DB = BlackStack::CRDB::connect
require 'lib/skeletons'

# TODO: emails extension should require leads extension as a dependency
require 'extensions/leads/lib/skeletons'
require 'extensions/leads/main'

require 'extensions/emails/lib/skeletons'
require 'extensions/emails/main'

# add required extensions
BlackStack::Extensions.append :i2p
BlackStack::Extensions.append :leads
BlackStack::Extensions.append :emails

l = BlackStack::LocalLogger.new('./import.ingest.log')

while (true)
    # active campaigns with jobs pending delivery
    l.logs "Get array of eml_upload_leads_row pending of import... "
    rows = BlackStack::Emails::UploadLeadsRow.where(:import_end_time => nil).all
    l.logf "done (#{rows.size})"

    # number of columns that each line must have
    l.logs "Get number of columns that each line must have... "
    colcount = rows[0].split("\t").size
    l.logf "done (#{colcount})"

    # for each row
    rows.each { |row|
        # flag start time
        l.logs "Flag start time... "
        row.import_start_time = now
        row.save
        l.done

        begin
            # import row
            l.logs "Import row... "
            row.import(l)
            l.done

            # update eml_upload_leads_job
            # flag start time
            l.logs "Flag end time... "
            row.import_success = true
            row.import_error_description = nil
            row.import_end_time = now
            row.save
            l.done    
        rescue => e
            l.logf "error (#{e.message})"

            row.import_success = false
            row.import_error_description = e.message
            row.import_end_time = now
            row.save
        end
    }

    l.logs 'Sleeping... '
    sleep(10)
    l.done
  end # while (true)