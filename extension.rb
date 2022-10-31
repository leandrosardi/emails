BlackStack::Extensions::add ({
    # descriptive name and descriptor
    :name => 'Emails',
    :description => 'Convert your GMail accounts into an Email Marketing platform.',

    # setup the url of the repository for installation and updates
    :repo_url => 'https://github.com/leandrosardi/emails',
    :repo_branch => 'main',

    # define version with format <mayor>.<minor>.<revision>
    :version => '0.0.2',

    # define the name of the author
    :author => 'leandrosardi',

    # what is the section to add this extension in either the top-bar, the footer, the dashboard.
    :services_section => 'Services',
    # show this extension as a service in the top bar?
    :show_in_top_bar => false,
    # show this extension as a service in the footer?
    :show_in_footer => false,
    # show this extension as a service in the dashboard?
    :show_in_dashboard => false,

    # what are the screens to add in the leftbar
    :leftbar_icons => [
        { :label => 'leads', :icon => :heart, :screen => :leads, },
        { :label => 'lists', :icon => :list, :screen => :lists, },
        { :label => 'addresses', :icon => :envelope, :screen => :addresses, },
        { :label => 'inboxes', :icon => :inbox, :screen => :inboxes, },
        { :label => 'campaigns', :icon => :beaker, :screen => :campaigns, },
#        { :label => 'jobs', :icon => :tasks, :screen => :jobs, },
        { :label => 'activity', :icon => :tasks, :screen => :activity, },
    ],

    # add a folder to the storage from where user can download the exports.
    :storage_folders => [
        { :name => 'emails.pictures', },
        { :name => 'emails.leads.uploads', },
        # removed becuase of the issue https://github.com/leandrosardi/emails/issues/31
        #{ :name => 'emails.google.tokens', },
    ],

    # deployment routines
    :deployment_routines => [{
        :name => 'install-gems',
        :commands => [{ 
            # removed becuase of the issue https://github.com/leandrosardi/emails/issues/31
            #gem install --no-document google-api-client -v 0.53.0;
            :command => "
                gem install --no-document mail -v 2.7.1;
                gem install --no-document net-imap -v 0.2.3;
                gem install --no-document email_reply_parser -v 0.5.10;
                gem install --no-document csv -v 3.2.2;
                gem install --no-document verify_email_addresses -v 0.1.0;
                gem install --no-document email_verifier -v 0.1.0;
            ",
            :sudo => true,
        }],
    }, {
        :name => 'upload-google-api-certificate',
        :commands => [{ 
            # back up old configuration file
            # upload configuration file from local working directory to remote server
            :command => "
                cd ~/code/mysaas;
                mv ./google-api.json ./google-api.%timestamp%.json;
                echo '%google_api_json_file%' > ./google-api.json;
            ",
            #:matches => [ /^$/, /mv: cannot stat '\.\/config.rb': No such file or directory/ ],
            #:nomatches => [ { :nomatch => /.+/, :error_description => 'No output expected.' } ],
            :sudo => false,
        }],
    }, {
        :name => 'start-planning-process',
        :commands => [{ 
            # back up old configuration file
            # setup new configuration file
            :command => "
                source /home/%ssh_username%/.rvm/scripts/rvm; rvm install 3.1.2; rvm --default use 3.1.2;
                cd /home/%ssh_username%/code/mysaas/extensions/emails/p; 
                export RUBYLIB=/home/%ssh_username%/code/mysaas;
                nohup ruby planner.rb;
            ",
            :sudo => true,
            :background => true,
        }],
    }, {
        :name => 'start-delivery-process',
        :commands => [{ 
            # back up old configuration file
            # setup new configuration file
            :command => "
                source /home/%ssh_username%/.rvm/scripts/rvm; rvm install 3.1.2; rvm --default use 3.1.2;
                cd /home/%ssh_username%/code/mysaas/extensions/emails/p; 
                export RUBYLIB=/home/%ssh_username%/code/mysaas;
                nohup ruby delivery.rb;
            ",
            :sudo => true,
            :background => true,
        }],
    }],

    # define CSS files to add
    :css_files => [
        '/emails/css/inboxes.css',
    ],
})

