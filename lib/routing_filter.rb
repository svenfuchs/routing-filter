require 'active_support/core_ext/module/attribute_accessors'

module RoutingFilter
  autoload :Base,           'routing_filter/base'
  autoload :Chain,          'routing_filter/chain'
  autoload :ForceExtension, 'routing_filter/filters/force_extension'
  autoload :Locale,         'routing_filter/filters/locale'
  autoload :Pagination,     'routing_filter/filters/pagination'
  autoload :Uuid,           'routing_filter/filters/uuid'

  mattr_accessor :active
  @@active = true
end

require 'routing_filter/rails'