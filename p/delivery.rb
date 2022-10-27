# MySaaS Emails - Delivery
# Copyright (C) 2022 ExpandedVenture, LLC.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# You may not use this file except in compliance with the License.
#
# Authors: Leandro Daniel Sardi (https://github.com/leandrosardi)
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

l = BlackStack::LocalLogger.new('./delivery.log')

while (true)

    # get the while list of addresses (shared and owned by the user)
    addresses = BlackStack::Emails::Address.where(:delete_time=>nil).all

    # itereate each address, looking for the next deliver to process
    addresses.each do |address|
        # get the next job to deliver
        job = address.next_job_to_deliver
        next if job.nil?

        # deliver the job
        job.deliver
    end

    # sleep for 5 seconds
    sleep 5

end # while (true)