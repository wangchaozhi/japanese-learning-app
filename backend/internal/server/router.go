package server

import (
	"net/http"
	"strings"

	"japanese-learning-app/internal/admin"
	"japanese-learning-app/internal/auth"
	"japanese-learning-app/internal/common"
	"japanese-learning-app/internal/config"
	"japanese-learning-app/internal/learn"
)

func NewRouter(cors config.CORSConfig) http.Handler {
	mux := http.NewServeMux()

	mux.HandleFunc("/api/admin/login", auth.AdminLoginHandler)
	mux.HandleFunc("/api/mobile/login", auth.MobileLoginHandler)
	mux.HandleFunc("/api/mobile/words", learn.WordsHandler)

	mux.HandleFunc("/api/admin/profile", admin.ProfileHandler)
	mux.HandleFunc("/api/admin/profile/theme", admin.ProfileThemeHandler)
	mux.HandleFunc("/api/admin/profile/avatar", admin.ProfileAvatarHandler)
	mux.HandleFunc("/api/admin/profile/assets/", admin.ProfileAssetHandler)
	mux.HandleFunc("/api/admin/users", admin.UsersHandler)
	mux.HandleFunc("/api/admin/users/", admin.UserByIDHandler)
	mux.HandleFunc("/api/admin/app-users", admin.AppUsersHandler)
	mux.HandleFunc("/api/admin/app-users/", admin.AppUserByIDHandler)
	mux.HandleFunc("/api/admin/roles", admin.RolesHandler)
	mux.HandleFunc("/api/admin/roles/", admin.RoleByIDHandler)
	mux.HandleFunc("/api/admin/menus", admin.MenusHandler)
	mux.HandleFunc("/api/admin/menus/", admin.MenuByIDHandler)

	mux.HandleFunc("/api/health", func(w http.ResponseWriter, r *http.Request) {
		common.WriteJSON(w, http.StatusOK, common.APIResponse{Code: 0, Msg: "ok", Data: map[string]string{"status": "up"}})
	})

	return withCORS(mux, cors)
}

func withCORS(next http.Handler, cors config.CORSConfig) http.Handler {
	allowHeaders := strings.Join(cors.AllowHeaders, ", ")
	allowMethods := strings.Join(cors.AllowMethods, ", ")
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if allowOrigin := resolveAllowedOrigin(cors.AllowOrigins, r.Header.Get("Origin")); allowOrigin != "" {
			w.Header().Set("Access-Control-Allow-Origin", allowOrigin)
		}
		w.Header().Set("Access-Control-Allow-Headers", allowHeaders)
		w.Header().Set("Access-Control-Allow-Methods", allowMethods)
		if r.Method == http.MethodOptions {
			w.WriteHeader(http.StatusNoContent)
			return
		}
		next.ServeHTTP(w, r)
	})
}

func resolveAllowedOrigin(allowed []string, origin string) string {
	for _, item := range allowed {
		item = strings.TrimSpace(item)
		if item == "*" {
			return "*"
		}
		if item != "" && item == origin {
			return origin
		}
	}
	return ""
}
