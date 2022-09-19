# This example is about sending emails using Outlook's SMTP.
#
# Follow the steps below to generate a 2-step authentication token in your Gmail account.
# 
# Step 1. Access here and get both: IMAP and SMTP connection parameters.
# https://outlook.live.com/mail/0/options/mail/accounts
# Activate POP3.

# Step 2. Turn On 2-step Verification
# https://support.microsoft.com/en-us/account-billing/how-to-use-two-step-verification-with-your-microsoft-account-c7910146-672f-01e9-50a0-93b4585e7eb4
# 
# Step 3. Create an App Password
# https://support.microsoft.com/en-us/account-billing/using-app-passwords-with-apps-that-don-t-support-two-step-verification-5896ed9b-4263-e681-128a-a6f2979a7944
# 
# 

require 'mail'

options = { 
    :address                => 'smtp.office365.com',
    :port                   => 587,
    :user_name              => 'leandrosardi2005@hotmail.com',
    :password               => '***',
    :authentication         => 'login',
    :enable_starttls_auto   => true, # activate this if you configured TLS in the server
    :openssl_verify_mode    => OpenSSL::SSL::VERIFY_NONE
}

Mail.defaults do
    delivery_method :smtp, options
end

mail = Mail.new do
#    to "a <postfixuser@fabulousfunfacts.site>"
    from "Leandro S. <leandrosardi2005@hotmail.com>"
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
