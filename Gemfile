source 'https://rubygems.org'

# Declare your gem's dependencies in spina-shop.gemspec.
# Bundler will treat runtime dependencies like base dependencies, and
# development dependencies will be added by default to the :development group.
gemspec

group :development, :test do
  gem 'rails', '5.1'
  gem 'globalize', git: 'git@github.com:Bramjetten/globalize.git', branch: :master
  gem 'refile', path: '~/apps/refile', require: 'refile/rails'
  gem 'spina', path: '~/apps/spina'

  gem 'rails-controller-testing'
  gem 'minitest-reporters'
  gem 'guard'
  gem 'guard-minitest'
end
# Declare any dependencies that are still in development here instead of in
# your gemspec. These might include edge Rails or gems from your path or
# Git. Remember to move these dependencies to your gemspec before releasing
# your gem to rubygems.org.

# To use a debugger
# gem 'byebug', group: [:development, :test]
