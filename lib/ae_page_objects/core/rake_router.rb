module AePageObjects
  class RakeRouter
    
    attr_reader :routes
    
    def initialize(rake_routes, mounted_prefix = '')
      @mounted_prefix = mounted_prefix || ""
      @routes = ActiveSupport::OrderedHash.new
      route_line_regex = /(\w+)(?:\s[A-Z]+)?\s+(\/.*)\(.:format\).*$/
      
      rake_routes.split("\n").each do |line|
        line = line.strip
        matches = route_line_regex.match(line)
        if matches
          @routes[matches[1].to_sym] = Route.new(matches[2], @mounted_prefix)
        end
      end
    end
    
    def path_recognizes_url?(path, url)
      if path.is_a?(String)
        path.sub(/\/$/, '') == url.sub(/\/$/, '')
      elsif path.is_a?(Symbol)
        route = @routes[path]
        route && route.matches?(url)
      end
    end

    def generate_path(named_route, *args)
      if named_route.is_a?(String)
        return Path.new(@mounted_prefix + named_route)
      end
      
      if route = @routes[named_route]
        options = args.extract_options!
        route.generate_path(options)
      end
    end
    
  private
  
    class Path < String
      attr_reader :params, :regex
      
      def initialize(value)
        super(value.gsub(/(\/)+/, '/').sub(/\(\.\:format\)$/, ''))
        
        @params = parse_params
        @regex  = generate_regex
      end
      
      def generate(param_values)
        param_values = param_values.symbolize_keys
        @params.values.inject(self) do |path, param|
          param.substitute(path, param_values)
        end
      end

    private
      def parse_params
        # overwrite the required status with the optional
        {}.merge(required_params).merge(optional_params)
      end
      
      def find_params(using_regex)
        scan(using_regex).flatten.map(&:to_sym)
      end
      
      def optional_params
        {}.tap do |optional_params|
          find_params(/\(\/\:(\w+)\)/).each do |param_name|
            optional_params[param_name] = Param.new(param_name, true)
          end
        end
      end
      
      def required_params
        {}.tap do |required_params|
          find_params(/\:(\w+)/).each do |param_name|
            required_params[param_name] = Param.new(param_name, false)
          end
        end
      end

      def generate_regex
        regex_spec = @params.values.inject(self) do |regex_spec, param|
          param.replace_param_in_url(regex_spec)
        end 
        Regexp.new regex_spec
      end
    end
    
    class Param < Struct.new(:name, :optional)
      include Comparable

      def optional?
        optional
      end
      
      def <=>(other)
        name.to_s <=> other.name.to_s
      end
      
      def eql?(other)
        name == other.name
      end
      
      def hash
        name.hash
      end
      
      def replace_param_in_url(url)
        if optional?
          url.gsub("(/:#{name})", '(\/.+)?')
        else
          url.gsub(":#{name}", '(.+)')
        end
      end
      
      def substitute(url, values)
        if optional?
          if values[name]
            url.sub("(/:#{name})", "/#{values[name]}")
          else
            url.sub("(/:#{name})", '')
          end
        else
          raise ArgumentError, "Missing required parameter '#{name}' for '#{url}' in #{values.inspect}" unless values.key? name
          url.sub(":#{name}", values[name])
        end
      end
    end
  
    class Route
      def initialize(spec, mounted_prefix)
        @path = Path.new(mounted_prefix + spec)
        @path.freeze
      end
    
      def matches?(url)
        url =~ @path.regex
      end

      def generate_path(options)
        options = options.symbolize_keys
        @path.generate(options)
      end
    end
  end
end
