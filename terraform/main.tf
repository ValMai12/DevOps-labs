resource "libvirt_pool" "lab4_pool" {
  name = "lab4-pool"
  type = "dir"

  target {
    path = "/opt/homebrew/var/lib/libvirt/images/lab4"
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

  network_config = templatefile("${path.module}/network-config.yml", {
    mac_address = "52:54:00:12:04:11"
    ip_address  = "192.168.56.11/24"
  })
}

resource "libvirt_cloudinit_disk" "db_cloudinit" {
  name = "lab4-db-cloudinit.iso"
  pool = libvirt_pool.lab4_pool.name

  user_data = templatefile("${path.module}/cloud-init.yml", {
    hostname               = "lab4-db"
    student_ssh_public_key = var.student_ssh_public_key
  })

  network_config = templatefile("${path.module}/network-config.yml", {
    mac_address = "52:54:00:12:04:12"
    ip_address  = "192.168.56.12/24"
  })
}

resource "libvirt_domain" "worker" {
  name    = "lab4-worker"
  type    = "qemu"
  machine = "virt"
  memory  = "2048"
  vcpu    = 2

  cloudinit = libvirt_cloudinit_disk.worker_cloudinit.id

  disk {
    volume_id = libvirt_volume.worker_disk.id
    scsi      = true
  }

  network_interface {
    bridge = "bridge100"
    mac    = "52:54:00:12:04:11"
  }

  xml {
    xslt = file("${path.module}/cloudinit-cdrom-scsi.xsl")
  }

}

resource "libvirt_domain" "db" {
  name    = "lab4-db"
  type    = "qemu"
  machine = "virt"
  memory  = "2048"
  vcpu    = 2

  cloudinit = libvirt_cloudinit_disk.db_cloudinit.id

  disk {
    volume_id = libvirt_volume.db_disk.id
    scsi      = true
  }

  network_interface {
    bridge = "bridge100"
    mac    = "52:54:00:12:04:12"
  }

  xml {
    xslt = file("${path.module}/cloudinit-cdrom-scsi.xsl")
  }

}
