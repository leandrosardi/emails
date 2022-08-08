# default screen
get "/emails", :agent => /(.*)/ do
    redirect2 "/emails/signup", params
end
get "/emails/", :agent => /(.*)/ do
    redirect2 "/emails/signup", params
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

get "/emails/campaigns/:gid/opens", :auth => true, :agent => /(.*)/ do
    erb :"/extensions/emails/views/opens", :layout => :"/views/layouts/core"
end

get "/emails/campaigns/:gid/clicks", :auth => true, :agent => /(.*)/ do
    erb :"/extensions/emails/views/clicks", :layout => :"/views/layouts/core"
end

get "/emails/campaigns/:gid/unsubscribes", :auth => true, :agent => /(.*)/ do
    erb :"/extensions/emails/views/unsubscribes", :layout => :"/views/layouts/core"
end

get "/emails/addresses", :auth => true, :agent => /(.*)/ do
    erb :"/extensions/emails/views/addresses", :layout => :"/views/layouts/core"
end

get "/emails/addresses/new", :auth => true, :agent => /(.*)/ do
    erb :"/extensions/emails/views/new_addresses", :layout => :"/views/layouts/core"
end

get "/emails/addresses/:gid/edit", :auth => true, :agent => /(.*)/ do
    erb :"/extensions/emails/views/edit_addresses", :layout => :"/views/layouts/core"
end

# filters
post "/emails/filter_new_campaign", :auth => true do
    erb :"/extensions/emails/views/filter_new_campaign"
end

post "/emails/filter_edit_campaign", :auth => true do
    erb :"/extensions/emails/views/filter_edit_campaign"
end

post "/emails/filter_launch_campaign", :auth => true do
    erb :"/extensions/emails/views/filter_launch_campaign"
end
get "/emails/filter_launch_campaign", :auth => true do
    erb :"/extensions/emails/views/filter_launch_campaign"
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
# TODO: Code Me!

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
