Resumen del proyecto
El repositorio contiene instrucciones pensadas para Portainer: crear una pila llamada UnifiSRV, pegar el contenido del archivo Yaml y desplegarla; esto genera automáticamente la red macvlan, los volúmenes de datos y base, y levanta los servicios MongoDB, UniFi y un helper.

Contenido del despliegue (Yaml)
Red y volúmenes: Define una red unifisrv-net con macvlan sobre la interfaz física ens18, además de los volúmenes persistentes unifi_data y unifi_db.

Servicio MongoDB: 
Ejecuta mongo:6.0, con IP fija 10.10.20.5, almacenamiento en unifi_db, y un healthcheck que usa mongosh para hacer ping a la instancia.

Servicio UniFi Network Application: 
Usa la imagen de LinuxServer, se conecta al Mongo anterior, persiste la configuración en unifi_data, expone todos los puertos habituales (STUN, adopción de APs, panel HTTPS, portales de invitados, etc.) y establece las variables de entorno necesarias para enlazarse al Mongo.

Servicio Helper (macvlan):
Contenedor alpine privilegiado que, al iniciar, crea y levanta una interfaz macvlan llamada unifisrv-macvlan sobre ens18, le asigna la IP 10.10.20.10/32 y se mantiene en ejecución.

Cómo usarlo:
En Portainer, crea una pila llamada UnifiSRV y pega el YAML proporcionado.
Al desplegar, tendrás una instancia completa del UniFi Network Application (controlador) respaldada por MongoDB y con conectividad en la red macvlan, lista para adoptar y gestionar dispositivos UniFi en tu segmento 10.10.20.0/24.

Designed by George Valdez EC @ Peltic Tech Solutions Ecuador

## Utilidades adicionales

### Limpieza y catalogación de imágenes ISO/IMG en Windows

En la carpeta [`scripts/`](scripts/) encontrarás el archivo por lotes `limpieza_iso_nombres.bat`. Este script recorre de forma recursiva la carpeta `E:\IsoBoot` (puedes ajustar la ruta modificando la variable `ROOT`), limpia los prefijos numéricos y reorganiza cada imagen `.iso` o `.img` en subcarpetas temáticas. Además, renombra cada archivo para que comience únicamente con el número de la categoría (`10 Windows 11.iso`, por ejemplo) antes de moverlo a su carpeta objetivo.

Catálogo aplicado automáticamente:

| Carpeta objetivo | Cuándo se usa |
|------------------|---------------|
| `00_Firewalls_Virtualization` | Firewalls y plataformas de virtualización (p. ej. pfSense, OPNsense, VMware ESXi, Proxmox). |
| `10_Windows_Client` | Sistemas cliente de escritorio Microsoft Windows (Windows 7/8/10/11, XP, Vista). |
| `30_Windows_Server` | Versiones de Windows Server y ediciones Hyper-V Server dedicadas. |
| `50_Linux_General` | Distribuciones Linux de propósito general (Ubuntu, Debian, Fedora, CentOS, openSUSE, etc.). |
| `70_Security_Forensics` | Distribuciones de seguridad, pentesting y forense (Kali, Parrot, Tails, Security Onion, etc.). |
| `80_Backup_Recovery` | Herramientas de respaldo y recuperación (Clonezilla, Rescuezilla, Macrium, Veeam, etc.). |
| `90_Utilities_Rescue` | Discos de rescate y utilidades multiuso (Hiren's BootCD, Strelec, DLC Boot, GParted, SystemRescue, etc.). |
| `99_Miscellaneous` | Imágenes que no encajan en las categorías anteriores. |

Para ejecutarlo:

1. Copia el archivo a un equipo Windows y haz doble clic para iniciarlo (o ejecútalo desde una consola `cmd`).
2. Ajusta el valor de `ROOT` si tus archivos están en otra ruta.
3. Revisa la lista de movimientos; el script mostrará cada cambio como `✓ archivo_original → carpeta_destino\archivo_final`.

El proceso finaliza mostrando un mensaje de confirmación y esperando a que presiones una tecla para cerrar la ventana.
