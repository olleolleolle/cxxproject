require 'cxxproject/buildingblocks/building_block'

class CommandLine < BuildingBlock

  def set_command_line(x)
    @line = x
    self
  end

  def get_command_line
    @line
  end

  def get_target
    @target
  end

  @@command_line_num = 0
  def initialize(name)
    super(name)
    @line = name
    @@command_line_num = @@command_line_num + 1
    @num = @@command_line_num
  end

  def get_task_name()
    "command line (#{@num}): " + get_command_line
  end

end