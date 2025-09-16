package v1

import (
	"github.com/go-playground/validator/v10"
	"github.com/puchidemy/puchi-user-services/internal/usecase"
	"github.com/puchidemy/puchi-user-services/pkg/logger"
)

// V1 -.
type V1 struct {
	t usecase.Translation
	l logger.Interface
	v *validator.Validate
}
