# This example is about sending emails using Gmail's SMTP.
#
# Follow the steps below to generate a 2-step authentication token in your Gmail account.
# Step 1:
# Go here https://mail.google.com/mail/u/1/#settings/fwdandpop and enable IMAP.
# Step 2:
# Go here https://myaccount.google.com/u/1/apppasswords and create an app password.
# 

require 'mail'

options = { 
    :address                => 'smtp.gmail.com',
    :port                   => 25,
    :user_name              => 'sardi.leandro.daniel@gmail.com',
    :password               => '********',
    :authentication         => 'plain',
    :enable_starttls_auto   => true, # activate this if you configured TLS in the server
    :openssl_verify_mode    => OpenSSL::SSL::VERIFY_NONE
}

Mail.defaults do
    delivery_method :smtp, options
end

mail = Mail.new do
#    to "a <postfixuser@fabulousfunfacts.site>"
    from "Leandro S. <sardi.leandro.daniel@gmail.com>"
    to "Another Leandro <leandro.sardi@expandedventure.com>"
    subject "This is the begining of a great friendship"
    body "Nice to meet you too Leandro."

    # Use this parameter when you want each response goes to another inbox - NOT RECOMMENDED if you want to track a conversation thread
    #reply_to reply_to_email.nil? ? BlackStack::Emails::from_email : reply_to_email
end # Mail.new

# deliver the email
message = mail.deliver

# record the message_id in the database, in order to track the conversation thread
puts "Message sent: #{message.message_id}"
