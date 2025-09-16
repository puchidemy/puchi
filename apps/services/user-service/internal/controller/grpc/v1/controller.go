package v1

import (
	"github.com/go-playground/validator/v10"
	v1 "github.com/hoan02/puchi-user-service/docs/proto/v1"
	"github.com/hoan02/puchi-user-service/internal/usecase"
	"github.com/hoan02/puchi-user-service/pkg/logger"
)

// V1 -.
type V1 struct {
	v1.TranslationServer

	t usecase.Translation
	l logger.Interface
	v *validator.Validate
}