# ----------------------------------------
# Pricing Model
# 
# Free Plan
# - 5,000 deliveries
# - Unlimited email verifications
# - Unlimited leads uploads
# - Unlimited sending addresses
# 
# Paid add-ons
# - DFY Databases
# - DFY Outreach
#

# setup the I2P product description here
BlackStack::I2P::add_services([
    { 
        :code=>'emails', 
        :name=>'Mail Merging & Tracking Service', 
        :unit_name=>'deliveries', 
        :consumption=>BlackStack::I2P::CONSUMPTION_BY_TIME, 
        # formal description to show in the list of products
        :description=>'CS Emails helps you scale your outreach campaigns through unlimited email sending accounts',
        # persuasive description to show in the sales letter
        :title=>'Scale Your Outreach Campaigns Through Unlimited Email Sending Accounts',
        # larger persuasive description to show in the sales letter
        :summary=>'CS Emails helps you scale your outreach campaigns through unlimited email sending accounts.',
        :thumbnail=>CS_HOME_WEBSITE+'/emails/images/logo.png',
        :return_path=>CS_HOME_WEBSITE+'/emails/leads',
        # what is the life time of this product or service?
        :credits_expiration_period => 'month',
        :credits_expiration_units => 1,
        # free tier configuration
        :free_tier=>{
            # add 10 records per month, for free
            :credits=>5000,
            :period=>'month',
            :units=>1,
        },
        # most popular plan configuratioon
        :most_popular_plan => 'emails.growth',
    },
])

# setup the I2P plans descriptors here
BlackStack::I2P::add_plans([
    {
        # which product is this plan belonging
        :service_code=>'emails', 
        # recurrent billing plan or one-time payments
        :type=>BlackStack::I2P::PAYMENT_SUBSCRIPTION,  
        # show this plan in the UI
        :public=>true,
        # is this a One-Time Offer?
        # true: this plan is available only if the account has not any invoice using this plan
        # false: this plan can be purchased many times
        :one_time_offer=>false,  
        # plan description
        :item_number=>'emails.growth', 
        :name=>'Growth Plan', 
        # billing details
        :credits=>100000, 
        :normal_fee=>99, # cognitive bias: expensive fee to show it strikethrough, as the normal price. But it's a lie. 
        :fee=>49, # this is the fee that your will charge to the account, as a special offer price.
        :period=>'month',
        :units=>1, # billed monthy
        # Force credits expiration in the moment when the client 
        # renew with a new payment from the same subscription.
        # Activate this option for every allocation service.
        :expiration_on_next_payment => true, # default true
        # Additional period after the billing cycle - Extend 2 weeks after the billing cycle - Referemce: https://github.com/ExpandedVenture/ConnectionSphere/issues/283.
        :expiration_lead_period => 'day', #'M', # default day
        :expiration_lead_units => 14, #3, # default 0
        # bonus
        :bonus_plans=>[
            { :item_number => "ces.lifetime", :period => 1 },
        ],
  }
])

# ----------------------------------------

# setup the I2P product description here
BlackStack::I2P::add_services([
    { 
        :code=>'dfy-databases', 
        :name=>'DFY Databases', 
        :unit_name=>'bind-record', 
        :consumption=>BlackStack::I2P::CONSUMPTION_BY_TIME, 
        # formal description to show in the list of products
        :description=>'Access our leads databases for cheap. Use them for your campaigns in our <b>Emails</b> service. Unlock the contact information just once the lead have replied positively.',
        # persuasive description to show in the sales letter
        :title=>'Access our leads databases for cheap. Unlock the contact information of those leads who replied positivly only.',
        # larger persuasive description to show in the sales letter
        :summary=>'Access our leads databases for cheap. Use them for your campaigns in our <b>Emails</b> service. Unlock the contact information just once the lead have replied positively.',
        :thumbnail=>CS_HOME_WEBSITE+'/dfy-databases/images/logo.png',
        :return_path=>CS_HOME_WEBSITE+'/dfy-databases/leads',
        # what is the life time of this product or service?
        :credits_expiration_period => 'month',
        :credits_expiration_units => 1,
        # no free tier configuration
        # most popular plan configuratioon
        :most_popular_plan => 'dfy-databases.bite',
    },
])

