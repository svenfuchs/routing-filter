require 'i18n'
require 'routing_filter/base'

module RoutingFilter
  class Locale < Base
    @@default_locale = :en
    cattr_reader :default_locale

    @@locales = I18n.available_locales
    cattr_reader :locales

    class << self
      def default_locale=(locale)
        @@default_locale = locale.to_sym
      end
      def locales=(locales)
        @@locales = locales
      end
      def locale_match
        %r(^/(#{@@locales.map{|l|l.to_s}.join('|')})(?=/|$))
      end
    end

    # remove the locale from the beginning of the path, pass the path
    # to the given block and set it to the resulting params hash
    def around_recognize(path, env, &block)
      locale = nil
      path.sub!(RoutingFilter::Locale.locale_match){ locale = $1; '' }
      returning yield do |params|
        params[:locale] = locale if locale
      end
    end

    def around_generate(*args, &block)
      locale = args.extract_options!.delete(:locale)
      locale = I18n.locale if locale.nil?
      locale = nil if locale && !@@locales.include?(locale.to_sym)
      returning yield do |result|
        locale ? result.sub!(%r(^(http.?://[^/]*)?(.*))){ "#{$1}/#{locale}#{$2}" } : result
      end
    end
  end
end
