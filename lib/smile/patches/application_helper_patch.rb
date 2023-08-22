require_dependency 'application_helper'

module Smile
  module Patches
    module ApplicationHelperPatch
      def self.included(base)
        base.send(:include, InstanceMethods)

        base.class_eval do
          unloadable # Send unloadable so it will not be unloaded in development

          alias_method :sidebar_content_without_toggle?, :sidebar_content?
          alias_method :sidebar_content?, :sidebar_content_with_toggle?

          alias_method :render_flash_messages_without_toggle, :render_flash_messages
          alias_method :render_flash_messages, :render_flash_messages_with_toggle
        end
      end

      module InstanceMethods
        def button_toggle_sidebar(float_right=true, no_margin_right=true, span=true)
          _style = ''

          if float_right || no_margin_right
            _style = ' style="'
            _style += 'float:right' if float_right
            _style += '; ' if float_right && no_margin_right
            _style += 'margin-right:0' if float_right && no_margin_right
            _style += '"'
          end

          show_sidebar = session[session_name_show_sidebar(controller_name, action_name)]
          show_sidebar = true if show_sidebar.nil?

          image_toggle_tag = "<img src=\"#{image_toggle_sidebar(show_sidebar)}\" id=\"sidebar_view\" />".html_safe

          if Rails::VERSION::MAJOR < 3
            toggle_distant = link_to_remote(
              image_toggle_tag,
              :url => {
                :controller => 'sidebar',
                :action => 'toggle',
                :original_controller => controller_name,
                :original_action => action_name,
                :protocol => Setting.protocol
              }
            )
          else
            toggle_distant = link_to(
              image_toggle_tag,
              sidebar_toggle_url(
                :original_controller => controller_name,
                :original_action => action_name,
                :protocol => Setting.protocol
              ),
              :remote => true
            )
          end

          if span
            "<span#{ _style }>#{ toggle_distant }</span>".html_safe
          else
            toggle_distant
          end
        end

        # 2/ New method
        def session_name_show_sidebar(p_controller_name, p_action_name)
          "#{p_controller_name}_#{p_action_name}_show_sidebar"
        end

        # 3/ New method
        def image_toggle_sidebar(p_show_sidebar)
          unless defined?(@@image_toggle_sidebar_true)
            @@image_toggle_sidebar_true = "#{Redmine::Utils::relative_url_root}/plugin_assets/redmine_smile_togglesidebar/images/"
            @@image_toggle_sidebar_false = @@image_toggle_sidebar_true
            @@image_toggle_sidebar_true += 'maximize.png'
            @@image_toggle_sidebar_false += 'minimize.png'
          end

          p_show_sidebar ? @@image_toggle_sidebar_true : @@image_toggle_sidebar_false
        end

        def sidebar_content_with_toggle?
          show_sidebar = sidebar_content_without_toggle?
          session_show_sidebar = session[session_name_show_sidebar(controller_name, action_name)]

          # Upstream behaviour if no session information
          return show_sidebar if session_show_sidebar.nil?

          show_sidebar && session_show_sidebar
        end

        def render_flash_messages_with_toggle
          flash_messages_rendered = render_flash_messages_without_toggle

          if content_for(:sidebar).present?
            return '<div id="toggle-sidebar" style="float: right; position: relative; margin-left: 4px">'.html_safe +
              button_toggle_sidebar(false, false, false).html_safe +
              '</div>'.html_safe +
              flash_messages_rendered
          end

          flash_messages_rendered
        end
      end
    end
  end
end

unless ApplicationHelper.included_modules.include?(Smile::Patches::ApplicationHelperPatch)
  ApplicationHelper.send(:include, Smile::Patches::ApplicationHelperPatch)
end
