server 'staging.cayennelabs.it', user: 'cayenne', roles: %w(web app db), port: 22

set :rails_env, 'staging'
set :bundle_without, %w( development test production ).join(' ')

set :branch, 'master'
