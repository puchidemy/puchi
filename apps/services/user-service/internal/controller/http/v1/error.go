package v1

import (
	"github.com/gofiber/fiber/v2"
	"github.com/puchidemy/puchi-user-services/internal/controller/http/v1/response"
)

func errorResponse(ctx *fiber.Ctx, code int, msg string) error {
	return ctx.Status(code).JSON(response.Error{Error: msg})
}
