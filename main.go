package main

import (
	v1 "app-gateway/pb/wallet-service"
	"context"
	"flag"
	"github.com/golang/glog"
	"github.com/grpc-ecosystem/grpc-gateway/v2/runtime"
	"google.golang.org/grpc"
	"net/http"
)

var (
	grpcWalletServiceEndpoint = flag.String("grpc-wallet-service-endpoint", "localhost:9000", "grpc wallet service endpoint")
)

func main() {
	flag.Parse()
	defer glog.Flush()

	if err := run(); err != nil {
		glog.Fatal(err)
	}
}

func run() error {
	ctx := context.Background()
	ctx, cancel := context.WithCancel(ctx)
	defer cancel()

	mux := runtime.NewServeMux()
	opts := []grpc.DialOption{grpc.WithInsecure()}

	err := v1.RegisterWalletServiceHandlerFromEndpoint(ctx, mux, *grpcWalletServiceEndpoint, opts)
	if err != nil {
		return err
	}
	return http.ListenAndServe("0.0.0.0:8080", mux)
}
