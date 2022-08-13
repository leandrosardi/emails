module BlackStack
    module Emails
        class Link < Sequel::Model(:eml_link)
            many_to_one :campaign, :class=>:'BlackStack::Emails::Campaign', :key=>:id_campaign

            # return the url of the tracking link
            def tracking_url(delivery)
                # validation: self.id is not nil and it is a valid guid
                errors << "id is nil" if self.id.nil? || !self.id.guid?
                s = "#{CS_HOME_WEBSITE}/api1.0/emails/click.json?lid=#{self.id.to_guid}&did=#{delivery.id.to_guid}"
puts self.id
puts s
                s
            end # def tracking_url
        end # class Link
    end # Emails
end # BlackStack