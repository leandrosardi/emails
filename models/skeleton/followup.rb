module BlackStack
    module Emails
        class Followup < Sequel::Model(:eml_followup)
            many_to_one :user, :class=>:'BlackStack::MySaaS::User', :key=>:id_user
            many_to_one :campaign, :class=>:'BlackStack::Emails::Campaign', :key=>:id_campaign      
            one_to_many :jobs, :class=>:'BlackStack::Emails::Job', :key=>:id_followup

            # types of email campaigns: text or html
            TYPE_TEXT = 0
            TYPE_HTML = 1

            # statuses of email campaigns: draft, sent, etc.
            STATUS_DRAFT = 0
            STATUS_ON = 1
            STATUS_OFF = 2
            STATUS_ERROR = 3

            # types
            def self.types
                [TYPE_TEXT, TYPE_HTML]
            end

            def self.type_name(n)
                case n
                when TYPE_TEXT
                    'Text'
                when TYPE_HTML
                    'HTML'
                else
                    'Unknown'
                end
            end

            def type_name
                BlackStack::Emails::Followup.type_name(self.type)
            end

            def type_color
                case self.type
                when TYPE_TEXT
                    'blue'
                when TYPE_HTML
                    'green'
                else
                    'red'
                end
            end

            # statuses of email campaigns: draft, sent, etc.
            def self.statuses
                [STATUS_DRAFT, STATUS_ON, STATUS_OFF, STATUS_ERROR]
            end

            def self.status_name(n)
                case n
                when STATUS_DRAFT
                    'Draft'
                when STATUS_ON
                    'On'
                when STATUS_OFF
                    'Off'
                when STATUS_ERROR
                    'Error'
                else
                    'Unknown'
                end
            end

            def status_name
                BlackStack::Emails::Followup.status_name(self.status)
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

            # leads in the export list.
            # note that may exist leads added after the campaign planning.
            def total_leads
                DB["
                    SELECT COUNT(el.*) AS n 
                    FROM fl_export_lead el
                    WHERE id_export = '#{self.campaign.id_export}'
                "].first[:n]
            end

            # total number of deliveries planned for this campaign
            def total_deliveries
                DB["
                    SELECT COUNT(*) AS n 
                    FROM eml_delivery d 
                    WHERE d.id_followup = '#{self.id}'
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

            # replace merge-tags in the string s with the values of the lead's atrtibutes.
            # return the string with the merge-tags replaced.
            # this is a general purpose method to send email.
            # this should not call this method.
            def merge(s, lead)
                ret = s.dup
                email = lead.emails.first.nil? ? '' : lead.emails.first.value
                phone = lead.phones.first.nil? ? '' : lead.phones.first.value
                linkd = lead.linkedins.first.nil? ? '' : lead.linkedins.first.value

                # replace merge-tags with no fallback values
                ret.gsub!(/#{Regexp.escape('{company-name}')}/, lead.stat_company_name.to_s)
                ret.gsub!(/#{Regexp.escape('{first-name}')}/, lead.first_name.to_s)
                ret.gsub!(/#{Regexp.escape('{last-name}')}/, lead.last_name.to_s)
                ret.gsub!(/#{Regexp.escape('{location}')}/, lead.stat_location_name.to_s)
                ret.gsub!(/#{Regexp.escape('{industry}')}/, lead.stat_industry_name.to_s)
                ret.gsub!(/#{Regexp.escape('{email-address}')}/, email.to_s)
                ret.gsub!(/#{Regexp.escape('{phone-number}')}/, phone.to_s)
                ret.gsub!(/#{Regexp.escape('{linkedin-url}')}/, linkd.to_s)

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

            # return true if 
            # - the lead sent a delivery for a followup with sequence_number-1, delivery_days before or ago
            # and
            # - the lead has not a delivery for a followup with same sequence_number;
            # otherwise return false
            def allowed_for?(lead)
                raise "sequence_number must be >= 1" if self.sequence_number < 1
                a = true
                b = true

                # the lead has not a delivery for a followup with same sequence_number
                a = DB["
                    SELECT COUNT(*) AS n
                    FROM eml_delivery d 
                    JOIN eml_followup f ON f.delivery_id = d.id
                    WHERE
                        d.id_lead='#{lead.id.to_guid}' AND 
                        f.id_campaign = '#{self.id_campaign.to_guid}' AND
                        f.sequence_number = #{self.sequence_number}
                "].first[:n] == 0

                if self.sequence_number > 1
                    # the lead sent a delivery for a followup with sequence_number-1, delivery_days before or ago
                    b = DB["
                        SELECT COUNT(*) AS n
                        FROM eml_delivery d 
                        JOIN eml_followup f ON f.delivery_id = d.id
                        WHERE
                            d.id_lead='#{lead.id.to_guid}' AND 
                            f.id_campaign = '#{self.id_campaign.to_guid}' AND
                            f.sequence_number = #{self.sequence_number} - 1 AND
                            d.delivery_end_time IS NOT NULL AND
                            d.delivery_end_time < CURRENT_TIMESTAMP - INTERVAL '#{self.delay_days} DAYS'
                    "].first[:n] == 0
                end # if sequence_number > 1

                # return 
                a && b
            end

            # create a deliver
            # return the delivery
            # 
            # choice 1, use the first VERIFIED email address of the lead.
            # choice 2, use ANY email address of the lead.
            # 
            def create_delivery(lead, address)
                email = lead.emails.select { |e| !e.verify_success.nil? && e.verify_success }.first.value
                email = lead.emails.first.value if email.nil?
                d = BlackStack::Emails::Delivery.new
                d.id = guid
                d.id_followup = self.id
                d.id_address = address.id
                d.id_lead = lead.id
                d.create_time = now
                # parameters
                d.email = email
                d.subject = self.merged_subject(lead).spin
                d.body = self.merged_body(lead).spin
                d.id_user = self.id_user # this parameter is replicated (unnormalized), because the `eml_delivery` table is use to register manually sent (individual) emails too.
                d.id_address = address.id # this parameter is replicated (unnormalized), because the `eml_delivery` table is use to register manually sent (individual) emails too.
                d.save
                # release resources
                GC.start
                DB.disconnect
                #
                d
            end

            # delete all the record in the table `eml_link` regarding this campaign.
            # create new record in the table `eml_link` for each anchor in the body.
            # call the `save` method of the parent class to save the changes.
            def after_create
                # call the `save` method of the parent class to save the changes.
                super
                # number of URL in the body
                n = 0
                # delete all the record in the table `eml_link` regarding this campaign.
                BlackStack::Emails::Link.where(:id_followup=>self.id).all { |link|
                    DB.execute("DELETE FROM eml_link WHERE id='#{link.id}'")
                    GC.start
                    DB.disconnect
                }
                # create new record in the table `eml_link` for each anchor in the body.
                # iterate all href attributes of anchor tags
                # reference: https://stackoverflow.com/questions/53766997/replacing-links-in-the-content-with-processed-links-in-rails-using-nokogiri
                fragment = Nokogiri::HTML.fragment(self.body)
                fragment.css("a[href]").each do |link| 
                    # increment the URL counter
                    n += 1
                    # create and save the object BlackStack::Emails::Link
                    o = BlackStack::Emails::Link.new
                    o.id = guid
                    o.id_followup = self.id
                    o.create_time = now
                    o.link_number = n
                    o.url = link['href']
                    o.save
                end
            end
        end # class Campaign
    end # Emails
end # BlackStack