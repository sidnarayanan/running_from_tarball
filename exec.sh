#!/bin/bash

export X509_USER_PROXY=${PWD}/x509up
export HOME=.

tar xvaf submit.tgz
cd submit
. runEventGeneration.sh
cd -
rm -r submit/

exit 0
