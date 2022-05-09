package main

import (
	"net/http"

	"github.com/gin-gonic/gin"
)

func main() {

	r := gin.Default()

	r.LoadHTMLGlob("templates/*")

	r.GET("/", func(ctx *gin.Context) {

		name, ok := ctx.GetQuery("name")
		if !ok {
			name = "unknown"
		}

		ctx.HTML(http.StatusOK, "index.html", gin.H{
			"Name": name,
		})

	})
	r.Run("0.0.0.0:3000")

}
