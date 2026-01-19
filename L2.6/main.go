// L2.6
// Что выведет программа?

// Объяснить поведение срезов при передаче их в функцию.

// Дедлайн — 20 янв, 02:59

// Решение:

package main

import (
	"fmt"
)

func main() {
	var s = []string{"1", "2", "3"}
	modifySlice(s)
	fmt.Println(s)
}

func modifySlice(i []string) {
	i[0] = "3"
	i = append(i, "4")
	i[1] = "5"
	i = append(i, "6")
}
