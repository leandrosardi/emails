# This example is about grabbing Hotmails's Inbox using IMAP.
#
# 
# Step 1. Access here and get both: IMAP and SMTP connection parameters.
# https://outlook.live.com/mail/0/options/mail/accounts
# Activate POP3.
#
# Step 2. Turn On 2-step Verification
# https://support.microsoft.com/en-us/account-billing/how-to-use-two-step-verification-with-your-microsoft-account-c7910146-672f-01e9-50a0-93b4585e7eb4
# 
# Step 3. Create an App Password
# https://support.microsoft.com/en-us/account-billing/using-app-passwords-with-apps-that-don-t-support-two-step-verification-5896ed9b-4263-e681-128a-a6f2979a7944
# 
# 

require 'net/imap'
require 'email_reply_parser'

imap = Net::IMAP.new("outlook.office365.com", 993, true)

res = imap.login('leandrosardi2005@hotmail.com', '****')
p res.name

# To list all of your mailboxes
#res = imap.list("", "*")
#res.each { |mailbox| puts mailbox.name }
#exit(0)

# To choose one mailbox Read-only:
res = imap.examine("Inbox")
p res.name

# To choose one mailbox Read-only:
#res = imap.examine("Junk")
#p res.name

# Searching email messages
res = imap.search(["SUBJECT", '']).reverse[0..2]
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
    puts "In-Reply-To: #{envelope.in_reply_to}" # use this parameter to track a conversation thread

    # this line gets the email body, even if it is HTML (not TEXT)
    #body = imap.fetch(id, "BODY[TEXT]")[0].attr["BODY[TEXT]"]
    #p body

    # get the actual email message that the person just wrote, excluding any quoted text
    # https://github.com/github/email_reply_parser
    # reference: https://stackoverflow.com/questions/7978987/get-the-actual-email-message-that-the-person-just-wrote-excluding-any-quoted-te
    #p EmailReplyParser.parse_reply(body)
}

imap.logout
