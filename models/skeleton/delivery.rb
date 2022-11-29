module BlackStack
    module Emails
        class Delivery < Sequel::Model(:eml_delivery)
            many_to_one :job, :class=>:'BlackStack::Emails::Job', :key=>:id_job
            many_to_one :lead, :class=>:'BlackStack::LeadsLead', :key=>:id_lead
            many_to_one :user, :class=>:'BlackStack::Emails::User', :key=>:id_user
            many_to_one :address, :class=>:'BlackStack::Emails::Address', :key=>:id_address

            LOG_TYPES = ['pending', 'failed', 'sent', 'open', 'click', 'unsubscribe', 'bounce', 'complaint', 'reply']

            # return either plain-text or html version of the body, assuming it is the full mime content.
            # fix known problems of email_reply_parser gem: https://github.com/github/email_reply_parser#known-issues
            # - remove the mime lines
            # - remove the signature
            # concatenate all the lines finishing with `=`
            # 
            # references: 
            # - https://stackoverflow.com/questions/2505104/html-to-plain-text-with-ruby
            # - https://github.com/github/email_reply_parser
            # 
            # Also, remove open tracking pixel
            def simplified_body(type='text/html')
                # validate type is either text/html or text/plain
                raise 'type should either text/html or text/plain. Other values are not supported yet.' unless ['text/html', 'text/plain'].include?(type)
                # process the body, assuming it is the full mime content
                s = body
                did_i_found_the_content_part_i_want = false # auxuliar flag
                ret = ''
                email = EmailReplyParser.read(s)
                email.fragments.each { |f|
                    # convert fragment object to string
                    f = f.to_s
                    # if a new content part is starting
                    if f =~ /^Content\-Type\:/
                        # check if this is the content part i want
                        if !did_i_found_the_content_part_i_want
                            # activate the flag, to start collecting the content
                            if f.to_s =~ /^Content\-Type\: #{Regexp.escape(type)}/
                                did_i_found_the_content_part_i_want = true 
                            end
                        else
                            # I have colectingthe content, so I return it
                            return ret
                        end
                    end
                    if did_i_found_the_content_part_i_want
                        # split the lines
                        lines = f.split("\n")                
            
                        # remove the mime lines
                        lines=lines.drop(1) if lines[0] =~ /^\-\-[a-zA-Z0-9]+$/
                        lines=lines.drop(1) if lines[0] =~ /^Content-Type: (.*)$/
                        lines=lines.drop(1) if lines[0] =~ /^Content-Transfer-Encoding: (.*)$/

                        # lines below work for `plain/text` only.
                        # remove the signature
                        n = lines.size
                        if n>=1
                            lines.pop if lines[n-1] =~ /^wrote:$/i
                        end

                        n = lines.size
                        if n>=2
                            if lines[n-2] =~ /^On(.*)\=$/i
                                lines.pop 
                                lines.pop
                            end
                        end # if n>=2

                        n = lines.size
                        if n>=1
                            if lines[n-1] =~ /^On (.*)\<#{Regexp.escape(self.address.address)}\>$/i
                                lines.pop 
                            end
                        end

                        # add the content to the ret variable
                        ret += lines.join("\n")
                    end
                }
            
                # concatenate all the lines finishing with `=`
                ret = ret.gsub(/\=\n/, '')
            
                # return the content
                return ret
            end
            
            # return a hash descriptor of this object
            def to_hash
                # getting a simplified version of the body
                simplified = self.simplified_body('text/html')
                simplified = self.simplified_body('text/plain') if simplified.nil? || simplified.empty?
                simplified = self.body if simplified.nil? || simplified.empty?
                # build the hash
                {
                    :id => self.id,
                    :id_job => self.id_job,
                    :id_lead => self.id_lead,
                    :create_time => self.create_time,
                    :email => self.email,
                    :subject => self.subject,
                    :body => body,
                    :simplified_body => self.is_response ? simplified : self.body,
                    :message_id => self.message_id,
                    :is_response => self.is_response,
                    :id_conversation => self.id_conversation,
                    # valid if is_response is true only.
                    :id_user => self.id_user,
                    :id_address => self.id_address,
                    :name => self.name,
                }
            end

            def self.log_type_color(type)
                raise "Invalid log type #{type}." unless LOG_TYPES.include?(type)
                ret = nil
                case type
                    when 'pending'
                        ret = 'gray'
                    when 'failed'
                        ret = 'red'
                    when 'sent'
                        ret = 'green'
                    when 'open'
                        ret = 'blue'
                    when 'click'
                        ret = 'pink'
                    when 'unsubscribe'
                        ret = 'orange'
                    when 'bounce'
                        ret = 'red'
                    when 'complaint'
                        ret = 'red'
                    when 'reply'
                        ret = 'purple'
                end
                ret
            end

            # track en event in the table eml_log
            def track(type, url=nil, error_description=nil)
                raise "Invalid log type #{type}." unless LOG_TYPES.include?(type)
                DB.execute("
                    INSERT INTO eml_log (
                        id,
                        create_time,
                        \"type\",
                        \"color\",
                        id_lead,
                        id_delivery, 
                        id_job, 
                        id_campaign,
                        lead_name,
                        campaign_name,
                        planning_time,
                        \"url\",
                        planning_id_address,
                        \"address\",
                        \"subject\",
                        \"body\",
                        error_description,
                        id_account,
                        lead_email
                    ) VALUES (
                        '#{guid}',
                        '#{now}',
                        '#{type.to_sql}',
                        '#{self.class.log_type_color(type)}',
                        '#{self.id_lead}',
                        '#{self.id}',
                        '#{self.id_job}',
                        '#{self.job.id_campaign}',
                        '#{self.lead.name.to_sql}',
                        '#{self.job.campaign.name.to_sql}',
                        '#{self.job.planning_time}',
                        #{url.nil? ? "NULL" : "'#{url.to_sql}'"},
                        '#{self.job.address.id}',
                        '#{self.job.address.address.to_sql}',
                        '#{self.subject.to_sql}',
                        '#{self.body.to_sql}',
                        #{error_description.nil? ? "NULL" : "'#{error_description.to_sql}'"},
                        '#{self.job.campaign.user.id_account}',
                        '#{self.email.to_sql}'
                    )
                ")
            end

            # update the delivery flags of this job
            def start_delivery()
                self.delivery_start_time = now
                self.save        
            end

            # update the delivery flags of this job
            def end_delivery(error=nil, message_id=nil)
                self.delivery_success = error.nil?
                self.delivery_error_description = error
                self.delivery_end_time = now
                self.message_id = message_id
                self.save
            end

            # send email
            def deliver()
                self.start_delivery
                begin
                    address = self.job.address
                    campaign = self.job.campaign
                    message_id = address.send({
                        :to_email => self.email, 
                        :to_name => self.lead.name,
                        :subject => self.subject, 
                        :body => self.body, 
                        :from_name => campaign.from_name, 
                        :reply_to => campaign.reply_to,
                    })
                    self.end_delivery(nil, message_id)

                    # increment the open count for the regarding campaign in the timeline snapshot
                    self.job.track('sent')

                    # track log
                    self.track('sent')

                rescue => e
                    self.end_delivery(e.message)
                    # track log
                    self.track('failed', nil, e.message)
                    # raise the exception
                    raise e
                end
            end

            # return the url of the pixel for open tracking
            def pixel_url
                errors = []
                # validation: self.id is not nil and it is a valid guid
                errors << "id is nil" if self.id.nil? || !self.id.guid?
                # if any error happened, raise an exception
                raise errors.join(", ") if errors.size > 0
                # return
                "#{CS_HOME_WEBSITE}/api1.0/emails/open.json?did=#{self.id.to_guid}"
            end  

            # return the url of the pixel for click tracking
            def pixel
                "<img src='#{self.pixel_url}' height='1px' width='1px' />"
            end

            def unsubscribe_url
                "#{CS_HOME_WEBSITE}/api1.0/emails/unsubscribe.json?did=#{self.id.to_guid}"
            end

            # apply pixel for tracking opens.
            # apply tracking links.
            # apply unsubscribe link.
            # finally, call the save method of the parent class.
            def after_create
                # call the parent class save method.
                super
                # this trigger is for replies from the leads.
                return if self.is_response
                # this trigger is not for manually created deliveries.
                return if self.is_single
                # apply pixel for tracking opens.
                self.body += self.pixel
                # apply tracking links.
                # iterate all href attributes of anchor tags
                # reference: https://stackoverflow.com/questions/53766997/replacing-links-in-the-content-with-processed-links-in-rails-using-nokogiri
                n = 0
                fragment = Nokogiri::HTML.fragment(self.body)
                fragment.css("a[href]").each do |link| 
                    # increment the URL counter
                    n += 1
                    # get the link
                    l = BlackStack::Emails::Link.where(:id_campaign=>self.job.id_campaign, :link_number=>n).first
                    # validate the link URL
                    raise "Link #{n} is not found." if l.nil?
                    raise "Link #{n} #{l.url} don't match with #{link['href']}." if l.url != link['href']
                    # replace the link with the tracking link
                    link['href'] = l.tracking_url(self)
                end
                # update notification body.
                self.body = fragment.to_html
                # this forcing is because of this glitch: https://github.com/sparklemotion/nokogiri/issues/1127
                self.body.gsub!(/#{Regexp.escape('&amp;')}/, '&')
                # apply unsubscribe link.
                self.body.gsub!(/#{Regexp.escape(BlackStack::Emails::UNSUBSCRIBE_MERGETAG)}/, self.unsubscribe_url)
                # write history in eml_log
                self.track('pending')
                # save the changes.
                self.save
            end

            # insert reply from the lead to the database.
            # reutrn the new delivery object.
            def insert_reply(subject, from_name, from_email, date, message_id, body)
                # if the reply is already registered, then return it.
                r = BlackStack::Emails::Delivery.where(:message_id=>message_id).first
                return r if !r.nil?
                # create a conversation id
                if self.id_conversation.nil?
                    self.id_conversation = guid
                    self.save
                end
                # insert the reply
                r = BlackStack::Emails::Delivery.new
                r.id = guid
                r.id_job = self.id_job
                r.id_lead = self.id_lead
                r.create_time = now
                r.name = from_name
                r.email = from_email
                r.subject = subject
                r.body = body
                r.message_id = message_id
                r.id_user = self.id_user # this parameter is replicated (unnormalized), because the `eml_delivery` table is use to register manually sent (individual) emails too.
                r.id_address = self.id_address # this parameter is replicated (unnormalized), because the `eml_delivery` table is use to register manually sent (individual) emails too.
                r.id_conversation = self.id_conversation
                r.is_response = true # very important flag!
                r.in_reply_to = self.message_id
                r.save
                # track - write history in eml_log
                self.job.track('reply')
                self.track('reply')
                # return 
                r
            end # def insert_reply(subject, from_name, from_email, date, message_id, body)

        end # class Delivery
    end # Emails
end # BlackStack