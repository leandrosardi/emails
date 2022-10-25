# default screen
get "/emails", :agent => /(.*)/ do
    redirect2 "/emails/campaigns", params
end
get "/emails/", :agent => /(.*)/ do
    redirect2 "/emails/campaigns", params
end

# public screens (signup/landing page)
get "/emails/signup", :agent => /(.*)/ do
    erb :"/extensions/emails/views/signup", :layout => :"/views/layouts/public"
end

# public screens (login page)
get "/emails/login", :agent => /(.*)/ do
    erb :"/extensions/emails/views/login", :layout => :"/views/layouts/public"
end

# internal app screens - leads upload
get "/emails/leads/uploads/new", :auth => true, :agent => /(.*)/ do
    erb :"/extensions/emails/views/new_upload_leads", :layout => :"/views/layouts/core"
end

post "/emails/leads/uploads/mapping", :auth => true, :agent => /(.*)/ do
    erb :"/extensions/emails/views/mapping_upload_leads", :layout => :"/views/layouts/core"
end

post "/emails/filter_new_upload_job", :auth => true, :agent => /(.*)/ do
    erb :"/extensions/emails/views/filter_new_upload_job"
end

get "/emails/leads/uploads", :auth => true, :agent => /(.*)/ do
    erb :"/extensions/emails/views/upload_leads_jobs", :layout => :"/views/layouts/core"
end

get "/emails/leads/uploads/:id", :auth => true, :agent => /(.*)/ do
    erb :"/extensions/emails/views/upload_leads_job", :layout => :"/views/layouts/core"
end

# internal app screens - campaigns
get "/emails/campaigns", :auth => true, :agent => /(.*)/ do
    erb :"/extensions/emails/views/campaigns", :layout => :"/views/layouts/core"
end

get "/emails/campaigns/new", :auth => true, :agent => /(.*)/ do
    erb :"/extensions/emails/views/new_campaign", :layout => :"/views/layouts/core"
end

get "/emails/campaigns/:gid/edit", :auth => true, :agent => /(.*)/ do
    erb :"/extensions/emails/views/edit_campaign", :layout => :"/views/layouts/core"
end

get "/emails/campaigns/:gid/:report", :auth => true, :agent => /(.*)/ do
    erb :"/extensions/emails/views/report_campaign", :layout => :"/views/layouts/core"
end

get "emails/campaigns/:id/schedules/new", :auth => true, :agent => /(.*)/ do
    erb :"/extensions/emails/views/new_schedule", :layout => :"/views/layouts/core"
end
get "emails/campaigns/:id/schedules/:sid/edit", :auth => true, :agent => /(.*)/ do
    erb :"/extensions/emails/views/edit_schedule", :layout => :"/views/layouts/core"
end
post "emails/filter_new_schedule", :auth => true, :agent => /(.*)/ do
    erb :"/extensions/emails/views/filter_new_schedule"
end
get "emails/filter_delete_schedule", :auth => true, :agent => /(.*)/ do
    erb :"/extensions/emails/views/filter_delete_schedule"
end
post "emails/filter_edit_schedule", :auth => true, :agent => /(.*)/ do
    erb :"/extensions/emails/views/filter_edit_schedule"
end

get "emails/campaigns/:id/followups/new", :auth => true, :agent => /(.*)/ do
    erb :"/extensions/emails/views/new_followup", :layout => :"/views/layouts/core"
end
get "emails/campaigns/:id/followups/:fid/edit", :auth => true, :agent => /(.*)/ do
    erb :"/extensions/emails/views/edit_followup", :layout => :"/views/layouts/core"
end
post "emails/filter_new_followup", :auth => true, :agent => /(.*)/ do
    erb :"/extensions/emails/views/filter_new_followup"
end
get "emails/filter_delete_followup", :auth => true, :agent => /(.*)/ do
    erb :"/extensions/emails/views/filter_delete_followup"
end
post "emails/filter_edit_followup", :auth => true, :agent => /(.*)/ do
    erb :"/extensions/emails/views/filter_edit_followup"
end

get "/emails/campaigns/:gid/sent", :auth => true, :agent => /(.*)/ do
    erb :"/extensions/emails/views/report_campaign?report=sents", :layout => :"/views/layouts/core"
end
get "/emails/campaigns/:gid/replies", :auth => true, :agent => /(.*)/ do
    erb :"/extensions/emails/views/report_campaign?report=replies", :layout => :"/views/layouts/core"
end
get "/emails/campaigns/:gid/opens", :auth => true, :agent => /(.*)/ do
    erb :"/extensions/emails/views/report_campaign?report=opens", :layout => :"/views/layouts/core"
end
get "/emails/campaigns/:gid/clicks", :auth => true, :agent => /(.*)/ do
    erb :"/extensions/emails/views/report_campaign?report=clicks", :layout => :"/views/layouts/core"
