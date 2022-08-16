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
    # active campaigns with jobs pending delivery
    l.logs "Get array of actiive campaigns with jobs pending to delivery... "
    campaigns = BlackStack::Emails::Campaign.pendings
    l.logf "done (#{campaigns.size})"

    # for each campaign
    campaigns.each { |campaign|
        l.logs "Process campaign #{campaign.id}... "
            l.logs "Get next job to deliver... "
            job = campaign.next_job
            l.logf "done (#{job.id})"

            begin
                # start job delivery
                l.logs "Flag delivery start... "
                job.start_delivery
                l.done

                l.logs "Deliver... "
                job.deliver
                l.done

                l.logs "Flag delivery end... "
                job.end_delivery
                l.done
            rescue => e
                l.logf "Error: #{e.message}"

                l.logs "Flag delivery error... "
                job.end_delivery(e.message)
                l.done
            end
        l.done
    }

    l.logs 'Sleeping... '
    sleep(10)
    l.done
  end # while (true)