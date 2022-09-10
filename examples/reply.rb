# This example is about replying to an email using Gmail's SMTP, and keep the conversation thread.
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

    # it is important to add "Re: " to the subject, otherwise Gmail will not recognize it as a reply
    subject "Re: This is the begining of a great friendship"

    body "Where can we meet this weekend?"

    # Use this parameter when you want each response goes to another inbox - NOT RECOMMENDED if you want to track a conversation thread
    #reply_to reply_to_email.nil? ? BlackStack::Emails::from_email : reply_to_email

    # use this parameter when you are not running a campaign, but sending a single email belonging a conversation thread
    # reference: https://www.ombulabs.com/blog/rails/emails/tutorial/send-emails-that-thread-with-rails.htmlCAEXobn5+BeNw1Dhm+Cd1Qz1d3dAtXcZ_o8WXYYwSvEuYN6Ba0A@mail.gmail.com
    in_reply_to 'esEFPxC6iWw+y+FiujYRwBKBnNHwKiedLkRNzpA@mail.gmail.com' # this is the message_id of the last email that I am replying to. 
    references '631c9556b0481_1ef2294-40@dev5.mail' # this is the message_id of the first email of the thread.
end # Mail.new

# deliver the email
mail.deliver
