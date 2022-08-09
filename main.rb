require "google/apis/gmail_v1"
require "googleauth"
require "googleauth/stores/file_token_store"
require "fileutils"
require 'mail'

module BlackStack
    module Emails
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