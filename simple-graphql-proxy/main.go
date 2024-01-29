package main

import (
	"fmt"
	"log"
	"net/http"

	logger "github.com/ethereum/go-ethereum/log"
	"github.com/gin-gonic/gin"
)

var (
	Log = logger.New("logscope", "master")
)

func main() {
	Log.Info("Start Storage Service....")
	router := gin.New()

	router.Use(gin.Recovery(), gin.Logger())

	router.GET("/ping", func(c *gin.Context) {
		c.JSON(http.StatusOK, gin.H{"data": "pong"})
	})

	setupRoutes(router)

	addr := fmt.Sprintf("0.0.0.0:%v", 8080)
	if err := router.Run(addr); err != nil {
		log.Fatal("Server run failed ", err)
	}
}

func setupRoutes(router *gin.Engine) {
	// Token vendor machine

	router.GET("/hotel/:name", func(c *gin.Context) {
		name := c.Param("name")
		statusCode, body := ProxyToGraphQL(name)
		print("statusCode", statusCode)
		c.String(statusCode, string(body))
	})
}
