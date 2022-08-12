BlackStack::Extensions::add ({
    # descriptive name and descriptor
    :name => 'Emails',
    :description => 'Manage thousands of GMail accounts from one signle dashboard.',

    # setup the url of the repository for installation and updates
    :repo_url => 'https://github.com/leandrosardi/emails',
    :repo_branch => 'main',

    # define version with format <mayor>.<minor>.<revision>
    :version => '0.0.1',

    # define the name of the author
    :author => 'leandrosardi',

    # what is the section to add this extension in either the top-bar, the footer, the dashboard.
    :services_section => 'Services for Marketers',
    # show this extension as a service in the top bar?
    :show_in_top_bar => true,
    # show this extension as a service in the footer?
    :show_in_footer => true,
    # show this extension as a service in the dashboard?
    :show_in_dashboard => true,

    # what are the screens to add in the leftbar
    :leftbar_icons => [
        { :label => 'leads', :icon => :heart, :screen => :leads, },
        { :label => 'lists', :icon => :list, :screen => :lists, },
        { :label => 'campaigns', :icon => :envelope, :screen => :campaigns, },
        { :label => 'jobs', :icon => :tasks, :screen => :jobs, },
        { :label => 'deliveries', :icon => :truck, :screen => :deliveries, },
        #{ :label => 'addresses', :icon => :tags, :screen => :addresses, },
    ],

    # add a folder to the storage from where user can download the exports.
    :storage_folders => [
        { :name => 'emails.pictures', },
        { :name => 'emails.google.tokens', },
    ],

    # deployment routines
    :deployment_routines => [{
        :name => 'install-gems',
        :commands => [{ 
            :command => "
                gem install google-api-client -v 0.53.0
                gem install mail -v 2.7.1
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
                echo \"%google_api_json_content%\" > ./google-api.json;
            ",
            #:matches => [ /^$/, /mv: cannot stat '\.\/config.rb': No such file or directory/ ],
            #:nomatches => [ { :nomatch => /.+/, :error_description => 'No output expected.' } ],
            :sudo => false,
        }],
    }],
})