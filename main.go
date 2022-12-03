package main

import (
	"io"
	"log"
	"net/http"
	"net/url"
)

func handle() http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		s := r.URL.Query().Get("dst")
		if s == "" {
			w.WriteHeader(http.StatusBadRequest)
			return
		}

		_, err := url.Parse(s)
		if err != nil {
			w.WriteHeader(http.StatusBadRequest)
			return
		}

		res, err := http.Get(s)
		if err != nil {
			w.WriteHeader(http.StatusInternalServerError)
			return
		}
		defer res.Body.Close()

		if res.StatusCode != http.StatusOK {
			w.WriteHeader(http.StatusInternalServerError)
			return
		}

		io.Copy(io.Discard, res.Body)
		w.WriteHeader(http.StatusOK)
	}
}

func main() {
	http.HandleFunc("/", handle())
	if err := http.ListenAndServe("127.0.0.1:8081", nil); err != nil {
		log.Fatalf("failed to listen: %v", err)
	}
}
