module BlackStack
    module Emails
        class Tag < Sequel::Model(:eml_tag)
            many_to_one :user, :class=>:'BlackStack::MySaaS::User', :key=>:id_user

            COLORS = ['orange','blue','purple','black']

            def self.color(name)
                COLORS[name.hash % COLORS.length]
            end

            def color
                Tag.color(name)
            end

        end # class Tag
    end # Emails
end # BlackStack