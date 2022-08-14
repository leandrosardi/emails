module BlackStack
    module Emails
        class Delivery < Sequel::Model(:eml_delivery)
            many_to_one :job, :class=>:'BlackStack::Emails::Job', :key=>:id_job
            many_to_one :lead, :class=>:'Leads::FlLead', :key=>:id_lead

            # update the delivery flags of this job
            def start_delivery()
                self.delivery_start_time = now
                self.save        
            end

            # update the delivery flags of this job
            def end_delivery(error=nil)
                self.delivery_success = error.nil?
                self.delivery_error_description = error
                self.delivery_end_time = now
                self.save
            end

            # send email
            def deliver()
                self.start_delivery
                begin
                    address = self.job.address
                    address = BlackStack::Emails::GMail.where(:id=>address.id).first # by now, I deliver using GMail accounts only.
                    campaign = self.job.campaign
                    address.send({
                        :to => self.email, 
                        :subject => self.subject, 
                        :body => self.body, 
                        :from_name => campaign.from_name, 
                        :reply_to => campaign.reply_to,
                    })
                    self.end_delivery

                    # increment the open count for the regarding campaign in the timeline snapshot
                    self.job.campaign.track('sent')
                rescue => e
                    self.end_delivery(e.message)
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
                # save the changes.
                self.save
            end

        end # class Delivery
    end # Emails
end # BlackStack