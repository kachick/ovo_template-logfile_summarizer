#!/usr/local/bin/ruby -w
#  Copyright (C) 2011-2012  Kenichi Kamiya

require 'logger'
require_relative 'openviewoperations/templates'
require_relative 'openviewoperations/templates/parser'
require_relative 'openviewoperations/templates/parser/logfile'
require_relative 'ovo_templatelogfile_summarizer/csvformatter'

class String
  def pathable
    gsub(%r![/:*?"<>|\\]!, '!')
  end
end

module OVO_TemplateLogfile_Summarizer

  include OpenViewOperations
  
  VERSION = '0.0.1'.freeze
  FORMATTER = CSVFormatter
  TITLE     = FORMATTER.title

  module_function
  
  def run(pathnames)
    pathnames.each do |path|
      logger = Logger.new "#{path}.log"
      logger.progname = :'OVOTemplate(Syslog)Summarizer'

      begin
        templates = Templates.load path
      rescue Exception
        logger.fatal 'Error occurred'
        raise
      else
        templates.each_pair do |name, template|
          base_path = "#{path}.#{name.pathable}"
          
          open "#{base_path}.summary.csv", 'w:windows-31J' do |out|
          open "#{base_path}.summary.oneline.csv", 'w:windows-31J' do |oneline|
            out.puts TITLE
            oneline.puts TITLE
            
            template.each_with_ovo_index do |cond, idx|
              formatter = FORMATTER.new cond, idx, template
              oneline_formatter = FORMATTER::OneLine.new cond, idx, template
              out.puts formatter
              oneline.puts oneline_formatter
            end
          end
          end
        end
        
        logger.info 'Complete'
      end
    end
  end

end