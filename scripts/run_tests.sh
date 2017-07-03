set -o pipefail && xcodebuild test -scheme DashboardUI\
 -configuration Debug\
 -sdk iphonesimulator\
 -destination "OS=10.3.1,name=iPhone 6"\
 -verbose | xcpretty -c
