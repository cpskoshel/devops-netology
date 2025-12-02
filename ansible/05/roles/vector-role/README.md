# Название и краткое описание
------------
Эта роль устанавливает Vector и настраивает предачу данных в clickhouse


# Требования
------------

# Role Variables
------------

       clickhouse_user: user
       clickhouse_password: 1234

       Конфигурация  vars/main.yml

# Dependencies
------------

# Example Playbook
------------

```
       - hosts: vector
         roles:
          - role: vector-role
```

# License
------------

MIT

# Author Information
------------

cpskoshel
