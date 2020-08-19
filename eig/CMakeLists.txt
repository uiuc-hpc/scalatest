include(ScaLATESTSources)

set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${SCALATEST_BINARY_DIR}/tests)

function(add_eig_library_precision NAME PRECISION)
  cmake_parse_arguments(${NAME} "" "" "SOURCES" ${ARGN})
  add_library(${PRECISION}${NAME} OBJECT)
  scalatest_sources(${PRECISION}${NAME} ${PRECISION} ${${NAME}_SOURCES})
endfunction()

function(add_eig_library NAME)
  foreach(PRECISION IN ITEMS s d c z)
    add_eig_library_precision(${NAME} ${PRECISION} ${ARGN})
  endforeach()
endfunction()

function(add_eig_library_float NAME)
  foreach(PRECISION IN ITEMS s d)
    add_eig_library_precision(${NAME} ${PRECISION} ${ARGN})
  endforeach()
endfunction()

function(add_eig_library_complex NAME)
  foreach(PRECISION IN ITEMS c z)
    add_eig_library_precision(${NAME} ${PRECISION} ${ARGN})
  endforeach()
endfunction()

function(add_eig_executable_precision NAME PRECISION)
  set(options NO_MATGEN)
  set(multiValueArgs SOURCES LIBRARIES NOPREFIX_LIBRARIES NOCMPLX_LIBRARIES)
  cmake_parse_arguments(${NAME} "${options}" "" "${multiValueArgs}" ${ARGN})
  if(NOT ${NAME}_NO_MATGEN)
    list(APPEND ${NAME}_LIBRARIES matgen)
  endif()
  add_executable(x${PRECISION}${NAME})
  scalatest_sources(x${PRECISION}${NAME} ${PRECISION} ${${NAME}_SOURCES})
  scalatest_link_libraries(x${PRECISION}${NAME} ${PRECISION} ${${NAME}_LIBRARIES})
  if(PRECISION STREQUAL "c")
    scalatest_link_libraries(x${PRECISION}${NAME} "s" ${${NAME}_NOCMPLX_LIBRARIES})
  elseif(PRECISION STREQUAL "z")
    scalatest_link_libraries(x${PRECISION}${NAME} "d" ${${NAME}_NOCMPLX_LIBRARIES})
  else()
    scalatest_link_libraries(x${PRECISION}${NAME} ${PRECISION} ${${NAME}_NOCMPLX_LIBRARIES})
  endif()
  target_link_libraries(x${PRECISION}${NAME} PRIVATE
    matgeninc
    MPI::MPI_Fortran
    ${ScaLAPACK_LIBRARIES}
    ${${NAME}_NOPREFIX_LIBRARIES}
  )
endfunction()

function(add_eig_executable NAME)
  foreach(PRECISION IN ITEMS s d c z)
    add_eig_executable_precision(${NAME} ${PRECISION} ${ARGN})
  endforeach()
endfunction()

function(add_eig_executable_float NAME)
  foreach(PRECISION IN ITEMS s d)
    add_eig_executable_precision(${NAME} ${PRECISION} ${ARGN})
  endforeach()
endfunction()

function(add_eig_executable_complex NAME)
  foreach(PRECISION IN ITEMS c z)
    add_eig_executable_precision(${NAME} ${PRECISION} ${ARGN})
  endforeach()
endfunction()

add_eig_library(sepchk SOURCES sepchk.f)
add_eig_library(sepqtq SOURCES sepqtq.f)
add_eig_library(lagsy SOURCES lagsy.f)
add_eig_library(latms SOURCES latms.f)
add_eig_library(lasizesep SOURCES lasizesep.f)
add_eig_library_float(sepinfo SOURCES sepinfo.f)
add_eig_library_float(lasizesyevx SOURCES lasizesyevx.f)
add_eig_library_complex(lasizeheevx SOURCES lasizeheevx.f)

add_library(xpjlaenv OBJECT xpjlaenv.f)

add_eig_executable(brd
  SOURCES brddriver.f brdinfo.f gebdrv.f
  LIBRARIES lafchk)

add_eig_executable(hrd
  SOURCES hrddriver.f hrdinfo.f gehdrv.f
  LIBRARIES lafchk)

# xstrd and xdtrd use pssytdrv.f/pdsytdrv.f
add_eig_executable_float(trd
  SOURCES trddriver.f ttrdtester.f latran.f trdinfo.f sytdrv.f
  LIBRARIES lafchk
  NOPREFIX_LIBRARIES xpjlaenv)
# xctrd and xztrd use pchetdrv.f/pzhetdrv.f
add_eig_executable_complex(trd
  SOURCES trddriver.f ttrdtester.f latran.f trdinfo.f hetdrv.f
  LIBRARIES lafchk
  NOPREFIX_LIBRARIES xpjlaenv)

add_eig_executable_float(svd
  SOURCES svddriver.f lagge.f svdchk.f svdcmp.f svdtst.f)

# x{s,d,c,z}sep is a bit more complex ...
add_eig_executable_float(sep
  SOURCES septst.f sepsubtst.f sepdriver.f sepreq.f lasizesyev.f sqpsubtst.f
          lasizesqp.f sdpsubtst.f
  LIBRARIES sepchk sepqtq lagsy latms lasizesep lasizesyevx
  NOCMPLX_LIBRARIES sepinfo)
add_eig_executable_complex(sep
  SOURCES septst.f sepsubtst.f sepdriver.f sepreq.f sdpsubtst.f
  LIBRARIES sepchk sepqtq lagsy latms lasizesep lasizeheevx
  NOCMPLX_LIBRARIES sepinfo)

add_eig_executable_float(gsep
  SOURCES gseptst.f gsepsubtst.f gsepchk.f gsepdriver.f gsepreq.f lasizegsep.f
  LIBRARIES lagsy latms lasizesep lasizesyevx
  NOCMPLX_LIBRARIES sepinfo)
add_eig_executable_complex(gsep
  SOURCES gseptst.f gsepsubtst.f gsepchk.f gsepdriver.f gsepreq.f lasizegsep.f
  LIBRARIES lagsy latms lasizesep lasizeheevx
  NOCMPLX_LIBRARIES sepinfo)

add_eig_executable(nep
  SOURCES nepdriver.f nepinfo.f nepfchk.f
  LIBRARIES)

add_eig_executable_complex(evc
  SOURCES evcdriver.f evcinfo.f get22.f
  LIBRARIES)

add_eig_executable_float(syevr
  SOURCES lasizesepr.f lasizesyevr.f seprdriver.f seprreq.f seprsubtst.f
          seprtst.f
  LIBRARIES sepchk sepqtq lagsy latms lasizesep
  NOCMPLX_LIBRARIES sepinfo)
add_eig_executable_complex(heevr
  SOURCES lasizesepr.f lasizeheevr.f seprdriver.f seprreq.f seprsubtst.f
          seprtst.f
  LIBRARIES sepchk sepqtq lagsy latms lasizesep
  NOCMPLX_LIBRARIES sepinfo)

add_eig_executable_float(hseqr
  SOURCES hseqrdriver.f matgen2.f
  NO_MATGEN)
