terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"
}

provider "yandex" {
  service_account_key_file = "./tf_key.json"
  folder_id                = local.folder_id
  zone                     = "ru-central1-a"
}

resource "yandex_vpc_network" "foo" {}

resource "yandex_vpc_subnet" "foo" {
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.foo.id
  v4_cidr_blocks = ["10.5.0.0/24"]
}

resource "yandex_container_registry" "registry1" {
  name = "sagrityaninregistry"
}

locals {
  folder_id = "b1g72ja3gj83ksl68q3h"
  service-accounts = toset([
    "sagrityanin1", 
  ])
  catgpt-sa-roles = toset([
    "container-registry.images.puller",
    "monitoring.editor",
    "container-registry.images.pusher",
    "vpc.user",
    "editor",
  
  ])
}
resource "yandex_iam_service_account" "service-accounts" {
  for_each = local.service-accounts
  name     = each.key
}
resource "yandex_resourcemanager_folder_iam_member" "catgpt-roles" {
  for_each  = local.catgpt-sa-roles
  folder_id = local.folder_id
  member    = "serviceAccount:${yandex_iam_service_account.service-accounts["sagrityanin1"].id}"
  role      = each.key
}

data "yandex_compute_image" "coi" {
  family = "container-optimized-image"
}
resource "yandex_compute_instance_group" "catgpt-group" {
  name = "catgpt-group"
  service_account_id = yandex_iam_service_account.service-accounts["sagrityanin1"].id
  instance_template {
    platform_id = "standard-v2"
    
    resources {
      cores         = 2
      memory        = 1
      core_fraction = 5
    }
    boot_disk {
      initialize_params {
        type = "network-hdd"
        size = "30"
        image_id = data.yandex_compute_image.coi.id
      }
    }
    network_interface {
      subnet_ids = ["${yandex_vpc_subnet.foo.id}"]
      nat = true
    }
    scheduling_policy {
      preemptible = true
    }


    metadata = {
      docker-compose = file("${path.module}/docker-compose.yaml")
      ssh-keys  = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
    }
  }
  scale_policy {
    fixed_scale {
      size = 2
    }
  }
  allocation_policy {
    zones = ["ru-central1-a"]
  }
  deploy_policy {
    max_unavailable = 2
    max_creating = 2
    max_expansion = 2
    max_deleting = 2
  }
}


