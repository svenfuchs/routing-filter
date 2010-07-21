require 'action_pack'
require 'active_support/core_ext/string/inflections'

module RoutingFilter
  autoload :Filter,     'routing_filter/filter'
  autoload :Chain,      'routing_filter/chain'
  autoload :Extension,  'routing_filter/filters/extension'
  autoload :Locale,     'routing_filter/filters/locale'
  autoload :Pagination, 'routing_filter/filters/pagination'
  autoload :Uuid,       'routing_filter/filters/uuid'

  class << self
    def build(name, options)
      const_get(name.to_s.camelize).new(options)
    end

    def active=(active)
      @@active = active
    end

    def active?
      defined?(@@active) ? @@active : @@active = true
    end
  end
end

require "routing_filter/adapters/rails_#{ActionPack::VERSION::MAJOR}"