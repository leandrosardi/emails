require "fileutils"
require 'mail'
require 'net/imap'
require 'csv'
require 'email_reply_parser'

module BlackStack
    module Emails
        UNSUBSCRIBE_MERGETAG = '{unsubscribe-url}'

        @@mergetags = [
            '{company-name}',
            '{first-name}',
            '{last-name}',
            '{location}',
            '{industry}',
            '{email-address}',
            '{phone-number}',
            '{linkedin-url}',
            UNSUBSCRIBE_MERGETAG,
        ]

        def self.set_mergetags(tags)
            @@mergetags = tags
        end

        def self.mergetags
            @@mergetags
        end
# Removed because of https://github.com/leandrosardi/emails/issues/31
=begin
        # GoogleConfig module
        module GoogleConfig
            # where to find the gmail cartification file for the app.
            @@google_api_certificate = nil
            @@oob_uri = nil #"urn:ietf:wg:oauth:2.0:oob".freeze
            @@app_name = nil #"ConnectionSphere".freeze
            @@scope = nil #Google::Apis::GmailV1::AUTH_SCOPE #AUTH_GMAIL_READONLY
                
            # where to find the gmail cartification file for the app.
            def self.set(h={})
                @@google_api_certificate = h[:google_api_certificate]
                @@oob_uri = h[:oob_uri]
                @@app_name = h[:app_name]
                @@scope = h[:scope]
            end

            # where to find the gmail cartification file for the app.
            def self.google_api_certificate
                @@google_api_certificate
            end

            def self.oob_uri
                @@oob_uri
            end

            def self.app_name
                @@app_name
            end

            def self.scope
                @@scope
            end
        end # module GoogleConfig
=end
    end # module Emails
end # module BlackStack