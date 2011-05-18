# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require(File.join(File.dirname(__FILE__), 'config', 'boot'))

require 'rake'
require 'rake/clean'
require 'rake/testtask'
require 'rake/rdoctask'
require 'tasks/rails'
require 'spec/rake/spectask'

desc "Set the RAILS_ENV to test"
task :set_test do
  ENV['RAILS_ENV'] = "test"
end

desc "Run the hydrangea rspec examples"
  task :spec => ["set_test", "db:test:clone_structure", "spec_without_db"] do
end

desc "Run the rspec examples without re-creating the test database first"
Spec::Rake::SpecTask.new('spec_without_db') do |t|
  t.spec_files = FileList['spec/**/*.rb']
  t.rcov = true
  t.rcov_opts = %w{--exclude spec\/*,gems\/*,ruby\/* --aggregate coverage.data}
end

desc "Run all hydrangea tests"
  task :alltests => ["set_test", "db:test:clone_structure", "spec_without_db", "cucumber"] do
end
require 'blacklight-sitemap'
Rake::BlacklightSitemapTask.new do |sm|
  # below are configuration options with their default values shown.

  # FIXME: you'll definitely want to change the url value
   sm.url = 'http://video.library.nd.edu/catalog'

  # base filename given to generated sitemap files
   sm.base_filename = 'videocontent'

  # Is the gzip commandline tool available? Then why not gzip up your sitemaps to
  # save bandwidth?
   sm.gzip = false

  # for changefreq see http://sitemaps.org/protocol.php#changefreqdef
  # valid values are: always, hourly, daily, weekly, monthly, yearly, never
   sm.changefreq = 'weekly' # nil won't display a changefreq element

  # sitemaps can contain up to 50000 locations, but also must not be more than
  # 10 MB in size. Using the max value you can control the size of your files.
   sm.max = 50000

  # Solr field used to retrieve from a document the value for the lastmod element for a url
   sm.lastmod_field = 'timestamp'

  # Solr field used to retrieve from a document the value for the priority element for a url
  # sm.priority_field = nil

  # Solr query sort parameter
   sm.sort = 'id asc'
end
