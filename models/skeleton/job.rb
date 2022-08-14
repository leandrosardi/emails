module BlackStack
    module Emails
        class Job < Sequel::Model(:eml_job)
            many_to_one :campaign, :class=>:'BlackStack::Emails::Campaign', :key=>:id_campaign
            many_to_one :address, :class=>:'BlackStack::Emails::Address', :key=>:planning_id_address
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

            # increment the counter of an event in the timeline of the campaign
            # event must be ['sent', 'open', 'click', 'bounce', 'unsubscribe', 'complaint']
            def track(event_name)
                raise "unknown event" if !['sent', 'open', 'click', 'bounce', 'unsubscribe', 'complaint'].include?(event_name)
                # get unique key: id_campaign, year, month, day, hour, minute
                # TODO: get a more reusable way to get year, month, day, hour, minute.
                cid = self.id_campaign.to_guid
                aid = self.planning_id_address.to_guid
                dt = now # example: 2022-01-01 00:00:00
                year = dt[0..3]
                month = dt[5..6]
                day = dt[8..9]
                hour = dt[11..12]
                minute = dt[14..15]
                # tracking in the timeline snapshpt, with ACID
                DB.execute("
                    -- start transaction
                    --BEGIN;

                    -- insert the record eml_campaign_timeline
                    -- Remember there is an unique key: id_campaign, year, month, day, hour, minute
                    -- So, I insert the record but I catch any conflitc with a `on conflitct do nothing` clause.
                    INSERT INTO eml_campaign_timeline 
                    (
                        id, id_campaign, create_time, 
                        year, month, day, hour, minute, 
                        stat_sents, stat_opens, stat_clicks, stat_bounces, stat_unsubscribes, stat_complaints
                    )
                    VALUES (
                        '#{guid}', '#{cid}', '#{dt}',
                        #{year}, #{month}, #{day}, #{hour}, #{minute},
                        0, 0, 0, 0, 0, 0
                    ) ON CONFLICT DO NOTHING;

                    -- insert the record eml_address_timeline
                    -- Remember there is an unique key: id_address, id_campaign, year, month, day, hour, minute
                    -- So, I insert the record but I catch any conflitc with a `on conflitct do nothing` clause.
                    INSERT INTO eml_address_timeline 
                    (
                        id, id_address, id_campaign, create_time, 
                        year, month, day, hour, minute, 
                        stat_sents, stat_opens, stat_clicks, stat_bounces, stat_unsubscribes, stat_complaints
                    )
                    VALUES (
                        '#{guid}', '#{aid}', '#{cid}', '#{dt}',
                        #{year}, #{month}, #{day}, #{hour}, #{minute},
                        0, 0, 0, 0, 0, 0
                    ) ON CONFLICT DO NOTHING;

                    -- increment the counter of the event in the eml_campaign_timeline snapshot
                    UPDATE eml_campaign_timeline 
                    SET stat_#{event_name}s = stat_#{event_name}s + 1 
                    WHERE id_campaign = '#{cid}' 
                    AND year = #{year} 
                    AND month = #{month} 
                    AND day = #{day} 
                    AND hour = #{hour} 
                    AND minute = #{minute};

                    -- increment the counter of the event in the eml_address_timeline snapshot
                    UPDATE eml_address_timeline 
                    SET stat_#{event_name}s = stat_#{event_name}s + 1 
                    WHERE id_address = '#{aid}' 
                    AND id_campaign = '#{cid}' 
                    AND year = #{year} 
                    AND month = #{month} 
                    AND day = #{day} 
                    AND hour = #{hour} 
                    AND minute = #{minute};

                    -- increment the counter of the event in the campaign record
                    UPDATE eml_campaign 
                    SET stat_#{event_name}s = stat_#{event_name}s + 1 
                    WHERE id = '#{cid}' 
                    
                    -- commit transaction
                    --COMMIT;
                ")
            end # def track

        end # class Job
    end # Emails
end # BlackStack