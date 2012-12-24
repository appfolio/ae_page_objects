module AePageObjects
  class Node
    include Methods::Node
    include LoadEnsuring
    include Staleable
  end
end
