require "google/apis/gmail_v1"
require "googleauth"
require "googleauth/stores/file_token_store"
require "fileutils"
require 'mail'

module BlackStack
    module Emails
        @@mergetags = [
            '{company-name}',
            '{first-name}',
            '{last-name}',
            '{location}',
            '{industry}',
            '{email-address}',
            '{phone-number}',
            '{linkedin-url}',
            '{unsubscribe-url}',
        ]

        def self.set_mergetags(tags)
            @@mergetags = tags
        end

        def self.mergetags
            @@mergetags
        end

        # inherit from BlackStack::MySaaS::User
        class User < BlackStack::MySaaS::User
            one_to_many :addresses, :class=>:'BlackStack::Emails::Address', :key=>:id_user
            one_to_many :campaigns, :class=>:'BlackStack::Emails::Campaign', :key=>:id_user
        end # class User

        # inherit from BlackStack::MySaaS::Account
        class Account < BlackStack::MySaaS::Account
            def addresses
                self.users.map { |u| BlackStack::Emails::Users.where(:id=>u.id).first.addresses }.flatten
            end # def addresses

            def campaigns
                self.users.map { |u| BlackStack::Emails::Users.where(:id=>u.id).first.campaigns }.flatten
            end # def campaigns
        end # class Account

        # Google module
        module Google
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
        end # module Google
    end # module Emails
end # module BlackStack