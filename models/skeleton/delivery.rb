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
                        :subject => campaign.merged_subject(lead), 
                        :body => campaign.merged_body(lead), 
                        :from_name => campaign.from_name, 
                        :reply_to => campaign.reply_to,
                        :track_opens => true,
                        :track_clicks => true,
                        :id_delivery => self.id,
                    })
                    self.end_delivery
                rescue => e
                    self.end_delivery(e.message)
                    raise e
                end
            end

        end # class Delivery
    end # Emails
end # BlackStack