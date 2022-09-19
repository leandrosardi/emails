# MySaaS Emails - Receive
# Copyright (C) 2022 ExpandedVenture, LLC.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# You may not use this file except in compliance with the License.
#
# Authors: Leandro Daniel Sardi (https://github.com/leandrosardi)
#

# References:
# - https://stackoverflow.com/questions/2185391/localized-gmail-imap-folders
# - https://stackoverflow.com/questions/1084780/getting-only-new-mail-from-an-imap-server
# - https://stackoverflow.com/questions/39736096/remove-header-characters-from-email-body
# - https://stackoverflow.com/questions/17883278/how-to-clean-up-a-string-email-body-with-regards-to-special-characters/17884027
# - https://github.com/github/email_reply_parser
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

#d = BlackStack::Emails::Delivery.where(:id=>'6a7b6345-6934-4a1f-b8d7-fc5ce3ef4adb').first
#puts d.simplified_body
#exit(0)

l = BlackStack::LocalLogger.new('./receive.log')

while (true)
    # active addresses
    l.logs "Get array of all active addresses... "
    addrs = BlackStack::Emails::Address.where(:delete_time=>nil).all
    l.logf "done (#{addrs.size})"

    # for each address
    addrs.each { |addr|
        # process the inbox
        l.logs "Process address inbox of #{addr.address}... "
        addr.receive('Inbox', 'imap_inbox_last_id', l, 25)
        l.done

        l.logs "Process address spam of #{addr.address}... "
        addr.receive('Spam', 'imap_spam_last_id', l, 25)
        l.done
    }

    l.logs 'Sleeping... '
    sleep(10)
    l.done
end # while (true)