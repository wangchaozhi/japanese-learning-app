package main

import (
	"log"
	"net/http"

	"japanese-learning-app/internal/config"
	"japanese-learning-app/internal/server"
	"japanese-learning-app/internal/store"
)

func main() {
	cfg, err := config.Load()
	if err != nil {
		log.Fatal(err)
	}

	if err := store.Init(cfg.Database, cfg.MinIO); err != nil {
		log.Fatal(err)
	}

	handler := server.NewRouter(cfg.CORS)
	addr := cfg.Server.Addr()
	log.Printf("server started env=%s addr=http://%s", cfg.Env, addr)
	if err := http.ListenAndServe(addr, handler); err != nil {
		log.Fatal(err)
	}
}
