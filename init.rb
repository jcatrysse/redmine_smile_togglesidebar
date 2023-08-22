Redmine::Plugin.register :redmine_smile_togglesidebar do
  name 'Redmine - Smile - Hide / Show Sidebar Button'
  author 'Jérôme BATAILLE'
  author_url 'mailto:Jerome BATAILLE <redmine-support@smile.fr>?subject=redmine_smile_togglesidebar'
  description 'Adds a button to hide / show the right sidebar'
  url 'https://github.com/Smile-SA/redmine_smile_togglesidebar'
  version '1.0.7'
  requires_redmine :version_or_higher => '1.2.1'
end

require File.dirname(__FILE__) + '/lib/smile/patches/application_helper_patch'
