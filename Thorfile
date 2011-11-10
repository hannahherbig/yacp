require 'rsa'
require 'yaml'
require 'pp'

class GenerateKey < Thor::Group
  include Thor::Actions

  class_option :bits, :default => 1024, :aliases => '-b'
  class_option :file, :default => 'etc/identity.yml', :aliases => '-f'
  
  def setup
    self.destination_root = File.expand_path(".", File.dirname(__FILE__))
  end
  
  def generate
    print "If this is slow, generate some randomness... "
    @key_pair = RSA::KeyPair.generate(options[:bits])
    puts "done."
  end

  def save
    create_file(options[:file], @key_pair.to_yaml)
  end
end
