module SimpleStyleSheet
  class Handler

    def initialize(style_sheet_hash, property_name_translator=nil)
      @map = {}
      @property_name_translator = property_name_translator
      populate(style_sheet_hash)
    end

    def value_for(tag=nil, property_name)
      found = if tag
                (@map[final_property_name(property_name)] || [])
                .select { |data| data[:selector].match?(tag) }
                .max_by { |data| data[:selector].specificity }

              else
                (@map[final_property_name(property_name)] || [])
                .select { |data| data[:selector].empty?      }
                .last

              end

      found && found[:value]
    end

    protected

    def populate(style_sheet_hash, selector=new_selector)

      style_sheet_hash.each do |key, value|

        case value
        when Hash
          populate(value, selector + key.to_s)
        else
          property_name = final_property_name(key)

          @map[property_name] ||= []
          @map[property_name] << { :value => value, :selector => selector }
        end
      end
    end

    def new_selector
      SimpleSelector.new
    end

    def final_property_name(property_name)
      @property_name_translator ? @property_name_translator.translate(property_name) : property_name
    end
  end
end
