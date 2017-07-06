#! /bin/bash

export PATH=$PATH:/home/marmar/programs-local/swift/swift-k/dist/swift-svn/bin/coaster-service #/core/matthew/swift-k/dist/swift-svn/bin

coaster-service -p 4030 -localport 4031 -stats -nosec -passive

