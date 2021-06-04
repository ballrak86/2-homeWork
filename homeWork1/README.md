------------------------------------------------------------
Описание файлов в директории
logFileFull.log - полный лог выполнения
used_commands.txt - команды которые использовал

Vagrant_folder - все что понадобится для поднятия VM и краткое описание файлов в ней
Vagrantfile - вагрант файл
provisionscript.sh - скрипт полуатоматического выполнения ДЗ :)

------------------------------------------------------------
Описание как запустить виртуальную машину (кратко)
Выполнить команду
vagrant up
vagrant ssh
 /home/vagrant/provisionscript.sh

------------Vagrantfile (только интересные моменты)------------
#в VM добавляем наш скрипт
box.vm.provision "file", source: "provisionscript.sh", destination: "/home/vagrant/"
#и далее делаем его исполняемым
box.vm.provision "shell", inline: <<-SHELL
  chmod +x /home/vagrant/provisionscript.sh
SHELL
