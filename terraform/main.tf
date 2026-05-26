resource "libvirt_pool" "lab4_pool" {
  name = "lab4-pool"
  type = "dir"

  target {
    path = "${path.module}/images"
  }
}

resource "libvirt_network" "lab4_network" {
  name      = "lab4-network"
  mode      = "nat"
  domain    = "lab4.local"
  addresses = ["192.168.56.0/24"]

  dhcp {
    enabled = true
  }
}

resource "libvirt_volume" "ubuntu_base" {
  name   = "ubuntu-24.04-arm64-base.qcow2"
  pool   = libvirt_pool.lab4_pool.name
  source = "https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-arm64.img"
  format = "qcow2"
}

resource "libvirt_volume" "worker_disk" {
  name           = "lab4-worker.qcow2"
  pool           = libvirt_pool.lab4_pool.name
  base_volume_id = libvirt_volume.ubuntu_base.id
  size           = 10737418240
}

resource "libvirt_volume" "db_disk" {
  name           = "lab4-db.qcow2"
  pool           = libvirt_pool.lab4_pool.name
  base_volume_id = libvirt_volume.ubuntu_base.id
  size           = 10737418240
}

resource "libvirt_cloudinit_disk" "worker_cloudinit" {
  name = "lab4-worker-cloudinit.iso"
  pool = libvirt_pool.lab4_pool.name

  user_data = templatefile("${path.module}/cloud-init.yml", {
    hostname               = "lab4-worker"
    student_ssh_public_key = var.student_ssh_public_key
  })
}

resource "libvirt_cloudinit_disk" "db_cloudinit" {
  name = "lab4-db-cloudinit.iso"
  pool = libvirt_pool.lab4_pool.name

  user_data = templatefile("${path.module}/cloud-init.yml", {
    hostname               = "lab4-db"
    student_ssh_public_key = var.student_ssh_public_key
  })
}

resource "libvirt_domain" "worker" {
  name   = "lab4-worker"
  memory = "2048"
  vcpu   = 2

  cloudinit = libvirt_cloudinit_disk.worker_cloudinit.id

  disk {
    volume_id = libvirt_volume.worker_disk.id
  }

  network_interface {
    network_id     = libvirt_network.lab4_network.id
    hostname       = "lab4-worker"
    wait_for_lease = true
  }

  console {
    type        = "pty"
    target_type = "serial"
    target_port = "0"
  }
}

resource "libvirt_domain" "db" {
  name   = "lab4-db"
  memory = "2048"
  vcpu   = 2

  cloudinit = libvirt_cloudinit_disk.db_cloudinit.id

  disk {
    volume_id = libvirt_volume.db_disk.id
  }

  network_interface {
    network_id     = libvirt_network.lab4_network.id
    hostname       = "lab4-db"
    wait_for_lease = true
  }

  console {
    type        = "pty"
    target_type = "serial"
    target_port = "0"
  }
}
