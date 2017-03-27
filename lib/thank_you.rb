# frozen_string_literal: true
require 'thank_you/version'
require 'gems'
require 'twitter'

# Say thanks
module Thank
  # Runs bundle show to get a list of gems used in the project
  # Using the twitter credentials, tweets thank you for the owners of the gem
  # if the twitter handle is present
  class You
    class << self
      def tweet
        return no_gemfile_error if no_gem_file_found?
        say_thanks
      end

      private

      def gem_list_from_bundle
        current_path = Dir.pwd
        `if [ -f #{current_path}/Gemfile ]
         then
           bundle show
         else
           echo Could not find the gemfile
         fi`
      end

      def gem_list
        gem_list_from_bundle.split(/\n+/)[1..-1].map do |name|
          name.tr('  *', '').gsub(/\(.*\)/, '')
        end
      end

      def msg(owner_name, gem_name)
        "Hi! @#{owner_name}, I am using your gem '#{gem_name}' for my project.
        Thank you for your help. Have a great day."
      end

      def say_thanks
        gem_list.each do |gem|
          owner_names = Gems.owners(gem)
          owner_names = owner_names.map { |e| e['handle'] }.compact
          owner_names.each do |owner_name|
            twitter_client.update(msg(owner_name, gem))
            puts "Tweeted thanks to #{owner_name} for #{gem}"
          end
        end
      end

      def no_gemfile_error
        puts 'Sorry. Could not find the Gemfile. Exiting'
      end

      def no_gem_file_found?
        gem_list_from_bundle.include?('Could not find gemfile')
      end

      def twitter_client
        Twitter::REST::Client.new do |config|
          config.consumer_key        = 'YOUR_CONSUMER_KEY'
          config.consumer_secret     = 'YOUR_CONSUMER_SECRET'
          config.access_token        = 'YOUR_ACCESS_TOKEN'
          config.access_token_secret = 'YOUR_ACCESS_SECRET'
        end
      end

      def gem_client
        Gems.configure do |config|
          config.key = 'YOUR_RUBY_KEY'
        end
      end
    end
  end
end
