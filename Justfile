# List available commands
default:
  just --list

# Run all checks from CI
ci: format test

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
