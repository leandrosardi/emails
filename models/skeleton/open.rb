module BlackStack
    module Emails
        class Open < Sequel::Model(:eml_open)
            many_to_one :delivery, :class=>:'BlackStack::Emails::Delivery', :key=>:id_delivery

            # increment the open count for the regarding campaign in the timeline snapshot
            def after_create
                super
                self.delivery.job.track('open')
            end
        end # class Open
    end # Emails
end # BlackStack