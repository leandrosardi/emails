module BlackStack
    module Emails
        class Address < Sequel::Model(:eml_address)
            many_to_one :user, :class=>:'BlackStack::MySaaS::User', :key=>:id_user
            many_to_one :shared, :class=>:'BlackStack::MySaaS::Account', :key=>:shared_id_account
            # types
            TYPE_GMAIL = 0
            TYPE_YAHOO = 1 # pending to develop
            TYPE_HOTMAIL = 2 # pending to develop

            # send email.
            # this is a general purpose method to send email.
            # end user should not call this method.
            def send(to, subject, body, from_name, reply_to)
                raise 'Abstract method'                
            end # send

            def send(h)
                err = []
                # validate: h is a hash
                err << 'h is not a hash' unless h.is_a?(Hash)
                # validate: to is required
                err << 'to is required' unless h[:to]
                # validate: subject is required
                err << 'subject is required' unless h[:subject]
                # validate: body is required
                err << 'body is required' unless h[:body]
                # validate: from_name is required
                err << 'from_name is required' unless h[:from_name]
                # validate: reply_to is required
                err << 'reply_to is required' unless h[:reply_to]
                # validate: to is a string and it is a valid email address
                err << 'to is not a string' unless !h[:to].nil? && !h[:to].is_a?(String)
                err << 'to is not a valid email address' unless !h[:to].nil? && !h[:to].to_s.email?
                # validate: subject is a string
                err << 'subject is not a string' unless !h[:subject].nil? && !h[:subject].is_a?(String)
                # validate: body is a string
                err << 'body is not a string' unless !h[:body].nil? && !h[:body].is_a?(String)
                # validate: from_name is a string
                err << 'from_name is not a string' unless !h[:from_name].nil? && !h[:from_name].is_a?(String)
                # validate: reply_to is a string and it is a valid email address
                err << 'reply_to is not a string' unless !h[:reply_to].nil? && !h[:reply_to].is_a?(String)
                err << 'reply_to is not a valid email address' unless !h[:reply_to].nil? && !h[:reply_to].to_s.email?
                # return if errors
                return err if err.size > 0
                # send email
                send(h[:to], h[:subject], h[:body], h[:from_name], h[:reply_to])
            end


        end # class Address


        class GMail < BlackStack::Emails::Address
            # authentication token file
            def token
                token = "#{self.user.account.storage_sub_folder('emails.google.tokens')}/#{id}.yaml".freeze
            end # def token

            # to access the gmail account, we need to use the gmail api's credentials
            def credentials
                oob_uri = BlackStack::Emails::Google::oob_uri
                app_name = BlackStack::Emails::Google::app_name
                google_api_certificate = BlackStack::Emails::Google::google_api_certificate
                scope = BlackStack::Emails::Google::scope 

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
                app_name = BlackStack::Emails::Google::app_name
                service = Google::Apis::GmailV1::GmailService.new
                service.client_options.application_name = app_name
                service.authorization = self.credentials
                service
            end # def service

            # send email.
            # this is a general purpose method to send email.
            # this should not call this method.
            def send(to, subject, body, from_name, reply_to)
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

            # send a test email to the logged in user
            def send_test(campaign, lead, user)
                self.send({
                    :to => user.email, 
                    :subject => '[Test] '+campaign.merged_subject(lead), 
                    :body => campaign.merged_body(lead), 
                    :from_name => user.name, 
                    :reply_to => user.email,
                })
            end

        end # class GMail

    end # Emails
end # BlackStack