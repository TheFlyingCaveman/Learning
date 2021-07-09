package main

import (
	"fmt"
	"log"
	"os"
	"sync"
)

func writeToFile(logKind string, line string, filename string, wg *sync.WaitGroup) {
	for i := 1; i <= 20; i++ {
		f, err := os.OpenFile(filename, os.O_APPEND|os.O_WRONLY|os.O_CREATE, 0600)
		if err != nil {
			panic(err)
		}

		defer f.Close()

		var lineToWrite = fmt.Sprintf("%s- Line %d: %s\n", logKind, i, line)

		var logger = log.New(f, "", 0)
		// Not that it is *super* necessary, but log is built to run concurrently
		logger.Output(2, lineToWrite)
	}

	wg.Done()
}

func main() {
	var wg = &sync.WaitGroup{}

	wg.Add(1)
	go writeToFile("Type 1", "Some Line 1", "First.log", wg)
	wg.Add(1)
	go writeToFile("Type 2", "Some Line 2", "Second.log", wg)

	wg.Wait()

	fmt.Println("Finished!")
}
