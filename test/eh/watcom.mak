# (c) 2004 Wojciech Gazda
# Asua Programmers Group
#
# Updated for Open Watcom on 32bit OS/2 and Windows.
# This requires Watcom make.
#
# Set the following environment variables/macros:
#   DEBUG       - when set enable standard debug options: -D_DEBUG macro for STL
#                 and -d2i compiler option. Without no DEBUG set, -d1 is used
#                 with default optimizations.
#   DEBUG_FLAGS - allows to customize debugging options (override the above).
#   CXXFLAGS    - additional compiler options.
#
# Note: command line macros takes priority over environment variables.
#
# Targets:
#   wmake -f watcom.mak
#     By default stl_test.exe is built in the curent directory.
#
#   wmake -f watcom.mak test.exe
#     Executable for single test is built in the current directory.
#     Warning procuced by wmake can be ignored.
#

.EXTENSIONS
.EXTENSIONS: .obj .cpp
.HOLD


# Set debug mode: DEBUG_FLAGS variable
STD_DEBUG=-d2i
!ifndef DEBUG_FLAGS
!ifdef %DEBUG_FLAGS
DEBUG_FLAGS=$(%DEBUG_FLAGS)
!else
# Check for standard debug mode
!ifdef DEBUG
DEBUG_FLAGS=$(STD_DEBUG)
!endif
!ifdef %DEBUG
DEBUG_FLAGS=$(STD_DEBUG)
!endif
!endif # %DEBUG_FLAGS
!endif # DEBUG_FLAGS
# Default
!ifndef DEBUG_FLAGS
DEBUG_FLAGS=-d1
!endif

# Set additional compiler options: CXXFLAGS
!ifndef CXXFLAGS
!ifdef %CXXFLAGS
CXXFLAGS=$(%CXXFLAGS)
!endif
!endif

AUX_OBJECTS=TestClass.obj main.obj nc_alloc.obj random_number.obj
TEST_OBJECTS=test_algo.obj &
    test_algobase.obj test_list.obj test_slist.obj &
    test_bit_vector.obj test_vector.obj &
    test_deque.obj test_set.obj test_map.obj &
    test_hash_map.obj test_hash_set.obj &
    test_string.obj test_bitset.obj test_valarray.obj &
    test_rope.obj
OBJECTS = $(AUX_OBJECTS) $(TEST_OBJECTS)


CC = wpp386
CXX = $(CC)
LINK = wlink
CPPFLAGS = -D_STLP_NO_OWN_IOSTREAMS -DEH_VECTOR_OPERATOR_NEW &
            $(STL_INCL) -i. -bm -we -xs $(DEBUG_FLAGS) $(CXXFLAGS)


#####################
# Top level targets #
#####################
all: bin eh_test.exe .SYMBOLIC
    @%null



########################
# Build standard tests #
########################
# Standard tests
eh_test.exe : bin $(OBJECTS)
    @%create bin/$^*.lnk
    @for %i in ($OBJECTS) do @%append bin/$^*.lnk file bin/%i
    $(LINK) $(OPT_LINK) debug dwarf system os2v2 name $^@ opt symf @bin/$^*.lnk


# General compilation rule
.obj: bin
.cpp.obj: .AUTODEPEND
    $(CXX) $(CPPFLAGS) $[&.cpp -fo=bin/$^. -fr=bin


# Make object directory
bin:
    -@mkdir bin >NUL 2>NUL


# Clean all
clean: .SYMBOLIC
    -@del *.sym *.exe *.err bin\* /N >NUL 2>NUL
    -@rmdir bin >NUL 2>NUL


