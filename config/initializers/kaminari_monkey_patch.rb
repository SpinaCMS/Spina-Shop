# Please see https://github.com/amatsuda/kaminari/pull/322 for an explanation.
# This fixes an issue when using Kaminari with engines/main_app.

Rails.application.config.to_prepare do
  Kaminari::Helpers::Tag.class_eval do
    def page_url_for(page)
      arguments = @params.merge(@param_name => (page <= 1 ? nil : page), :only_path => true)
      begin
        @template.spina.url_for arguments
      rescue
        @template.main_app.url_for arguments
      end
    end
  end
end