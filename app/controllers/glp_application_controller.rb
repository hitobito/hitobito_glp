class GlpApplicationController < ActionController::Base
  def handle_options_request
    head(:ok) if request.request_method == "OPTIONS"
  end
end
