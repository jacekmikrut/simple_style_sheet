module SimpleStyleSheet
  class SelectorSpecificity

    include Comparable

    def initialize(a=0, b=0, c=0, d=0)
      @a, @b, @c, @d = a, b, c, d
    end

    attr_accessor :a, :b, :c, :d

    def <=>(other)
      [:a, :b, :c, :d].each do |name|
        result = send(name) <=> other.send(name)
        return result unless result == 0
      end
      0
    end

    def +(other)
      self.class.new(a + other.a, b + other.b, c + other.c, d + other.d)
    end

    def to_s
      "#{a},#{b},#{c},#{d}"
    end

    def inspect
      "#<#{self.class} #{to_s.inspect}>"
    end
  end
end
