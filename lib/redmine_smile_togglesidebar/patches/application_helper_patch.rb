module RedmineSmileTogglesidebar
  module Patches
    module ApplicationHelperPatch
      module ToggleSidebar
        def self.extended(base)
          base.class_eval do
            # Style Methods
            def toggle_sidebar_build_style(float_right, no_margin_right)
              return '' unless float_right || no_margin_right

              styles = []
              styles << 'float:right' if float_right
              styles << 'margin-right:0' if no_margin_right
              " style=\"#{styles.join('; ')}\""
            end

            def toggle_sidebar_wrap_in_span(content, _style)
              "<span#{_style}>#{content}</span>".html_safe
            end

            # Session & State Methods
            def toggle_sidebar_session_name_show_sidebar(p_controller_name, p_action_name)
              "#{p_controller_name}_#{p_action_name}_show_sidebar"
            end

            def toggle_sidebar_fetch_show_sidebar
              session[toggle_sidebar_session_name_show_sidebar(controller_name, action_name)] || true
            end

            # URL & Link Building Methods
            def toggle_sidebar_build_remote_link_options(_class)
              {
                url: {
                  controller: 'sidebar',
                  action: 'toggle',
                  original_controller: controller_name,
                  original_action: action_name,
                  protocol: Setting.protocol
                },
                class: _class
              }
            end

            def toggle_sidebar_build_standard_link_options
              {
                original_controller: controller_name,
                original_action: action_name,
                protocol: Setting.protocol
              }
            end

            def toggle_sidebar_button(float_right=true, no_margin_right=true, span=true)
              _style = toggle_sidebar_build_style(float_right, no_margin_right)
              show_sidebar = toggle_sidebar_fetch_show_sidebar

              image_toggle_tag = "<img src=\"#{toggle_sidebar_image(show_sidebar)}\" id=\"sidebar_view\" />".html_safe
              _class = span ? nil : 'icon-toggle'

              toggle_distant = link_to(image_toggle_tag, sidebar_toggle_url(toggle_sidebar_build_standard_link_options), class: _class, remote: true)

              span ? toggle_sidebar_wrap_in_span(toggle_distant, _style) : toggle_distant
            end

            # Image Methods
            def toggle_sidebar_image(p_show_sidebar)
              if p_show_sidebar
                image_path("#{Redmine::Utils::relative_url_root}/plugin_assets/redmine_smile_togglesidebar/images/maximize.png")
              else
                image_path("#{Redmine::Utils::relative_url_root}/plugin_assets/redmine_smile_togglesidebar/images/minimize.png")
              end
            end

            # Overridden Methods
            def sidebar_content_with_toggle?
              show_sidebar = sidebar_content_without_toggle?
              session_show_sidebar = session[toggle_sidebar_session_name_show_sidebar(controller_name, action_name)]
              return show_sidebar if session_show_sidebar.nil?
              return show_sidebar && session_show_sidebar
            end

            def render_flash_messages_with_toggle
              flash_messages_rendered = render_flash_messages_without_toggle

              if content_for(:sidebar).present?
                return '<div id="toggle-sidebar" style="float: right; position: relative; margin-left: 4px">'.html_safe +
                  toggle_sidebar_button(false, false, false).html_safe +
                  '</div>'.html_safe +
                  flash_messages_rendered
              end

              flash_messages_rendered
            end
          end

          base.instance_eval do
            alias_method :sidebar_content_without_toggle?, :sidebar_content?
            alias_method :sidebar_content?, :sidebar_content_with_toggle?

            alias_method :render_flash_messages_without_toggle, :render_flash_messages
            alias_method :render_flash_messages, :render_flash_messages_with_toggle
          end
        end
      end
    end
  end
end

unless ApplicationHelper.include? RedmineSmileTogglesidebar::Patches::ApplicationHelperPatch::ToggleSidebar
  ApplicationHelper.send(:extend, RedmineSmileTogglesidebar::Patches::ApplicationHelperPatch::ToggleSidebar)
end
