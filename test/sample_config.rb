# Sample Configuration
require 'logger'

host 'localhost'
port 1025

access_key "amazon-access-key"
secret_key "amazon-secret-key"
domain "example.com"
logger Logger.new(STDOUT)

# attach hooks to perform custom actions before and after emails are sent
before_send do|email|
  "sending email"
end

after_send do|email, status|
  "email sent with status: #{status}"
end
