package v1

import (
	"github.com/go-playground/validator/v10"
	"github.com/hoan02/puchi-user-service/internal/usecase"
	"github.com/hoan02/puchi-user-service/pkg/logger"
	"github.com/hoan02/puchi-user-service/pkg/rabbitmq/rmq_rpc/server"
)

// NewTranslationRoutes -.
func NewTranslationRoutes(routes map[string]server.CallHandler, t usecase.Translation, l logger.Interface) {
	r := &V1{t: t, l: l, v: validator.New(validator.WithRequiredStructEnabled())}

	{
		routes["v1.getHistory"] = r.getHistory()
	}
}