end
get "/emails/campaigns/:gid/unsubscribes", :auth => true, :agent => /(.*)/ do
    erb :"/extensions/emails/views/report_campaign?report=unsubscribes", :layout => :"/views/layouts/core"
end

get "/emails/addresses", :auth => true, :agent => /(.*)/ do
    erb :"/extensions/emails/views/addresses", :layout => :"/views/layouts/core"
end

get "/emails/addresses/new", :auth => true, :agent => /(.*)/ do
    erb :"/extensions/emails/views/new_address", :layout => :"/views/layouts/core"
end

get "/emails/addresses/new/gmail", :auth => true, :agent => /(.*)/ do
    erb :"/extensions/emails/views/new_gmail_address", :layout => :"/views/layouts/core"
end

get "/emails/addresses/new/hotmail", :auth => true, :agent => /(.*)/ do
    erb :"/extensions/emails/views/new_hotmail_address", :layout => :"/views/layouts/core"
end

get "/emails/addresses/:aid/edit", :auth => true, :agent => /(.*)/ do
    erb :"/extensions/emails/views/edit_address", :layout => :"/views/layouts/core"
end

get "/emails/leads", :auth => true, :agent => /(.*)/ do
    erb :"/extensions/leads/views/results", :layout => :"/views/layouts/core"
end

get "/emails/lists", :auth => true, :agent => /(.*)/ do
    erb :"/extensions/leads/views/exports", :layout => :"/views/layouts/core"
end
=begin
get "/emails/lists/:lid", :auth => true, :agent => /(.*)/ do
    erb :"/extensions/leads/views/edit_export", :layout => :"/views/layouts/core"
end

get "/emails/jobs", :auth => true, :agent => /(.*)/ do
    erb :"/extensions/emails/views/jobs", :layout => :"/views/layouts/core"
end

get "/emails/jobs/:jid", :auth => true, :agent => /(.*)/ do
    erb :"/extensions/emails/views/view_job", :layout => :"/views/layouts/core"
end
=end
get "/emails/activity", :auth => true, :agent => /(.*)/ do
    erb :"/extensions/emails/views/report_campaign", :layout => :"/views/layouts/core"
end

get "/emails/inboxes", :auth => true, :agent => /(.*)/ do
    erb :"/extensions/emails/views/inboxes", :layout => :"/views/layouts/core"
end

# filters
post "/emails/filter_new_campaign", :auth => true do
    erb :"/extensions/emails/views/filter_new_campaign"
end

post "/emails/filter_edit_campaign", :auth => true do
    erb :"/extensions/emails/views/filter_edit_campaign"
end

get "/emails/filter_delete_campaign", :auth => true do
    erb :"/extensions/emails/views/filter_delete_campaign"
end

post "/emails/filter_test_campaign", :auth => true do
    erb :"/extensions/emails/views/filter_test_campaign"
end
get "/emails/filter_test_campaign", :auth => true do
    erb :"/extensions/emails/views/filter_test_campaign"
end

post "/emails/filter_play_campaign", :auth => true do
    erb :"/extensions/emails/views/filter_play_campaign"
end
get "/emails/filter_play_campaign", :auth => true do
    erb :"/extensions/emails/views/filter_play_campaign"
end

post "/emails/filter_pause_campaign", :auth => true do
    erb :"/extensions/emails/views/filter_pause_campaign"
end
get "/emails/filter_pause_campaign", :auth => true do
    erb :"/extensions/emails/views/filter_pause_campaign"
end

post "/emails/filter_new_address", :auth => true do
    erb :"/extensions/emails/views/filter_new_address"
end

post "/emails/filter_edit_address", :auth => true do
    erb :"/extensions/emails/views/filter_edit_address"
end
get "/emails/filter_edit_address", :auth => true do
    erb :"/extensions/emails/views/filter_edit_address"
end

get "/emails/filter_delete_address", :auth => true do
    erb :"/extensions/emails/views/filter_delete_address"
end

# AJAX 
post "/ajax/emails/upload_picture.json", :auth => true do
    erb :"/extensions/emails/views/ajax/upload_picture"
end

post "/ajax/emails/load_deliveries.json", :auth => true do
    erb :"/extensions/emails/views/ajax/load_deliveries"
end

post "/ajax/emails/create_delivery.json", :auth => true do
    erb :"/extensions/emails/views/ajax/create_delivery"
end

# API
get "/api1.0/emails/open.json" do
    erb :"/extensions/emails/views/api1.0/open"
end

get "/api1.0/emails/click.json" do
    erb :"/extensions/emails/views/api1.0/click"
end

get "/api1.0/emails/unsubscribe.json" do
    erb :"/extensions/emails/views/api1.0/unsubscribe"
end
