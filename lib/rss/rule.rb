module RSS
  # Class to build and compare RSS Rules.
  class Rule
    attr_reader :recurrence

    def initialize(attributes = {})
      @recurrence = {}

      self.id         = SecureRandom.uuid
      self.attributes = attributes
    end

    # getters
    attr_reader :id, :duration

    def starts_at
      @recurrence[:starts_at]
    end

    def ends_at
      @recurrence[:ends_at]
    end

    def count
      @recurrence[:count]
    end

    def frequency
      @recurrence[:frequency] || 'daily'
    end

    def interval
      @recurrence[:interval] || 1
    end

    def attributes
      {}.tap do |a|
        a[:id] = id
        a[:recurrence] = @recurrence.stringify_keys
        a[:duration]   = @duration if @duration
      end
    end

    def convert_date(t)
      t = t.is_a?(String) ? Time.zone.parse(t) : t
      return if t.nil?
      t.utc.iso8601
    end

    # setters
    def id=(id)
      @id = id.to_s
    end

    def count=(c)
      @recurrence[:count] = c
    end

    def frequency=(f)
      @recurrence[:frequency] = f.to_s
    end

    def interval=(i)
      @recurrence[:interval]  = i.to_i
    end

    def starts_at=(t)
      @recurrence[:starts_at] = convert_date(t)
    end

    def ends_at=(t)
      @recurrence[:ends_at] = convert_date(t)
    end

    def duration=(d)
      @duration = d.to_i
    end

    def recurrence=(r)
      if r.is_a?(Hash)
        self.attributes = r
      else
        fail "recurrence= can only receive a Hash. Received #{r.class}"
      end
    end

    def attributes=(attributes = {})
      attributes.each_pair do |attr, value|
        if respond_to?(assign = "#{attr}=")
          send(assign, value)
        end
      end
    end

    # @return JSON string
    def as_json(_options = nil)
      # when on rails 4 use deep stringify keys
      attributes.stringify_keys
    end

    # Tell wether +self+ is an one-off +Rule+ or not. +self+ is considered to be
    # one-off if and only if it evaluates to a single occurrence.
    #
    # @return [true] if +self+ is a one-off +Rule+. This is 100% reliable.
    # @return [false] if +self+ looks like it is not an one-off +Rule+. This is
    #   not 100% reliable. Unfortunately, there is no obvious way to tell for
    #   sure if +self+ evaluates to multple occurrences or not.
    def one_off?
      # TODO@cs: There are various problematic edge-cases in the system, because
      # +#one_off?+ is not 100% reliable. We have to fix this ASAP.
      count == 1 || starts_at == ends_at
    end

    # @return [Array of Rule Objects]
    def self.load(value)
      parsed = JSON.load(value)
      parsed.is_a?(Array) ? parsed.map { |p| new(p) } : []
    end

    def ==(other)
      as_json == other.as_json
    end

    # @return JSON string of rules
    def self.dump(rules)
      value = rules.is_a?(Array) ? rules.map(&:as_json) : []
      JSON.dump(value)
    end
  end
end
