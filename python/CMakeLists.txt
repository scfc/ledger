message(STATUS "Generating ledger python package __init__.py")
configure_file(
  ${CMAKE_CURRENT_SOURCE_DIR}/__init__.py.in
  ${CMAKE_BINARY_DIR}/python/${PROJECT_NAME}/__init__.py)

# The following configure_file is for easier development only
configure_file (
  ${CMAKE_CURRENT_SOURCE_DIR}/core/__init__.py
  ${CMAKE_BINARY_DIR}/python/${PROJECT_NAME}/core/__init__.py COPYONLY)

set(LEDGER_PYTHON_SOURCES
  ${CMAKE_BINARY_DIR}/python/${PROJECT_NAME}/__init__.py)

install(FILES ${LEDGER_PYTHON_SOURCES}
  DESTINATION ${PYTHON_SITE_PACKAGES}/${PROJECT_NAME})

install(DIRECTORY
  ${CMAKE_CURRENT_SOURCE_DIR}/core
  ${CMAKE_CURRENT_SOURCE_DIR}/server
  DESTINATION ${PYTHON_SITE_PACKAGES}/${PROJECT_NAME})
