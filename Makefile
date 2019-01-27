bootstrap:
	brew update || brew update
	brew install carthage
	scripts/install_dependencies.sh

test: bootstrap
	scripts/run_tests.sh
