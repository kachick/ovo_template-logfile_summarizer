# Copyright (C) 2012  Kenichi Kamiya

require 'striuct'

module OpenViewOperations; class Templates; class Parser

  class LOGFILE < self

    Core = Striuct.define do
      member :text, AND(String, NOT(''))
    end
    
    class << self
      def sepcific_sets
        [:LOGPATH, :INTERVAL, :CHSET, :FROM_LAST_POS, :NO_LOGFILE_MSG,
        :CLOSE_AFTER_READ]
      end
      
      def set_defines
        sepcific_sets + SET_DEFINES.map{|prefix, type|prefix}      
      end
    end
    
    private
    
    def template_type
      :LOGFILE
    end
    
    def parse_core
      if parse_flag :CONDITION
        Core.define do |core|
          core.text = parse_text
        end
      end
    end
    
    def parse_text
      parse_quoted :TEXT
    end
    
    def sepcific_sets
      self.class.__send__ __method__
    end
    
    def set_defines
      self.class.__send__ __method__     
    end

    def parse_set_logpath
      parse_quoted :LOGPATH
    end
 
    def parse_set_interval
      parse_quoted :INTERVAL
    end

    def parse_set_chset
      parse_naked :CHSET
    end
 
    def parse_set_from_last_pos
      parse_flag :FROM_LAST_POS
    end

    def parse_set_no_logfile_msg
      parse_flag :NO_LOGFILE_MSG
    end
 
    def parse_set_close_after_read
      parse_flag :CLOSE_AFTER_READ
    end

  end

  Logfile = Syslog = LOGFILE

end; end; end