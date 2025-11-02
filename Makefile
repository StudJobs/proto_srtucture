.PHONY: proto proto-deps py_gen clean

PROTO_DIR=proto
GO_OUT=gen/go
PYTHON_OUT=gen/python


proto: clean
	@make proto-imports-add
	@echo " "
	@echo "Generating Go code..."
	@protoc --proto_path="." \
		--go_out="$(GO_OUT)" --go_opt=paths=source_relative \
		--go-grpc_out="$(GO_OUT)" --go-grpc_opt=paths=source_relative \
		proto/auth/v1/service.proto proto/auth/v1/types.proto \
		proto/common/v1/types.proto \
		proto/users/v1/service.proto proto/users/v1/types.proto \
		proto/vacancy/v1/service.proto proto/vacancy/v1/types.proto \
		proto/achievement/v1/service.proto proto/achievement/v1/types.proto \
        proto/company/v1/service.proto proto/company/v1/types.proto
	@echo "Go code generation completed!"
	@echo " "
	@make fix-imports

py_gen:
	@make proto-imports-clean
	@echo " "
	@echo "Generating Python code..."
	@if not exist "$(PYTHON_OUT)" mkdir "$(PYTHON_OUT)"
	@python -m grpc_tools.protoc -I proto --python_out="$(PYTHON_OUT)" --grpc_python_out="$(PYTHON_OUT)" achievement/v1/service.proto achievement/v1/types.proto common/v1/types.proto
	@echo "Python code generation completed!"

all-generate:
	@make proto
	@make py_gen

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

all-deps:
	@echo " "
	@make proto-deps
	@echo " "
	@make py-deps
	@echo " "

# Fix imports in generated files (post-processing)
fix-imports:
	@echo "Fixing import paths..."
	@powershell -Command "Get-ChildItem -Path '$(GO_OUT)' -Recurse -Filter '*.pb.go' | ForEach-Object { $$content = Get-Content $$_.FullName -Raw; $$content = $$content -replace 'github.com/StudJobs/proto_srtucture/gen/go/common/v1', 'github.com/StudJobs/proto_srtucture/gen/go/proto/common/v1'; Set-Content $$_.FullName $$content }"
	@echo "Import paths fixed!"

# Remove 'proto/' prefix from imports in achievement service
proto-imports-clean:
	@echo "Removing 'proto/' prefix from achievement service imports..."
	@powershell -Command "\
		$$file = 'proto/achievement/v1/service.proto'; \
		if (Test-Path $$file) { \
			$$content = Get-Content $$file -Raw; \
			$$content = $$content -replace 'import \"proto/(achievement/v1/types\.proto)\"', 'import \"$$1\"'; \
			$$content = $$content -replace 'import \"proto/(common/v1/types\.proto)\"', 'import \"$$1\"'; \
			Set-Content $$file $$content -NoNewline; \
			echo 'Removed proto/ prefix from: $$file'; \
		} else { \
			echo 'File not found: $$file'; \
		}"
	@echo "Achievement imports cleaned!"

# Add 'proto/' prefix to imports in achievement service
proto-imports-add:
	@echo "Adding 'proto/' prefix to achievement service imports..."
	@powershell -Command "\
		$$file = 'proto/achievement/v1/service.proto'; \
		if (Test-Path $$file) { \
			$$content = Get-Content $$file -Raw; \
			$$content = $$content -replace 'import \"(achievement/v1/types\.proto)\"', 'import \"proto/$$1\"'; \
			$$content = $$content -replace 'import \"(common/v1/types\.proto)\"', 'import \"proto/$$1\"'; \
			Set-Content $$file $$content -NoNewline; \
			echo 'Added proto/ prefix to: $$file'; \
		} else { \
			echo 'File not found: $$file'; \
		}"
	@echo "Achievement imports prefixed!"
