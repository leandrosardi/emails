module BlackStack
    module Emails
        class Click < Sequel::Model(:eml_click)
            many_to_one :delivery, :class=>:'BlackStack::Emails::Delivery', :key=>:id_delivery
            many_to_one :link, :class=>:'BlackStack::Emails::Link', :key=>:id_link

            # increment the click count for the regarding campaign in the timeline snapshot
            def after_create
                super
                self.delivery.job.campaign.track('click')
            end

        end # class Click
    end # Emails
end # BlackStack