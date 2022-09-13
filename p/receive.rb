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

l = BlackStack::LocalLogger.new('./receive.log')

while (true)
    # active addresses
    l.logs "Get array of all active addresses... "
    addrs = BlackStack::Emails::Address.where(:delete_time=>nil).all
    l.logf "done (#{addrs.size})"

    # for each address
    addrs.each { |addr|
        l.logs "Process address #{addr.address}... "

        l.logs "Connecting IMAP... "
        imap = Net::IMAP.new(addr.mta.imap_address, addr.mta.imap_port, true)
        conn = imap.login(addr.address, addr.password)
        l.logf "done (#{conn.name})"

        # To choose one mailbox Read-only:
        #l.logs "Choosing mailbox SPAM... "
        #res = imap.examine("[Gmail]/Spam")
        #l.logf res.name

        # To choose one mailbox Read-only:
        l.logs "Choosing mailbox INBOX... "
        res = imap.examine('Inbox')
        l.logf res.name

        # Gettin all messages
        l.logs "Getting all messages... "
        res = imap.search(["SUBJECT", '*'])
        id = res.first
        l.logf id.to_s
        
        # 
        envelope = imap.fetch(id, "ENVELOPE")[0].attr["ENVELOPE"]
        puts "From: <#{envelope.from[0].name}> #{envelope.from[0].mailbox}@#{envelope.from[0].host}"
        puts "To: <#{envelope.to[0].name}> #{envelope.to[0].mailbox}@#{envelope.to[0].host}"
        puts "Subject: #{envelope.subject}"
        puts "Date: #{envelope.date}"
        puts "Message-ID: #{envelope.message_id}"
        puts "In-Reply-To: #{envelope.in_reply_to}" # use this parameter to track a conversation thread
    
        # disconnect
        l.logs "Disconnecting IMAP... "
        res = imap.logout
        l.logf "done (#{res.name})"


        l.done
    }

    l.logs 'Sleeping... '
    sleep(10)
    l.done
end # while (true)