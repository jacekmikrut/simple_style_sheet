module SimpleStyleSheet
  class Handler

    def initialize(style_sheet_hash)
      @map = {}
      populate(style_sheet_hash)
    end

    def value_for(tag, property_name)
      found = (@map[property_name] || [])
        .select { |data| data[:selector].match?(tag) }
        .max_by { |data| data[:selector].specificity }

      found && found[:value]
    end

    protected

    def populate(style_sheet_hash, selector=new_selector)

      style_sheet_hash.each do |key, value|

        case value
        when Hash
          populate(value, selector + key)
        else
          property_name = key

          @map[property_name] ||= []
          @map[property_name] << { :value => value, :selector => selector }
        end
      end
    end

    def new_selector
      Selector.new
    end
  end
end
