module BlackStack
    module Emails
        class Unsubscribe < Sequel::Model(:eml_unsubscribe)
            many_to_one :delivery, :class=>:'BlackStack::Emails::Delivery', :key=>:id_delivery

            # increment the unsubscribe count for the regarding campaign in the timeline snapshot
            def after_create
                super
                self.delivery.job.track('unsubscribe')
                # write history in eml_log
                self.delivery.track('unsubscribe')
            end
        end # class Unsubscribe
    end # Emails
end # BlackStack