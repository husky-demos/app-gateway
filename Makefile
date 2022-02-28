gen-common-pb:
	rm -rf ./pb/common
	mkdir -p ./pb/common
	protoc --proto_path=./proto/common \
	--go_out=./pb/common \
	--go_opt=paths=source_relative \
 	--go-grpc_out=./pb/common \
 	--go-grpc_opt=paths=source_relative \
 	--go-grpc_opt=require_unimplemented_servers=false \
 	proto/common/*.proto

gen-wallet-service-pb:
	rm -rf ./pb/wallet-service
	mkdir -p ./pb/wallet-service
	protoc --proto_path=./proto/wallet-service \
	--go_out=./pb/wallet-service \
	--go_opt=paths=source_relative \
 	--go-grpc_out=./pb/wallet-service \
 	--go-grpc_opt=paths=source_relative \
 	--go-grpc_opt=require_unimplemented_servers=false \
 	proto/wallet-service/*.proto

gen-wallet-service-gateway-pb: gen-wallet-service-pb
	protoc -I ./proto/wallet-service \
      --grpc-gateway_out ./pb/wallet-service \
      --grpc-gateway_opt logtostderr=true \
      --grpc-gateway_opt paths=source_relative \
      --grpc-gateway_opt grpc_api_configuration=./config/wallet-service.yaml \
      proto/wallet-service/*.proto

gen-user-service-pb:
	rm -rf ./pb/user-service
	mkdir -p ./pb/user-service
	protoc --proto_path=./proto/user-service \
	--go_out=./pb/user-service \
	--go_opt=paths=source_relative \
 	--go-grpc_out=./pb/user-service \
 	--go-grpc_opt=paths=source_relative \
 	--go-grpc_opt=require_unimplemented_servers=false \
 	proto/user-service/*.proto

gen-user-service-gateway-pb: gen-user-service-pb
	protoc -I ./proto/user-service \
      --grpc-gateway_out ./pb/user-service \
      --grpc-gateway_opt logtostderr=true \
      --grpc-gateway_opt paths=source_relative \
      --grpc-gateway_opt grpc_api_configuration=./config/user-service.yaml \
      proto/user-service/*.proto

gen-user-service-go-pb:
	rm -rf ./pb/user-service-go
	mkdir -p ./pb/user-service-go
	protoc --proto_path=./proto/user-service-go \
	--go_out=./pb/user-service-go \
	--go_opt=paths=source_relative \
 	--go-grpc_out=./pb/user-service-go \
 	--go-grpc_opt=paths=source_relative \
 	--go-grpc_opt=require_unimplemented_servers=false \
 	proto/user-service-go/*.proto

gen-user-service-go-gateway-pb: gen-user-service-go-pb
	protoc -I ./proto/user-service-go \
      --grpc-gateway_out ./pb/user-service-go \
      --grpc-gateway_opt logtostderr=true \
      --grpc-gateway_opt paths=source_relative \
      --grpc-gateway_opt grpc_api_configuration=./config/user-service-go.yaml \
      proto/user-service-go/*.proto

gen-all: gen-common-pb gen-wallet-service-gateway-pb gen-user-service-gateway-pb gen-user-service-go-gateway-pb