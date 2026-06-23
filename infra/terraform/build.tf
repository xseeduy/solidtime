data "aws_ecr_authorization_token" "this" {}

provider "docker" {
  registry_auth {
    address  = data.aws_ecr_authorization_token.this.proxy_endpoint
    username = data.aws_ecr_authorization_token.this.user_name
    password = data.aws_ecr_authorization_token.this.password
  }
}

resource "docker_image" "this" {
  count = var.image_tag != "" ? 1 : 0

  name = "${aws_ecr_repository.this.repository_url}:${var.image_tag}"

  build {
    context    = "${path.root}/../.."
    dockerfile = "${path.root}/../../docker/prod/Dockerfile"
    tag = [
      "${aws_ecr_repository.this.repository_url}:${var.image_tag}",
      "${aws_ecr_repository.this.repository_url}:latest",
    ]
    platform = "linux/amd64"
  }

  triggers = {
    dir_sha1 = sha1(join("", [
      for f in fileset("${path.root}/../..", "docker/prod/**")
      : filesha1("${path.root}/../../${f}")
    ]))
  }
}

resource "docker_registry_image" "this" {
  count = var.image_tag != "" ? 1 : 0

  name = docker_image.this[0].name
}
