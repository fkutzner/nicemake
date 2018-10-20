# Copyright (c) 2018 Felix Kutzner
#
# This file originated from the nicemake project
# (https://github.com/fkutzner/nicemake). See README.md for details
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#
# Except as contained in this notice, the name(s) of the above copyright holders
# shall not be used in advertising or otherwise to promote the sale, use or
# other dealings in this Software without prior written authorization.

# This file contains bash functions useful for testing CMake projects.

# Usage: check_build_dir_artifacts EXPECTED_ARTIFACTS_FILE
#
# Reads the file EXPECTED_ARTIFACTS_FILE line-by-line, and for each line L
# in EXPECTED_ARTIFACTS_FILE, checks the following:
#
# - if L begins with "File", L is expected to have the format
#
#   File <FILENAME>
#
#   check_build_dir_artifacts checks whether <FILENAME> exists. If <FILENAME>
#   is a relative path, it is interpreted relative to the current directory.
#
# - if L begins with "Executable", L is expecteed to have the format
#
#   Executable <FILENAME> <EXPECTEDOUTPUT>
#
#   check_build_dir_artifacts checks whether <FILENAME> exists and that the
#   execution of <FILENAME> results in <EXPECTEDOUTPUT> being printed to the
#   standard output.
#
# If none of the above apply to L, or if L does not conform to the syntax
# laid out above, or if a check fails, check_build_dir_artifacts exits with exit
# code 1. Otherwise, check_build_dir_artifacts has no effect beside executing
# binaries specified in "Executable" lines.
function check_build_dir_artifacts {
  EXPECTED_ARTIFACTS_FILE=$1

  if [ ! -e ${EXPECTED_ARTIFACTS_FILE} ]
  then
    echo "${EXPECTED_ARTIFACTS_FILE}: no such file or directory"
    exit 1
  fi

  while read -r spec || [[ -n "$spec" ]]; do
    if [[ "${spec}" == File* ]]
    then
      # Check that the given file exists
      read cmd filename <<< ${spec}
      if [ ! -e ${filename} ]
      then
        echo "Missing file ${filename} in build directory"
        exit 1
      fi
    elif [[ "${spec}" == Executable* ]]
    then
      # Check that the given executable exists and produces the desired output
      read cmd executable expected_output <<< ${spec}
      if [ ! -e ${executable} ]
      then
        echo "Missing file ${executable} in build directory"
        exit 1
      fi

      output=$(${executable})
      if [[ "${output}" != "${expected_output}" ]]
      then
        echo "Executable ${executable} produced unexpected output."
        echo "  Expected: ${expected_output}"
        echo "  Actual:   ${output}"
        exit 1
      fi
    else
      echo "Unknown expected-artifact kind: ${spec}"
      exit 1
    fi
  done < ${EXPECTED_ARTIFACTS_FILE}
}
