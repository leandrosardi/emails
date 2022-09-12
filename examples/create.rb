# load gem and connect database
require 'mail'

require 'mysaas'
require 'lib/stubs'
require 'config'
DB = BlackStack::CRDB::connect
require 'lib/skeletons'
require 'extensions/emails/lib/skeletons'

# this example is about parse a hash descritor with the address and mta parameter.

# this is the same `params` hash that I receive from the form in `emails/views/new_address.erb`.
params = {
    "id_user"=>"4b92c07f-70d3-47c8-9674-57e820edc8f3", 
    "smtp_address"=>"smtp.gmail.com", 
    "smtp_port"=>"25", 
    "imap_address"=>"imap.googlemail.com", 
    "imap_port"=>"993", 
    "type"=>"0", # google
    "address"=>"leandro@gmail.com", 
    "password"=>"pass1232",
}
puts "params: #{params.to_s}"

# this function call is to convert the keys, from strings to symbols.
# reference: https://stackoverflow.com/questions/800122/best-way-to-convert-strings-to-symbols-in-hash
h = params.transform_keys(&:to_sym)
puts "\nh: #{h.to_s}"

print 'Creating MTA... '
if BlackStack::Emails::Mta.exists?(h)
    mta = BlackStack::Emails::Mta.load(h)
    puts 'loaded'
else
    mta = BlackStack::Emails::Mta.new(h).save
    puts 'created'
end

print 'Creating Address... '
h[:id_mta] = mta.id
if BlackStack::Emails::Address.exists?(h)
    add = BlackStack::Emails::Address.load(h)
    puts 'loaded'
else
    add = BlackStack::Emails::Address.new(h).save
    puts 'created'
end