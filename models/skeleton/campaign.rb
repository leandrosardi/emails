module BlackStack
    module Emails
        class Campaign < Sequel::Model(:eml_campaign)
            many_to_one :user, :class=>:'BlackStack::MySaaS::User', :key=>:id_user
            many_to_one :export, :class=>:'Leads::FlExport', :key=>:id_export      
            one_to_many :jobs, :class=>:'BlackStack::Emails::Job', :key=>:id_campaign
            
            # types of email campaigns: text or html
            TYPE_TEXT = 0
            TYPE_HTML = 1

            # statuses of email campaigns: draft, sent, etc.
            STATUS_DRAFT = 0
            STATUS_ON = 1
            STATUS_OFF = 2
            STATUS_ERROR = 3

            # statuses of email campaigns: draft, sent, etc.
            def self.statuses
                [STATUS_DRAFT, STATUS_SENT, STATUS_ERROR]
            end

            def status_name
                case self.status
                when STATUS_DRAFT
                    'draft'
                when STATUS_ON
                    'on'
                when STATUS_OFF
                    'off'
                when STATUS_ERROR
                    'error'
                end
            end

            def status_color
                case self.status
                when STATUS_DRAFT
                    'blue'
                when STATUS_ON
                    'green'
                when STATUS_OFF
                    'gray'
                when STATUS_ERROR
                    'red'
                end
            end

            def can_edit?
                self.status == STATUS_DRAFT
            end

            def can_play?
                self.status == STATUS_DRAFT || self.status == STATUS_OFF
            end

            def can_pause?
                self.status == STATUS_ON
            end

            # campaign ratios
            def total_leads
                DB["SELECT COUNT(*) AS n FROM fl_export_lead WHERE id_export = '#{self.id_export}'"].first[:n]
            end

            def sent_ratio
                t = self.total_leads
                t == 0 ? 0 : ((self.stat_sent.to_f / t.to_f) * 100.to_f).to_i
            end
            
            def opens_ratio
                t = self.stat_sent
                t == 0 ? 0 : ((self.stat_opened.to_f / t.to_f) * 100.to_f).to_i
            end

            def clicks_ratio
                t = self.stat_opened
                t == 0 ? 0 : ((self.stat_clicked.to_f / t.to_f) * 100.to_f).to_i
            end

            def unsubscribes_ratio
                t = self.stat_opened
                t == 0 ? 0 : ((self.stat_unsubscribed.to_f / t.to_f) * 100.to_f).to_i
            end
        end # class Address
    end # Emails
end # BlackStack