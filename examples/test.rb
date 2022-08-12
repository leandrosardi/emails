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

l = BlackStack::LocalLogger.new('./test.log')

# map parameters
u = BlackStack::Emails::User.where(:email=>'leandro.sardi@expandedventure.com').first
a = BlackStack::Emails::Account.where(:id=>u.id_account).first
c = a.campaigns.first

# choose a random lead
l.logs "Choose a lead... "
lead = c.export.fl_export_leads.sample.fl_lead
l.logf "done (#{lead.name})"

# choose a random address
# first choice: own addresses
# second choice: shared addresses
l.logs "Choose an address... "
address = a.addresses.shuffle.first
address = BlackStack::Emails::Address.where(:delete_time=>nil, :shared=>true).all.shuffle.first if address.nil?
address = BlackStack::Emails::GMail.where(:id=>address.id).first
l.logf "done (#{address.address})"

# send a test email to the logged in user
l.logs "Sending test email... "
address.send_test(c, lead, u)
l.done