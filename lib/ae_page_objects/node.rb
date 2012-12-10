module AePageObjects
  class Node
    include Methods::Node
    include LoadEnsuring
    include Staleable

    alias :page :node
  end
end
