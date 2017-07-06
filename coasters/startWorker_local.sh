#! /bin/bash

export PATH=$PATH:/home/marmar/programs-local/swift/swift-k/dist/swift-svn/bin/coaster-service #/core/matthew/swift-k/dist/swift-svn/bin

worker.pl -c 2 http://localhost:4031 local logs

