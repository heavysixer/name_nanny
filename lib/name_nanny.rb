# The Name Nanny makes sure that users behave themselves when on the system.
module NameNanny
  RESERVED_NAMES = (IO.readlines RAILS_ROOT + '/vendor/plugins/name_nanny/lib/reserved_words.txt').each { |w| w.chop! }
  BAD_WORDS      = (IO.readlines RAILS_ROOT + '/vendor/plugins/name_nanny/lib/bad_words.txt').each { |w| w.chop! }
  
  # Use a non-descript error to prevent the users from trying to hack around the filter.
  # Hopefully, they will just give up and choose something nicer.
  def validates_wholesomeness_of(*attr_names)
    configuration = { :message => "is already taken" }
    configuration.merge!(attr_names.pop) if attr_names.last.is_a?(Hash)
    
    validates_each(attr_names) do |record, attr_names|
      unless !configuration[:if].nil? and not configuration[:if].call(record)
        record.errors.add( attr_names, configuration[:message] ) if bad_name? record.send(attr_names)
      end
    end
  end

  def bleep_text(str)
    sub_text(str,"bleeep")
  end

  def smurf_text(str)
    sub_text(str,"smurf")
  end

  def strip_text(str)
    sub_text(str,"")
  end

  protected
  def sub_text(str,replacement = "bleeep")
    
    # Replace commas with an unlikely character combination
    str = str.gsub(',', ' ^&^ ')
    baddies = str.split(" ").map { | word | word.rstrip if BAD_WORDS.include?(word.rstrip.downcase) }.compact
    baddies.each { |word| str.gsub!(word, replacement) }
    
    # Return commas to their correct position within the string
    str = str.gsub(' ^&^ ', ',')
    str
  end
  
  def bad_name?(str)
    bad_name = false
    words =  str.split(" ").each do |name|
      bad_name = true if RESERVED_NAMES.include?(name.downcase)
      bad_name = true if BAD_WORDS.include?(name.downcase)
    end
    bad_name
  end
end