module Glp::Sheet::Base
  extend ActiveSupport::Concern

  def render_as_parent(&)
    return super unless view.current_person.simplified_view?
    render_breadcrumbs + render_parent_title + child.render(&)
  end
end
