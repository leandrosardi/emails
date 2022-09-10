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
    :password               => '*****',
    :authentication         => 'plain',
    :enable_starttls_auto   => true, # activate this if you configured TLS in the server
    :openssl_verify_mode    => OpenSSL::SSL::VERIFY_NONE
}

Mail.defaults do
    delivery_method :smtp, options
end

mail = Mail.new do
#    to "a <postfixuser@fabulousfunfacts.site>"
    to "a <leandro.sardi@expandedventure.com>"
    message_id 'lalala01' # use this for
    from "Leandro S. <sardi.leandro.daniel@gmail.com>"
    #reply_to reply_to_email.nil? ? BlackStack::Emails::from_email : reply_to_email
    subject "Test 678 abcde"
    body "Test 678 abcde"
end # Mail.new

# deliver the email
mail.deliver
