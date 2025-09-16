package v1

import (
	"github.com/go-playground/validator/v10"
	"github.com/puchidemy/puchi-user-services/internal/usecase"
	"github.com/puchidemy/puchi-user-services/pkg/logger"
	"github.com/puchidemy/puchi-user-services/pkg/rabbitmq/rmq_rpc/server"
)

// NewTranslationRoutes -.
func NewTranslationRoutes(routes map[string]server.CallHandler, t usecase.Translation, l logger.Interface) {
	r := &V1{t: t, l: l, v: validator.New(validator.WithRequiredStructEnabled())}

	{
		routes["v1.getHistory"] = r.getHistory()
	}
}
