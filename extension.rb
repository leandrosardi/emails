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
#        { :label => 'jobs', :icon => :tasks, :screen => :jobs, },
        { :label => 'activity', :icon => :tasks, :screen => :activity, },
        { :label => 'addresses', :icon => :tags, :screen => :addresses, },
    ],

    # add a folder to the storage from where user can download the exports.
    :storage_folders => [
        { :name => 'emails.pictures', },
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
})