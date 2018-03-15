# sd-exam1

## Primer Parcial Sistemas Distribuidos
#### Universidad Icesi
### Paula Andrea Bolaños
#### A00068008


### Objetivos

- Realizar de forma autónoma el aprovisionamiento automático de infraestructura
- Diagnosticar y ejecutar de forma autónoma las acciones necesarias para lograr infraestructuras estables
- Realizar el aprovisionamiento automático de un balanceador de carga


### Prerrequisitos

- Vagrant
- Box del sistema operativo CentOS7


### Descripción

Se realiza	el	aprovisionamiento	de	un	ambiente	compuesto	por	tres máquinas	por medio de aprovisionamiento con chef.

- Un servidor	balanceador de	carga
- Dos	servidores	web

Por último, se prueba	el	funcionamiento	del balanceador	mostrando visualmente cuál servidor web (su nombre y dirección IP) atiende la	petición.


![DiagramaUML](sd-exam1/A00068008/diagramaUML.png)


### Actividades

1. Comandos de Linux necesarios para el aprovisionamiento de los servicios solicitados
- Balanceador de carga  


Instalar el haproxy: 


	sudo yum install haproxy


Configurarlo, editando el archivo haproxy.cfg: 


	sudo vi /etc/haproxy/haproxy.cfg

	#---------------------------------------------------------------------
	# round robin balancing between the various backends
	#---------------------------------------------------------------------
		 backend nodes
		   balance     roundrobin
		   server app1 192.168.34.12:80 check
		   server app2 192.168.34.13:80 check`
	   
	  
Configurar los logs en el archivo rsyslog:
        
	
	sudo vi /etc/sysconfig/rsyslog
      
	SYSLOGD_OPTIONS="-r"
        local2.*                       /var/log/haproxy.log


Reiniciar el servicio: 


	sudo service haproxy restart 


- Servidores Web


Instalar httpd:


	sudo yum install httpd


Iniciar el servicio:


	sudo service httpd start


2. Archivo Vagrantfile para realizar el aprovisionamiento


		# -*- mode: ruby -*-

		# vi: set ft=ruby :

		VAGRANTFILE_API_VERSION = "2"
		Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|  
		  config.ssh.insert_key = false

		  #Balanceador de carga
		  config.vm.define :load_balancer do |load_balancer|
		   load_balancer.vm.box = "centos1706v3"
		   load_balancer.vm.network :private_network, ip: "192.168.34.11"
		   load_balancer.vm.provider :virtualbox do |vb|
		      vb.customize ["modifyvm", :id, "--memory", "1024","--cpus", "4", "--name", "load_balancer" ]
		    end
		   config.vm.provision :chef_solo do |chef|
		      chef.install = false
		      chef.cookbooks_path = "cookbooks"
		      chef.add_recipe "haproxy"
		      chef.json = {
			"web_servers" => [
			  {"ip":"192.168.34.12"},
			  {"ip":"192.168.34.13"}
			]
		      }
		   end 
		  end

		  #Servidor web 
		  config.vm.define :web_server1 do |web_server1|
		    web_server1.vm.box = "centos1706v3"
		    web_server1.vm.network :private_network, ip: "192.168.34.12"
		    web_server1.vm.provider :virtualbox do |vb|
		      vb.customize ["modifyvm", :id, "--memory", "1024","--cpus", "4", "--name", "web_server_a" ]
		    end
		   config.vm.provision :chef_solo do |chef|
		      chef.install = false
		      chef.cookbooks_path = "cookbooks"
		      chef.add_recipe "httpd"
		      chef.json = {
			"service_name" => "webserver1",
			"ip" => "192.168.34.12"
			}
		   end
		  end

		  #Servidor web 2
		  config.vm.define :web_server2 do |web_server2|
		    web_server2.vm.box = "centos1706v3"
		    web_server2.vm.network :private_network, ip: "192.168.34.13"
		    web_server2.vm.provider :virtualbox do |vb|
		      vb.customize ["modifyvm", :id, "--memory", "1024","--cpus", "4", "--name", "web_server_b" ] 
		    end
		   config.vm.provision :chef_solo do |chef|
		      chef.install = false
		      chef.cookbooks_path = "cookbooks"
		      chef.add_recipe "httpd"
		      chef.json = {
			"service_name" => "webserver2",
			"ip" => "192.168.34.13"
			}
		   end
		  end
		end


3. Cookbooks necesarios para realizar la instalación de los servicios solicitados

![Estructura](/cookbook_tree.png)


   Los cookbooks que se han creado son uno para el balanceador, haproxy, y otro para los servidores web, httpd. Cada uno tiene recetas de configuración e instalación, que automatizan los comandos presentados en el paso 1, donde el archivo default hace referencia a los archivos de instalación y configuración respectivamente. Por otra parte, cuenta con unos templates, que son archivos que adoptarán los servidores y que pueden contener variables que se pasan por medio de un json en el Vagrantfile. Estos templates son referenciados a la carpeta en la que se ubicarán y otras características, así como las variables, en el archivo de configuración de la receta.
   
4. Funcionamiento
   Básicamente, lo que hace el balanceador es que cuando se accede a este desde un navegador por el puerto 80, él envía una solicitud al servidor web 1 y la siguiente al servidor web 2 y así sucesivamente va alternando entre los dos de forma secuencial, ya que usa el algoritmo round robin. En la página, cuando se accede al balanceador, este muestra el nombre del servidor web que está atendiendo la solicitud y la dirección IP, ya que esto es lo que contienen las páginas de los servidores web (cada uno con su nombre y su dirección IP), como se puede ver en el video test_balanceador del repositorio o en el link https://photos.app.goo.gl/nZuPRZIi81kK5WIN2.
   
   
   * Para todo el aprovisionamiento se utilizaron direcciones IP privadas.
   
5. Dificultades
   Se encontró que el balanceador inicialmente no funcionaba y al acceder a este por el navegador en el puerto 80 no cargaba nada y en el 5000 salía error 503, sin embargo, en el servidor apaecía el haproxy corriendo. Por ello, fue necesario verificar por medio de pings que las máquinas se podían ver, lo cual no tuvo problema. Posteriormente, se verificaron los procesos activos y los puertos a los que estaban asociados para confirmar que el puerto no estuviese ocupado. Finalmente, se configuró el archivo de logs (/etc/sysconfig/rsyslog), como se explicó en pasos anteriores, y se reinició el servicio. Con esto se logró solucionar el problema.
   
   
#### URL: https://github.com/paulaandrea27/sd-exam1



