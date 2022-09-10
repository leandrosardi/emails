# This example is about testing an SMTP connection.
#
# Follow the steps below to generate a 2-step authentication token in your Gmail account.
# Step 1:
# Go here https://mail.google.com/mail/u/1/#settings/fwdandpop and enable IMAP.
# Step 2:
# Go here https://myaccount.google.com/u/1/apppasswords and create an app password.
# 

require 'net/imap'

imap = Net::IMAP.new("imap.googlemail.com", 993, true)

begin
    res = imap.login('sardi.leandro.daniel@gmail.com', '********')
    raise res.name unless res.name == "OK"
    puts res.name
    imap.logout
rescue => e
    puts "Connection Filed: #{e.message}."
end
