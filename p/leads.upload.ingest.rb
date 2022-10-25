# MySaaS Emails - Ingest Uploaded CSV of Leads
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

l = BlackStack::LocalLogger.new('./leads.upload.ingest.log')

while (true)
    # active jobs, pending pending of ingestion
    l.logs "Get array of actiive eml_upload_leads_job pending of ingestion... "
    jobs = BlackStack::Emails::UploadLeadsJob.where(:ingest_end_time => nil).all
    l.logf "done (#{jobs.size})"

    # for each job
    jobs.each { |j|
        # 
        j.ingest_start_time = now
        j.save
        # 
        j.ingest(l)
        # 
        j.ingest_end_time = now
        j.save
    }

    l.logs 'Sleeping... '
    sleep(10)
    l.done
  end # while (true)