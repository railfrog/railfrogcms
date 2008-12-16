module Railfrog
  module SymbolExtension
    def method_missing(symbol, *args)
      args.first if symbol == :l and !args.nil? and !args.empty?
    end
  end
end
