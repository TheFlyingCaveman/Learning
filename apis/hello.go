package main

import (
	"fmt"
	"net/http"
	"time"
)

func main() {
	handler := http.NewServeMux()
	handler.HandleFunc("/api/hello", sayHello)

	fmt.Printf("http://localhost:8080/api/hello")

	http.ListenAndServe("0.0.0.0:8080", handler)
}

func sayHello(w http.ResponseWriter, r *http.Request) {
	dt := time.Now()
	fmt.Fprintf(w, `Hello world. It is %v`, dt)
}
