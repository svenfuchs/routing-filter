# The Locale filter extracts segments matching /:locale from the beginning of
# the recognized path and exposes the page parameter as params[:locale]. When a
# path is generated the filter adds the segments to the path accordingly if
# the page parameter is passed to the url helper.
#
#   incoming url: /de/products
#   filtered url: /products
#   params:       params[:locale] = 'de'
#
# You can install the filter like this:
#
#   # in config/routes.rb
#   Rails.application.routes.draw do
#     filter :locale
#   end
#
# To make your named_route helpers or url_for add the locale segments you
# can use:
#
#   products_path(:locale => 'de')
#   url_for(:products, :locale => 'de'))

module RoutingFilter
  class Locale < Filter
    @@include_default_locale = true
    cattr_writer :include_default_locale

    class << self
      def include_default_locale?
        @@include_default_locale
      end

      def locales
        @@locales ||= I18n.available_locales.map(&:to_sym)
      end

      def locales=(locales)
        @@locales = locales.map(&:to_sym)
      end

      def locales_pattern
        @@locales_pattern ||= %r(^/(#{self.locales.map { |l| Regexp.escape(l.to_s) }.join('|')})(?=/|$))
      end
    end

    def around_recognize(path, env, &block)
      locale = extract_segment!(self.class.locales_pattern, path) # remove the locale from the beginning of the path
      yield.tap do |params|                                       # invoke the given block (calls more filters and finally routing)
        params[:locale] = locale if locale                        # set recognized locale to the resulting params hash
      end
    end

    def around_generate(*args, &block)
      params = args.extract_options!                              # this is because we might get a call like forum_topics_path(forum, topic, :locale => :en)

      locale = params.delete(:locale)                             # extract the passed :locale option
      locale = I18n.locale if locale.nil?                         # default to I18n.locale when locale is nil (could also be false)
      locale = nil unless valid_locale?(locale)                   # reset to no locale when locale is not valid

      args << params

      yield.tap do |result|
        prepend_segment!(result, locale) if prepend_locale?(locale)
      end
    end

    protected

      def valid_locale?(locale)
        locale && self.class.locales.include?(locale.to_sym)
      end

      def default_locale?(locale)
        locale && locale.to_sym == I18n.default_locale.to_sym
      end

      def prepend_locale?(locale)
        locale && (self.class.include_default_locale? || !default_locale?(locale))
      end
  end
end
