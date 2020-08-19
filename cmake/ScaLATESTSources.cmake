function(scalatest_sources NAME PRECISION)
  if(ARGC GREATER 2)
    list(TRANSFORM ARGN PREPEND "p${PRECISION}" OUTPUT_VARIABLE ${NAME}_SOURCES)
    target_sources(${NAME} PRIVATE ${${NAME}_SOURCES})
  endif()
endfunction()

function(scalatest_link_libraries NAME PRECISION)
  if(ARGC GREATER 2)
    list(TRANSFORM ARGN PREPEND "${PRECISION}" OUTPUT_VARIABLE ${NAME}_LIBRARIES)
    target_link_libraries(${NAME} PRIVATE ${${NAME}_LIBRARIES})
  endif()
endfunction()
