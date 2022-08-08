# Emails

[MySaaS](https://github.com/leandrosardi/mysaas) extension to do free email marketing using GMail.

This project is under construction.

**Follow me to get notified when we release the beta-test!!**

## 1. Getting Started

Follow the steps below to install **Emails** as an extension in your **MySaaS** project 

We are assuming that you have installed your **MySaaS** in your computer, and it is working.

If you have not **MySaaS** working on your computer, follow [this tutorial](https://github.com/leandrosardi/mysaas/blob/main/docu/12.extensibility.md).

If you don't know how do **MySaaS** extensions work, refer to [this article](https://github.com/leandrosardi/mysaas#mysaas---open-source-saas-platform---extensible-and-scalable).

**Step 1:** Access the extensions folder of your **MySaaS** project.

```bash
cd ~/code/mysaas/extensions
```

**Step 2:** Clone the **Emails** project there.

```bash
git clone https://github.com/leandrosardi/emails/
```

**Step 3:** Add the extension in your configuration file

```ruby
# add required extensions
BlackStack::Extensions.append :emails
```

**Step 4:** Setup the extension in your configuration file

```ruby
# setup google api certificate - Remember to add it to the .gitignore file! 
BlackStack::Emails.set_google_api_certificate(LOCALW ? '/home/leandro/code/mysaas/google-api.json' : '/home/ubuntu/code/mysaas/google-api.json')
```

**Step 5:** Add certificates and tokens to your `.gitignore` file. _(optional)_

We recommend you also add `google-api.json` to the `.gitignore` file of your **MySaaS** project.

```ruby
# ignore google-api credentials
google-api.json
```

Also, add all authorization tokens of end-users.

```ruby
# ignore google-api access tokens
*.token.yaml
```

**Step 6:** Setup **Emails** as an [I2P](https://github.com/leandrosardi/i2p) product with plans. _(optional)_

Some screens of the **Emails** extensions are assuming that there is an I2P product called `'emails'`, with some plans defined too.

You should add both product and plans in the `config.rb` of **[MySaaS](https://github.com/leandrosardi/mysaas)**.

Here is a good example:

```ruby
# setup the product
BlackStack::I2P::add_services([
    { 
        :code=>'leads', 
        :name=>'B2B Contacts', 
        :unit_name=>'records', 
        :consumption=>BlackStack::I2P::CONSUMPTION_BY_TIME, 
        # formal description to show in the list of products
        :description=>'B2B Contacts with Emails & Phone Numbers',
        # persuasive description to show in the sales letter
        :title=>'The Best Data Quality, at the Best Price',
        # larger persuasive description to show in the sales letter
        :summary=>'B2B Contacts with verified <b>email addresses</b>, <b>phone numbers</b> and <b>LinkedIn profiles</b>.',
        :thumbnail=>CS_HOME_WEBSITE+'/leads/images/logo.png',
        :return_path=>CS_HOME_WEBSITE+'/leads/results',
        # what is the life time of this product or service?
        :credits_expiration_period => 'month',
        :credits_expiration_units => 1,
        # free tier configuration
        :free_tier=>{
            # add 10 records per month, for free
            :credits=>10,
            :period=>'month',
            :units=>1,
        },
        # most popular plan configuratioon
        :most_popular_plan => 'leads.batman',
    },
])

# setup the plan
BlackStack::I2P::add_plans([
    {
        # which product is this plan belonging
        :service_code=>'leads', 
        # recurrent billing plan or one-time payments
        :type=>BlackStack::I2P::PAYMENT_SUBSCRIPTION,  
        # show this plan in the UI
        :public=>false,
        # is this a One-Time Offer?
        # true: this plan is available only if the account has not any invoice using this plan
        # false: this plan can be purchased many times
        :one_time_offer=>true,  
        # plan description
        :item_number=>'leads.offer', 
        :name=>'90% Off', 
        # trial configuration
        :trial_credits=>280, 
        :trial_fee=>7, 
        :trial_units=>1, 
        :trial_period=>'month',     
        # billing details
        :credits=>28, 
        :normal_fee=>7, # cognitive bias: expensive fee to show it strikethrough, as the normal price. But it's a lie. 
        :fee=>7, # this is the fee that your will charge to the account, as a special offer price.
        :period=>'month',
        :units=>1, # billed monthy
		# Force credits expiration in the moment when the client 
		# renew with a new payment from the same subscription.
		# Activate this option for every allocation service.
		:expiration_on_next_payment => true, # default true
		# Additional period after the billing cycle - Extend 2 weeks after the billing cycle - Referemce: https://github.com/ExpandedVenture/ConnectionSphere/issues/283.
		:expiration_lead_period => 'day', #'M', # default day
		:expiration_lead_units => 365 #3, # default 0
    }, {
        # which product is this plan belonging
        :service_code=>'leads', 
        # recurrent billing plan or one-time payments
        :type=>BlackStack::I2P::PAYMENT_SUBSCRIPTION,  
        # show this plan in the UI
        :public=>true,
        # is this a One-Time Offer?
        # true: this plan is available only if the account has not any invoice using this plan
        # false: this plan can be purchased many times
        :one_time_offer=>false,  
        # plan description
        :item_number=>'leads.robin', 
        :name=>'Robin', 
        # billing details
        :credits=>28, 
        :normal_fee=>7, # cognitive bias: expensive fee to show it strikethrough, as the normal price. But it's a lie. 
        :fee=>7, # this is the fee that your will charge to the account, as a special offer price.
        :period=>'month',
        :units=>1, # billed monthy
		# Force credits expiration in the moment when the client 
		# renew with a new payment from the same subscription.
		# Activate this option for every allocation service.
		:expiration_on_next_payment => true, # default true
		# Additional period after the billing cycle - Extend 2 weeks after the billing cycle - Referemce: https://github.com/ExpandedVenture/ConnectionSphere/issues/283.
		:expiration_lead_period => 'day', #'M', # default day
		:expiration_lead_units => 365 #3, # default 0
    }, {
        # which product is this plan belonging
        :service_code=>'leads', 
        # recurrent billing plan or one-time payments
        :type=>BlackStack::I2P::PAYMENT_SUBSCRIPTION,  
        # show this plan in the UI
        :public=>true,
        # is this a One-Time Offer?
        # true: this plan is available only if the account has not any invoice using this plan
        # false: this plan can be purchased many times
        :one_time_offer=>false,  
        # plan description
        :item_number=>'leads.batman', 
        :name=>'Batman', 
        # billing details
        :credits=>135, 
        :normal_fee=>33, # cognitive bias: expensive fee to show it strikethrough, as the normal price. But it's a lie. 
        :fee=>27, # this is the fee that your will charge to the account, as a special offer price.
        :period=>'month',
        :units=>1, # billed monthy
		# Force credits expiration in the moment when the client 
		# renew with a new payment from the same subscription.
		# Activate this option for every allocation service.
		:expiration_on_next_payment => true, # default true
		# Additional period after the billing cycle - Extend 2 weeks after the billing cycle - Referemce: https://github.com/ExpandedVenture/ConnectionSphere/issues/283.
		:expiration_lead_period => 'day', #'M', # default day
		:expiration_lead_units => 365 #3, # default 0
    }, {
        # which product is this plan belonging
        :service_code=>'leads', 
        # recurrent billing plan or one-time payments
        :type=>BlackStack::I2P::PAYMENT_SUBSCRIPTION,  
        # show this plan in the UI
        :public=>true,
        # is this a One-Time Offer?
        # true: this plan is available only if the account has not any invoice using this plan
        # false: this plan can be purchased many times
        :one_time_offer=>false,  
        # plan description
        :item_number=>'leads.hulk', 
        :name=>'Hulk', 
        # billing details
        :credits=>314, 
        :normal_fee=>79, # cognitive bias: expensive fee to show it strikethrough, as the normal price. But it's a lie. 
        :fee=>47, # this is the fee that your will charge to the account, as a special offer price.
        :period=>'month',
        :units=>1, # billed monthy
		# Force credits expiration in the moment when the client 
		# renew with a new payment from the same subscription.
		# Activate this option for every allocation service.
		:expiration_on_next_payment => true, # default true
		# Additional period after the billing cycle - Extend 2 weeks after the billing cycle - Referemce: https://github.com/ExpandedVenture/ConnectionSphere/issues/283.
		:expiration_lead_period => 'day', #'M', # default day
		:expiration_lead_units => 365 #3, # default 0
    }
])
```

Restart the **MySaaS** webserver in order to get working the new extension.
