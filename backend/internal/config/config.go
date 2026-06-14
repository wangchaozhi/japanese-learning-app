package config

import (
	"fmt"
	"net"
	"os"
	"path/filepath"
	"strconv"
	"strings"

	"go.yaml.in/yaml/v3"
)

const defaultEnv = "local"

type Config struct {
	Env      string         `yaml:"env"`
	Server   ServerConfig   `yaml:"server"`
	Database DatabaseConfig `yaml:"database"`
	MinIO    MinIOConfig    `yaml:"minio"`
	CORS     CORSConfig     `yaml:"cors"`
}

type ServerConfig struct {
	Host string `yaml:"host"`
	Port int    `yaml:"port"`
}

type DatabaseConfig struct {
	DSN string `yaml:"dsn"`
}

type MinIOConfig struct {
	Endpoint     string `yaml:"endpoint"`
	AccessKey    string `yaml:"accessKey"`
	SecretKey    string `yaml:"secretKey"`
	UseSSL       bool   `yaml:"useSSL"`
	AvatarBucket string `yaml:"avatarBucket"`
}

type CORSConfig struct {
	AllowOrigins []string `yaml:"allowOrigins"`
	AllowHeaders []string `yaml:"allowHeaders"`
	AllowMethods []string `yaml:"allowMethods"`
}

func Load() (Config, error) {
	env := strings.TrimSpace(os.Getenv("APP_ENV"))
	if env == "" {
		env = defaultEnv
	}

	path := strings.TrimSpace(os.Getenv("CONFIG_FILE"))
	if path == "" {
		path = filepath.Join("configs", env+".yml")
	}

	raw, err := os.ReadFile(path)
	if err != nil {
		return Config{}, fmt.Errorf("read config %s: %w", path, err)
	}

	cfg := defaultConfig(env)
	if err = yaml.Unmarshal(raw, &cfg); err != nil {
		return Config{}, fmt.Errorf("parse config %s: %w", path, err)
	}
	cfg.Env = env
	applyEnvOverrides(&cfg)
	normalize(&cfg)
	return cfg, nil
}

func (c ServerConfig) Addr() string {
	return net.JoinHostPort(c.Host, strconv.Itoa(c.Port))
}

func defaultConfig(env string) Config {
	return Config{
		Env: env,
		Server: ServerConfig{
			Host: "0.0.0.0",
			Port: 8080,
		},
		CORS: CORSConfig{
			AllowOrigins: []string{"*"},
			AllowHeaders: []string{"Content-Type", "Authorization"},
			AllowMethods: []string{"GET", "POST", "PUT", "DELETE", "OPTIONS"},
		},
	}
}

func applyEnvOverrides(cfg *Config) {
	if value := strings.TrimSpace(os.Getenv("SERVER_HOST")); value != "" {
		cfg.Server.Host = value
	}
	if value := strings.TrimSpace(os.Getenv("SERVER_PORT")); value != "" {
		if port, err := strconv.Atoi(value); err == nil {
			cfg.Server.Port = port
		}
	}
	if value := strings.TrimSpace(os.Getenv("DATABASE_DSN")); value != "" {
		cfg.Database.DSN = value
	}
	if value := strings.TrimSpace(os.Getenv("MINIO_ENDPOINT")); value != "" {
		cfg.MinIO.Endpoint = value
	}
	if value := strings.TrimSpace(os.Getenv("MINIO_ACCESS_KEY")); value != "" {
		cfg.MinIO.AccessKey = value
	}
	if value := strings.TrimSpace(os.Getenv("MINIO_SECRET_KEY")); value != "" {
		cfg.MinIO.SecretKey = value
	}
	if value := strings.TrimSpace(os.Getenv("MINIO_USE_SSL")); value != "" {
		cfg.MinIO.UseSSL = strings.EqualFold(value, "true")
	}
	if value := strings.TrimSpace(os.Getenv("MINIO_AVATAR_BUCKET")); value != "" {
		cfg.MinIO.AvatarBucket = value
	}
}

func normalize(cfg *Config) {
	if strings.TrimSpace(cfg.Server.Host) == "" {
		cfg.Server.Host = "0.0.0.0"
	}
	if cfg.Server.Port == 0 {
		cfg.Server.Port = 8080
	}
	if len(cfg.CORS.AllowOrigins) == 0 {
		cfg.CORS.AllowOrigins = []string{"*"}
	}
	if len(cfg.CORS.AllowHeaders) == 0 {
		cfg.CORS.AllowHeaders = []string{"Content-Type", "Authorization"}
	}
	if len(cfg.CORS.AllowMethods) == 0 {
		cfg.CORS.AllowMethods = []string{"GET", "POST", "PUT", "DELETE", "OPTIONS"}
	}
}
