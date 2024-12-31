terraform {
  required_providers {
    local = {
      source = "hashicorp/local"
      # lets user define version of the provider
      # version = "2.5.2"
    }

    random = {
      source = "hashicorp/random"
    }
  }
}

resource "random_pet" "pet" {
  length    = 3
  prefix    = "Pet:"
  separator = " "
}

resource "local_file" "file1" {
  filename = "file1.txt"
  content  = <<EOF
    ${var.file_content}
    ${random_pet.pet.id}
  EOF
}

output "name_my_pet" {
  value = "The pet name is ${random_pet.pet.id}"
}
