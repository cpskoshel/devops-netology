# 1. Сервисный аккаунт
resource "yandex_iam_service_account" "sa-bucket" {
  name      = "bucket-sa"
  folder_id = var.folder_id
}

# 2. Роль для управления хранилищем
resource "yandex_resourcemanager_folder_iam_member" "sa-editor" {
  folder_id = var.folder_id
  role      = "editor"
  member    = "serviceAccount:${yandex_iam_service_account.sa-bucket.id}"
}

# 3. Статический ключ
resource "yandex_iam_service_account_static_access_key" "sa-static-key" {
  service_account_id = yandex_iam_service_account.sa-bucket.id
}

# 4. Симметричный ключ KMS
resource "yandex_kms_symmetric_key" "bucket-key" {
  folder_id         = var.folder_id
  name              = "bucket-kms-key"
  default_algorithm = "AES_128"
  rotation_period   = "8760h"
}

# 5. Права для SA 
resource "yandex_kms_symmetric_key_iam_binding" "encrypter-decrypter" {
  symmetric_key_id = yandex_kms_symmetric_key.bucket-key.id
  role             = "kms.keys.encrypterDecrypter"
  members = [
    "serviceAccount:${yandex_iam_service_account.sa-bucket.id}",
  ]
}

# 6. Бакет с шифрованием
resource "yandex_storage_bucket" "nuke-bucket" {

  access_key = yandex_iam_service_account_static_access_key.sa-static-key.access_key
  secret_key = yandex_iam_service_account_static_access_key.sa-static-key.secret_key

  folder_id     = var.folder_id 
  bucket        = "nuke-storage-${formatdate("DDMMYY", timestamp())}"
  force_destroy = true
  acl           = "public-read"

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = yandex_kms_symmetric_key.bucket-key.id
        sse_algorithm     = "aws:kms"
      }
    }
  }

  depends_on = [yandex_resourcemanager_folder_iam_member.sa-editor]
}

# 7. Загрузка картинки
resource "yandex_storage_object" "nuke-pic" {
  access_key = yandex_iam_service_account_static_access_key.sa-static-key.access_key
  secret_key = yandex_iam_service_account_static_access_key.sa-static-key.secret_key
  
  bucket     = yandex_storage_bucket.nuke-bucket.id
  key        = "image.jpg"
  source     = "/Users/koshel_np/projects/devops-netology/clopro/15.2/image.png"
  acl        = "public-read"
}
