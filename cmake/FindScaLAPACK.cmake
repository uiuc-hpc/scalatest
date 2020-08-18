# Distributed under the OSI-approved BSD 3-Clause License.  See accompanying
# file Copyright.txt or https://cmake.org/licensing for details.

#[=======================================================================[.rst:
FindScaLAPACK
----------

Find Scalable Linear Algebra PACKage (ScaLAPACK) library

This module finds an installed fortran library that implements the
ScaLAPACK linear-algebra interface (see http://www.netlib.org/scalapack/).

Input Variables
^^^^^^^^^^^^^^^

The following variables may be set to influence this module's behavior:

``BLA_STATIC``
  if ``ON`` use static linkage

``BLA_VENDOR``
  If set, checks only the specified vendor, if not set checks all the
  possibilities.  List of vendors valid in this module:

  * ``Intel10_32`` (intel mkl v10 32 bit)
  * ``Intel10_64lp`` (intel mkl v10+ 64 bit, threaded code, lp64 model)
  * ``Intel10_64lp_seq`` (intel mkl v10+ 64 bit, sequential code, lp64 model)
  * ``Intel10_64ilp`` (intel mkl v10+ 64 bit, threaded code, ilp64 model)
  * ``Intel10_64ilp_seq`` (intel mkl v10+ 64 bit, sequential code, ilp64 model)
  * ``Intel`` (obsolete versions of mkl 32 and 64 bit)
  * ``OpenBLAS``
  * ``FLAME``
  * ``ACML``
  * ``Apple``
  * ``NAS``
  * ``Generic``

Result Variables
^^^^^^^^^^^^^^^^

This module defines the following variables:

``ScaLAPACK_FOUND``
  library implementing the ScaLAPACK interface is found
``ScaLAPACK_LINKER_FLAGS``
  uncached list of required linker flags (excluding -l and -L).
``ScaLAPACK_LIBRARIES``
  uncached list of libraries (using full path name) to link against
  to use ScaLAPACK

.. note::

  C or CXX must be enabled to use Intel MKL

  For example, to use Intel MKL libraries and/or Intel compiler:

  .. code-block:: cmake

    set(BLA_VENDOR Intel10_64lp)
    find_package(ScaLAPACK)
#]=======================================================================]

set(_scalapack_ORIG_CMAKE_FIND_LIBRARY_SUFFIXES ${CMAKE_FIND_LIBRARY_SUFFIXES})

# Check the language being used
if( NOT (CMAKE_C_COMPILER_LOADED OR CMAKE_CXX_COMPILER_LOADED OR CMAKE_Fortran_COMPILER_LOADED) )
  if(ScaLAPACK_FIND_REQUIRED)
    message(FATAL_ERROR "FindScaLAPACK requires Fortran, C, or C++ to be enabled.")
  else()
    message(STATUS "Looking for ScaLAPACK... - NOT found (Unsupported languages)")
    return()
  endif()
endif()

if (CMAKE_Fortran_COMPILER_LOADED)
include(CheckFortranFunctionExists)
else ()
include(CheckFunctionExists)
endif ()
include(CMakePushCheckState)

cmake_push_check_state()
set(CMAKE_REQUIRED_QUIET ${ScaLAPACK_FIND_QUIETLY})

set(ScaLAPACK_FOUND FALSE)

# TODO: move this stuff to separate module

macro(Check_Scalapack_Libraries LIBRARIES _prefix _name _flags _list _lapack _threads _mpi)
# This macro checks for the existence of the combination of fortran libraries
# given by _list.  If the combination is found, this macro checks (using the
# Check_Fortran_Function_Exists macro) whether can link against that library
# combination using the name of a routine given by _name using the linker
# flags given by _flags.  If the combination of libraries is found and passes
# the link test, LIBRARIES is set to the list of complete library paths that
# have been found.  Otherwise, LIBRARIES is set to FALSE.

#  N.B. _prefix is the prefix applied to the names of all cached variables that
# are generated internally and marked advanced by this macro.

set(_libraries_work TRUE)
set(${LIBRARIES})
set(_combined_name)
if (NOT _libdir)
  if (WIN32)
    set(_libdir ENV LIB)
  elseif (APPLE)
    set(_libdir ENV DYLD_LIBRARY_PATH)
  else ()
    set(_libdir ENV LD_LIBRARY_PATH)
  endif ()
endif ()

list(APPEND _libdir "${CMAKE_C_IMPLICIT_LINK_DIRECTORIES}")

foreach(_library ${_list})
  set(_combined_name ${_combined_name}_${_library})

  if(_libraries_work)
    if (BLA_STATIC)
      if (WIN32)
        set(CMAKE_FIND_LIBRARY_SUFFIXES .lib ${CMAKE_FIND_LIBRARY_SUFFIXES})
      endif ()
      if (APPLE)
        set(CMAKE_FIND_LIBRARY_SUFFIXES .lib ${CMAKE_FIND_LIBRARY_SUFFIXES})
      else ()
        set(CMAKE_FIND_LIBRARY_SUFFIXES .a ${CMAKE_FIND_LIBRARY_SUFFIXES})
      endif ()
    else ()
      if (CMAKE_SYSTEM_NAME STREQUAL "Linux")
        # for ubuntu's libblas3gf and liblapack3gf packages
        set(CMAKE_FIND_LIBRARY_SUFFIXES ${CMAKE_FIND_LIBRARY_SUFFIXES} .so.3gf)
      endif ()
    endif ()
    find_library(${_prefix}_${_library}_LIBRARY
      NAMES ${_library}
      PATHS ${_libdir}
      )
    mark_as_advanced(${_prefix}_${_library}_LIBRARY)
    set(${LIBRARIES} ${${LIBRARIES}} ${${_prefix}_${_library}_LIBRARY})
    set(_libraries_work ${${_prefix}_${_library}_LIBRARY})
  endif()
endforeach()

if(_libraries_work)
  # Test this combination of libraries.
  if(UNIX AND BLA_STATIC)
    set(CMAKE_REQUIRED_LIBRARIES ${_flags} "-Wl,--start-group" ${${LIBRARIES}} ${_lapack} "-Wl,--end-group" ${_threads} ${_mpi})
  else()
    set(CMAKE_REQUIRED_LIBRARIES ${_flags} ${${LIBRARIES}} ${_lapack} ${_threads} ${_mpi})
  endif()
#  message("DEBUG: CMAKE_REQUIRED_LIBRARIES = ${CMAKE_REQUIRED_LIBRARIES}")
  if (NOT CMAKE_Fortran_COMPILER_LOADED)
    check_function_exists("${_name}_" ${_prefix}${_combined_name}_WORKS)
  else ()
    check_fortran_function_exists(${_name} ${_prefix}${_combined_name}_WORKS)
  endif ()
  set(CMAKE_REQUIRED_LIBRARIES)
  set(_libraries_work ${${_prefix}${_combined_name}_WORKS})
  #message("DEBUG: ${LIBRARIES} = ${${LIBRARIES}}")
endif()

 if(_libraries_work)
   if("${_list}" STREQUAL "")
     set(${LIBRARIES} "${LIBRARIES}-PLACEHOLDER-FOR-EMPTY-LIBRARIES")
   else()
     set(${LIBRARIES} ${${LIBRARIES}} ${_lapack} ${_threads} ${_mpi})
   endif()
 else()
    set(${LIBRARIES} FALSE)
 endif()

endmacro()


set(ScaLAPACK_LINKER_FLAGS)
set(ScaLAPACK_LIBRARIES)


if(ScaLAPACK_FIND_QUIETLY OR NOT ScaLAPACK_FIND_REQUIRED)
  find_package(LAPACK)
else()
  find_package(LAPACK REQUIRED)
endif()

if(LAPACK_FOUND)
  set(ScaLAPACK_LINKER_FLAGS ${LAPACK_LINKER_FLAGS})
  if (NOT $ENV{BLA_VENDOR} STREQUAL "")
    set(BLA_VENDOR $ENV{BLA_VENDOR})
  else ()
    if(NOT BLA_VENDOR)
      set(BLA_VENDOR "All")
    endif()
  endif ()


set(MPI_DETERMINE_LIBRARY_VERSION ON)
if (ScaLAPACK_FIND_QUIETLY OR NOT ScaLAPACK_FIND_REQUIRED)
  find_package(MPI)
else()
  find_package(MPI REQUIRED)
endif()

if (MPI_FOUND)
  if (CMAKE_Fortran_COMPILER_LOADED)
    set(BLACS_MPI_LIBRARIES ${MPI_Fortran_LIBRARIES})
  else()
    set(BLACS_MPI_LIBRARIES ${MPI_C_LIBRARIES})
  endif()


#intel scalapack
if (BLA_VENDOR MATCHES "Intel" OR BLA_VENDOR STREQUAL "All")
  if(NOT ScaLAPACK_LIBRARIES)
  if (NOT WIN32)
    set(ScaLAPACK_mkl_LM "-lm")
    set(ScaLAPACK_mkl_LDL "-ldl")
  endif ()
  if (CMAKE_C_COMPILER_LOADED OR CMAKE_CXX_COMPILER_LOADED)
    if(ScaLAPACK_FIND_QUIETLY OR NOT ScaLAPACK_FIND_REQUIRED)
      find_PACKAGE(Threads)
    else()
      find_package(Threads REQUIRED)
    endif()

    if (BLA_VENDOR MATCHES "_64ilp")
      set(ScaLAPACK_mkl_ILP_MODE "ilp64")
    else ()
      set(ScaLAPACK_mkl_ILP_MODE "lp64")
    endif ()

    if (MPI_C_LIBRARY_VERSION_STRING MATCHES "Intel" OR
        MPI_C_LIBRARY_VERSION_STRING MATCHES "MPICH")
      set(ScaLAPACK_mkl_MPI "intelmpi")
    elseif (MPI_C_LIBRARY_VERSION_STRING MATCHES "Open MPI")
      set(ScaLAPACK_mkl_MPI "openmpi")
    elseif (MPI_C_LIBRARY_VERSION_STRING MATCHES "SGI")
      set(ScaLAPACK_mkl_MPI "sgimpt")
    endif()

    if (DEFINED ScaLAPACK_mkl_MPI)
      set(ScaLAPACK_mkl_LIBS
          "mkl_scalapack_${ScaLAPACK_mkl_ILP_MODE}"
          "mkl_blacs_${ScaLAPACK_mkl_MPI}_${ScaLAPACK_mkl_ILP_MODE}")

      check_scalapack_libraries(
        ScaLAPACK_LIBRARIES
        ScaLAPACK
        pcheev
        ""
        "${ScaLAPACK_mkl_LIBS}"
        "${LAPACK_LIBRARIES};${BLAS_LIBRARIES}"
        "${CMAKE_THREAD_LIBS_INIT};${ScaLAPACK_mkl_LM};${ScaLAPACK_mkl_LDL}"
        "${BLACS_MPI_LIBRARIES}"
      )
    endif()

    unset(ScaLAPACK_mkl_LIBS)
    unset(ScaLAPACK_mkl_MPI)
    unset(ScaLAPACK_mkl_ILP_MODE)
    unset(ScaLAPACK_mkl_LM)
    unset(ScaLAPACK_mkl_LDL)
  endif ()
  endif()
endif()

# Generic ScaLAPACK library?
if (BLA_VENDOR STREQUAL "Goto" OR
    BLA_VENDOR STREQUAL "OpenBLAS" OR
    BLA_VENDOR STREQUAL "FLAME" OR
    BLA_VENDOR MATCHES "ACML" OR
    BLA_VENDOR STREQUAL "Apple" OR
    BLA_VENDOR STREQUAL "NAS" OR
    BLA_VENDOR STREQUAL "Generic" OR
    BLA_VENDOR STREQUAL "ATLAS" OR
    BLA_VENDOR STREQUAL "All")
  if ( NOT ScaLAPACK_LIBRARIES )
    check_scalapack_libraries(
    ScaLAPACK_LIBRARIES
    ScaLAPACK
    pcheev
    ""
    "scalapack"
    "${LAPACK_LIBRARIES};${BLAS_LIBRARIES}"
    ""
    "${BLACS_MPI_LIBRARIES}"
    )
  endif ()
endif ()

else()
  message(STATUS "ScaLAPACK requires MPI")
endif()

else()
  message(STATUS "ScaLAPACK requires LAPACK")
endif()

if(ScaLAPACK_LIBRARIES)
  set(ScaLAPACK_FOUND TRUE)
else()
  set(ScaLAPACK_FOUND FALSE)
endif()

if(NOT ScaLAPACK_FIND_QUIETLY)
  if(ScaLAPACK_FOUND)
    message(STATUS "A library with ScaLAPACK API found.")
  else()
    if(ScaLAPACK_FIND_REQUIRED)
      message(FATAL_ERROR
      "A required library with ScaLAPACK API not found. Please specify library location."
      )
    else()
      message(STATUS
      "A library with ScaLAPACK API not found. Please specify library location."
      )
    endif()
  endif()
endif()

# On compilers that implicitly link ScaLAPACK (such as ftn, cc, and CC on Cray HPC machines)
# we used a placeholder for empty ScaLAPACK_LIBRARIES to get through our logic above.
if (ScaLAPACK_LIBRARIES STREQUAL "ScaLAPACK_LIBRARIES-PLACEHOLDER-FOR-EMPTY-LIBRARIES")
  set(ScaLAPACK_LIBRARIES "")
endif()

cmake_pop_check_state()
set(CMAKE_FIND_LIBRARY_SUFFIXES ${_scalapack_ORIG_CMAKE_FIND_LIBRARY_SUFFIXES})
