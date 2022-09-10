# This example is about grabbing Gmail's Inbox using IMAP.
#
# Follow the steps below to generate a 2-step authentication token in your Gmail account.
# Step 1:
# Go here https://mail.google.com/mail/u/1/#settings/fwdandpop and enable IMAP.
# Step 2:
# Go here https://myaccount.google.com/u/1/apppasswords and create an app password.
# 
# Reference: 
# https://www.ombulabs.com/blog/ruby/imap/a-comprehensive-guide-to-interacting-with-imap-using-ruby.html
# 

require 'net/imap'
require 'email_reply_parser'

imap = Net::IMAP.new("imap.googlemail.com", 993, true)

res = imap.login('sardi.leandro.daniel@gmail.com', '***')
p res.name

# To list all of your mailboxes
#res = imap.list("", "*")
#res.each { |mailbox| puts mailbox.name }

# To choose one mailbox Read-only:
res = imap.examine("[Gmail]/Todos")
p res.name

# To choose one mailbox Read-and-write:
#res = imap.select("INBOX")
#p res.name

# Searching email messages
res = imap.search(["SUBJECT", '"Test 678 abcde"']) #, "SINCE", "08-Sept-2022"
p res.inspect

# ids of the messages that match with the search
ids = res

# parse each email
ids.each { |id|
    puts
    puts

    envelope = imap.fetch(id, "ENVELOPE")[0].attr["ENVELOPE"]
    puts "From: <#{envelope.from[0].name}> #{envelope.from[0].mailbox}@#{envelope.from[0].host}"
    puts "To: <#{envelope.to[0].name}> #{envelope.to[0].mailbox}@#{envelope.to[0].host}"
    puts "Subject: #{envelope.subject}"
    puts "Date: #{envelope.date}"
    puts "Message-ID: #{envelope.message_id}"

    # this line gets the email body, even if it is HTML (not TEXT)
    body = imap.fetch(id, "BODY[TEXT]")[0].attr["BODY[TEXT]"]
    #p body

    # get the actual email message that the person just wrote, excluding any quoted text
    # https://github.com/github/email_reply_parser
    # reference: https://stackoverflow.com/questions/7978987/get-the-actual-email-message-that-the-person-just-wrote-excluding-any-quoted-te
    p EmailReplyParser.parse_reply(body)
}

imap.logout
