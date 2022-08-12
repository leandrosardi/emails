module BlackStack
    module Emails
        class Job < Sequel::Model(:eml_job)
            many_to_one :campaign, :class=>:'BlackStack::Emails::Campaign', :key=>:id_campaign
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


        end # class Job
    end # Emails
end # BlackStack