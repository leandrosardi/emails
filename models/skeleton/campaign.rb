module BlackStack
    module Emails
        class Campaign < Sequel::Model(:eml_campaign)
            many_to_one :user, :class=>:'BlackStack::MySaaS::User', :key=>:id_user
            many_to_one :export, :class=>:'Leads::FlExport', :key=>:id_export      
            one_to_many :followups, :class=>"BlackStack::Emails::Followup", :key=>:id_campaign
            one_to_many :schedules, :class=>"BlackStack::Emails::Schedule", :key=>:id_campaign
            one_to_many :outreaches, :class=>"BlackStack::Emails::Outreach", :key=>:id_campaign
            
            # statuses of email campaigns: draft, sent, etc.
            STATUS_ON = 1
            STATUS_OFF = 2

            # return array of tag objects, connected to this campaign thru the :outreaches attribute
            def tags()
                self.outreaches.map { |o| o.tag }.uniq
            end

            # return array of address objects, connected to this campaign thru the :outreaches attribute
            def addresses()
                self.outreaches.map { |o| o.tag }.uniq.map { |t| t.addresses }.flatten.uniq
            end

            # statuses of email campaigns: draft, sent, etc.
            def self.statuses
                [STATUS_ON, STATUS_OFF]
            end

            # can edit if there is not any followup who can't edit
            def can_edit?
                self.followups.select { |f| !f.can_edit? }.first.nil?
            end

            # if is ON if any followup is ON
            def status
                self.followups.select { |f| f.status == BlackStack::Emails::Followup::STATUS_ON }.first.nil? ? STATUS_OFF : STATUS_ON
            end 

            # if is ON if any followup is ON
            def status_name
                self.status == STATUS_ON ? 'on' : 'off'
            end

            def status_color
                case self.status
                when STATUS_ON
                    'green'
                when STATUS_OFF
                    'gray'
                end
            end

            # leads in the export list.
            # note that may exist leads added after the campaign planning.
            def total_leads
                DB["SELECT COUNT(*) AS n FROM fl_export_lead WHERE id_export = '#{self.id_export}'"].first[:n]
            end

            # total number of deliveries planned for this campaign
            def total_deliveries
                DB["
                    SELECT COUNT(*) AS n 
                    FROM eml_followup f
                    JOIN eml_delivery d on f.id=d.id_followup 
                    WHERE f.id_campaign = '#{self.id}'
                "].first[:n]
            end

            def sent_ratio
                t = self.total_deliveries
                t == 0 ? 0 : ((self.stat_sents.to_f / t.to_f) * 100.to_f).to_i
            end

            def replies_ratio
                t = self.stat_sents
                t == 0 ? 0 : ((self.stat_replies.to_f / t.to_f) * 100.to_f).to_i
            end

            def positive_replies_ratio
                t = self.stat_sents
                t == 0 ? 0 : ((self.stat_positive_replies.to_f / t.to_f) * 100.to_f).to_i
            end

            def opens_ratio
                t = self.stat_sents
                t == 0 ? 0 : ((self.stat_opens.to_f / t.to_f) * 100.to_f).to_i
            end

            def clicks_ratio
                t = self.stat_sents
                t == 0 ? 0 : ((self.stat_clicks.to_f / t.to_f) * 100.to_f).to_i
            end

            def replies_ratio
                t = self.stat_sents
                t == 0 ? 0 : ((self.stat_replies.to_f / t.to_f) * 100.to_f).to_i
            end

            def positive_replies_ratio
                t = self.stat_sents
                t == 0 ? 0 : ((self.stat_positive_replies.to_f / t.to_f) * 100.to_f).to_i
            end

            def unsubscribes_ratio
                t = self.stat_sents
                t == 0 ? 0 : ((self.stat_unsubscribes.to_f / t.to_f) * 100.to_f).to_i
            end


        end # class Campaign
    end # Emails
end # BlackStack