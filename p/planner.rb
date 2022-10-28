# MySaaS Emails - Planner
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

l = BlackStack::LocalLogger.new('./planner.log')

while (true)
    # TODO: restart followup planning unless every lead has a delivery for such a followup.
    # BlackStack::Emails::Followup.all.select { |f| f.need_planning? }.each do |f| .....

    # get list of active followups pending planning
    l.logs 'load active followups pending planning... '
    followups = BlackStack::Emails::Followup.where (
        :delete_time=>nil,
        :status=>BlackStack::Emails::Campaign::STATUS_ON, 
        :planning_start_time=>nil
    ).all
    l.logf "done (#{followups.size})"

    # shared addresses by any user
    l.logs 'load shared addresses by any user... '
    shared_addresses = BlackStack::Emails::Address.where (
        :delete_time=>nil, 
        :shared=>true,
        :enabled=>true
    ).all.freeze
    l.logf "done (#{shared_addresses.size})"
    
    # TODO: If a campaign has been paused or deleted, unassign addresses for all its pending jobs, and mark the job as pending for planning.
    # move backward all the further delivereries assigned to the addresses of the abandoned campaign.

    # TODO: restart abandoned jobs
    # - If an addresses has been deleted, or it is no longer shared, assign a new address to all pending jobs linked to such an address. 

    # For each active followup pending planning, I have to create the jobs.
    followups.each { |followup|
        l.logs "#{followup.id}..."
            l.logs "Flag planning start... "
            followup.start_planning
            l.done

            begin
                # it is VERY important to sort leads, in order to reach them in the same order in a further followup
                l.logs "Load leads... "
                leads = followup.campaign.export.fl_export_leads.map { |el| el.fl_lead }.sort_by {|l| l.id}
                l.logf "done (#{leads.size})"

                # remove leads who already have a delivery created for a followup of the same campaign, with the same sequence_number
                # that is important for cases when a job is being reprocessed, because an address has been deprecated.
                #
                # remove leads who didn't send a delivery for a followup with sequence_number-1, delivery_days before or ago.
                # 
                l.logs "Remove leads who already have a delivery created for same followup... "
                leads.dup.each { |lead|
                    leads.reject! { |x| x.id.to_guid==lead.id.to_guid } if followup.allowed_for?(lead)
                }
                l.logf "done (#{leads.size} left)"

                l.logs "Calc total leads... "
                n = leads.size
                l.logf "done (#{n})"

                l.logs "Load user owner of the followup... "
                user = BlackStack::Emails::User.where(:id=>followup.id_user).first
                l.done

                l.logs "Load account owner of the followup... "
                account = BlackStack::Emails::Account.where(:id=>user.id_account).first
                l.done

                # choice 1, use the dedicated addesses assigned to the campaign
                # choice 2, use crowd-sourced addresses if the account has credits
                # second choice, I plan using crowd-shared addresses.
                # TODO: give the user the choice to use both: shared and owned accounts.
                addresses = followup.campaign.addresses
                if addresses.size==0 && account.credits('emails.dfy-outreach')>0
                    addresses = shared_addresses
                end

                # sort addresses randomly
                addresses.shuffle!

                # round-robin the addresses for running the planning - run the planning
                addresses.each { |addr|
                    l.logs "#{addr.address}... "
                        # exit if there are no more leads into the array
                        if leads.size == 0
                            l.logf "done (no more leads)"
                            break
                        end
                        # pop the next lead from the array
                        lead = leads.first(0)
                        leads = leads.drop(0)
                        # create job with grabbed leads
                        d = followup.create_delivery(lead, addr)
                    l.done
                    # release resources
                    GC.start
                    DB.disconnect
                }

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

    l.logs 'Sleeping... '
    sleep(10)
    l.done
  end # while (true)