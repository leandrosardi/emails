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

            # replace merge-tags in the string s with the values of the lead's atrtibutes.
            # return the string with the merge-tags replaced.
            # this is a general purpose method to send email.
            # this should not call this method.
            def merge(s, lead)
                ret = s
                email = lead.datas.select { |d| d.type == Leads::FlData::TYPE_EMAIL }.first
                phone = lead.datas.select { |d| d.type == Leads::FlData::TYPE_PHONE }.first
                linkd = lead.datas.select { |d| d.type == Leads::FlData::TYPE_LINKEDIN }.first
                unsub = "#{CS_HOME_WEBSITE}/api1.0/emails/unsubscribe.json?lid=#{lead.id.to_guid}&gid=#{self.id.to_guid}"

                # replace merge-tags with no fallback values
                ret.gsub!(/#{Regexp.escape('{company-name}')}/, lead.stat_company_name.to_s)
                ret.gsub!(/#{Regexp.escape('{first-name}')}/, lead.first_name.to_s)
                ret.gsub!(/#{Regexp.escape('{last-name}')}/, lead.last_name.to_s)
                ret.gsub!(/#{Regexp.escape('{location}')}/, lead.stat_location_name.to_s)
                ret.gsub!(/#{Regexp.escape('{industry}')}/, lead.stat_industry_name.to_s)
                ret.gsub!(/#{Regexp.escape('{email-address}')}/, email.to_s)
                ret.gsub!(/#{Regexp.escape('{phone-number}')}/, phone.to_s)
                ret.gsub!(/#{Regexp.escape('{linkedin-url}')}/, linkd.to_s)
                ret.gsub!(/#{Regexp.escape('{unsubscribe-url}')}/, unsub.to_s)

                # replace merge-tags with fallback values
                ret.scan(/#{Regexp.escape('{company-name|')}.*#{Regexp.escape('}')}/).each { |m| 
                    ret.sub!(m, lead.stat_company_name.to_s.empty? ? m.gsub(/^\{company-name\|/, '').gsub(/\}$/) : lead.stat_company_name.to_s)
                } 
                ret.scan(/#{Regexp.escape('{first-name|')}.*#{Regexp.escape('}')}/).each { |m| 
                    ret.sub!(m, lead.first_name.to_s.empty? ? m.gsub(/^\{first-name\|/, '').gsub(/\}$/) : lead.first_name.to_s)
                } 
                ret.scan(/#{Regexp.escape('{last-name|')}.*#{Regexp.escape('}')}/).each { |m| 
                    ret.sub!(m, lead.last_name.to_s.empty? ? m.gsub(/^\{last-name\|/, '').gsub(/\}$/) : lead.last_name.to_s)
                } 
                ret.scan(/#{Regexp.escape('{location|')}.*#{Regexp.escape('}')}/).each { |m| 
                    ret.sub!(m, lead.stat_location_name.to_s.empty? ? m.gsub(/^\{location\|/, '').gsub(/\}$/) : lead.stat_location_name.to_s)
                } 
                ret.scan(/#{Regexp.escape('{industry|')}.*#{Regexp.escape('}')}/).each { |m| 
                    ret.sub!(m, lead.stat_industry_name.to_s.empty? ? m.gsub(/^\{industry\|/, '').gsub(/\}$/) : lead.stat_industry_name.to_s)
                } 
                ret.scan(/#{Regexp.escape('{email-address|')}.*#{Regexp.escape('}')}/).each { |m| 
                    ret.sub!(m, email.to_s.empty? ? m.gsub(/^\{email-address\|/, '').gsub(/\}$/) : email.to_s)
                } 
                ret.scan(/#{Regexp.escape('{phone-number|')}.*#{Regexp.escape('}')}/).each { |m| 
                    ret.sub!(m, phone.to_s.empty? ? m.gsub(/^\{phone-number\|/, '').gsub(/\}$/) : phone.to_s)
                } 
                ret.scan(/#{Regexp.escape('{linkedin-url|')}.*#{Regexp.escape('}')}/).each { |m| 
                    ret.sub!(m, linkd.to_s.empty? ? m.gsub(/^\{linkedin-url\|/, '').gsub(/\}$/) : linkd.to_s)
                } 
                ret.scan(/#{Regexp.escape('{unsubscribe-url|')}.*#{Regexp.escape('}')}/).each { |m| 
                    ret.sub!(m, unsub.to_s.empty? ? m.gsub(/^\{unsubscribe-url\|/, '').gsub(/\}$/) : unsub.to_s)
                }
                # return
                ret             
            end

            # replace merge-tags in the subject with the values of the lead's atrtibutes.
            # return the subject with the merge-tags replaced.
            def merged_subject(lead)
                merge(self.subject, lead)
            end

            # replace merge-tags in the body with the values of the lead's atrtibutes.
            # return the body with the merge-tags replaced.
            def merged_body(lead)
                merge(self.body, lead)
            end

        end # class Address
    end # Emails
end # BlackStack