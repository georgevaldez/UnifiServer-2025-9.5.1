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


version: "3.9"

networks:
  unifisrv-net:
    driver: macvlan
    driver_opts:
      parent: ens18              # interfaz física real (10.10.20.3)
    ipam:
      config:
        - subnet: 10.10.20.0/24
          gateway: 10.10.20.2

volumes:
  unifi_data:
  unifi_db:

services:
  mongo:
    image: mongo:6.0
    container_name: unifi-mongo
    hostname: unifi-mongo
    restart: unless-stopped
    networks:
      unifisrv-net:
        ipv4_address: 10.10.20.5
    volumes:
      - unifi_db:/data/db
    command: >
      mongod --bind_ip_all --replSet rs0 --oplogSize 128
    healthcheck:
      test: ["CMD", "mongosh", "--eval", "db.runCommand({ ping: 1 })"]
      interval: 30s
      timeout: 10s
      retries: 5

  unifisrv:
    image: linuxserver/unifi-network-application:latest
    container_name: UnifiSRV
    hostname: UnifiSRV
    depends_on:
      mongo:
        condition: service_healthy
    restart: unless-stopped
    networks:
      unifisrv-net:
        ipv4_address: 10.10.20.4
    environment:
      - TZ=America/Guayaquil
      - PUID=1000
      - PGID=1000
      - MONGO_HOST=10.10.20.5
      - MONGO_PORT=27017
      - MONGO_USER=unifi
      - MONGO_PASS=unifi
      - MONGO_DBNAME=unifi
    volumes:
      - unifi_data:/config
    ports:
      - 3478:3478/udp      # STUN
      - 5514:5514/udp      # Syslog
      - 8080:8080/tcp      # Adopción de APs
      - 8443:8443/tcp      # Panel HTTPS
      - 8880:8880/tcp      # Portal invitados HTTP
      - 8843:8843/tcp      # Portal invitados HTTPS
      - 6789:6789/tcp      # Speed test
      - 10001:10001/udp    # Descubrimiento
      - 1900:1900/udp      # SSDP/UPnP
      - 5656-5699:5656-5699/tcp  # Rango interno

  macvlan-helper:
    image: alpine
    container_name: macvlan-helper
    network_mode: "host"
    privileged: true
    restart: unless-stopped
    command: >
      sh -c "
        ip link add unifisrv-macvlan link ens18 type macvlan mode bridge;
        ip addr add 10.10.20.10/32 dev unifisrv-macvlan;
        ip link set unifisrv-macvlan up;
        sleep infinity
      "
