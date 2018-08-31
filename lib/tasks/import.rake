require 'aws-sdk'
require 'dotenv/tasks'

namespace :import do
  task historical_data: :environment do
    Aws.config[:credentials] = Aws::Credentials.new(ENV["ACCESS_KEY_ID"], ENV["SECRET_ACCESS_KEY"])
    s3 = Aws::S3::Resource.new
    bucket = s3.bucket('zw-glp')
    csv = bucket.object('historical_data.csv')
    puts csv
  end
end
