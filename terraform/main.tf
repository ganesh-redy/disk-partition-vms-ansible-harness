provider "google" {
    project = "sam-474404"
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

#if u can't to create two seperate pipeline for iacm and cd the we can use this for trigger 

  metadata = {
  startup-script = <<-EOT
    #!/bin/bash
    
    # Get the private IP address (more reliable than hostname -i)
    HOSTKEY=$(hostname -I | awk '{print $1}' || echo "unknown")
    
    echo "Detected host IP: $HOSTKEY"
    
    # Trigger Harness pipeline with the IP
    response=$(curl -s -w "\n%%{http_code}" -X POST \
      -H 'content-type: application/json' \
      --url 'https://app.harness.io/gateway/pipeline/api/webhook/custom/PYmjEWiwTKKwvl_q6PK2qg/v3?accountIdentifier=ucHySz2jQKKWQweZdXyCog&orgIdentifier=default&projectIdentifier=SFTY_Training&pipelineIdentifier=cdjavatriggerganesh&triggerIdentifier=host_ip' \
      -d '{"host": "'"$HOSTKEY"'"}')
    
    http_code=$(echo "$response" | tail -n1)
    response_body=$(echo "$response" | sed '$d')
    
    echo "Harness API response: $http_code"
    echo "Response body: $response_body"
    
    if [ "$http_code" -eq 200 ]; then
        echo "Successfully triggered pipeline with IP: $HOSTKEY"
    else
        echo "Failed to trigger pipeline. HTTP code: $http_code"
        exit 1
    fi
  EOT
}
  
}


