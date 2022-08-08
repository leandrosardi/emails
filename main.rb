module BlackStack
    module Emails
        # where to find the gmail cartification file for the app.
        @@google_api_certificate = nil

        # where to find the gmail cartification file for the app.
        def self.set_google_api_certificate(filename)
            @@google_api_certificate = filename
        end

        # where to find the gmail cartification file for the app.
        def self.google_api_certificate
            @@google_api_certificate
        end
    end # module Emails
end # module BlackStack