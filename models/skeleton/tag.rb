module BlackStack
    module Emails
        class Tag < Sequel::Model(:eml_tag)
            many_to_one :user, :class=>:'BlackStack::MySaaS::User', :key=>:id_user
            one_to_many :outreaches, :class=>:'BlackStack::Emails::Outreach', :key=>:id_tag
            one_to_many :addresstags, :class=>:'BlackStack::Emails::AddressTag', :key=>:id_tag


            COLORS = ['orange','blue','purple','black']

            def self.color(name)
                COLORS[name.hash % COLORS.length]
            end

            def color
                Tag.color(name)
            end

            # return array of tag objects, connected to this campaign thru the :outreaches attribute
            def addresses()
                self.addresstags.map { |o| o.tag }.uniq
            end

        end # class Tag
    end # Emails
end # BlackStack