module HasSources

  def sources
    @sources ||= []
  end
  def set_sources(x)
    @sources = x
    self
  end

  def includes
    @includes ||= []
  end
  def set_includes(x)
    @includes = x
    self
  end

  def includeString(type)
    @includeString[type] ||= ""
  end

  def defineString(type)
    @defineString[type] ||= ""
  end

  def calc_compiler_strings()
    @includeString = {}
    @defineString = {}
    [:CPP, :C, :ASM].each do |type|
      strMap = []
      all_dependencies.each do |e|
        d = ALL_BUILDING_BLOCKS[e]
        next if not HasSources === d
        if d.includes.length == 0
          strMap << File.relFromTo("include", d.project_dir)
        else
          d.includes.each { |k| strMap << File.relFromTo(k, d.project_dir) }
        end
      end
      @includeString[type] = strMap.map!{|k| "#{tcs[:COMPILER][type][:INCLUDE_PATH_FLAG]}#{k}"}.join(" ")

      @defineString[type] = @tcs[:COMPILER][type][:DEFINES].map {|k| "#{@tcs[:COMPILER][type][:DEFINE_FLAG]}#{k}"}.join(" ")
    end
  end

  def get_object_file(source)
    File.relFromTo(source, @project_dir + "/" + @output_dir) + ".o"
  end

  def get_dep_file(object)
    object + ".d"
  end

  def getSourceType(source)
    ex = File.extname(source)
    [:CPP, :C, :ASM].each do |t|
      return t if tcs[:COMPILER][t][:SOURCE_FILE_ENDINGS].include?(ex)
    end
    nil
  end

  def get_sources_task_name
    "Sources of #{name}"
  end

end
