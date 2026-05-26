output "worker_ip" {
  description = "Worker VM IP address"
  value       = libvirt_domain.worker.network_interface[0].addresses[0]
}

output "db_ip" {
  description = "Database VM IP address"
  value       = libvirt_domain.db.network_interface[0].addresses[0]
}

output "ssh_worker" {
  description = "SSH command for worker VM"
  value       = "ssh ansible@${libvirt_domain.worker.network_interface[0].addresses[0]}"
}

output "ssh_db" {
  description = "SSH command for db VM"
  value       = "ssh ansible@${libvirt_domain.db.network_interface[0].addresses[0]}"
}
