module PreProcessor
  class LineOfWords
    @words = []
    @words_s = ""
    @hash_s = ""

    def initialize
      @words = []
      @words_s = ""
      @hash_s = ""
    end

    def words
      @words
    end

    def hash_s
      @hash_s
    end

    def words_s
      @words_s
    end

    def set(words_s)
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

    def increment(word)
      unless word.empty?
        if @accum.has_key? word
          @accum[word] += 1
        else
          @accum[word] = 1
        end
      end
    end

    def add_words(words)
      words.each { |w| increment(w) unless w.empty? }
    end

    def to_json
      @accum.to_json
    end

    def to_s
      @accum.to_s
    end
  end
end