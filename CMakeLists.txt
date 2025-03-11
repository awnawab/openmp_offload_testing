# define minimum version of cmake required
cmake_minimum_required( VERSION 3.24 FATAL_ERROR )

# find ecbuild
find_package( ecbuild 3.8.2 QUIET HINTS ${CMAKE_BINARY_DIR} ${CMAKE_CURRENT_SOURCE_DIR} ${CMAKE_CURRENT_SOURCE_DIR}/../ecbuild )
if( NOT ecbuild_FOUND )
  include(cmake/fetchcontent_ecbuild.cmake)
endif()

# define the project
project( openmp_offload_test LANGUAGES Fortran VERSION 0.0 )

# set compiler flags
include( cmake/compile_options.cmake )

# find OpenMP
# CMake find_package struggles to find openmp in the pre-built amdflang
# but luckily ecbuild_find_package sets the appropriate hints
ecbuild_find_package( OpenMP REQUIRED COMPONENTS Fortran )
include( cmake/check_openmp_offload.cmake )

option( HAVE_OMP_OFFLOAD "OpenMP target offload is available" ${_HAVE_OMP_OFFLOAD} )
if( NOT HAVE_OMP_OFFLOAD )
   message( FATAL_ERROR "OpenMP target offload is required." )
endif()

# sources
list( APPEND srcs
      src/test_openmp_target.F90
      src/test_openmp_target_present.F90
      src/test_openmp_target_attach.F90
      src/test_openmp_target_runtime.F90
      src/test_openmp_target_struct.F90
)

# add tests
include(CTest)
foreach( src IN LISTS srcs)

   get_filename_component( _name ${src} NAME_WE )
   add_executable( ${_name}.x ${src} )
   target_link_libraries( ${_name}.x PRIVATE OpenMP::OpenMP_Fortran )
   target_link_options( ${_name}.x PRIVATE SHELL:${OpenMP_Fortran_FLAGS} )
   add_test( NAME ${_name} COMMAND ${_name}.x )

endforeach()
