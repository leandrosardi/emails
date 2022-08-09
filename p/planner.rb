# load gem and connect database
require 'mysaas'
require 'lib/stubs'
require 'config'
require 'version'
DB = BlackStack::CRDB::connect
require 'lib/skeletons'

require 'extensions/leads/lib/skeletons'
require 'extensions/leads/main'

require 'extensions/emails/lib/skeletons'
require 'extensions/emails/main'

BlackStack::Emails::Campaign.where(
    :status=>BlackStack::Emails::Campaign::STATUS_ON, 
    :planning_start_time=>nil
).each { |g|

    puts "Campaign #{g.id} is ON and has no planning_start_time"

    n = g.export.fl_export_leads.size
    puts "Campaign #{g.id} has #{n} leads"

    u = BlackStack::Emails::User.where(:id_user=>g.id_user).first
    a = BlackStack::Emails::Account.where(:id=>u.id_account).first

    g.export.fl_export_leads.each { |o|
        puts

        l = o.fl_lead
        puts "Lead: #{l.name}"
        puts g.merged_body(l)

    }
}


