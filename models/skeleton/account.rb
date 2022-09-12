module BlackStack
    module Emails
        # inherit from BlackStack::MySaaS::Account
        class Account < BlackStack::MySaaS::Account
            def mtas
                self.users.map{ |u|
                    BlackStack::Emails::User.where(:id=>u.id).first.mtas
                }.flatten
            end

            def addresses
                self.users.map { |u| 
                    BlackStack::Emails::User.where(:id=>u.id).first.addresses.select { |o| 
                        o.delete_time.nil? && o.enabled 
                    } 
                }.flatten
            end # def addresses

            def campaigns
                self.users.map { |u| 
                    BlackStack::Emails::User.where(:id=>u.id).first.campaigns.select { |o|
                        o.delete_time.nil?
                    }
                }.flatten
            end # def campaigns
        end # class Account
    end # module Emails
end # module BlackStack