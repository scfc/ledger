#.rst
# CheckForBoostPythonMakeSetter
# -----------------------------
#
# Checks if boost::python::make_setter() works properly
# See https://github.com/boostorg/python/issues/39
#
# This will define the following variables::
#
#   BOOST_MAKE_SETTER_RUNS

#=============================================================================
# Copyright 2015 Alexis Hildebrandt
#
# Distributed under the OSI-approved BSD License (the "License");
# see accompanying file Copyright.txt for details.
#
# This software is distributed WITHOUT ANY WARRANTY; without even the
# implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
# See the License for more information.
#=============================================================================

include(CheckCXXSourceCompiles)
include(CMakePushCheckState)

cmake_push_check_state()

set(CMAKE_REQUIRED_INCLUDES ${CMAKE_INCLUDE_PATH} ${Boost_INCLUDE_DIRS} ${PYTHON_INCLUDE_DIRS})
set(CMAKE_REQUIRED_LIBRARIES ${Boost_LIBRARIES} ${PYTHON_LIBRARIES})

check_cxx_source_compiles("
#include <boost/python.hpp>

struct X { int y; };

int main()
{
  boost::python::make_setter(&X::y);
  return 0;
}" BOOST_MAKE_SETTER_RUNS)

cmake_pop_check_state()
