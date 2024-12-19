module Processor
  class Processor
    @accum = WordAccumulator.new
  end

  class LineOfWords
    @words = []
    @words_s = ""
    @hash_s = ""

    def initialize
      @words = []
      @words_s = ""
      @hash_s = ""
    end

    def self.words
      @words
    end

    def self.hash_s
      @hash_s
    end

    def self.words_s
      @words_s
    end

    def self.set(words_s)
      @words_s = words_s
      @hash_s = Digest::SHA256.hexdigest words_s
      @words = words_s.split
    end
  end

  class WordAccumulator
    @accum = {}

    def initialize
      @accum = {}
    end

    def self.increment(word)
      unless word.empty?
        if @accum.has_key? word
          @accum[word].increment
        else
          @accum[word] = WordCount.new(word, 1)
        end
      end
    end

    def self.add_words(words)
      words.each { |w| increment(w) unless w.empty? }
    end

    def self.to_json
      @accum.to_json
    end

    def self.to_s
      @accum.to_s
    end
  end

  class WordCount
    @key = ""
    @count = 0

    def initialize(word, count)
      @key = word
      @count = count
    end

    def self.key
      @key
    end

    def self.count
      @count
    end

    def self.set_count!(count)
      @count = count
    end

    def self.increment
      @count += 1
    end

    def self.add(count)
      @count += count
    end
  end
end
