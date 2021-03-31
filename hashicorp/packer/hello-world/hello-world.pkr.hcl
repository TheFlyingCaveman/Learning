variable message {
  type    = string
  default = "Hello World"
}

source "docker" "ubuntu" {
  image   = "ubuntu"
  commit  = true
  changes = [
      "CMD [\"echo\", \"Hello World\"]"
  ]
}

build {
  sources = [
    "source.docker.ubuntu",
  ]

  provisioner "shell" {
    inline = [
        "apt-get update"            
      ]
  }

  post-processor "docker-tag" {
    repository = "trfc/hello-world"
    tag        = ["1.0"]
  }
}