set -o pipefail && xcodebuild test -scheme DashboardUI\
 -configuration Debug\
 -sdk iphonesimulator\
 -destination "OS=11.2,name=iPhone X"\
 -verbose | xcpretty -c
