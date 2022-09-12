# this example is about sending a test email to a user.

require 'mail'
require 'mysaas'
require 'lib/stubs'
require 'config'
DB = BlackStack::CRDB::connect
require 'lib/skeletons'
require 'extensions/leads/lib/skeletons'
require 'extensions/emails/lib/skeletons'

print 'load user... '
user = BlackStack::Emails::User.where(:email=>'leandro.sardi@expandedventure.com').first
puts "done (#{user.email})"

print 'load the account... ' # account of the user, with the Email module methods.
account = BlackStack::Emails::Account.where(:id=>user.id_account).first
puts "done (#{account.name})"

print 'load address... '
address = account.addresses.first
puts "done (#{address.address})"

print 'load campaign... '
campaign = account.campaigns.first
puts "done (#{campaign.name})"

print 'load a random lead... '
lead = campaign.export.fl_export_leads.first.fl_lead
puts "done (#{lead.name})"

print 'deliver test email... '
address.send_test(campaign, lead, user)
puts "done"

