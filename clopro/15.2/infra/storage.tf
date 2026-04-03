# Cервисный аккаунта для работы с бакетом
resource "yandex_iam_service_account" "sa-bucket" {
  name = "bucket-sa"
}

# Роль для управления хранилищем
resource "yandex_resourcemanager_folder_iam_member" "sa-editor" {
  folder_id = var.folder_id
  role      = "editor"
  member    = "serviceAccount:${yandex_iam_service_account.sa-bucket.id}"
}

# Статический ключ доступа
resource "yandex_iam_service_account_static_access_key" "sa-static-key" {
  service_account_id = yandex_iam_service_account.sa-bucket.id
}

# Бакет с публичным доступом на чтение
resource "yandex_storage_bucket" "nuke-bucket" {
  folder_id = var.folder_id 
  bucket     = "nuke-storage-${formatdate("DDMMYY", timestamp())}"
  force_destroy = true
  acl        = "public-read"
}

# Загрузка картинки в бакет
resource "yandex_storage_object" "nuke-pic" {
  access_key = yandex_iam_service_account_static_access_key.sa-static-key.access_key
  secret_key = yandex_iam_service_account_static_access_key.sa-static-key.secret_key
  bucket     = yandex_storage_bucket.nuke-bucket.id
  key        = "image.jpg"
  source     = "/Users/koshel_np/projects/devops-netology/clopro/15.2/image.png" # Путь к файлу
  acl        = "public-read"
}
