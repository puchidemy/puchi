package grpc

import (
	v1 "github.com/puchidemy/puchi-user-services/internal/controller/grpc/v1"
	"github.com/puchidemy/puchi-user-services/internal/usecase"
	"github.com/puchidemy/puchi-user-services/pkg/logger"
	pbgrpc "google.golang.org/grpc"
	"google.golang.org/grpc/reflection"
)

// NewRouter -.
func NewRouter(app *pbgrpc.Server, t usecase.Translation, l logger.Interface) {
	{
		v1.NewTranslationRoutes(app, t, l)
	}

	reflection.Register(app)
}
