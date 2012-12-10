module AePageObjects
  module AttributeMethods
    module Nodes
      extend ActiveSupport::Concern
      include Node
    
      module ClassMethods
        include InternalHelpers
        
        # Defines a collection of elements. Blocks are evaluated on the item class used by the 
        # collection. nodes() defines a method on the class that returns an instance of a collection
        # class which contains instances of the collection's item class.
        #
        # Supported signatures are described below. 
        # 
        # ------------------------------------------------        
        # Signature: (:as, no :contains, no block)
        # 
        #     nodes :addresses, :as => AddressList
        # 
        #   Collection class: AddressList
        #   Item class:       AddressList.item_class
        # 
        # ------------------------------------------------
        # Signature: (no :as, :contains, no block)
        # 
        #     nodes :addresses, :contains => Address
        # 
        #   Collection class: one-off subclass of ::AePageObjects::Collection  
        #   Item class:       Address
        # 
        # ------------------------------------------------
        # Signature: (:as, :contains, no block)
        # 
        #     nodes :addresses, :as => AddressList, :contains => ExtendedAddress
        # 
        #   Collection class: one-off subclass ofAddressList
        #   Item class:       ExtendedAddress
        #   
        # ------------------------------------------------
        # Signature: (no :as, no :contains, block)
        # 
        #     nodes :addresses do
        #       node :city
        #       node :state
        #     end
        #   
        #   Collection class: one-off subclass of ::AePageObjects::Collection
        #   Item class:       one-off subclass of ::AePageObjects::Element
        #   Methods defined on item class:
        #     city()  # -> instance of ::AePageObjects::Element
        #     state() # -> instance of ::AePageObjects::Element
        # 
        # ------------------------------------------------
        # Signature: (:as, no :contains, block)
        # 
        #   nodes :addresses, :as => AddressList do
        #     node :longitude
        #     node :latitude
        #   end
        # 
        #   Collection class: one-off subclass of AddressList  
        #   Item class:       one-off subclass of AddressList.item_class
        #   Methods defined on item class:
        #     longitude()  # -> instance of ::AePageObjects::Element
        #     latitude() # -> instance of ::AePageObjects::Element
        # 
        # ------------------------------------------------
        # Signature: (no :as, :contains, block)
        # 
        #   nodes :addresses, :contains => Address do
        #     node :longitude
        #     node :latitude
        #   end
        # 
        #   Collection class: one-off subclass of ::AePageObjects::Collection  
        #   Item class:       one-off subclass of Address
        #   Methods defined on item class:
        #     longitude()  # -> instance of ::AePageObjects::Element
        #     latitude() # -> instance of ::AePageObjects::Element
        # 
        # ------------------------------------------------
        # Signature: (:as, :contains, block)
        # 
        #   nodes :addresses, :as => AddressList, :contains => Address do
        #     node :longitude
        #     node :latitude
        #   end
        # 
        #   Collection class: one-off subclass of AddressList
        #   Item class:       one-off subclass of Address
        #   Methods defined on item class:
        #     longitude()  # -> instance of ::AePageObjects::Element
        #     latitude() # -> instance of ::AePageObjects::Element
        # 
        def nodes(name, options = {}, &block)
          options ||= {}
          
          # only a collection class is specified or the item class
          # specified matches the collection's item class
          if block.blank? && options[:as] && ( 
              options[:contains].blank? || options[:as].item_class == options[:contains] 
            )
            return node(name, options)
          end
          
          options = options.dup
          
          # create/get the collection class
          if options[:as]
            ensure_class_for_param!(:as, options[:as], ::AePageObjects::Collection)
          else
            options[:as] = ::AePageObjects::Collection
            
            raise ArgumentError, "Must specify either a block or a :contains option." if options[:contains].blank? && block.blank?
          end
          
          item_class = options.delete(:contains) || options[:as].item_class
          if block.present?
            item_class = item_class.new_subclass(&block).tap do |new_item_class|
              new_item_class.node_attributes.merge!(item_class.node_attributes)
            end
          end
          
          # since we are creating a new item class, we need to subclass the collection class
          # so we can parameterize the collection class with an item class
          options[:as] = options[:as].new_subclass
          options[:as].item_class = item_class
        
          node(name, options)
        end
      end
    end
  end
end