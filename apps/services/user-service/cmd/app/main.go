package main

import (
	"log"

	"github.com/hoan02/puchi-user-service/config"
	"github.com/hoan02/puchi-user-service/internal/app"
)

func main() {
	// Configuration
	cfg, err := config.NewConfig()
	if err != nil {
		log.Fatalf("Config error: %s", err)
	}

	// Run
	app.Run(cfg)
}
