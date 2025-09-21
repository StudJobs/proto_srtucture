.PHONY: proto-install proto-gen proto-clean proto-verify proto-deps proto-init-go proto-all

# Install dependencies
proto-install:
	# Install Buf
	choco install buf -y
	# Install Go
	choco install golang -y
	# Install Python
	choco install python -y

# Generate code
proto-gen:
	buf generate

# Clean generated files
proto-clean:
	if exist gen rmdir /s /q gen
	if exist go.mod del go.mod
	if exist go.sum del go.sum

# Verify generation
proto-verify:
	buf generate
	cd gen\go && go mod tidy
	cd gen\go && go build ./...
	echo "Generation successful!"

# Update Buf dependencies
proto-deps:
	buf mod update

# Initialize Go module
proto-init-go:
	if not exist gen\go\go.mod (
		cd gen\go && go mod init github.com/StudJobs/proto_srtucture/gen/go
	)
	cd gen\go && go mod tidy

# Full installation and generation
proto-all: proto-gen proto-init-go proto-verify