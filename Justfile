# List available commands
default:
  just --list

# Run all checks from CI
ci: format test

# Run Stylua
format:
  stylua .

# Run the lua tests
test:
  ./tests/run.sh
