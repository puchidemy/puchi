package main

import (
	"log"

	"github.com/puchidemy/puchi-user-services/config"
	"github.com/puchidemy/puchi-user-services/internal/app"
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
