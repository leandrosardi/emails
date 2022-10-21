module BlackStack
    module Emails
        class Campaign < Sequel::Model(:eml_campaign)
            many_to_one :user, :class=>:'BlackStack::MySaaS::User', :key=>:id_user
            many_to_one :export, :class=>:'Leads::FlExport', :key=>:id_export      
            one_to_many :followups, :class=>"BlackStack::Emails::Followup", :key=>:id_campaign
            one_to_many :schedules, :class=>"BlackStack::Emails::Schedule", :key=>:id_campaign
            one_to_many :outreaches, :class=>"BlackStack::Emails::Outreach", :key=>:id_campaign

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
                    JOIN eml_job j ON f.id=j.id_followup
                    JOIN eml_delivery d on j.id=d.id_job 
                    WHERE f.id_campaign = '#{self.id}'
                "].first[:n]
            end

            def sent_ratio
                t = self.total_deliveries
                t == 0 ? 0 : ((self.stat_sents.to_f / t.to_f) * 100.to_f).to_i
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