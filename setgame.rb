module SET # all-caps to differentiate from `Set`

  ##
  # Card represents an individual Card in the game of Set.  It also provides class methods to encapsulate
  # the logic for determining if three cards are a set and for finding and removing a set from an array of Cards.
  class Card
    NUMBER = %w[one two three].freeze
    COLOR = %w[red green purple].freeze
    SHADING = %w[solid empty striped].freeze
    SHAPE = %w[diamond squiggle oval].freeze
    NUMBER_OF_UNIQUE_CARDS = NUMBER.length * COLOR.length * SHADING.length * SHAPE.length # 81

    attr_reader :values

    def initialize(number, color, shading, shape)
      @values = [number, color, shading, shape]
    end

    def to_s # human-readable format
      n = values[0]
      suffix = n > 0 ? 's' : ''
      "#{NUMBER[n]} #{COLOR[values[1]]} #{SHADING[values[2]]} #{SHAPE[values[3]]}#{suffix}"
    end

    def self.set?(a, b, c)
      # return false unless a && b && c
      # Count the number unique attribute values across three cards.  There are three possibilities: 1 unique value
      # means "all the same", 3 means "all different", and 2 means "not a set".  We can stop counting as soon as we
      # find the first "not a set".
      [a.values, b.values, c.values].transpose.none? { |attrs| attrs.uniq.length == 2 }
    end

    def self.find_set(*cards) # return Array<Card>[3] or nil
      cards.combination(3).find do |a, b, c|
        set?(a, b, c)
      end
    end

    def self.remove_set(cards) # modify cards, return Array<Card>[3] or nil
      find_set(*cards).tap do |set|
        cards.reject! { |card| set.include?(card) } if set
      end
    end
  end

  ##
  # Deck represents a randomly ordered sequence of k (default 81) Cards.  An array of Cards can be
  # removed from a deck by calling `deal`.
  class Deck
    def initialize(deck_size)
      @cards = (0...deck_size).to_a.shuffle! # represent cards by integer card numbers
    end

    def empty?
      @cards.empty?
    end

    def length
      @cards.length
    end

    def deal(n) # return Array<Card>, may be empty
      @cards.pop(n).map! do |i|
        i = i.to_i % Card::NUMBER_OF_UNIQUE_CARDS
        # Convert to base-3 string, left pad with zeros, convert to four-integer array.  For example:
        # 8 as a base-3 string is "22".  Left-padding with zeroes it becomes "0022".  Converting to a
        # four-integer array it becomes [0, 0, 2, 2]
        args = ("%4s" % i.to_s(3)).tr(' ', '0').split('').map(&:to_i)
        Card.new(*args)
      end
    end
  end

  class Game
    DECK_SIZE = Card::NUMBER_OF_UNIQUE_CARDS
    BOARD_SIZE = 12
    DEAL_SIZE = 3

    def initialize
      @deck = Deck.new(DECK_SIZE)
      @sets = []
      @board = @deck.deal(BOARD_SIZE)
    end

    def play
      loop do
        set = Card.remove_set(@board)
        if set
          @sets << set
        elsif @deck.empty?
          break
        end
        @board += @deck.deal(DEAL_SIZE)
      end
      self
    end

    def report
      s = "#{@board.length} unmatched cards on table\n" \
        "#{@deck.length} cards in deck\n" \
        "SETS FOUND:\n"
      @sets.each { |set| s << (set.map(&:to_s).join(', ')) << "\n" }
      s
    end
  end
end
