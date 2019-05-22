run 'pgrep spring | xargs kill -9'

# GEMFILE
########################################
run 'rm Gemfile'
file 'Gemfile', <<-RUBY
source 'https://rubygems.org'
ruby '2.5.3'

gem 'rails', '~> 5.2.3'
gem 'pg', '>= 0.18', '< 2.0'
gem 'puma', '~> 3.11'
gem 'uglifier', '>= 1.3.0'
gem 'webpacker'
gem 'react-rails'
gem 'jbuilder', '~> 2.5'
gem 'redis', '~> 4.0'
gem 'font-awesome-sass', '~> 5.6.1'
gem 'bootsnap'
gem 'capistrano-rails', group: :development

group :development, :test do
  gem 'byebug'
  gem 'dotenv-rails'
end

group :development do
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'web-console', '>= 3.3.0'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

group :test do
  gem 'capybara', '>= 2.15'
  gem 'selenium-webdriver'
  gem 'chromedriver-helper'
end
RUBY

# Procfile
########################################
file 'Procfile', <<-YAML
web: bundle exec puma -C config/puma.rb
YAML

# Webpack Javascript Setup
########################################
run 'rm -rf app/javascript'
run 'rm -rf vendor'
run 'curl -L https://github.com/rdzcn/my-templates/blob/master/app-javascript.zip > javascript.zip'
run 'unzip javascript.zip -d app && rm javascript.zip && mv app/app-javascript app/javascript'

# Dev environment
########################################
gsub_file('config/environments/development.rb', /config\.assets\.debug.*/, 'config.assets.debug = false')

# Layout
########################################
run 'rm app/views/layouts/application.html.erb'
file 'app/views/layouts/application.html.erb', <<-HTML
<!DOCTYPE html>
<html>
  <head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
    <title>TODO</title>
    <%= csrf_meta_tags %>
    <%= action_cable_meta_tag %>
  </head>
  <body>
    <%= yield %>
    <%= javascript_pack_tag 'application' %>
  </body>
</html>
HTML

# Generators
########################################
generators = <<-RUBY
config.generators do |generate|
      generate.assets false
      generate.helper false
      generate.test_framework  :test_unit, fixture: false
    end
RUBY

########################################
# AFTER BUNDLE
########################################
after_bundle do
  # Generators: db + simple form + pages controller
  ########################################
  rails_command 'db:drop db:create db:migrate'
  rails_command 'generate react:install'
  rails_command 'generate controller pages home --skip-routes --no-test-framework'
 

	# Webpack Javascript Setup
	########################################
	run 'rm -rf app/javascript'
	run 'rm -rf vendor'
	run 'curl -L https://github.com/rdzcn/my-templates/blob/master/app-javascript.zip > javascript.zip'
	run 'unzip javascript.zip -d app && rm javascript.zip && mv app/app-javascript app/javascript'
  
	run 'rm package.json'
  	run 'curl -L https://raw.githubusercontent.com/rdzcn/my-templates/master/package.json > package.json'
	run 'yarn install'
	
	# Routes
  ########################################
  route "root to: 'pages#home'"

  # Git ignore
  ########################################
  run 'rm .gitignore'
  file '.gitignore', <<-TXT
    .bundle
    log/*.log
    tmp/**/*
    tmp/*
    !log/.keep
    !tmp/.keep
    *.swp
    .DS_Store
    public/assets
    public/packs
    public/packs-test
    node_modules
    yarn-error.log
    .byebug_history
    .env*
  TXT

  # Dotenv
  ########################################
  run 'touch .env'
  
  # Rubocop
  ########################################
  run 'curl -L https://raw.githubusercontent.com/lewagon/rails-templates/master/.rubocop.yml > .rubocop.yml'
  
  # Git
  ########################################
  git :init
  git add: '.'
  git commit: "-m 'Initial commit with minimal template for React with Rails'"
end

