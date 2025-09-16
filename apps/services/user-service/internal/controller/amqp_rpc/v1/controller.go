package v1

import (
	"github.com/go-playground/validator/v10"
	"github.com/hoan02/puchi-user-service/internal/usecase"
	"github.com/hoan02/puchi-user-service/pkg/logger"
)

// V1 -.
type V1 struct {
	t usecase.Translation
	l logger.Interface
	v *validator.Validate
}
