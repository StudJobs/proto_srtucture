.PHONY: proto proto-deps py_gen clean

PROTO_DIR=proto
GO_OUT=gen/go
PYTHON_OUT=gen/python

clean:
	@echo "Cleaning generated files..."
	@if exist "$(GO_OUT)" rmdir /s /q "$(GO_OUT)"
	@mkdir "$(GO_OUT)"

proto-deps:
	@echo "Installing protoc plugins..."
	@go install google.golang.org/protobuf/cmd/protoc-gen-go@latest
	@go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest

py-deps:
	@echo "Installing Python protoc plugins..."
	@pip install grpcio-tools
	@echo "Python plugins installed"

# Fixed version - use paths=source_relative without module
proto: clean
	@echo "Generating Go code..."
	@protoc --proto_path="." \
		--go_out="$(GO_OUT)" --go_opt=paths=source_relative \
		--go-grpc_out="$(GO_OUT)" --go-grpc_opt=paths=source_relative \
		proto/auth/v1/service.proto proto/auth/v1/types.proto \
		proto/common/v1/types.proto \
		proto/users/v1/service.proto proto/users/v1/types.proto \
		proto/vacancy/v1/service.proto proto/vacancy/v1/types.proto
	@echo "Go code generation completed!"

py_gen:
	@echo "Generating Python code..."
	@if not exist "$(PYTHON_OUT)" mkdir "$(PYTHON_OUT)"
	@python -m grpc_tools.protoc -I proto --python_out="$(PYTHON_OUT)" --grpc_python_out="$(PYTHON_OUT)" vacancy/v1/service.proto vacancy/v1/types.proto common/v1/types.proto
	@echo "Python code generation completed!"

# Fix imports in generated files (post-processing)
fix-imports:
	@echo "Fixing import paths..."
	@powershell -Command "Get-ChildItem -Path '$(GO_OUT)' -Recurse -Filter '*.pb.go' | ForEach-Object { $$content = Get-Content $$_.FullName -Raw; $$content = $$content -replace 'github.com/StudJobs/proto_srtucture/gen/go/common/v1', 'github.com/StudJobs/proto_srtucture/gen/go/proto/common/v1'; Set-Content $$_.FullName $$content }"
	@echo "Import paths fixed!"

all-generate:
	@make proto-deps
	@make py-deps
	@make proto
	@make fix-imports
	@make py_gen
	@make go mod tidy
