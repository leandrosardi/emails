# default screen
get "/emails", :agent => /(.*)/ do
    redirect2 "/emails/campaigns", params
end
get "/emails/", :agent => /(.*)/ do
    redirect2 "/emails/campaigns", params
end

# public email verification screen
get "/emails/verify", :agent => /(.*)/ do
    erb :"/extensions/emails/views/verify", :layout => :"/views/layouts/public"
end
get "/emails/verify/", :agent => /(.*)/ do
    erb :"/extensions/emails/views/verify", :layout => :"/views/layouts/public"
end
get "/emails/verify/:email", :agent => /(.*)/ do
    erb :"/extensions/emails/views/verify", :layout => :"/views/layouts/public"
end
get "/emails/verify/:email/", :agent => /(.*)/ do
    erb :"/extensions/emails/views/verify", :layout => :"/views/layouts/public"
end
post "/emails/filter_verify", :agent => /(.*)/ do
    erb :"/extensions/emails/views/filter_verify"
end

# email verification API
get '/api1.0/emails/verify.json' do #, :api_key=>true do
    erb :'/extensions/emails/views/api1.0/verify'
end

# public screens (signup, login)
get "/emails/signup", :agent => /(.*)/ do
    erb :"/extensions/emails/views/signup", :layout => :"/views/layouts/public"
end

get "/emails/login", :agent => /(.*)/ do
    erb :"/extensions/emails/views/login", :layout => :"/views/layouts/public"
end

# internal app screens - wizard
get "/emails/wizard/step1", :auth => true, :agent => /(.*)/ do
    erb :"/extensions/emails/views/step1", :layout => :"/views/layouts/core"
end

get "/emails/wizard/step2", :auth => true, :agent => /(.*)/ do
    erb :"/extensions/emails/views/step1", :layout => :"/views/layouts/core"
end

get "/emails/wizard/step3", :auth => true, :agent => /(.*)/ do
    erb :"/extensions/emails/views/step1", :layout => :"/views/layouts/core"
end

post "/emails/filter_step1", :auth => true, :agent => /(.*)/ do
    erb :"/extensions/emails/views/filter_step1"
end

post "/emails/filter_step2", :auth => true, :agent => /(.*)/ do
    erb :"/extensions/emails/views/filter_step2"
end

post "/emails/filter_step3", :auth => true, :agent => /(.*)/ do
    erb :"/extensions/emails/views/filter_step3"
end

# internal app screens - leads, leads upload and lists
get "/emails/leads", :auth => true, :agent => /(.*)/ do
    erb :"/extensions/leads/views/results", :layout => :"/views/layouts/core"
end

get "/emails/lists", :auth => true, :agent => /(.*)/ do
    erb :"/extensions/leads/views/exports", :layout => :"/views/layouts/core"
end

get "/emails/leads/uploads/new", :auth => true, :agent => /(.*)/ do
    erb :"/extensions/emails/views/new_upload_leads", :layout => :"/views/layouts/core"
end

post "/emails/leads/uploads/mapping", :auth => true, :agent => /(.*)/ do
    erb :"/extensions/emails/views/mapping_upload_leads", :layout => :"/views/layouts/core"
end

post "/emails/filter_new_upload_job", :auth => true, :agent => /(.*)/ do
    erb :"/extensions/emails/views/filter_new_upload_leads_job"
end

get "/emails/leads/uploads", :auth => true, :agent => /(.*)/ do
    erb :"/extensions/emails/views/upload_leads_jobs", :layout => :"/views/layouts/core"
end

get "/emails/leads/uploads/:id", :auth => true, :agent => /(.*)/ do
    erb :"/extensions/emails/views/upload_leads_job", :layout => :"/views/layouts/core"
end

# addresses
get "/emails/addresses", :auth => true, :agent => /(.*)/ do
    erb :"/extensions/emails/views/addresses", :layout => :"/views/layouts/core"
end

get "/emails/addresses/new", :auth => true, :agent => /(.*)/ do
    erb :"/extensions/emails/views/new_address", :layout => :"/views/layouts/core"
end

get "/emails/addresses/new/gmail", :auth => true, :agent => /(.*)/ do
    erb :"/extensions/emails/views/new_gmail_address", :layout => :"/views/layouts/core"
end

get "/emails/addresses/:aid/edit", :auth => true, :agent => /(.*)/ do
    erb :"/extensions/emails/views/edit_address", :layout => :"/views/layouts/core"
end

