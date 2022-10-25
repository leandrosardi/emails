module BlackStack
    module Emails
        # inherit from BlackStack::MySaaS::Account
        class Account < BlackStack::MySaaS::Account

            # return array of Tag objects, each one linked to this account thru the table user.
            def tags
                self.users.map{ |u|
                    BlackStack::Emails::User.where(:id=>u.id).first.tags
                }.flatten
            end

            # return array of MTA objects, each one linked to this account thru the table user.
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