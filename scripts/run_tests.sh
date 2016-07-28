set -o pipefail && xcodebuild test -scheme DashboardUI\
 -configuration Debug\
 -sdk iphonesimulator\
 -destination "OS=9.3,name=iPhone 6s"\
 -verbose | xcpretty -c
