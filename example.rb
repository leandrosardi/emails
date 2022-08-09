require "google/apis/gmail_v1"
require "googleauth"
require "googleauth/stores/file_token_store"
require "fileutils"
require 'mail'

OOB_URI = "urn:ietf:wg:oauth:2.0:oob".freeze
APPLICATION_NAME = "ConnectionSphere".freeze
CREDENTIALS_PATH = "credentials.json".freeze

# The file token.yaml stores the user's access and refresh tokens, and is
# created automatically when the authorization flow completes for the first
# time.
TOKEN_PATH = "token.yaml".freeze
SCOPE = Google::Apis::GmailV1::AUTH_SCOPE #AUTH_GMAIL_READONLY

# Ensure valid credentials, either by restoring from the saved credentials
# files or intitiating an OAuth2 authorization. If authorization is required,
# the user's default browser will be launched to approve the request.
#
# @return [Google::Auth::UserRefreshCredentials] OAuth2 credentials
def authorize
  client_id = Google::Auth::ClientId.from_file CREDENTIALS_PATH
  token_store = Google::Auth::Stores::FileTokenStore.new file: TOKEN_PATH
  authorizer = Google::Auth::UserAuthorizer.new client_id, SCOPE, token_store
  user_id = "default"
  credentials = authorizer.get_credentials user_id
  # first authentication
  if credentials.nil?
    url = authorizer.get_authorization_url base_url: OOB_URI
    puts "Open the following URL in the browser and enter the " \
         "resulting code after authorization:\n" + url
    code = gets
    credentials = authorizer.get_and_store_credentials_from_code(
      user_id: user_id, code: code, base_url: OOB_URI
    )
  end
  credentials
end

# Initialize the API
service = Google::Apis::GmailV1::GmailService.new
service.client_options.application_name = APPLICATION_NAME
service.authorization = authorize

# access the email account as the google logged-in
user_id = "me"

# get the email address of the google logged-in user
puts service.get_user_profile(user_id).email_address

=begin
# list labels
result = service.list_user_labels user_id
puts "Labels:"
puts "No labels found" if result.labels.empty?
result.labels.each { |label| puts "- #{label.name}"
=end

# example of sending email address, with HTML body, and reply_to field.
body = "This is a <b>test</b>.
Did you receive it?"
message = Mail.new(body)
message.to = 'sardi.leandro.daniel@gmail.com'
message.from = 'Pepe Garcia <leandro.sardi@expandedventure.com>'
message.reply_to = 'sardi.leandro.daniel.2@gmail.com'
message.subject = 'Test'
message.text_part = body
message.html_part = body
service.send_user_message(user_id, upload_source: StringIO.new(message.to_s), content_type: 'message/rfc822')

=begin
# read emails
# reference: https://googleapis.dev/ruby/google-api-client/latest/Google/Apis/GmailV1/Message.html
l = 500
query = 'to:sardi.leandro.daniel@gmail.com'
ids = service.fetch_all(max: l, items: :messages) { |token|
    service.list_user_messages('me', max_results: l, q: query, page_token: token)
}.map(&:id)

callback = lambda do |result, err|
    if err
        puts "error: #{err.inspect}"
    else
        headers = result.payload.headers
        date = headers.any? { |h| h.name == 'Date' } ? headers.find { |h| h.name == 'Date' }.value : ''
        subject = headers.any? { |h| h.name == 'Subject' } ? headers.find { |h| h.name == 'Subject' }.value : ''
        puts "#{result.id}, #{date}, #{subject}"

        # TODO: this is not working yet
        body = result.payload.body.data.to_s
        begin
            puts 'body:'+result.payload #body.to_s
        rescue => e
            puts 'body:'+e.message
        end
    end
end

ids.each_slice(1000) do |ids_array|
    service.batch do |gm|
        ids_array.each { |id| gm.get_user_message('me', id, &callback) }
    end
end
=end