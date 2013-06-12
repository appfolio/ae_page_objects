require 'capybara'
require 'capybara/dsl'
require 'active_support'
require 'active_support/core_ext/module/delegation'
require 'active_support/core_ext/hash/keys'
require 'active_support/core_ext/object/try'
require 'active_support/core_ext/class'
require 'active_support/dependencies'

require 'ae_page_objects/version'

module AePageObjects
  autoload :Universe,             'ae_page_objects/core/universe'
  autoload :ConstantResolver,     'ae_page_objects/core/constant_resolver'
  autoload :DependenciesHook,     'ae_page_objects/core/dependencies_hook'
  autoload :Installable,          'ae_page_objects/core/installable'
  autoload :Configuration,        'ae_page_objects/core/configuration'
  autoload :Singleton,            'ae_page_objects/core/singleton'
  autoload :Application,          'ae_page_objects/core/application'
  autoload :ApplicationRouter,    'ae_page_objects/core/application_router'
  autoload :RakeRouter,           'ae_page_objects/core/rake_router'
  autoload :InternalHelpers,      'ae_page_objects/core/internal_helpers'
  
  module Dsl
    autoload :Element,            'ae_page_objects/core/dsl/element'
    autoload :Collection,         'ae_page_objects/core/dsl/collection'
    autoload :FormFor,            'ae_page_objects/core/dsl/form_for'
  end
  
  module Concerns
    autoload :LoadEnsuring,     'ae_page_objects/concerns/load_ensuring'
    autoload :Staleable,        'ae_page_objects/concerns/staleable'
    autoload :Visitable,        'ae_page_objects/concerns/visitable'
  end
  
  autoload :Node,              'ae_page_objects/node'
  autoload :Document,          'ae_page_objects/document'
  autoload :Element,           'ae_page_objects/element'
  autoload :ElementProxy,      'ae_page_objects/element_proxy'
  
  autoload :Collection,        'ae_page_objects/elements/collection'
  autoload :Form,              'ae_page_objects/elements/form'
  autoload :Select,            'ae_page_objects/elements/select'
  autoload :Checkbox,          'ae_page_objects/elements/checkbox'  
end

ActiveSupport::Dependencies.extend AePageObjects::DependenciesHook









