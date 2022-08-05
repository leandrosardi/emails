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
        { :label => 'campaigns', :icon => :desktop, :screen => :campaigns, },
        { :label => 'gmails', :icon => :random, :screen => :gmails, },
        #{ :label => 'readers', :icon => :'user', :screen => :readers, },
        #{ :label => 'profits', :icon => :'money', :screen => :'profits', },
    ],

    # add a folder to the storage from where user can download the exports.
    :storage_folders => [
        { :name => 'emails.pictures', },
    ],

    # deployment routines
    :deployment_routines => [{
        :name => 'install-gems',
        :commands => [{ 
            :command => "
                gem install google-api-client -v 0.53.0
                gem install rmail -v 1.1.4
            ",
            :sudo => true,
        }],
    }],

    # define CSS files to add
    :css_files => [
        '/content/css/section.css',
    ],
})