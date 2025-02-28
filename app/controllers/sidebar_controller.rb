class SidebarController < ApplicationController
  def toggle
    original_session_name_show_sidebar = toggle_sidebar_session_name_show_sidebar(
      params[:original_controller], params[:original_action]
    )
    original_show_sidebar = session[original_session_name_show_sidebar]
    # If not set in session, set to show as default behaviour
    original_show_sidebar = true if original_show_sidebar.nil?

    # Toggle Sidebar show state in session
    session[original_session_name_show_sidebar] = !original_show_sidebar

    respond_to do |format|
      format.js {
        render(:template => 'sidebar/toggle', :layout => false)
      }
    end
  end

  private

  # TODO : remove duplication with the same method in application_helper
  def toggle_sidebar_session_name_show_sidebar(p_controller_name, p_action_name)
    p_controller_name + '_' + p_action_name + '_show_sidebar'
  end
end
