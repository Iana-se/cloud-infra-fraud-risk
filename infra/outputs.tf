# Выходные данные
output "proxy_public_ip" {
  value = yandex_compute_instance.proxy.network_interface[0].nat_ip_address
}

output "bucket_name" {
  value = yandex_storage_bucket.data_bucket.bucket
}

output "source_bucket_name" {
  value = var.source_bucket_name
}