provider "google" {
    project = "sam-465905"
    zone = "us-central1-a"
}
locals {
  disk_names =["one" , "two"]
}
resource "google_compute_disk" "disk1" {
  count = length(local.disk_names)
  name = "disk-${local.disk_names[count.index]}"
  size = 10
  zone = "us-central1-a"
}
resource "google_compute_instance" "name" {
    count = length(local.disk_names)
    name = "instance-${local.disk_names[count.index]}"

    machine_type = "e2-medium"
    boot_disk {
      initialize_params {
        image = "centos-stream-9"
      }
    }
    network_interface {
      network = "default"
      access_config {
        
      }
    }
    labels = {
      label1= "ansible"
    }
    attached_disk {
      device_name = "disk-${local.disk_names[count.index]}"
      source = google_compute_disk.disk1[count.index].name
    }
    depends_on = [ google_compute_disk.disk1 ]
  
}


