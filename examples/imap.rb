require 'net/imap'
require 'email_reply_parser'

n = 8
imap = Net::IMAP.new("104.168.174.79", 143, false)

res = imap.login('postfixuser', '***')
p res.name

res = imap.list("", "*")
p res.inspect

res = imap.select("INBOX")
p res.name

res = imap.search(["ALL"])
p res.inspect

envelope = imap.fetch(8, "ENVELOPE")[0].attr["ENVELOPE"]
p envelope.from[0].name
p envelope.from[0].mailbox
p envelope.subject
p envelope.message_id
p envelope.date

# this line gets the email body, even if it is HTML (not TEXT)
body = imap.fetch(8, "BODY[TEXT]")[0].attr["BODY[TEXT]"]
#p body

# get the actual email message that the person just wrote, excluding any quoted text
# https://github.com/github/email_reply_parser
# reference: https://stackoverflow.com/questions/7978987/get-the-actual-email-message-that-the-person-just-wrote-excluding-any-quoted-te
p EmailReplyParser.parse_reply(body)

imap.logout
