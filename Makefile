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

gen-all: gen-common-pb gen-wallet-service-gateway-pb