get "/emails/addresses/uploads/new", :auth => true, :agent => /(.*)/ do
    erb :"/extensions/emails/views/new_upload_addresses", :layout => :"/views/layouts/core"
end

post "/emails/addresses/uploads/mapping", :auth => true, :agent => /(.*)/ do
    erb :"/extensions/emails/views/mapping_upload_addresses", :layout => :"/views/layouts/core"
end

post "/emails/filter_new_upload_addresses_job", :auth => true, :agent => /(.*)/ do
    erb :"/extensions/emails/views/filter_new_upload_addresses_job"
end

get "/emails/addresses/uploads", :auth => true, :agent => /(.*)/ do
    erb :"/extensions/emails/views/upload_addresses_jobs", :layout => :"/views/layouts/core"
end

get "/emails/addresses/uploads/:id", :auth => true, :agent => /(.*)/ do
    erb :"/extensions/emails/views/upload_addresses_job", :layout => :"/views/layouts/core"
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

# schedules
get "/emails/campaigns/:gid/schedules", :auth => true, :agent => /(.*)/ do
    erb :"/extensions/emails/views/schedules", :layout => :"/views/layouts/core"
end
get "/emails/campaigns/:gid/schedules/new", :auth => true, :agent => /(.*)/ do
    erb :"/extensions/emails/views/new_schedule", :layout => :"/views/layouts/core"
end
post "/emails/filter_new_schedule", :auth => true, :agent => /(.*)/ do
    erb :"/extensions/emails/views/filter_new_schedule"
end
get "/emails/filter_delete_schedule", :auth => true, :agent => /(.*)/ do
    erb :"/extensions/emails/views/filter_delete_schedule"
end

# followups
get "/emails/campaigns/:gid/followups", :auth => true, :agent => /(.*)/ do
    erb :"/extensions/emails/views/followups", :layout => :"/views/layouts/core"
end
get "/emails/campaigns/:gid/followups/new", :auth => true, :agent => /(.*)/ do
    erb :"/extensions/emails/views/new_followup", :layout => :"/views/layouts/core"
end
get "/emails/campaigns/:gid/followups/:fid/edit", :auth => true, :agent => /(.*)/ do
    erb :"/extensions/emails/views/edit_followup", :layout => :"/views/layouts/core"
end
post "/emails/filter_new_followup", :auth => true, :agent => /(.*)/ do
    erb :"/extensions/emails/views/filter_new_followup"
end
get "/emails/filter_delete_followup", :auth => true, :agent => /(.*)/ do
    erb :"/extensions/emails/views/filter_delete_followup"
end
post "/emails/filter_edit_followup", :auth => true, :agent => /(.*)/ do
    erb :"/extensions/emails/views/filter_edit_followup"
end

# activities - campaigns
get "/emails/campaigns/:gid/report/:report", :auth => true, :agent => /(.*)/ do
    erb :"/extensions/emails/views/report_campaign", :layout => :"/views/layouts/core"
end

# activities - followups
get "/emails/campaigns/:gid/followups/:fid/report/:report", :auth => true, :agent => /(.*)/ do
    erb :"/extensions/emails/views/report_campaign", :layout => :"/views/layouts/core"
end

# unibox
get "/emails/unibox", :auth => true, :agent => /(.*)/ do
    erb :"/extensions/emails/views/unibox", :layout => :"/views/layouts/core"
end

get "/emails/campaign/:gid/unibox", :auth => true, :agent => /(.*)/ do
    erb :"/extensions/emails/views/unibox", :layout => :"/views/layouts/core"
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

post "/emails/filter_test_followup", :auth => true do
    erb :"/extensions/emails/views/filter_test_followup"
end
get "/emails/filter_test_followup", :auth => true do
    erb :"/extensions/emails/views/filter_test_followup"
end

post "/emails/filter_play_followup", :auth => true do
    erb :"/extensions/emails/views/filter_play_followup"
end
get "/emails/filter_play_followup", :auth => true do
    erb :"/extensions/emails/views/filter_play_followup"
end

post "/emails/filter_pause_followup", :auth => true do
    erb :"/extensions/emails/views/filter_pause_followup"
end
get "/emails/filter_pause_followup", :auth => true do
    erb :"/extensions/emails/views/filter_pause_followup"
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

post "/emails/filter_edit_addresses", :auth => true do
    erb :"/extensions/emails/views/filter_edit_addresses"
end
get "/emails/filter_edit_addresses", :auth => true do
    erb :"/extensions/emails/views/filter_edit_addresses"
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
