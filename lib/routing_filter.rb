require 'action_pack'

module RoutingFilter
  autoload :Base,           'routing_filter/base'
  autoload :Chain,          'routing_filter/chain'
  autoload :ForceExtension, 'routing_filter/filters/force_extension'
  autoload :Locale,         'routing_filter/filters/locale'
  autoload :Pagination,     'routing_filter/filters/pagination'
  autoload :Uuid,           'routing_filter/filters/uuid'

  class << self
    def active=(active)
      @@active = active
    end

    def active?
      defined?(@@active) ? @@active : @@active = true
    end
  end
end

require 'routing_filter/adapters/rails_3'