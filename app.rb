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

# internal app screens
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

get "/emails/addresses", :auth => true, :agent => /(.*)/ do
    erb :"/extensions/emails/views/addresses", :layout => :"/views/layouts/core"
end

get "/emails/addresses/new", :auth => true, :agent => /(.*)/ do
    erb :"/extensions/emails/views/new_address", :layout => :"/views/layouts/core"
end

get "/emails/leads", :auth => true, :agent => /(.*)/ do
    erb :"/extensions/emails/views/leads", :layout => :"/views/layouts/core"
end

get "/emails/lists", :auth => true, :agent => /(.*)/ do
    erb :"/extensions/emails/views/lists", :layout => :"/views/layouts/core"
end

get "/emails/lists/:lid", :auth => true, :agent => /(.*)/ do
    erb :"/extensions/emails/views/view_list", :layout => :"/views/layouts/core"
end

get "/emails/jobs", :auth => true, :agent => /(.*)/ do
    erb :"/extensions/emails/views/jobs", :layout => :"/views/layouts/core"
end

get "/emails/jobs/:jid", :auth => true, :agent => /(.*)/ do
    erb :"/extensions/emails/views/view_job", :layout => :"/views/layouts/core"
end

get "/emails/deliveries", :auth => true, :agent => /(.*)/ do
    erb :"/extensions/emails/views/deliveries", :layout => :"/views/layouts/core"
end


# filters
post "/emails/filter_new_campaign", :auth => true do
    erb :"/extensions/emails/views/filter_new_campaign"
end

post "/emails/filter_edit_campaign", :auth => true do
    erb :"/extensions/emails/views/filter_edit_campaign"
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

# AJAX 
post "/ajax/emails/upload_picture.json", :auth => true do
    erb :"/extensions/emails/views/ajax/upload_picture"
end

# API
get "/api1.0/emails/open.json", :auth => true do
    erb :"/extensions/emails/views/api1.0/open"
end

get "/api1.0/emails/click.json", :auth => true do
    erb :"/extensions/emails/views/api1.0/click"
end

get "/api1.0/emails/unsubscribe.json", :auth => true do
    erb :"/extensions/emails/views/api1.0/unsubscribe"
end
