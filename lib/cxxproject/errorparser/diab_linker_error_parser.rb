require 'cxxproject/errorparser/error_parser'

module Cxxproject
  class DiabLinkerErrorParser < ErrorParser

    def initialize()
      @error_expression = /dld: ([A-Za-z]+): (.+)/
    end

    def scan_lines(consoleOutput, proj_dir)
      res = []
      error_severity = 255
      consoleOutput.each_line do |l|
        l.rstrip!
        d = ErrorDesc.new
        scan_res = l.scan(@error_expression)
        if scan_res.length == 0 # msg will end with the beginning of the next message
          d.severity = error_severity
          d.message = l
        else
          d.file_name = proj_dir
          d.line_number = 0
          d.message = scan_res[0][1]
          d.severity = get_severity(scan_res[0][0])
          error_severity = d.severity
        end
        res << d
      end
      [res, consoleOutput]
    end

  end
end
