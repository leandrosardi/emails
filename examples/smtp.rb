require 'mail'

options = { 
    :address                => '104.168.174.79',
    :port                   => 25,
    #:user_name              => 'postfixuser',
    #:password               => 'SantaClara123',
    #:authentication         => 'plain',
    :enable_starttls_auto   => true, # activate this if you configured TLS in the server
    :openssl_verify_mode    => OpenSSL::SSL::VERIFY_NONE
}

Mail.defaults do
    delivery_method :smtp, options
end

mail = Mail.new do
#    to "a <postfixuser@fabulousfunfacts.site>"
    to "a <leandro.sardi@expandedventure.com>"
    #message_id the_message_id # use this for
    from "b <root@fabulousfunfacts.site>"
    #reply_to reply_to_email.nil? ? BlackStack::Emails::from_email : reply_to_email
    subject "Test 678 abc"
    body "Test 678 abc"
end # Mail.new

# deliver the email
mail.deliver
