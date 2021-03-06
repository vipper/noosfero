# -*- coding: utf-8 -*-
require 'fast_gettext'
module Noosfero
  PROJECT = 'noosfero'
  VERSION = '0.47.1'

  def self.pattern_for_controllers_in_directory(dir)
    disjunction = controllers_in_directory(dir).join('|')
    pattern = disjunction.blank? ? '' : ('(' + disjunction + ')')
    Regexp.new(pattern)
  end

  class << self
    def locales
      @locales ||= {
        'en' => 'English',
        'pt' => 'Português',
        'fr' => 'Français',
        'hy' => 'հայերեն լեզու',
        'de' => 'Deutsch',
        'ru' => 'русский язык',
        'es' => 'Español',
        'eo' => 'Esperanto',
        'it' => 'Italiano'
      }
    end
    attr_writer :locales
    attr_accessor :default_locale
    def available_locales
      @available_locales ||=
        begin
          locales_list = locales.keys
          # move English to the beginning
          if locales_list.include?('en')
            locales_list = ['en'] + (locales_list - ['en']).sort
          end
          locales_list
        end
    end
    def each_locale
      locales.keys.sort.each do |key|
        yield(key, locales[key])
      end
    end
    def with_locale(locale)
      orig_locale = FastGettext.locale
      FastGettext.set_locale(locale)
      yield
      FastGettext.set_locale(orig_locale)
    end
  end

  def self.identifier_format
    '[a-z0-9][a-z0-9~.]*([_-][a-z0-9~.]+)*'
  end

  def self.default_hostname
    Environment.table_exists? && Environment.default ? Environment.default.default_hostname : 'localhost'
  end

  private

  def self.controllers_in_directory(dir)
    app_controller_path = Dir.glob(File.join(RAILS_ROOT, 'app', 'controllers', dir, '*_controller.rb'))
    app_controller_path.map do |item|
      item.gsub(/^.*\/([^\/]+)_controller.rb$/, '\1')
    end
  end

  def self.term(t)
    self.terminology.get(t)
  end
  def self.terminology
    @terminology ||= Noosfero::Terminology::Default.instance
  end
  def self.terminology=(term)
    @terminology = term
  end

  def self.url_options
    case ENV['RAILS_ENV']
    when 'development'
      development_url_options
    when 'cucumber'
      if Capybara.current_driver == :selenium
        { :host => Capybara.current_session.driver.rack_server.host, :port => Capybara.current_session.driver.rack_server.port }
      end
    end || { }
  end

  def self.development_url_options
    @development_url_options || {}
  end

end

require 'noosfero/constants'
require 'noosfero/core_ext'
