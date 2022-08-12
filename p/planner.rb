# MySaaS Emails - Planner
# Copyright (C) 2022 ExpandedVenture, LLC.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# You may not use this file except in compliance with the License.
#
# Authors: Leandro Daniel Sardi (https://github.com/leandrosardi)
#
# Use Cases:
# - Same address can't deliver more than X emails per day. Such a limit is defined on its field `max_deliveries_per_day`.
# - Each `eml_job` record has one and only one address assigned.
# - If an addresses has been deleted, or it is no longer shared, assign a new address to all pending jobs linked to such an address. 
# - If a campaign has been paused or deleted, unassign addresses for all its pending jobs, and mark the job as pending for planning.
# 
# - TODO: Same Lead cannot receive more than 1 email every Y days. Such a limit is defined on the parameters BlackStack::Emails::lead_rest_days.
# - TODO: The account owner of the campaign, can use the pool of shared addresses if he has `email` credits.
# - TODO: If the account owner of the campaign has no `email` credits, he can use his own addresses only.

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

BlackStack::Extensions.add_storage_subfolders

l = BlackStack::LocalLogger.new('./planner.log')

# active campaigns pending planning
l.logs 'load active campaigns pending planning... '
campaigns = BlackStack::Emails::Campaign.where(
    :delete_time=>nil,
    :status=>BlackStack::Emails::Campaign::STATUS_ON, 
    :planning_start_time=>nil
).all
l.logf "done (#{campaigns.size})"

# shared addresses by any user
l.logs 'load shared addresses by any user... '
shared_addresses = BlackStack::Emails::Address.where(
    :delete_time=>nil, 
    :shared=>true
).all.freeze
l.logf "done (#{shared_addresses.size})"

# TODO: Use case: If a campaign has been paused or deleted, unassign addresses for all its pending jobs, and mark the job as pending for planning.

# TODO: restart abandoned jobs
# If an addresses has been deleted, or it is no longer shared, assign a new address to all pending jobs linked to such an address. 

# Use case: Each `eml_job` record has one and only one address assigned.
# For each active campaign pending planning, I have to create the jobs.
campaigns.each { |campaign|
    l.logs "#{campaign.id}..."
        l.logs "Flag planning start... "
        campaign.start_planning
        l.done

        begin
            # it is VERY important to sort leads, in order to reach them in the same order in a further followup
            l.logs "Load leads... "
            leads = campaign.export.fl_export_leads.map { |el| el.fl_lead }.sort_by {|l| l.id}
            l.logf "done (#{leads.size})"

            # remove leads who already have a delivery created for this campaign
            # that is important for cases when a job is being reprocessed, because an address has been deprecated.
            l.logs "Remove leads who already have a delivery created for this campaign... "
            leads.dup.each { |lead|
                leads.reject! { |x| x.id.to_guid==lead.id.to_guid } if campaign.include?(lead)
            }
            l.logf "done (#{leads.size} left)"

            l.logs "Calc total leads... "
            n = leads.size
            l.logf "done (#{n})"

            l.logs "Load campaign user... "
            user = BlackStack::Emails::User.where(:id=>campaign.id_user).first
            l.done

            l.logs "Load campaign account... "
            account = BlackStack::Emails::Account.where(:id=>user.id_account).first
            l.done

            # first choice, I plan using dedicated addresses of the account owner of the campaign.
            # second choice, I plan using crowd-shared addresses.
            # TODO: give the user the choice to use both: shared and owned accounts.
            addresses = account.addresses
            addresses = shared_addresses if addresses.size == 0
            
            # round-robin the accounts for running the planning - run the planning
            while leads.size > 0
                addresses.each { |addr|
                    l.logs "#{addr.address}... "
                        # grab the first leads and drop them from the array
                        i = addr.max_deliveries_per_day
                        my_leads = leads.first(i)
                        leads = leads.drop(i)
                        # exit if there are no more leads into the array
                        break if my_leads.size == 0
                        # create job with grabbed leads
                        campaign.create_jobs(my_leads, addr)
                    l.logf "done (#{my_leads.size.to_s})"
                    # release resources
                    GC.start
                    DB.disconnect
                }
            end # while

            l.logs "Flag planning end... "
            campaign.end_planning
            l.done
        rescue Exception => e
            l.logf "Error: #{e.message}"

            l.logs "Flag planning error... "
            campaign.end_planning(e.message)
            l.done
        end
    l.done
}


