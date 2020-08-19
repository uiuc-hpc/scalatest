include(ScaLATESTSources)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${SCALATEST_BINARY_DIR}/tests)

function(add_pblas_library NAME)
  cmake_parse_arguments(${NAME} "" "" "SOURCES" ${ARGN})
  foreach(PRECISION IN ITEMS s d c z)
    add_library(${PRECISION}${NAME} OBJECT)
    scalatest_sources(${PRECISION}${NAME} ${PRECISION} ${${NAME}_SOURCES})
  endforeach()
endfunction()

function(add_pblas_executable_precision NAME PRECISION)
  set(multiValueArgs SOURCES LIBRARIES NOPREFIX_LIBRARIES NOCMPLX_LIBRARIES)
  cmake_parse_arguments(${NAME} "" "" "${multiValueArgs}" ${ARGN})
  add_executable(${PRECISION}${NAME})
  scalatest_sources(${PRECISION}${NAME} ${PRECISION} ${${NAME}_SOURCES})
  scalatest_link_libraries(${PRECISION}${NAME} ${PRECISION} ${${NAME}_LIBRARIES})
  if(PRECISION STREQUAL "c")
    scalatest_link_libraries(${PRECISION}${NAME} "s" ${${NAME}_NOCMPLX_LIBRARIES})
  elseif(PRECISION STREQUAL "z")
    scalatest_link_libraries(${PRECISION}${NAME} "d" ${${NAME}_NOCMPLX_LIBRARIES})
  else()
    scalatest_link_libraries(${PRECISION}${NAME} ${PRECISION} ${${NAME}_NOCMPLX_LIBRARIES})
  endif()
  target_link_libraries(${PRECISION}${NAME} PRIVATE
    MPI::MPI_Fortran
    ${ScaLAPACK_LIBRARIES}
    ${${NAME}_NOPREFIX_LIBRARIES}
  )
endfunction()

function(add_pblas_executable NAME)
  foreach(PRECISION IN ITEMS s d c z)
    add_pblas_executable_precision(${NAME} ${PRECISION} ${ARGN})
  endforeach()
endfunction()

add_library(PblasErrorHandler OBJECT PB_Cwarn.c PB_Cabort.c)
add_library(_pbtcom OBJECT pblastst.f)
add_library(slamch OBJECT slamch.f)
add_library(dlamch OBJECT dlamch.f)
add_pblas_library(pbtcom SOURCES blastst.f)

foreach(LVL IN ITEMS 1 2 3)
  add_pblas_executable("pb${LVL}tst"
    SOURCES "blas${LVL}tst.f"
    LIBRARIES pbtcom
    NOCMPLX_LIBRARIES lamch
    NOPREFIX_LIBRARIES _pbtcom PblasErrorHandler
  )
endforeach()

file(COPY PCBLAS1TST.dat DESTINATION ${CMAKE_RUNTIME_OUTPUT_DIRECTORY})
file(COPY PCBLAS2TST.dat DESTINATION ${CMAKE_RUNTIME_OUTPUT_DIRECTORY})
file(COPY PCBLAS3TST.dat DESTINATION ${CMAKE_RUNTIME_OUTPUT_DIRECTORY})
file(COPY PDBLAS1TST.dat DESTINATION ${CMAKE_RUNTIME_OUTPUT_DIRECTORY})
file(COPY PDBLAS2TST.dat DESTINATION ${CMAKE_RUNTIME_OUTPUT_DIRECTORY})
file(COPY PDBLAS3TST.dat DESTINATION ${CMAKE_RUNTIME_OUTPUT_DIRECTORY})
file(COPY PSBLAS1TST.dat DESTINATION ${CMAKE_RUNTIME_OUTPUT_DIRECTORY})
file(COPY PSBLAS2TST.dat DESTINATION ${CMAKE_RUNTIME_OUTPUT_DIRECTORY})
file(COPY PSBLAS3TST.dat DESTINATION ${CMAKE_RUNTIME_OUTPUT_DIRECTORY})
file(COPY PZBLAS1TST.dat DESTINATION ${CMAKE_RUNTIME_OUTPUT_DIRECTORY})
file(COPY PZBLAS2TST.dat DESTINATION ${CMAKE_RUNTIME_OUTPUT_DIRECTORY})
file(COPY PZBLAS3TST.dat DESTINATION ${CMAKE_RUNTIME_OUTPUT_DIRECTORY})
