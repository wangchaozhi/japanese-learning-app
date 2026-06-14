package learn

import (
	"net/http"
	"strings"

	"japanese-learning-app/internal/common"
	"japanese-learning-app/internal/store"
)

// Word 是移动端单词卡片的数据结构。
type Word struct {
	ID             int    `json:"id"`
	Kana           string `json:"kana"`
	Kanji          string `json:"kanji"`
	Romaji         string `json:"romaji"`
	Meaning        string `json:"meaning"`
	Example        string `json:"example"`
	ExampleMeaning string `json:"exampleMeaning"`
	Level          string `json:"level"`
}

// WordsHandler 提供单词卡片列表，支持按 JLPT 等级过滤：GET /api/mobile/words?level=N5。
func WordsHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodGet {
		common.WriteJSON(w, http.StatusMethodNotAllowed, common.APIResponse{Code: 405, Msg: "method not allowed"})
		return
	}

	query := store.DB().Model(&store.Word{}).Order("sort_order ASC, id ASC")
	if level := strings.TrimSpace(r.URL.Query().Get("level")); level != "" {
		query = query.Where("level = ?", strings.ToUpper(level))
	}

	var records []store.Word
	if err := query.Find(&records).Error; err != nil {
		common.WriteJSON(w, http.StatusInternalServerError, common.APIResponse{Code: 500, Msg: err.Error()})
		return
	}

	result := make([]Word, 0, len(records))
	for _, record := range records {
		result = append(result, Word{
			ID:             record.ID,
			Kana:           record.Kana,
			Kanji:          record.Kanji,
			Romaji:         record.Romaji,
			Meaning:        record.Meaning,
			Example:        record.Example,
			ExampleMeaning: record.ExampleMeaning,
			Level:          record.Level,
		})
	}
	common.WriteJSON(w, http.StatusOK, common.APIResponse{Code: 0, Msg: "ok", Data: result})
}
