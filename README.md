# Игнорировать все файлы в дирректории:
.terraform/

# Игнорировать файлы содержащие в названии .tfstate.
*.tfstate.*

# Игнорировать файлы который начинаются с crash. далее любое значение и заканчивается .log
crash.*.log
# Игнорировать все файлы с содержанием в названии значения после *:
*.tfvars
*.tfvars.json
*_override.tf
*_override.tf.json
*.tfstate
# Игнорировать файлы с именами:
.terraform.tfstate.lock.info
.terraformrc
terraform.rc
override.tf
override.tf.json
crash.log