# setup the I2P plans descriptors here
BlackStack::I2P::add_plans([
    {
        # which product is this plan belonging
        :service_code=>'dfy-databases', 
        # recurrent billing plan or one-time payments
        :type=>BlackStack::I2P::PAYMENT_SUBSCRIPTION,  
        # show this plan in the UI
        :public=>true,
        # is this a One-Time Offer?
        # true: this plan is available only if the account has not any invoice using this plan
        # false: this plan can be purchased many times
        :one_time_offer=>false,  
        # plan description
        :item_number=>'dfy-databases.bite', 
        :name=>'A Bite of Our Data', 
        # billing details
        :credits=>50, 
        :normal_fee=>5, # cognitive bias: expensive fee to show it strikethrough, as the normal price. But it's a lie. 
        :fee=>1, # this is the fee that your will charge to the account, as a special offer price.
        :period=>'month',
        :units=>1, # billed monthy
        # Force credits expiration in the moment when the client 
        # renew with a new payment from the same subscription.
        # Activate this option for every allocation service.
        :expiration_on_next_payment => true, # default true
        # Additional period after the billing cycle - Extend 2 weeks after the billing cycle - Referemce: https://github.com/ExpandedVenture/ConnectionSphere/issues/283.
        :expiration_lead_period => 'day', #'M', # default day
        :expiration_lead_units => 14, #3, # default 0
        # bonus
        :bonus_plans=>[
            { :item_number => "ces.lifetime", :period => 1 },
        ],
  }
])

# ----------------------------------------

# setup the I2P product description here
BlackStack::I2P::add_services([
    { 
        :code=>'dfy-outreach', 
        :name=>'DFY Outreach', 
        :unit_name=>'crowd-deliveries', 
        :consumption=>BlackStack::I2P::CONSUMPTION_BY_TIME, 
        # formal description to show in the list of products
        :description=>'Deliver your email campaigns from our crowd of sending accounts. Save time and money building your own sending infrastructure.',
        # persuasive description to show in the sales letter
        :title=>'Deliver your email campaigns from our crowd of sending accounts. Save time and money building your own sending infrastructure.',
        # larger persuasive description to show in the sales letter
        :summary=>'Deliver your email campaigns from our crowd of sending accounts. Save time and money building your own sending infrastructure.',
        :thumbnail=>CS_HOME_WEBSITE+'/dfy-outreach/images/logo.png',
        :return_path=>CS_HOME_WEBSITE+'/dfy-outreach/leads',
        # what is the life time of this product or service?
        :credits_expiration_period => 'month',
        :credits_expiration_units => 1,
        # no free tier configuration
        # most popular plan configuratioon
        :most_popular_plan => 'dfy-outreach.batch',
    },
])

# setup the I2P plans descriptors here
BlackStack::I2P::add_plans([
    {
        # which product is this plan belonging
        :service_code=>'dfy-databases', 
        # recurrent billing plan or one-time payments
        :type=>BlackStack::I2P::PAYMENT_SUBSCRIPTION,  
        # show this plan in the UI
        :public=>true,
        # is this a One-Time Offer?
        # true: this plan is available only if the account has not any invoice using this plan
        # false: this plan can be purchased many times
        :one_time_offer=>false,  
        # plan description
        :item_number=>'dfy-outreach.batch', 
        :name=>'A Bite to Our Outreach System', 
        # billing details
        :credits=>50, 
        :normal_fee=>5, # cognitive bias: expensive fee to show it strikethrough, as the normal price. But it's a lie. 
        :fee=>1, # this is the fee that your will charge to the account, as a special offer price.
        :period=>'month',
        :units=>1, # billed monthy
        # Force credits expiration in the moment when the client 
        # renew with a new payment from the same subscription.
        # Activate this option for every allocation service.
        :expiration_on_next_payment => true, # default true
        # Additional period after the billing cycle - Extend 2 weeks after the billing cycle - Referemce: https://github.com/ExpandedVenture/ConnectionSphere/issues/283.
        :expiration_lead_period => 'day', #'M', # default day
        :expiration_lead_units => 14, #3, # default 0
        # bonus
        :bonus_plans=>[
            { :item_number => "ces.lifetime", :period => 1 },
        ],
  }
])