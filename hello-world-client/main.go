package main

import (
	"flag"
	"fmt"
	"io/ioutil"
	"log"
	"net/http"
	"strings"
	"time"
)

const (
	helloAddr = "localhost:9191"
	worldAddr = "localhost:9192"
	interval = 2 * time.Second
)

func main() {
	var (
		loop = flag.Bool("loop", true, "Make continuous requests to hello service.")
	)
	flag.Parse()

	ticker := time.NewTicker(interval)
	for {
		hello, err := doRequest(helloAddr, "hello")
		if err != nil {
			log.Printf("[ERR] failed to dial hello service: %v", err)
		}
		world, err := doRequest(worldAddr, "world")
		if err != nil {
			log.Printf("[ERR] failed to dial world service: %v", err)
		}
		fmt.Printf("%s %s\n", hello, world)
		if !*loop {
			// Only run once if not looping
			break
		}
		<-ticker.C
	}
}

func doRequest(addr, endpoint string) (string, error) {
	target := fmt.Sprintf("http://%s/%s", addr, endpoint)
	resp, err := http.Get(target)
	if err != nil {
		return "", err
	}
	defer resp.Body.Close()

	body, err := ioutil.ReadAll(resp.Body)
	if err != nil {
		return "", fmt.Errorf("failed to read body: %v", err)
	}

	return strings.TrimSpace(string(body)), nil
}
