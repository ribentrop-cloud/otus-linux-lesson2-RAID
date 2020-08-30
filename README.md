## Описание решения
(* доп. задание - Vagrantfile, который сразу собирает систему с подключенным рейдом)

Был модифицирован исходный Vagrantfile для следующих задач:
- подключение нужного количества дисков для последующей сборки RAID5
Для этого в Vagrantfile добавлена секция:
```sh
                :sata5 => {
                        :dfile => './sata5.vdi',
                        :size => 250, # Megabytes
                        :port => 5
                }
```
- в секции Provisioning добавлен скрипт для автосборки RAID 5 после загрузки.  
- в секции Provisioning добавлены команды для создания пяти GPT разделов

__Проверка:__
1. vagrant up 
2. vagrant ssh 
3. cat /proc/mdstat
4. lsblk
5. cat /etc/fstab

