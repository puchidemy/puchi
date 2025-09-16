package v1

import (
	"github.com/gofiber/fiber/v2"
	"github.com/hoan02/puchi-user-service/internal/controller/http/v1/response"
)

func errorResponse(ctx *fiber.Ctx, code int, msg string) error {
	return ctx.Status(code).JSON(response.Error{Error: msg})
}
