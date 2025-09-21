py_gen:
	python -m grpc_tools.protoc \
	  -I proto \
	  --python_out=gen/python \
	  --grpc_python_out=gen/python \
	  proto/vacancy/v1/service.proto \
	  proto/vacancy/v1/types.proto \
	  proto/common/v1/types.proto

