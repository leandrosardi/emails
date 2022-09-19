module BlackStack
    module Emails
        class Address < Sequel::Model(:eml_address)
            many_to_one :user, :class=>:'BlackStack::MySaaS::User', :key=>:id_user
            many_to_one :mta, :class=>:'BlackStack::Emails::Mta', :key=>:id_mta

            # types
            TYPE_GMAIL = 0
            TYPE_YAHOO = 1 # pending to develop
            TYPE_OUTLOOK = 2 # pending to develop
            TYPE_GENERIC = 3 # generic MTA

            # return array of valid types for an address
            def self.types
                [TYPE_GMAIL, TYPE_YAHOO, TYPE_OUTLOOK, TYPE_GENERIC]
            end

            # return a descriptive string for a type
            def self.type_name(type)
                case type
                when TYPE_GMAIL
                    'Gmail'
                when TYPE_YAHOO
                    'Yahoo'
                when TYPE_OUTLOOK
                    'Hotmail'
                when TYPE_GENERIC
                    'Generic'
                else
                    'Unknown'
                end
            end

            # return a descriptive string for the address
            def type_name
                Address.type_name(self.type)
            end

            # validate hash descriptor
            # TODO: move this to a base module, in order to  develop a stub-skeleton/rpc model.
            def self.validate_descriptor(h)
                errors = []
                # validate: h is a hash
                errors << 'h is not a hash' unless h.is_a?(Hash)
                # if h is a hash, then validate the keys
                if h.is_a?(Hash)
                    # validate: id_user is mandatory
                    errors << 'id_user is mandatory' unless h[:id_user] 
                    # validate: id_mta is mandatory
                    errors << 'id_mta is mandatory' unless h[:id_mta]
                    # validate: type is mandatory
                    errors << 'type is mandatory' unless h[:type]
                    # validate: address is mandatory
                    errors << 'address is mandatory' unless h[:address]
                    # validate: password is mandatory
                    errors << 'password is mandatory' unless h[:password]
                    # validate: shared is mandatory
                    #errors << 'shared is mandatory' unless h[:shared]
                    # validate: max_deliveries_per_day is mandatory
                    #errors << 'max_deliveries_per_day is mandatory' unless h[:max_deliveries_per_day]
                    # validate: enabled is mandatory
                    #errors << 'enabled is mandatory' unless h[:enabled]

                    # validate: id_user is an uuid
                    errors << 'id_user is not an uuid' if h[:id_user] && !h[:id_user].to_s.guid?
                    # validate: user exists
                    errors << 'user does not exists' if h[:id_user] && BlackStack::MySaaS::User.where(:id=>h[:id_user]).first.nil?

                    # validate: id_mta is an uuid
                    errors << 'id_mta is not an uuid' if h[:id_mta] && !h[:id_mta].to_s.guid?
                    # validate: mta exists and it is belonging the user's account
                    errors << 'mta does not exists in the account of the user' if h[:id_mta] && DB["
                        SELECT * 
                        FROM eml_mta m
                        JOIN \"user\" u ON (u.id = m.id_user AND u.id_account = '#{BlackStack::MySaaS::User.where(:id=>h[:id_user]).first.id_account}')
                    "].first.nil?

                    # validate: if type exists it is a valid value
                    errors << "type is not a valid value (#{BlackStack::Emails::Address.types.join(', ')})" if h[:type] && !BlackStack::Emails::Address.types.include?(h[:type].to_i)
                    # validate: if address exists it is a valid email address
                    errors << 'address is not a valid email address' if h[:address] && !h[:address].to_s.email?
                    # validate: if password exists it is a string
                    errors << 'password is not a string' if h[:password] && !h[:password].is_a?(String)
                    # validate: if shared exists it is a boolean
                    errors << 'shared is not a boolean' if h[:shared] && !h[:shared].is_a?(TrueClass) && !h[:shared].is_a?(FalseClass)
                    # validate: if max_deliveries_per_day exists it is a number
                    errors << 'max_deliveries_per_day is not a number' if h[:max_deliveries_per_day] && !h[:max_deliveries_per_day].to_s =~ /^\d+$/
                    # validate: if enabled exists it is a boolean
                    errors << 'enabled is not a boolean' if h[:enabled] && !h[:enabled].is_a?(TrueClass) && !h[:enabled].is_a?(FalseClass)
                    # return
                    errors
                end # if h.is_a?(Hash)
            end # def self.validate

            # create a new object from a hash descriptor
            def initialize(h)
                # create Sequel object
                super()
                # validate descriptor
                errors = BlackStack::Emails::Address.validate_descriptor(h)
                raise errors.join(', ') unless errors.empty?
                # map attributes
                self.id = guid
                self.create_time = now
                self.id_user = h[:id_user]
                self.id_mta = h[:id_mta]
                self.type = h[:type].to_i
                self.address = h[:address]
                self.password = h[:password]
                self.shared = h[:shared] || false
                self.max_deliveries_per_day = h[:max_deliveries_per_day] || 50
                self.enabled = h[:enabled] || true
            end

            # update object from a hash descriptor
            def to_hash
                {
                    :id => self.id,
                    :create_time => self.create_time,
                    :id_user => self.id_user,
                    :id_mta => self.id_mta,
                    :type => self.type,
                    :address => self.address,
                    :password => self.password,
                    :shared => self.shared,
                    :max_deliveries_per_day => self.max_deliveries_per_day,
                    :enabled => self.enabled
                }
            end

            # return an Address object belonging the account of the user, with the same address and id_mta
            def self.load(h)
                u = BlackStack::Emails::User.where(:id=>h[:id_user]).first
                row = DB["
                    SELECT a.id 
                    FROM eml_address a
                    JOIN \"user\" u ON ( u.id=a.id_user AND u.id_account='#{u.id_account}' )
                    WHERE a.address='#{h[:address]}' 
                    AND a.id_mta='#{h[:id_mta]}' 
                "].first
                return nil if row.nil?
                return BlackStack::Emails::Address.where(:id=>row[:id]).first
            end

            # return true if the user's account already has an MTA record with these settings
            def self.exists?(h)
                !BlackStack::Emails::Address.load(h).nil?
            end

            # return true if the user's account already has an MTA record with these settings
            def exists?
                !BlackStack::Emails::Address.exists?(self.to_hash).nil?
            end

            # test the the login to the imap server
            # raise an exception if the login fails
            def test
                imap = Net::IMAP.new(self.mta.imap_address, self.mta.imap_port, true)
                res = imap.login(self.address, self.password)
                raise res.name unless res.name == "OK"
                imap.logout
            end

            # send email.
            # return the message_id of the delivered email.
            #
            # this is a general purpose method to send email.
            # end user should not call this method.
            #
            def send_email(to_email, to_name, subject, body, from_name, reply_to=nil, track_opens=false, track_clicks=false, id_delivery=nil)
                mta = self.mta

                options = { 
                    :address                => mta.smtp_address,
                    :port                   => mta.smtp_port,
                    :user_name              => self.address,
                    :password               => self.password,
                    :authentication         => 'plain', #mta.authentication,
                    :enable_starttls_auto   => true, #mta.enable_starttls_auto,
                    :openssl_verify_mode    => OpenSSL::SSL::VERIFY_NONE #mta.openssl_verify_mode
                }
                
                Mail.defaults do
                    delivery_method :smtp, options
                end

                addr = self
                mail = Mail.new do
                    from "#{from_name} <#{addr.address}>"
                    to "#{to_name} <#{to_email}>"
                    
                    reply_to "#{reply_to}" if !reply_to.nil?
                    
                    subject "#{subject}"
                    
                    # plain text email
                    body "#{body}"

                    # TODO: enable this only of HTML content is enabled for the campaign
                    html_part do
                        content_type 'text/html; charset=UTF-8'
                        body "#{body}"
                    end                
                end # Mail.new
                
                # deliver the email
                message = mail.deliver
                
                # record the message_id in the database, in order to track the conversation thread
                return message.message_id
            end # send

            # recevive all same the parameters than `send_email` but into a hash.
            # validate the value of each parameters.
            # raise exception with all the errors found in the parameters.
            # if there is no errors, then call `send_email` with the parameters. 
            def send(h)
                err = []
                # validate: h is a hash
                err << 'h is not a hash' unless h.is_a?(Hash)
                # validate: to_email is required
                err << 'to_email is required' unless h[:to_email]
                # validate: to_name is required
                err << 'to_name is required' unless h[:to_name]
                # validate: subject is required
                err << 'subject is required' unless h[:subject]
                # validate: body is required
                err << 'body is required' unless h[:body]
                # validate: from_name is required
                err << 'from_name is required' unless h[:from_name]
                # validate: reply_to is required
                #err << 'reply_to is required' unless h[:reply_to]
                # validate: to is a string and it is a valid email address
                err << 'to is not a string' if !h[:to].nil? && !h[:to].is_a?(String)
                err << 'to is not a valid email address' if !h[:to].nil? && !h[:to].to_s.email?
                # validate: subject is a string
                err << 'subject is not a string' if !h[:subject].nil? && !h[:subject].is_a?(String)
                # validate: body is a string
                err << 'body is not a string' if !h[:body].nil? && !h[:body].is_a?(String)
                # validate: from_name is a string
                err << 'from_name is not a string' if !h[:from_name].nil? && !h[:from_name].is_a?(String)
                # validate: reply_to is a string and it is a valid email address
                err << 'reply_to is not a string' if !h[:reply_to].empty? && !h[:reply_to].is_a?(String)
                err << 'reply_to is not a valid email address' if !h[:reply_to].empty? && !h[:reply_to].to_s.email?
                # raise exception if any error
                raise err.join("\n") unless err.empty?
                # send email & return the message_id
                return send_email(h[:to_email], h[:to_name], h[:subject], h[:body], h[:from_name], h[:reply_to])
            end

            # send a test email to the logged in user
            def send_test(campaign, lead, user)
                self.send({
                    :to_email => user.email,
                    :to_name => user.name, 
                    :subject => '[Test] '+campaign.merged_subject(lead), 
                    :body => campaign.merged_body(lead), 
                    :from_name => campaign.from_name, 
                    :reply_to => campaign.reply_to,
                })
            end

            # return the next day when it is available to deliver the number of emails configured on its `max_deliveries_per_day` parameters.
            def next_available_day
                ret = DB["
                    select max(planning_time) as dt
                    from eml_job j
                    where j.planning_id_address='#{self.id.to_guid}'
                "].first[:dt]

                if ret.nil?
                    return now
                else
                    return DB["
                        select max(planning_time)+interval '1 day' as dt
                        from eml_job j
                        where j.planning_id_address='#{self.id.to_guid}'
                    "].first[:dt]
                end
            end

            # connect the address via IMAP.
            # find the new incoming emails, using the last ID processed.
            # for each email, if it is a reply to a previous email sent by the system, then insert it in the delivery table.
            # update the last id processed for this address.
            #
            # This method is for internal use only.
            # It should not be called by the end user.
            # 
            def receive(folder='Inbox', track_field='imap_inbox_last_id', l=nil, limit=1000)
                addr = self

                # create dummy log
                l = BlackStack::DummyLogger.new(nil) if l.nil?

                # connecting imap 
                l.logs "Connecting IMAP... "
                imap = Net::IMAP.new(addr.mta.imap_address, addr.mta.imap_port, true)
                conn = imap.login(addr.address, addr.password)
                l.logf "done (#{conn.name})"
        
                # To choose one mailbox Read-only:
                l.logs "Choosing mailbox #{folder}... "
                res = imap.examine(folder)
                l.logf "done (#{res.name})"
        
                # Gettin latest 1000 messages received, in reverse order (newest first)
                l.logs "Getting latest #{limit.to_s} messages... "
                ids = imap.search(["SUBJECT", addr.mta.search_all_wildcard]).reverse[0..limit]
                l.logf "done (#{ids.size.to_s} messages)"
                
                # iterate the messages
                ids.each { |id|
                    l.logs "Processing message #{id.to_s}... "
                    # getting the envelope
                    envelope = imap.fetch(id, "ENVELOPE")[0].attr["ENVELOPE"]
                    # getting the parameters
                    from_name = envelope.from[0].name
                    from_email = envelope.from[0].mailbox.to_s + '@' + envelope.from[0].host.to_s 
                    date = envelope.date

                    # TODO: develop a normalization function for mail.message_id
                    message_id = envelope.message_id.to_s.gsub(/^</, '').gsub(/>$/, '')
                    in_reply_to = envelope.in_reply_to.to_s.gsub(/^</, '').gsub(/>$/, '') # use this parameter to track a conversation thread

                    subject = envelope.subject
                    body = imap.fetch(id, "BODY[]")[0].attr["BODY[]"]
                    
                    # check if this message_id is is the latest processed
                    #if message_id == addr[track_field.to_sym]
                    #    l.logf "done with all new messages"
                    #    break
                    #else
                        # check if it is a reply to a previous email sent by the system
                        d = in_reply_to.to_s.empty? ? nil : BlackStack::Emails::Delivery.where(:message_id => in_reply_to).first 
                        if d.nil?
                            l.logf "ignored" # not a reply to a previous email sent by the system
                        else
                            d.insert_reply(subject, from_name, from_email, date, message_id, body)
                            l.logf "registered" # insert such a reply in database 
                        end
                        # update the last id processed
                        DB.execute("update eml_address set #{track_field} = '#{message_id.to_s}' where id='#{addr.id.to_guid}'")
                    #end
                    
                    # TODO: ingest ALL the inbox anyway, in order to gather information about our users
                    # TODO: ingest ALL the sent messages anyway, in order to gather information about our users
                    # TODO: track the automated warming up emails
                    
                }
                
                # disconnect
                l.logs "Disconnecting IMAP... "
                res = imap.logout
                l.logf "done (#{res.name})"
            end # end receive

        end # class Address

=begin
        # removed becuase of the issue https://github.com/leandrosardi/emails/issues/31
        class GMail < BlackStack::Emails::Address
            # authentication token file
            def token
                token = "#{self.user.account.storage_sub_folder('emails.google.tokens')}/#{id}.yaml".freeze
            end # def token
            
            # to access the gmail account, we need to use the gmail api's credentials
            def credentials
                oob_uri = BlackStack::Emails::GoogleConfig::oob_uri
                app_name = BlackStack::Emails::GoogleConfig::app_name
                google_api_certificate = BlackStack::Emails::GoogleConfig::google_api_certificate
                scope = BlackStack::Emails::GoogleConfig::scope 
            
                client_id = Google::Auth::ClientId.from_file google_api_certificate
                token_store = Google::Auth::Stores::FileTokenStore.new file: self.token
                authorizer = Google::Auth::UserAuthorizer.new client_id, scope, token_store
                user_id = 'default'
                ret = authorizer.get_credentials user_id
                raise "Address credentials not found" if ret.nil?
                ret
            end

            # get gmail service
            def service
                require "google/apis/gmail_v1"
                require "googleauth"
                require "googleauth/stores/file_token_store"
            
                app_name = BlackStack::Emails::GoogleConfig::app_name
                service = Google::Apis::GmailV1::GmailService.new
                service.client_options.application_name = app_name
                service.authorization = self.credentials
                service
            end # def service

            # send email.
            # this is a general purpose method to send email.
            # this should not call this method.
            def send_email(to, subject, body, from_name, reply_to, track_opens=false, track_clicks=false, id_delivery=nil)
                user_id = "me"
                message = Mail.new(body)
                message.to = to
                message.from = "#{from_name} <#{self.address}>"
                message.reply_to = reply_to
                message.subject = subject
                message.text_part = body
                message.html_part = body
                self.service.send_user_message(user_id, upload_source: StringIO.new(message.to_s), content_type: 'message/rfc822')                
            end # send
        end # class GMail
=end
    end # Emails
end # BlackStack