include(ScaLATESTSources)

function(add_aux_library NAME)
  set(multiValueArgs SOURCES)
  cmake_parse_arguments(${NAME} "" "" "${multiValueArgs}" ${ARGN})
  foreach(PRECISION IN ITEMS s d c z)
    add_library(${PRECISION}${NAME} OBJECT)
    scalatest_sources(${PRECISION}${NAME} ${PRECISION} ${${NAME}_SOURCES})
  endforeach()
endfunction()

add_library(matgeninc OBJECT)
target_sources(matgeninc PRIVATE pmatgeninc.f)

add_aux_library(matgen SOURCES matgen.f)
add_aux_library(lafchk SOURCES lafchk.f)
