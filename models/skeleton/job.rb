module BlackStack
    module Emails
        class Job < Sequel::Model(:eml_job)
            many_to_one :campaign, :class=>:'BlackStack::Emails::Campaign', :key=>:id_campaign
            many_to_one :address, :class=>:'BlackStack::Emails::Address', :key=>:id_address
            one_to_many :deliveries, :class=>:'BlackStack::Emails::Delivery', :key=>:id_job

            # return a list of jobs with pending deliveries, assigned to an address that is deleted, or it is belonging another account and no longer shared
            def self.abandoned()
                ret = []
                DB["
                    SELECT DISTINCT j.id
                    FROM eml_job j
                    JOIN eml_address a ON ( a.id = j.planning_id_address )
                    JOIN \"user\" u ON ( u.id = a.id_user )
                    JOIN account t ON t.id=u.id_account  
                    WHERE j.delivery_start_time IS NULL -- the job should not start to deliver yet 
                    AND (
                        -- address is deleted
                        a.delete_time IS NOT NULL
                        OR
                        -- address is belonging another account but it is no longer shared
                        (
                            a.shared=false
                            AND
                            a.id_user NOT IN ( 
                                select v.id 
                                from \"user\" v
                                where v.id_account=t.id
                            )
                        )
                    ) 
                "].all { |r| 
                    ret << BlackStack::Emails::Job.where(:id=>r[:id]).first
                    GC.start
                    DB.disconnect
                } 
                ret
            end # def abandoned_jobs()

            # return true if the jobs has pending deliveries; and it is assigned to an address that is deleted, or it is belonging another account and no longer shared
            def self.abandoned?
                BlackStack::Emails::Job.abandoned.map { |j| j.id.to_guid }.include?(self.id.to_guid)
            end

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

            # deliver all the pending deliveries of this job, stored in the table `eml_delivery`
            def deliver()
                self.deliveries.each { |delivery|
                    # deliver only if it didn't started delivery yet.
                    # this way, I can restart a failed job and don't email to the same lead twice.
                    delivery.deliver if delivery.delivery_start_time.nil?
                }
            end


        end # class Job
    end # Emails
end # BlackStack