module SharedSecretAuthentication
  extend self

  def self.sign_hash(hash)
    hash.merge('signature' => hash_signature(hash))
  end

  def self.hash_signature_correct?(hash)
    raise ArgumentError.new("hash must be signed (have a key of 'signature')") unless expected_signature = hash.delete('signature')
    
    hash_signature(hash) == expected_signature
  end

  def self.hash_signature(hash)
    d = Digest::SHA2.new
    string_keys = hash.keys.inject({}) {|keys, key| keys.merge!(key.to_s => key) }
    string_keys.keys.sort.each do |key|
      d.update key
      value = hash[string_keys[key]]
      if value.instance_of? Hash
        value = value.collect {|k,v| k.to_s + v.to_s}
      end
      if value.instance_of? Array
        value = value.sort
      end
      d.update value.to_s
    end
    d.update SHARED_SECRET
    d.to_s
  end
end
