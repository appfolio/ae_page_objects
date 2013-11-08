require 'capybara'
require 'capybara/dsl'

require 'ae_page_objects/version'
require 'ae_page_objects/exceptions'

module AePageObjects
  autoload :Universe,             'ae_page_objects/core/universe'
  autoload :Site,                 'ae_page_objects/core/site'
  autoload :BasicRouter,          'ae_page_objects/core/basic_router'
  autoload :ApplicationRouter,    'ae_page_objects/core/application_router'
  autoload :RakeRouter,           'ae_page_objects/core/rake_router'
  autoload :Dsl,                  'ae_page_objects/core/dsl'

  autoload :Singleton,            'ae_page_objects/util/singleton'
  autoload :InternalHelpers,      'ae_page_objects/util/internal_helpers'
  autoload :HashSymbolizer,       'ae_page_objects/util/hash_symbolizer'
  autoload :Inflector,            'ae_page_objects/util/inflector'
  autoload :Waiter,               'ae_page_objects/util/waiter'

  module Concerns
    autoload :LoadEnsuring,     'ae_page_objects/concerns/load_ensuring'
    autoload :Staleable,        'ae_page_objects/concerns/staleable'
    autoload :Visitable,        'ae_page_objects/concerns/visitable'
  end
  
  autoload :Window,            'ae_page_objects/window'
  autoload :Node,              'ae_page_objects/node'
  autoload :Document,          'ae_page_objects/document'
  autoload :DocumentFinder,    'ae_page_objects/document_finder'
  autoload :VariableDocument,  'ae_page_objects/variable_document'
  autoload :Element,           'ae_page_objects/element'
  autoload :ElementProxy,      'ae_page_objects/element_proxy'
  
  autoload :Collection,        'ae_page_objects/elements/collection'
  autoload :Form,              'ae_page_objects/elements/form'
  autoload :Select,            'ae_page_objects/elements/select'
  autoload :Checkbox,          'ae_page_objects/elements/checkbox'  
end

require 'ae_page_objects/core_ext/module'










