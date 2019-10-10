class OptionLoader

  require 'optparse'
  require 'yaml'

  attr_accessor :options_list

  def initialize(options_list)
    self.options_list = options_list
  end

  def switch(key)
    "--#{key.to_s.gsub('_', '-')} [String]"
  end

  def label(key)
    key.to_s.gsub('_', ' ').capitalize
  end

  def load_from_env
    options = {}
    options_list.each do |key|
      options[key] = ENV[key.to_s.upcase] if ENV[key.to_s.upcase]
    end
    options
  end

  def load_from_file
    return {} unless File.exist?('config.yml')
    config = YAML.load_file('config.yml')
    return {} unless config.is_a?(Hash)
    options = {}
    (config.keys & options_list.collect(&:to_s)).each do |key|
      puts config[key.to_s]
      options[key.to_sym] = config[key.to_s] if config[key.to_s]
    end
    options
  end

  def load_from_switches
    options = {}
    OptionParser.new do |opts|
      opts.banner = 'Usage: ruby migrate.rb [options]'
      options_list.each do |key|
        opts.on(switch(key), String, label(key)) do |var|
          options[key] = var if var
        end
      end
    end.parse!
    options
  end

  def empty_list
    options = {}
    options_list.each do |key|
      options[key] = ''
    end
    options
  end

  def load
    empty_list
      .merge(load_from_env)
      .merge(load_from_file)
      .merge(load_from_switches)
  end

end
