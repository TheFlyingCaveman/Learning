package main

import (
	"archive/zip"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"io/ioutil"
	"log"
	"net/http"
	"os"
	"path"
	"path/filepath"
	"strings"
)

type garminDevice struct {
	DeviceUUID            string `json:"deviceUuid"`
	PartNumber            string `json:"partNumber"`
	Name                  string `json:"name"`
	ProductInfoFileExists bool   `json:"productInfoFileExists"`
	CiqInfoFileExists     bool   `json:"ciqInfoFileExists"`
	Upcoming              bool   `json:"upcoming"`
	ProductInfoHash       string `json:"productInfoHash"`
	CiqInfoHash           string `json:"ciqInfoHash"`
	Group                 string `json:"group"`
	DisplayName           string `json:"displayName"`
	LastUpdateTime        string `json:"lastUpdateTime"`
}

func main() {
	accessToken := os.Args[1]
	destination := os.Args[2]

	err := os.MkdirAll(destination, os.ModePerm)

	if err != nil {
		log.Fatal(err)
		return
	}

	var httpClient = http.Client{}
	get := func(url string) (*http.Response, error) {
		return authorizedGet(httpClient, url, accessToken)
	}

	var garminAPIHost = "https://api.gcs.garmin.com"

	devices, err := fetchDeviceList(garminAPIHost, get)

	if err != nil {
		log.Fatal(err)
		return
	}

	var uniqueDevices = removeDuplicatesByDeviceName(devices)

	files, err := downloadDeviceFiles(garminAPIHost, uniqueDevices, destination, get)

	if err != nil {
		log.Fatal(err)
		return
	}

	err = unzipAllDeviceFiles(files, destination, unzip)

	if err != nil {
		log.Fatal(err)
		return
	}
}

func unzipAllDeviceFiles(files []string, destination string, unzip func(src, dest string) error) error {
	for _, file := range files {
		var _, fileNameWithExtension = filepath.Split(file)
		var fileName = strings.TrimSuffix(fileNameWithExtension, path.Ext(fileNameWithExtension))
		var destinationFolder = path.Join(destination, fileName)

		fmt.Println("Unzipping to " + destinationFolder)

		err := unzip(file, destinationFolder)

		if err != nil {
			return err
		}

		err = os.Remove(file)

		if err != nil {
			log.Fatal(err)
			return err
		}
	}

	return nil
}

func downloadDeviceFiles(garminAPIHost string, devices []garminDevice, destination string, get func(string) (*http.Response, error)) ([]string, error) {
	files := []string{}

	for _, device := range devices {
		var getDeviceURL = fmt.Sprintf("%s/ciq-product-onboarding/devices/%s/ciqInfo", garminAPIHost, device.PartNumber)

		var fileName = path.Join(destination, device.Name+".zip")

		err := downloadZip(getDeviceURL, fileName, get)

		files = append(files, fileName)

		if err != nil {
			return files, err
		}
	}

	return files, nil
}

func fetchDeviceList(garminAPIHost string, get func(string) (*http.Response, error)) ([]garminDevice, error) {
	var existingDevicesURL = fmt.Sprintf("%s/ciq-product-onboarding/devices", garminAPIHost)
	resp, err := get(existingDevicesURL)

	if err != nil {
		return []garminDevice{}, err
	}

	defer resp.Body.Close()

	body, err := ioutil.ReadAll(resp.Body)

	if err != nil {
		return []garminDevice{}, err
	}

	devices := []garminDevice{}

	err = json.Unmarshal([]byte(body), &devices)

	if err != nil {
		return []garminDevice{}, err
	}

	return devices, nil
}

func authorizedGet(client http.Client, url string, accessToken string) (*http.Response, error) {
	req, _ := http.NewRequest("GET", url, nil)

	req.Header.Set("Authorization", "Bearer "+accessToken)

	return client.Do(req)
}

func downloadZip(url string, fileName string, get func(string) (*http.Response, error)) error {
	fmt.Println("Downloading " + url)

	file, err := os.Create(fileName)
	if err != nil {
		return err
	}
	defer file.Close()

	resp, err := get(url)
	if err != nil {
		return err
	}
	defer resp.Body.Close()

	if resp.StatusCode != 200 {
		return errors.New("Download unauthorized")
	}

	size, err := io.Copy(file, resp.Body)
	fmt.Printf("Downloaded a file %s with size %d\n", fileName, size)

	return nil
}

func unzip(src, dest string) error {
	r, err := zip.OpenReader(src)
	if err != nil {
		return err
	}
	defer func() {
		if err := r.Close(); err != nil {
			panic(err)
		}
	}()

	os.MkdirAll(dest, 0755)

	// Closure to address file descriptors issue with all the deferred .Close() methods
	extractAndWriteFile := func(f *zip.File) error {
		rc, err := f.Open()
		if err != nil {
			return err
		}
		defer func() {
			if err := rc.Close(); err != nil {
				panic(err)
			}
		}()

		path := filepath.Join(dest, f.Name)

		// Check for ZipSlip (Directory traversal)
		if !strings.HasPrefix(path, filepath.Clean(dest)+string(os.PathSeparator)) {
			return fmt.Errorf("illegal file path: %s", path)
		}

		if f.FileInfo().IsDir() {
			os.MkdirAll(path, f.Mode())
		} else {
			os.MkdirAll(filepath.Dir(path), f.Mode())
			f, err := os.OpenFile(path, os.O_WRONLY|os.O_CREATE|os.O_TRUNC, f.Mode())
			if err != nil {
				return err
			}
			defer func() {
				if err := f.Close(); err != nil {
					panic(err)
				}
			}()

			_, err = io.Copy(f, rc)
			if err != nil {
				return err
			}
		}
		return nil
	}

	for _, f := range r.File {
		err := extractAndWriteFile(f)
		if err != nil {
			return err
		}
	}

	return nil
}

func removeDuplicatesByDeviceName(d []garminDevice) []garminDevice {
	keys := make(map[string]bool)
	list := []garminDevice{}

	// If the key(values of the slice) is not equal
	// to the already present value in new slice (list)
	// then we append it. else we jump on another element.
	for _, entry := range d {
		if _, value := keys[entry.Name]; !value {
			keys[entry.Name] = true
			list = append(list, entry)
		}
	}

	return list
}
