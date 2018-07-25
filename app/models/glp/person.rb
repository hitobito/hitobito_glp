module Glp::Person
    extend ActiveSupport::Concern

    PREFERRED_LANGUAGES = [:en, :de, :fr, :it]

    included do
      Person::PUBLIC_ATTRS << :title
      alias_method_chain :full_name, :title
    end

    def full_name_with_title(format = :default)
      case format
      when :list, :print_list then "#{title} #{full_name_without_title(format)}".strip
      else "#{title} #{full_name_without_title}".strip
      end
    end
end
