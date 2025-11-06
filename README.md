⚙️ Instrucciones en Portainer

1️⃣ Ve a Stacks → Add stack

2️⃣ Nómbralo: UnifiSRV
3️⃣ Pega todo este YAML.
4️⃣ Haz clic en Deploy the stack.

Portainer creará:
- la red macvlan (unifisrv-net)
- el volumen de datos (unifi_data)
- el volumen de base (unifi_db)
- los servicios MongoDB (10.10.20.5), UniFi (10.10.20.4) y helper (10.10.20.10)
