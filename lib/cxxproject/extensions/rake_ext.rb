require 'cxxproject/extensions/stdout_ext'
require 'cxxproject/utils/dot/graph_writer'

require 'rake'
require 'stringio'
require 'thread'

Rake::TaskManager.record_task_metadata = true

module Rake

  $exit_code = 0

  #############
  # - Limit parallel tasks
  #############
  class MultiTask < Task

    @@max_parallel_tasks = 8

    def self.max_parallel_tasks
      @@max_parallel_tasks
    end

    def self.set_max_parallel_tasks(number)
      @@max_parallel_tasks = number
    end

    private
    def invoke_prerequisites(args, invocation_chain)
      return unless @prerequisites

      jobqueue = @prerequisites.dup
      m = Mutex.new
      numThreads = [jobqueue.length, @@max_parallel_tasks].min
      threads = []
      numThreads.times {
        threads << Thread.new(jobqueue) { |jq|
          while true do
            p = nil
            m.synchronize { p = jq.shift }
            break unless p
            prereq = application[p]
            prereq.invoke_with_call_chain(args, invocation_chain)
            if prereq.failure
              set_failed
            end
            synchronized_output(m, prereq.output_string)
          end
        }
      }
      threads.each { |t| t.join }
    end

    def synchronized_output(mutex, output)
      return if Rake::Task.output_disabled
      mutex.synchronize { puts output }
    end
  end

  ###########
  # - Go on if a task fails (but to not execute the parent)
  # - showInGraph is used for GraphWriter (internal tasks are not shown)
  #############
  class Task
    class << self
      attr_accessor :bail_on_first_error
      attr_accessor :output_disabled
    end

    attr_accessor :failure # specified if that task has failed
    attr_accessor :deps # used to store deps by depfile task for the apply task (no re-read of depsfile)
    attr_accessor :type
    attr_accessor :transparent_timestamp
    attr_accessor :dismissed_prerequisites
    attr_accessor :progress_count
    attr_accessor :output_string

    UNKNOWN     = 0x0000 #
    OBJECT      = 0x0001 #
    SOURCEMULTI = 0x0002 # x
    DEPFILE     = 0x0004 #
    LIBRARY     = 0x0008 # x
    EXECUTABLE  = 0x0010 # x
    CONFIG      = 0x0020 #
    APPLY       = 0x0040 #
    UTIL        = 0x0080 #
    BINARY      = 0x0100 # x
    MODULE      = 0x0200 # x
    MAKE        = 0x0400 # x
    RUN         = 0x0800 #
    CUSTOM      = 0x1000 # x
    COMMANDLINE = 0x2000 # x

    STANDARD    = 0x371A # x above means included in STANDARD
    attr_reader :ignore
    execute_org = self.instance_method(:execute)
    initialize_org = self.instance_method(:initialize)
    timestamp_org = self.instance_method(:timestamp)
    invoke_prerequisites_org = self.instance_method(:invoke_prerequisites)
    invoke_org = self.instance_method(:invoke)

    define_method(:initialize) do |task_name, app|
      initialize_org.bind(self).call(task_name, app)
      @type = UNKNOWN
      @deps = nil
      @transparent_timestamp = false
      @dismissed_prerequisites = []
      @neededStored = nil # cache result for performance
      progress_count = 0
      @ignore = false
      @failure = false
    end

    define_method(:invoke) do |*args|
      $exit_code = 0
      invoke_org.bind(self).call(*args)
      if @failure or BuildingBlock.idei.get_abort
        $exit_code = 1
      end
    end

    define_method(:invoke_prerequisites) do |task_args, invocation_chain|
      orgLength = 0
      while @prerequisites.length > orgLength do
        orgLength = @prerequisites.length
        @prerequisites.dup.each do |n| # dup needed when apply tasks changes that array
          break if BuildingBlock.idei.get_abort
          begin
            prereq = application[n, @scope]
            prereq_args = task_args.new_scope(prereq.arg_names)
            prereq.invoke_with_call_chain(prereq_args, invocation_chain)
            if prereq.failure
              set_failed
            end
          rescue Exception => e
            begin
              if Rake::Task[n].ignore
                @prerequisites.delete(n)
                def self.needed?
                  true
                end
                next
              end
            rescue => e
              puts "Error #{name}: #{e.message}"
            end
            set_failed
          end
        end
      end
    end

    def set_failed()
      @failure = true
      if Rake::Task.bail_on_first_error
        BuildingBlock.idei.set_abort(true)
      end
    end

    define_method(:execute) do |arg|
      s = StringIO.new
      Thread.current[:stdout] = s

      break if @failure # check if a prereq has failed
      break if BuildingBlock.idei.get_abort

      begin
        execute_org.bind(self).call(arg)
      rescue Exception => ex1 # todo: no rescue to stop on first error
        # todo: debug log, no puts here!
        if not BuildingBlock.idei.get_abort()
          puts "Error for task: #{@name} #{ex1.message}"
        end
        begin
          FileUtils.rm(@name) if File.exists?(@name) # todo: error parsing?
        rescue Exception => ex2
          # todo: debug log, no puts here!
          puts "Error: Could not delete #{@name}: #{ex2.message}"
        end
        set_failed
      end
      self.output_string = s.string
      Thread.current[:stdout] = nil
    end

    define_method(:timestamp) do
      if @transparent_timestamp
        ts = Rake::EARLY
        @prerequisites.each do |pre|
          prereq_timestamp = Rake.application[pre].timestamp
          ts = prereq_timestamp if prereq_timestamp > ts
        end
      else
        ts = timestamp_org.bind(self).call()
      end
      ts
    end

    def ignore_missing_file
      @ignore = true
    end

  end

  at_exit do
    exit($exit_code)
  end

end

