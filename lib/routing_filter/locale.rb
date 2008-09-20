require 'i18n'

module RoutingFilter
  class Locale < Base
    @@default_locale = :en
    cattr_reader :default_locale
    
    class << self
      def default_locale=(locale)
        @@default_locale = locale.to_sym
      end
    end
    
    # remove the locale from the beginning of the path, pass the path
    # to the given block and set it to the resulting params hash
    def around_recognition(route, path, env, &block)
      locale = nil
      path.sub! %r(^/([a-zA-Z]{2})(?=/|$)) do locale = $1; '' end
      returning yield do |params|
        params[:locale] = locale if locale
      end
    end
    
    def around_generation(controller, *args, &block)
      options = args.extract_options!
      locale = options.delete(:locale) || I18n.locale.to_sym
      returning yield do |result|
        prepend_locale! result, locale if locale != @@default_locale
      end
    end
    
    def prepend_locale!(result, locale)
      result.match %r(^(http.?://[^/]*)?(.*))
      result.replace "#{$1}/#{locale}#{$2}"
    end
  end
end