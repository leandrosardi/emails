require 'extensions/emails/models/skeleton/address'
require 'extensions/emails/models/skeleton/campaign'
require 'extensions/emails/models/skeleton/click'
require 'extensions/emails/models/skeleton/open'
require 'extensions/emails/models/skeleton/unsubscribe'
require 'extensions/emails/models/skeleton/delivery'
require 'extensions/emails/models/skeleton/job'
require 'extensions/emails/models/skeleton/link'

require "google/apis/gmail_v1"
require "googleauth"
require "googleauth/stores/file_token_store"
require "fileutils"
require 'mail'

