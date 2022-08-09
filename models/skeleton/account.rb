module BlackStack
    module Emails
        # inherit from BlackStack::MySaaS::Account
        class Account < BlackStack::MySaaS::Account
            def addresses
                self.users.map { |u| BlackStack::Emails::User.where(:id=>u.id).first.addresses }.flatten
            end # def addresses

            def campaigns
                self.users.map { |u| BlackStack::Emails::User.where(:id=>u.id).first.campaigns }.flatten
            end # def campaigns
        end # class Account
    end # module Emails
end # module BlackStack