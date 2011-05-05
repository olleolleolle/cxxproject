require 'cxxproject/toolchain/base'

module Cxxproject
  module Toolchain

<<<<<<< HEAD
    DiabChain = Provider.add("Diab")

    DiabChain[:COMPILER][:C].update({
      :COMMAND => "dcc",
      :FLAGS => "-tPPCE200Z6VEN:simple -O -XO -Xsize-opt -Xsmall-const=0 -Xenum-is-best -Xrtti-off -Xexceptions-off -Xexceptions-off -Xenum-is-best -g -Xmake-dependency=6",
      :DEFINE_FLAG => "-D",
      :OBJECT_FILE_FLAG => "-o",
      :INCLUDE_PATH_FLAG => "-I",
      :COMPILE_FLAGS => "-c"
    })

    DiabChain[:COMPILER][:CPP] = DiabChain[:COMPILER][:C]
    DiabChain[:COMPILER][:CPP][:FLAGS].concat(" -Xrtti-off")
    
    DiabChain[:COMPILER][:ASM] = DiabChain[:COMPILER][:C]
    DiabChain[:COMPILER][:ASM][:COMMAND] = "das"
    DiabChain[:COMPILER][:ASM][:FLAGS] = "-tPPCE200Z6VEN:simple -Xisa-vle -g -Xasm-debug-on"
    DiabChain[:COMPILER][:ASM][:COMPILE_FLAGS] = ""
    
    DiabChain[:ARCHIVER][:COMMAND] = "dar"
    DiabChain[:ARCHIVER][:ARCHIVE_FLAGS] = "-r"

    DiabChain[:LINKER][:COMMAND] = "dcc"
    DiabChain[:LINKER][:SCRIPT] = "-Wm"
    DiabChain[:LINKER][:USER_LIB_FLAG] = "-l:"
    DiabChain[:LINKER][:EXE_FLAG] = "-o"
    DiabChain[:LINKER][:LIB_FLAG] = "-l"
    DiabChain[:LINKER][:LIB_PATH_FLAG] = "-L"
    DiabChain[:LINKER][:MAP_FILE_FLAG] = "-Wl,-m6" # no map file if this string is empty, otherwise -Wl,-m6 > abc.map
    DiabChain[:LINKER][:FLAGS] = "-ulink_date_time -uResetConfigurationHalfWord -Wl,-Xstop-on-redeclaration -Wl,-Xstop-on-warning -tPPCE200Z6VEN:simple -Wl,-Xremove-unused-sections -Wl,-Xunused-sections-list"
    DiabChain[:LINKER][:OUTPUT_ENDING] = ".elf"
=======
    DiabChainDebug = Provider.add("Diab_Debug")

    DiabChainDebug[:COMPILER][:C].update({
      :COMMAND => "dcc",
      :FLAGS => "-tPPCE200Z6VEN:simple -O -XO -Xsize-opt -Xsmall-const=0 -Xenum-is-best -Xrtti-off -Xexceptions-off -Xexceptions-off -Xenum-is-best -g",
      :DEFINE_FLAG => "-D",
      :OBJECT_FILE_FLAG => "-o",
      :INCLUDE_PATH_FLAG => "-I",
      :COMPILE_FLAGS => "-c",
      :DEP_FLAGS => "-Xmake-dependency=6 -Xmake-dependency-savefile="
    })

    DiabChainDebug[:COMPILER][:CPP] = DiabChainDebug[:COMPILER][:C].clone()
    DiabChainDebug[:COMPILER][:CPP][:FLAGS].concat(" -Xrtti-off")
    DiabChainDebug[:COMPILER][:CPP][:SOURCE_FILE_ENDINGS] = Provider.default[:COMPILER][:CPP][:SOURCE_FILE_ENDINGS]

    DiabChainDebug[:COMPILER][:ASM] = DiabChainDebug[:COMPILER][:C]
    DiabChainDebug[:COMPILER][:ASM][:COMMAND] = "das"
    DiabChainDebug[:COMPILER][:ASM][:FLAGS] = "-tPPCE200Z6VEN:simple -Xisa-vle -g -Xasm-debug-on"
    DiabChainDebug[:COMPILER][:ASM][:COMPILE_FLAGS] = ""
    DiabChainDebug[:COMPILER][:ASM][:SOURCE_FILE_ENDINGS] = Provider.default[:COMPILER][:ASM][:SOURCE_FILE_ENDINGS]

    DiabChainDebug[:ARCHIVER][:COMMAND] = "dar"
    DiabChainDebug[:ARCHIVER][:ARCHIVE_FLAGS] = "-r"

    DiabChainDebug[:LINKER][:COMMAND] = "dcc"
    DiabChainDebug[:LINKER][:SCRIPT] = "-Wm"
    DiabChainDebug[:LINKER][:USER_LIB_FLAG] = "-l:"
    DiabChainDebug[:LINKER][:EXE_FLAG] = "-o"
    DiabChainDebug[:LINKER][:LIB_FLAG] = "-l"
    DiabChainDebug[:LINKER][:LIB_PATH_FLAG] = "-L"
    DiabChainDebug[:LINKER][:MAP_FILE_FLAG] = "-Wl,-m6" # no map file if this string is empty, otherwise -Wl,-m6 > abc.map
    DiabChainDebug[:LINKER][:FLAGS] = "-ulink_date_time -uResetConfigurationHalfWord -Wl,-Xstop-on-redeclaration -Wl,-Xstop-on-warning -tPPCE200Z6VEN:simple -Wl,-Xremove-unused-sections -Wl,-Xunused-sections-list"
    DiabChainDebug[:LINKER][:OUTPUT_ENDING] = ".elf"

    DiabChainRelease = Provider.add("Diab_Release", "Diab_Debug")
    DiabChainRelease[:COMPILER][:C][:FLAGS] = "-tPPCE200Z6VEN:simple -XO -Xsize-opt -Xsmall-const=0 -Xenum-is-best -Xsection-split -Xforce-declarations -Xmake-dependency=6"
    DiabChainRelease[:COMPILER][:CPP][:FLAGS] = "-tPPCE200Z6VEN:simple -XO -Xsize-opt -Xsmall-const=0 -Xenum-is-best -Xrtti-off -Xexceptions-off -Xsection-split -Xmake-dependency=6"
>>>>>>> apichange

  end
end
