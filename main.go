package main

import (
	common "app-gateway/pb/common"
	userService "app-gateway/pb/user-service"
	walletService "app-gateway/pb/wallet-service"
	"context"
	"flag"
	"github.com/golang/glog"
	"github.com/grpc-ecosystem/grpc-gateway/v2/runtime"
	"google.golang.org/grpc"
	"google.golang.org/grpc/grpclog"
	"google.golang.org/grpc/status"
	"io"
	"net/http"
)

var (
	grpcWalletServiceEndpoint = flag.String("grpc-wallet-service-endpoint", "localhost:9000", "grpc wallet service endpoint")
	grpcUserServiceEndpoint   = flag.String("grpc-user-service-endpoint", "localhost:9001", "grpc user service endpoint")
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

	mux := runtime.NewServeMux(
		runtime.WithErrorHandler(errorHandler),
		runtime.WithIncomingHeaderMatcher(incomingHeaderMatcherHandler),
		runtime.WithOutgoingHeaderMatcher(outgoingHeaderMatcherHandler),
	)
	opts := []grpc.DialOption{grpc.WithInsecure()}

	if err := walletService.RegisterWalletServiceHandlerFromEndpoint(ctx, mux, *grpcWalletServiceEndpoint, opts); err != nil {
		return err
	}
	if err := userService.RegisterUserServiceHandlerFromEndpoint(ctx, mux, *grpcUserServiceEndpoint, opts); err != nil {
		return err
	}
	return http.ListenAndServe("0.0.0.0:8080", mux)
}

func errorHandler(ctx context.Context, mux *runtime.ServeMux, marshaler runtime.Marshaler, w http.ResponseWriter, r *http.Request, err error) {
	const fallback = `{"code":-1,"message":"service error"}`

	s := status.Convert(err)
	pb := s.Proto()

	w.Header().Del("Trailer")
	w.Header().Del("Transfer-Encoding")
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusInternalServerError)

	var buf []byte
	var mErr error
	if len(pb.Details) > 0 {
		errorResult := &common.ErrorResult{}
		if mErr = pb.Details[0].UnmarshalTo(errorResult); mErr == nil {
			buf, mErr = marshaler.Marshal(errorResult)
		}
	} else {
		mErr = err
	}
	if mErr != nil {
		grpclog.Infof("Failed to marshal error message %q: %v", s, mErr)
		if _, err := io.WriteString(w, fallback); err != nil {
			grpclog.Infof("Failed to write response: %v", err)
		}
		return
	}

	if _, err := w.Write(buf); err != nil {
		grpclog.Infof("Failed to write response: %v", err)
	}
}
func incomingHeaderMatcherHandler(key string) (string, bool) {
	return runtime.DefaultHeaderMatcher(key)
}
func outgoingHeaderMatcherHandler(key string) (string, bool) {
	return key, true
}
