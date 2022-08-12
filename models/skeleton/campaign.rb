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
                t == 0 ? 0 : ((self.stat_opens.to_f / t.to_f) * 100.to_f).to_i
            end

            def clicks_ratio
                t = self.stat_opens
                t == 0 ? 0 : ((self.stat_clicks.to_f / t.to_f) * 100.to_f).to_i
            end

            def unsubscribes_ratio
                t = self.stat_opens
                t == 0 ? 0 : ((self.stat_unsubscribes.to_f / t.to_f) * 100.to_f).to_i
            end

            # replace merge-tags in the string s with the values of the lead's atrtibutes.
            # return the string with the merge-tags replaced.
            # this is a general purpose method to send email.
            # this should not call this method.
            def merge(s, lead)
                ret = s.dup
                email = lead.emails.first.nil? ? '' : lead.emails.first.value
                phone = lead.phones.first.nil? ? '' : lead.phones.first.value
                linkd = lead.linkedins.first.nil? ? '' : lead.linkedins.first.value
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
                    ret.sub!(m, lead.stat_company_name.to_s.empty? ? m.gsub(/^\{company-name\|/, '').gsub(/\}$/, '') : lead.stat_company_name.to_s)
                } 
                ret.scan(/#{Regexp.escape('{first-name|')}.*#{Regexp.escape('}')}/).each { |m| 
                    ret.sub!(m, lead.first_name.to_s.empty? ? m.gsub(/^\{first-name\|/, '').gsub(/\}$/, '') : lead.first_name.to_s)
                } 
                ret.scan(/#{Regexp.escape('{last-name|')}.*#{Regexp.escape('}')}/).each { |m| 
                    ret.sub!(m, lead.last_name.to_s.empty? ? m.gsub(/^\{last-name\|/, '').gsub(/\}$/, '') : lead.last_name.to_s)
                } 
                ret.scan(/#{Regexp.escape('{location|')}.*#{Regexp.escape('}')}/).each { |m| 
                    ret.sub!(m, lead.stat_location_name.to_s.empty? ? m.gsub(/^\{location\|/, '').gsub(/\}$/, '') : lead.stat_location_name.to_s)
                } 
                ret.scan(/#{Regexp.escape('{industry|')}.*#{Regexp.escape('}')}/).each { |m| 
                    ret.sub!(m, lead.stat_industry_name.to_s.empty? ? m.gsub(/^\{industry\|/, '').gsub(/\}$/, '') : lead.stat_industry_name.to_s)
                } 
                ret.scan(/#{Regexp.escape('{email-address|')}.*#{Regexp.escape('}')}/).each { |m| 
                    ret.sub!(m, email.to_s.empty? ? m.gsub(/^\{email-address\|/, '').gsub(/\}$/, '') : email.to_s)
                } 
                ret.scan(/#{Regexp.escape('{phone-number|')}.*#{Regexp.escape('}')}/).each { |m| 
                    ret.sub!(m, phone.to_s.empty? ? m.gsub(/^\{phone-number\|/, '').gsub(/\}$/, '') : phone.to_s)
                } 
                ret.scan(/#{Regexp.escape('{linkedin-url|')}.*#{Regexp.escape('}')}/).each { |m| 
                    ret.sub!(m, linkd.to_s.empty? ? m.gsub(/^\{linkedin-url\|/, '').gsub(/\}$/, '') : linkd.to_s)
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

            # update the planning flags of this campaign
            def start_planning()
                self.planning_start_time = now
                self.save        
            end

            # update the planning flags of this campaign
            def end_planning(error=nil)
                self.planning_success = error.nil?
                self.planning_error_description = error
                self.planning_end_time = now
                self.save
            end

            # return true if there is a delivery for the given lead
            # otherwise return false
            def include?(lead)
                DB["
                    SELECT COUNT(*) AS n
                    FROM eml_job j
                    JOIN eml_delivery d ON (
                        j.id = d.id_job AND 
                        d.id_lead='#{lead.id.to_guid}' AND 
                        d.delivery_start_time IS NULL -- delivery should not be started yet
                    )
                    WHERE j.id_campaign = '#{self.id}'
                "].first[:n] > 0
            end

            # create a job to deliver an email to all the leads in the array `leads`, thru the address in `address`
            def create_jobs(leads, address)
                # create the job
                j = BlackStack::Emails::Job.new
                j.id = guid
                j.id_campaign = self.id
                j.create_time = now
                j.planning_id_address = address.id
                j.planning_time = address.next_available_day
                j.save
                
                # create deliveries for each lead
                leads.each { |lead|
                    d = BlackStack::Emails::Delivery.new
                    d.id = guid
                    d.id_job = j.id
                    d.id_lead = lead.id
                    d.create_time = now
                    d.email = lead.emails.first.value
                    d.subject = self.merged_subject(lead)
                    d.body = self.merged_body(lead)
                    d.save
                    # release resources
                    GC.start
                    DB.disconnect
                }

                # return the job
                j
            end

        end # class Campaign
    end # Emails
end # BlackStack