.PHONY: proto proto-deps py_gen

PROTO_DIR=proto
GO_OUT=gen\go
PYTHON_OUT=gen\python

proto-deps:
	@go install google.golang.org/protobuf/cmd/protoc-gen-go@latest
	@go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest

proto:
	@echo "Генерация Go кода..."
	@if exist "$(GO_OUT)" rmdir /s /q "$(GO_OUT)"
	@mkdir "$(GO_OUT)"
	@cd . && protoc --proto_path="." --go_out="$(GO_OUT)" --go_opt=paths=source_relative --go-grpc_out="$(GO_OUT)" --go-grpc_opt=paths=source_relative proto/auth/v1/service.proto proto/auth/v1/types.proto
	@cd . && protoc --proto_path="." --go_out="$(GO_OUT)" --go_opt=paths=source_relative --go-grpc_out="$(GO_OUT)" --go-grpc_opt=paths=source_relative proto/common/v1/types.proto
	@cd . && protoc --proto_path="." --go_out="$(GO_OUT)" --go_opt=paths=source_relative --go-grpc_out="$(GO_OUT)" --go-grpc_opt=paths=source_relative proto/users/v1/service.proto proto/users/v1/types.proto
	@cd . && protoc --proto_path="." --go_out="$(GO_OUT)" --go_opt=paths=source_relative --go-grpc_out="$(GO_OUT)" --go-grpc_opt=paths=source_relative proto/vacancy/v1/service.proto proto/vacancy/v1/types.proto
	@echo "Генерация завершена!"

# Только для auth (если нужно тестировать)
proto-auth:
	@echo "Генерация Auth..."
	@if exist "$(GO_OUT)" rmdir /s /q "$(GO_OUT)"
	@mkdir "$(GO_OUT)"
	@protoc --proto_path="." --go_out="$(GO_OUT)" --go_opt=paths=source_relative --go-grpc_out="$(GO_OUT)" --go-grpc_opt=paths=source_relative proto/auth/v1/service.proto proto/auth/v1/types.proto proto/common/v1/types.proto
	@echo "Генерация завершена!"

py_gen:
	@echo "Генерация Python кода..."
	@if not exist "$(PYTHON_OUT)" mkdir "$(PYTHON_OUT)"
	@python -m grpc_tools.protoc -I . --python_out="$(PYTHON_OUT)" --grpc_python_out="$(PYTHON_OUT)" proto/achievement/v1/service.proto proto/achievement/v1/types.proto proto/common/v1/types.proto
	@echo "Python генерация завершена!"