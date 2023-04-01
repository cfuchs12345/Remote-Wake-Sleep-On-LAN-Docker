## A fork of the original docker image made by ex0nuss which is unfortunately no longer maintained.
(https://github.com/ex0nuss/Remote-Wake-Sleep-On-LAN-Docker)

I wanted to fix a problem that I found when I used it - hence, I forked it.</br>
(The sleep functionality was apparently no longer working since the curl support was not installed and activated with the latest Ubuntu and used PHP version)</br>
</br>
new: </br>
- Created an Alpine image which is smaller / faster startup etc... had to tweak it a bit so that the commands work as expected by the PHP code</br>
- Alpine image can use a different interface than eth0 for WoL (can be set by env arg)</br>
- changed the password hashing since it also changed in the PHP code</br>

# Remote-Wake-Sleep-On-LAN-Docker
A docker image of [sciguy14/Remote-Wake-Sleep-On-LAN-Server](https://github.com/sciguy14/Remote-Wake-Sleep-On-LAN-Server).

Dockerhub: https://hub.docker.com/r/afoxdocker/remote-wake-sleep-on-lan-docker or https://hub.docker.com/r/afoxdocker/remote-wake-sleep-on-lan-docker-alpine

## Summary

> The Remote Wake/Sleep-on-LAN Server (RWSOLS) is a simple webapp that runs on Docker to remotely power up any computer via WOL. </br> This is necesarry, since WOL packages (Layer&nbsp;2) cannot be forwarded via a normal VPN (Layer&nbsp;3).

![preview img](https://raw.githubusercontent.com/cfuchs12345/Remote-Wake-Sleep-On-LAN-Docker/main/IMG_webinterface_preview.png)

**Information:**
- You don't need any additonal software to wake your client via WOL.
- Additional software is needed to sleep/shutdown your client via this webinterface.
    (You need to install a small programm on the server that should go to sleep i.e. this one here: https://github.com/SR-G/sleep-on-lan)

## Usage
Here are some example snippets to help you get started creating a container.

For Alpine image replace **afoxdocker/remote-wake-sleep-on-lan-docker** with **afoxdocker/remote-wake-sleep-on-lan-docker-alpine**

### docker-compose (recommended)
```YAML
version: "3"

services:
  frontend-rwsols:
    image: afoxdocker/remote-wake-sleep-on-lan-docker
    container_name: frontend-rwsols
    restart: unless-stopped
    network_mode: host
    environment:
      - PASSPHRASE=MyPassword
      - RWSOLS_COMPUTER_NAME="Pc1","Pc2"
      - RWSOLS_COMPUTER_MAC="XX:XX:XX:XX:XX:XX","XX:XX:XX:XX:XX:XX"
      - RWSOLS_COMPUTER_IP="192.168.1.45","192.168.1.50"
```

### docker CLI
```
docker run -d \
  --name=frontend-rwsols \
  --network="host" \
  -e PASSPHRASE=MyPassword \
  -e 'RWSOLS_COMPUTER_NAME="Pc1","Pc2"' \
  -e 'RWSOLS_COMPUTER_MAC="XX:XX:XX:XX:XX:XX","XX:XX:XX:XX:XX:XX"' \
  -e 'RWSOLS_COMPUTER_IP="192.168.1.45","192.168.1.50"' \
  --restart unless-stopped \
  afoxdocker/remote-wake-sleep-on-lan-docker
```


## Parameters and environment variables
Container images are configured using parameters passed at runtime (such as those above). There is no config file needed.

Parameter / Env var | Optional | Default value | Description
------------ | :-------------: | ------------- | -------------
`network_mode: host` | no | / | The container’s network stack is not isolated from the Docker host. This is necessary to send WOL packages from a container. The port of the webserver is configured via `APACHE2_PORT`.
`APACHE2_PORT` | yes | 8080 |	Port of the webinterface.
`PASSPHRASE` | yes | admin | Password of the webinterface. If no password is specified, you don't need a password to wake a PC.
`RWSOLS_COMPUTER_NAME` | no | / | Displaynames for the computers (**array**)<br>(**No spaces supported.** Please use hyphens or underscores)
`RWSOLS_COMPUTER_MAC` | no | / | MAC addresses for the computers (**array**)
`RWSOLS_COMPUTER_IP` | no | / | IP addresses for the computers (**array**)
`RWSOLS_SLEEP_PORT` | yes | 7760 | This is the Port being used by the Windows SleepOnLan Utility to initiate a Sleep State (**not necessary for WOL**)
`RWSOLS_SLEEP_CMD` | yes | suspend | Command to be issued by the windows sleeponlan utility (**not necessary for WOL**)
`INTERFACE_FOR_WOL` | yes | eth0 | Interface that is used for wake on lan (**only used for Alpine image**)

#### Explanation: Configuring the destination computer name, MAC and IP
To configure the computers, we will use these three environment variables:
- `RWSOLS_COMPUTER_NAME`
- `RWSOLS_COMPUTER_MAC`
- `RWSOLS_COMPUTER_IP`

<br/>

Let's say we want to wake 2 computers with the following configurations:
1. PC1
   - Displayname: PC-of-Mark
   - MAC address: 24:00:dd:5a:21:04
   - IP address: 192.168.1.146
2. PC2
   - Displayname: PC-of-John
   - MAC address: 59:3c:45:3c:30:f6
   - IP address: 192.168.1.177

<br/>

To configure the env vars it's easier to arrange them in a **vertical** table:
><table>
>  <tr>
>    <th><code>RWSOLS_COMPUTER_NAME</code></th>
>    <td>PC-of-Mark</td>
>    <td>PC-of-John</td>
>  </tr>
>  <tr>
>    <th><code>RWSOLS_COMPUTER_MAC</code></th>
>    <td>24:00:dd:5a:21:04</td>
>    <td>59:3c:45:3c:30:f6</td>
>  </tr>
>  <tr>
>    <th><code>RWSOLS_COMPUTER_IP</code></th>
>    <td>192.168.1.146</td>
>    <td>192.168.1.177</td>
>  </tr>
></table>

<br/>

Now you just format the table in an array:
>```
>      - RWSOLS_COMPUTER_NAME="PC-of-Mark","PC-of-John"
>      - RWSOLS_COMPUTER_MAC="24:00:dd:5a:21:04","59:3c:45:3c:30:f6"
>      - RWSOLS_COMPUTER_IP="192.168.1.146","192.168.1.177"
>```
>It's important to use the format as shown: `Env_var="XXX","XXX"`
