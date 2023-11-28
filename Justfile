# List available commands
default:
  just --list

# Run all pull request checks from CI via act
ci:
  act --reuse --container-architecture=linux/amd64 pull_request

# Run Neovim nightly tests from CI via act
ci-nightly:
  act --reuse --container-architecture=linux/amd64 -j TestsOnNightly

# Run all pull request checks from CI via local commnds (faster than ci via act)
ci-local: format test

# Run Stylua
format:
  stylua .

# Run the lua tests
test: test-0-9-4 test-0-8-3

# Run the lua tests against Neovim 0.8.3
test-0-9-4:
  bob use 0.9.4 && ./tests/run.sh

# Run the lua tests against Neovim 0.8.3
test-0-8-3:
  bob use 0.8.3 && ./tests/run.sh

# Run the lua tests against Neovim nightly
test-nightly:
  bob use nightly && ./tests/run.sh
