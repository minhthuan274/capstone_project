
require 'carrierwave/storage/abstract'
require 'carrierwave/storage/file'
require 'carrierwave/storage/fog'

if Rails.env.production?
    CarrierWave.configure do |config|
        config.fog_provider = 'fog/aws'
        config.fog_directory     =  'books-management'
        config.fog_credentials = {
        # Configuration for Amazon S3
        :provider              => 'AWS',
        :aws_access_key_id     => 'AKIAIPWNK3MNW6FH2OOQ',
        :aws_secret_access_key => '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',
        :region                => 'ap-southeast-1'
        }
    end
end
