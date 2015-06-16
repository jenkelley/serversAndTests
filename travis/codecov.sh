#!/bin/bash

if [[ "$TRAVIS_PULL_REQUEST" != "false" ]]; then
    echo "This is a pull request. Code coverage will only be uploaded on merge."
    exit 0
fi

#install the codecov tool
sudo pip install codecov

# run the XcodeCoverage scripts to generate a code coverage report
"${XCODE_COVERAGE_DIR}/getcov"

# where XcodeCoverage puts its results
source ${XCODE_COVERAGE_DIR}/envcov.sh
LCOV_OUTPUT_DIR="${BUILT_PRODUCTS_DIR}/lcov"

# zip up the output directory for easier S3 uploading
zip --quiet --recurse-paths "${TRAVIS_BUILD_DIR}/lcov" "${LCOV_OUTPUT_DIR}"

# lcov output file from XcodeCoverage scripts
LCOV_FILE="${LCOV_OUTPUT_DIR}/Coverage.info"

#CODECOV_TOKEN must be an encrypted environment variable set in .travis.yml and generated like so:
# travis encrypt --pro -r <repo slug> CODECOV_TOKEN=<unecrypted codecov.io token>

# copy the lcov file output by XcodeCoverage to a place and name that the codecov uploader expects
cp "${LCOV_FILE}" "${TRAVIS_BUILD_DIR}/lcov.info"

# run the codecov uploader
codecov

# legacy curl uploading below
# CODECOV_URL="https://codecov.io/upload/v1?token=$CODECOV_TOKEN&commit=$TRAVIS_COMMIT&branch=$TRAVIS_BRANCH&travis_job_id=$TRAVIS_JOB_ID"
# echo "Uploading $LCOV_FILE for commit $TRAVIS_COMMIT"
# UPLOAD_OUPUT=$(curl -X POST -H 'Content-Type: text/lcov' --data-binary @$LCOV_FILE $CODECOV_URL)
# echo $UPLOAD_OUPUT
