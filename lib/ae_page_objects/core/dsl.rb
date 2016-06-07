require 'ae_page_objects/util/internal_helpers'
require 'ae_page_objects/element_proxy'

module AePageObjects
  module Dsl
    include InternalHelpers

    def inherited(subclass)
      subclass.class_eval do
        class << self
          def element_attributes
            @element_attributes ||= {}
          end
        end
      end
    end

    def element(name, options = {}, &block)
      options = options.dup
      options[:name] ||= name

      klass   = field_klass(options, &block)

      self.element_attributes[name.to_sym] = klass

      define_method name do
        ElementProxy.new(klass, self, options)
      end

      klass
    end

    # Defines a collection of elements. Blocks are evaluated on the item class used by the
    # collection. collection() defines a method on the class that returns an instance of a collection
    # class which contains instances of the collection's item class.
    #
    # Supported signatures are described below.
    #
    # ------------------------------------------------
    # Signature: (no :is, no :contains, no block)
    #
    #     collection :addresses
    #
    #   Collection class: Collection
    #   Item class:       Element
    #
    # ------------------------------------------------
    # Signature: (no :is, no :contains, block)
    #
    #     collection :addresses do
    #       element :city
    #       element :state
    #     end
    #
    #   Collection class: one-off subclass of Collection
    #   Item class:       one-off subclass of Element
    #   Methods defined on item class:
    #     city()  # -> instance of Element
    #     state() # -> instance of Element
    #
    # ------------------------------------------------
    # Signature: (no :is, :contains, no block)
    #
    #     collection :addresses, :contains => Address
    #
    #   Collection class: one-off subclass of Collection
    #   Item class:       Address
    #
    # ------------------------------------------------
    # Signature: (no :is, :contains, block)
    #
    #   collection :addresses, :contains => Address do
    #     element :longitude
    #     element :latitude
    #   end
    #
    #   Collection class: one-off subclass of Collection  element
    #   Item class:       one-off subclass of Address
    #   Methods defined on item class:
    #     longitude()  # -> instance of Element
    #     latitude() # -> instance of Element
    #
    # ------------------------------------------------
    # Signature: (:is, no :contains, no block)
    #
    #     collection :addresses, :is => AddressList
    #
    #   Collection class: AddressList
    #   Item class:       AddressList.item_class
    #
    # ------------------------------------------------
    # Signature: (:is, no :contains, block)
    #
    #   collection :addresses, :is => AddressList do
    #     element :longitude
    #     element :latitude
    #   end
    #
    #   Collection class: one-off subclass of AddressList
    #   Item class:       one-off subclass of AddressList.item_class
    #   Methods defined on item class:
    #     longitude()  # -> instance of Element
    #     latitude() # -> instance of Element
    #
    # ------------------------------------------------
    # Signature: (:is, :contains, no block)
    #
    #     collection :addresses, :is => AddressList, :contains => ExtendedAddress
    #
    #   Collection class: one-off subclass ofAddressList
    #   Item class:       ExtendedAddress
    #
    # ------------------------------------------------
    # Signature: (:is, :contains, block)
    #
    #   collection :addresses, :is => AddressList, :contains => Address do
    #     element :longitude
    #     element :latitude
    #   end
    #
    #   Collection class: one-off subclass of AddressList
    #   Item class:       one-off subclass of Address
    #   Methods defined on item class:
    #     longitude()  # -> instance of Element
    #     latitude() # -> instance of Element
    #
    def collection(name, options = {}, &block)
      options ||= {}

      # only a collection class is specified or the item class
      # specified matches the collection's item class
      if ! block_given? && options[:is] && (
      options[:contains].nil? || options[:is].item_class == options[:contains]
      )
        return element(name, options)
      end

      options = options.dup

      # create/get the collection class
      if options[:is]
        ensure_class_for_param!(:is, options[:is], Collection)
      else
        options[:is] = Collection
      end

      item_class = options.delete(:contains) || options[:is].item_class
      if block_given?
        item_class = Class.new(item_class, &block).tap do |new_item_class|
          new_item_class.element_attributes.merge!(item_class.element_attributes)
        end
      end

      # since we are creating a new item class, we need to subclass the collection class
      # so we can parameterize the collection class with an item class
      options[:is] = Class.new(options[:is])
      options[:is].item_class = item_class

      element(name, options)
    end

    def form_for(form_name, options = {}, &block)
      options ||= {}

      raise ArgumentError, ":is option not supported" if options[:is]
      raise ArgumentError, "Block required." if block.nil?

      klass = Class.new(Form, &block)

      options      = options.dup
      options[:is] = klass

      element(form_name, options)

      klass.element_attributes.each do |element_name, element_klazz|
        class_eval <<-RUBY
          def #{element_name}(*args, &block)
            #{form_name}.#{element_name}(*args, &block)
          end
        RUBY

        self.element_attributes[element_name] = element_klazz
      end
    end

  private

    def field_klass(options, &block)
      klass = options.delete(:is) || Element

      if block_given?
        Class.new(klass, &block)
      else
        klass
      end
    end
  end
end
