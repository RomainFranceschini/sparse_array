# SparseArray maps integers to generic types. It allows gaps in incices, just
# like a Hash, but in a memory efficient manner.
class SparseArray(K, V)
  include Indexable(V)

  getter size : Int32
  @capacity : Int32

  def self.build(capacity : Int) : self
    ary = SparseArray(K, V).new(capacity)
    ary.size = (yield ary.to_unsafe).to_i
    ary
  end

  def initialize
    {% if K < Int::Primitive %}
      # Support integer types
    {% else %}
      {{ raise "Can only create SparseArray with primitive integer types as keys, not #{K}" }}
    {% end %}

    @size = 0
    @capacity = 0
    @keys = Pointer(K).null
    @values = Pointer(V).null
  end

  def initialize(initial_capacity : Int)
    {% if K < Int::Primitive %}
      # Support integer types
    {% else %}
      {{ raise "Can only create SparseArray with primitive integer types as keys, not #{K}" }}
    {% end %}

    if initial_capacity < 0
      raise ArgumentError.new("negative sparse array size: #{initial_capacity}")
    end

    @size = 0
    @capacity = initial_capacity.to_i

    if initial_capacity == 0
      @values = Pointer(V).null
      @keys = Pointer(K).null
    else
      @values = Pointer(V).malloc(initial_capacity)
      @keys = Pointer(K).malloc(initial_capacity)
    end
  end

  def clear
    @values.clear(@size)
    @keys.clear(@size)
    @size = 0
    self
  end

  def []?(key : Int)
    fetch(key) { nil }
  end

  def [](key : Int)
    fetch(key)
  end

  def fetch(key : Int)
    fetch(key) do
      raise KeyError.new "Missing key: #{key.inspect}"
    end
  end

  def fetch(key : Int, default)
    fetch(key) { default }
  end

  def fetch(key : Int)
    i = find_index(key)

    if i < 0 || i >= @size
      yield key
    elsif i
      @values[i]
    end
  end

  def has_key?(key : Int)
    i = find_index(key)
    i >= 0 && i < @size
  end

  def []=(key : K, value : V)
    i = find_index(key)

    if i >= 0
      @values[i] = value
    else
      i = ~i
      check_needs_resize

      @values[@size] = value
      @keys[@size] = key
      @size += 1
    end

    self
  end

  def unsafe_at(key : Int)
    i = find_index(key)
    @values[i]
  end

  def to_unsafe
    {@keys, @values}
  end

  def to_s(io : IO)
    io << '{'
    (0...size).each do |i|
      key = @keys[i]
      key.inspect(io)
      io << " => "
      index = find_index(key)
      @values[index].inspect(io)
      io << ", " if index < size - 1
    end
    io << '}'
  end

  def inspect(io : IO)
    to_s(io)
  end

  def dup
    SparseArray(K, V).build(@capacity) do |keybuf, valbuf|
      keybuf.copy_from(@keys, size)
      valbuf.copy_from(@values, size)
      size
    end
  end

  def ==(other : SparseArray)
    equals?(other) { |x, y| x == y }
  end

  def ==(other)
    false
  end

  protected def size=(size : Int)
    @size = size.to_i
  end

  private def find_index(key : K)
    lo = 0
    hi = @size - 1

    while lo <= hi
      mid = (lo + hi) >> 1
      midval = @keys[mid]

      if midval < key
        lo = mid + 1
      elsif midval > key
        hi = mid - 1
      else
        return mid
      end
    end

    ~lo
  end

  private def check_needs_resize
    double_capacity if @size == @capacity
  end

  private def double_capacity
    resize_to_capacity(@capacity == 0 ? 3 : (@capacity * 2))
  end

  private def resize_to_capacity(capacity)
    @capacity = capacity
    if @values
      @values = @values.realloc(@capacity)
      @keys = @keys.realloc(@capacity)
    else
      @values = Pointer(V).malloc(@capacity)
      @keys = Pointer(K).malloc(@capacity)
    end
  end
end
