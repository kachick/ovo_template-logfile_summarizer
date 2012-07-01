#  Copyright (C) 2010-2012  Kenichi Kamiya

require 'forwardable'
require 'csv'

module OVO_TemplateLogfile_Summarizer

  class CSVFormatter
    extend Forwardable
    
    module ParameterFormattable
      attr_accessor :param_separator
    
      def to_s
        [].tap { |list|
          each_pair do |key, value|
            list << "#{key}: #{value}"
          end
        }.join param_separator
      end
    end
    
    COLUMNS = [
      %w[Index                   index],
      %w[c/Description           description],
      %w[c/Condition_ID          condition_id],
      %w[c/Text                  core.text],
      %w[!/Mode                  mode],
      %w[s/ServerLogOnly         set_serverlogonly],
      %w[j/Enable?               enable?],
      %w[s/Severity              set_severity],
      %w[s/MessageGroup          set_msggrp],
      %w[s/Application           set_application],
      %w[s/Object                set_object],
      %w[s/MessageType           set_msgtype],
      %w[s/AutoAction            set_autoaction],
      %w[s/Text                  set_text],
      %w[s/HelpText              set_helptext],
      %w[[!|c|s]/OtherParameters other_parameters]
    ]
    
    SET_DEFINES = OpenViewOperations::Templates::Parser::LOGFILE.set_defines
    OTHER_SET_PARAMETERS = SET_DEFINES - COLUMNS.select{|type, *|%r!^s/! =~ type}
                                         .map{|type, *|type.slice(%r!/(.+?)$!, 1).upcase.to_sym}
    
    class << self
      def headers
        COLUMNS.map(&:first)
      end
      
      def title
        headers.to_csv
      end
    end
    
    attr_reader :index
    
    def initialize(condition, index, template)
      @condition, @index, @template = condition, index, template
    end
    
    def_delegators :@condition,
                    :mode, :description, :supp_dupl_ident,
                    :supp_dupl_ident_output_msg, :condition_id, :core, :set
                    
    def_delegators :self.class, :headers, :title
    
    def row
      COLUMNS.map{|*, mname|instance_eval mname}
    end
    
    def to_s
      row.to_csv
    end
    
    SET_DEFINES.each do |prefix|
      key = prefix.downcase

      define_method :"set_#{key}" do
        (set ? set[key] : nil) || \
        (@template.set[key] && "t/#{@template.set[key]}")
      end
    end
    
    def enable?
      case mode
      when :suppresscondition
        false
      else
        !set_serverlogonly
      end
    end
    
    def other_parameters
      result = {}
      
      %w(SUPP_DUPL_IDENT SUPP_DUPL_IDENT_OUTPUT_MSG).each do |name|
        value = __send__ name.downcase
        result["c/#{name}"] = value unless value == nil
      end
      
      OTHER_SET_PARAMETERS.each do |name|
        value = __send__ "set_#{name.downcase}"
        result["s/#{name}"] = value unless value == nil
      end
      
      if result.empty?
        nil
      else
        result.extend ParameterFormattable
        result.param_separator = param_separator
        result
      end
    end
    
    private
    
    def param_separator
      "\n"
    end
    
    class OneLine < self    
      def to_s
        super.gsub(/\n(?!\Z)/){'\n'}
      end
      
      private
      
      def param_separator
        ' | '
      end
    end
  end

end