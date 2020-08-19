include(ScaLATESTSources)

set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${SCALATEST_BINARY_DIR}/tests)

function(add_lin_library NAME)
  cmake_parse_arguments(${NAME} "" "" "SOURCES" ${ARGN})
  foreach(PRECISION IN ITEMS s d c z)
    add_library(${PRECISION}${NAME} OBJECT)
    scalatest_sources(${PRECISION}${NAME} ${PRECISION} ${${NAME}_SOURCES})
  endforeach()
endfunction()

function(add_lin_executable NAME)
  set(multiValueArgs SOURCES LIBRARIES)
  cmake_parse_arguments(${NAME} "" "" "${multiValueArgs}" ${ARGN})
  list(APPEND ${NAME}_LIBRARIES matgen)
  foreach(PRECISION IN ITEMS s d c z)
    add_executable(x${PRECISION}${NAME})
    scalatest_sources(x${PRECISION}${NAME} ${PRECISION} ${${NAME}_SOURCES})
    scalatest_link_libraries(x${PRECISION}${NAME} ${PRECISION} ${${NAME}_LIBRARIES})
    target_link_libraries(x${PRECISION}${NAME} PRIVATE
      matgeninc
      MPI::MPI_Fortran
      ${ScaLAPACK_LIBRARIES}
    )
  endforeach()
endfunction()

add_lin_library(laschk SOURCES laschk.f)
add_lin_library(dblaschk SOURCES dblaschk.f)
add_lin_library(bmatgen SOURCES bmatgen.f)
add_lin_library(dbmv1 SOURCES dbmv1.f)
add_lin_library(pbmv1 SOURCES pbmv1.f)

add_lin_executable(lu
  SOURCES ludriver.f luinfo.f getrrv.f
  LIBRARIES laschk lafchk)
add_lin_executable(dblu
  SOURCES dbdriver.f dbinfo.f
  LIBRARIES dblaschk dbmv1 bmatgen)
add_lin_executable(dtlu
  SOURCES dtdriver.f dtinfo.f dtlaschk.f
  LIBRARIES dbmv1 bmatgen)
add_lin_executable(gblu
  SOURCES gbdriver.f gbinfo.f gbmv1.f
  LIBRARIES dblaschk bmatgen)
add_lin_executable(llt
  SOURCES lltdriver.f lltinfo.f potrrv.f
  LIBRARIES laschk lafchk)
add_lin_executable(pbllt
  SOURCES pbdriver.f pbinfo.f pblaschk.f
  LIBRARIES pbmv1 bmatgen)
add_lin_executable(ptllt
  SOURCES ptdriver.f ptinfo.f ptlaschk.f
  LIBRARIES pbmv1 bmatgen)
add_lin_executable(inv
  SOURCES invdriver.f invinfo.f invchk.f)
add_lin_executable(qr
  SOURCES qrdriver.f qrinfo.f geqrrv.f geqlrv.f gelqrv.f gerqrv.f tzrzrv.f
  LIBRARIES lafchk)
add_lin_executable(ls
  SOURCES lsdriver.f lsinfo.f qrt13.f qrt14.f qrt16.f qrt17.f)
