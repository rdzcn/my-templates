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
	run 'curl -L https://github.com/rdzcn/my-templates/blob/master/app-javascript.zip?raw=true > javascript.zip'
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
  *.rbc
	capybara-*.html
	.rspec
	/db/*.sqlite3
	/db/*.sqlite3-journal
	/public/system
	/coverage/
	/spec/tmp
	*.orig
	rerun.txt
	pickle-email-*.html

	# Ignore all logfiles and tempfiles.
	/log/*
	/tmp/*
	!/log/.keep
	!/tmp/.keep

	# TODO Comment out this rule if you are OK with secrets being uploaded to the repo
	config/initializers/secret_token.rb
	config/master.key

	# Only include if you have production secrets in this file, which is no longer a Rails default
	# config/secrets.yml

	# dotenv
	# TODO Comment out this rule if environment variables can be committed
	.env

	## Environment normalization:
	/.bundle
	/vendor/bundle

	# these should all be checked in to normalize the environment:
	# Gemfile.lock, .ruby-version, .ruby-gemset

	# unless supporting rvm < 1.11.0 or doing something fancy, ignore this:
	.rvmrc

	# if using bower-rails ignore default bower_components path bower.json files
	/vendor/assets/bower_components
	*.bowerrc
	bower.json

	# Ignore pow environment settings
	.powenv

	# Ignore Byebug command history file.
	.byebug_history

	# Ignore node_modules
	node_modules/

	# Ignore precompiled javascript packs
	/public/packs
	/public/packs-test
	/public/assets

	# Ignore yarn files
	/yarn-error.log
	yarn-debug.log*
	.yarn-integrity

	# Ignore uploaded files in development
	/storage/*
	!/storage/.keep
  TXT

	inject_into_file 'config/webpack/environment.js', before: 'module.exports' do
	<<-JS
	// Preventing Babel from transpiling NodeModules packages
	environment.loaders.delete('nodeModules');
	JS
  end

  # Dotenv
  ########################################
  run 'touch .env'
  
  # Rubocop
  ########################################
  run 'curl -L https://raw.githubusercontent.com/lewagon/rails-templates/master/.rubocop.yml > .rubocop.yml'
  
  # Git
  ########################################
  git :init
end

