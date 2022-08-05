BlackStack::Extensions::add ({
    # descriptive name and descriptor
    :name => 'Content',
    :description => 'Get paid for your knowledge. Publish online seminars and courses inside a user interface designed to get readers to purchasing.',

    # setup the url of the repository for installation and updates
    :repo_url => 'https://github.com/leandrosardi/content',
    :repo_branch => 'main',

    # define version with format <mayor>.<minor>.<revision>
    :version => '0.0.1',

    # define the name of the author
    :author => 'leandrosardi',

    # what is the section to add this extension in either the top-bar, the footer, the dashboard.
    :services_section => 'Services for Marketers',
    # show this extension as a service in the top bar?
    :show_in_top_bar => false,
    # show this extension as a service in the footer?
    :show_in_footer => false,
    # show this extension as a service in the dashboard?
    :show_in_dashboard => false,

    # what are the screens to add in the leftbar
    :leftbar_icons => [
        { :label => 'paths', :icon => :random, :screen => :paths, },
        { :label => 'seminars', :icon => :desktop, :screen => :seminars, },
        #{ :label => 'readers', :icon => :'user', :screen => :readers, },
        #{ :label => 'profits', :icon => :'money', :screen => :'profits', },
    ],

    # add a folder to the storage from where user can download the exports.
    :storage_folders => [
        { :name => 'content.pictures', },
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