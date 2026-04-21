#import "/typ/post.typ": post

#show: post.with(
  title: [How to Build a Java Edition Minecraft Server],
  subtitle: none,
  authors: "Bendancom",
  description: [Self-host a Java Edition Minecraft server, covering installation, backup, mod management, auto-start, etc.],
  date: datetime(year: 2023,month: 6,day: 18),
  lastModDate: datetime(year: 2026,month: 4,day: 10),
  category: "Game",
  tags: ("Minecraft","Java","Server"),
  order: none,
  image: none,
  lang: "en",
)

= Preface

After a long time of playing Minecraft solo, despite its rich gameplay content, I still wanted to find like-minded friends to play together and create good memories. The Chinese edition of Minecraft can be said to have many restrictions, making the international Java edition server the preferred choice for multiplayer.

= Preparations

== Equipment Preparation

Choose one of the following:

- A networked computer with performance meeting game requirements, system priority: `Linux > Windows = Mac`.
- Cloud server

== Environment Preparation

- `OpenJDK`

== Knowledge Preparation

- Basic computer knowledge
- Basic `Linux` knowledge (Linux system)
- Certain English proficiency to facilitate troubleshooting

= Minecraft File Root Directory

Recommended to create on a filesystem with snapshot capability.

= Server Installation

== Vanilla

#link("https://launchermeta.mojang.com/mc/game/version_manifest.json")[Versions]
Select the desired server version from it; if using mods, pay attention to the matching of `Minecraft` versions.

```json
{
    "id": "1.20.1",
    "type": "release",
    "url": "https://piston-meta.mojang.com/v1/packages/30e78c499d4df02aab34a811e290c1805f925105/1.20.1.json",
    "time": "2024-04-03T06:24:18+00:00",
    "releaseTime": "2023-06-12T13:25:51+00:00"
},
```

Obtain the `URL` corresponding to the version number and open this `json` file, find the `downloads` element (line 165).

```json
"downloads": {
        "client": {
            "sha1": "4e969a3079409732a39aa722ea61d03876c41367",
            "size": 25230298,
            "url": "https://piston-data.mojang.com/v1/objects/4e969a3079409732a39aa722ea61d03876c41367/client.jar"
        },
        "client_mappings": {
            "sha1": "85283b9708072cada19de2a29955957939af2127",
            "size": 9308979,
            "url": "https://piston-data.mojang.com/v1/objects/85283b9708072cada19de2a29955957939af2127/client.txt"
        },
        "server": {
            "sha1": "00cab0438130dc3e6ae91f53387bb96ae7986d31",
            "size": 50546942,
            "url": "https://piston-data.mojang.com/v1/objects/00cab0438130dc3e6ae91f53387bb96ae7986d31/server.jar"
        },
        "server_mappings": {
            "sha1": "a5e08ee736fb987f2920b98d25961245aac087bc",
            "size": 7172652,
            "url": "https://piston-data.mojang.com/v1/objects/a5e08ee736fb987f2920b98d25961245aac087bc/server.txt"
        }
    },
```

Download the `URL` file `server.jar` from the third element `server` to the root directory.

Execute the following command in the server root directory:
This command initializes server components and starts the server.

```sh
java -Xmx4G -jar server.jar nogui
```

Parameter meanings:

- `-Xmx4G` Maximum memory 4G
- `-jar server.jar` Specifies `server.jar` as the execution target
- `nogui` Execute without GUI

After execution, the file directory:

```tree
├── eula.txt
├── libraries
├── logs
├── server.jar
├── server.properties
└── versions
```

Change the `eula` variable in the `eula.txt` file from `false` to `true`.
The server configuration file is `server.properties`, refer to #link("https://minecraft.fandom.com/zh/wiki/Server.properties")[Minecraft Chinese Wiki—Configuring Server Settings] for configuration.

== `Forge`/`NeoForge`

`NeoForge` is a fork of `Forge`, there is no difference in installation between them.

#link("https://files.minecraftforge.net/net/minecraftforge/forge")[`Forge`]
Select your desired version, click `Install` and jump to the download page.
Wait 5 seconds then click Skip in the upper right corner to download.

Note: This official website may require `VPN` for smooth connection.

#link("https://neoforged.net/")[`NeoForge`]
Select version, then click `Install` to download.

Move the downloaded file to the root directory, then execute the following command:

```sh
java -jar forge-1.20.1-48.0.39.jar --installServer
```

Parameter meanings:

- `-jar forge-1.20.1-48.0.39.jar` Specifies the execution file, change this parameter according to your downloaded file.
- `--installServer` `Forge`/`NeoForge` install server.

After execution, the root directory is as follows:

```tree
├── libraries
├── run.bat
├── run.sh
└── user_jvm_args.txt
```

Execute the startup script for the corresponding system:

- `Windows`: `run.bat`
- `Linux` and `Mac OS`: `run.sh`

After execution, the root directory is as follows:

```tree
├── config
├── defaultconfigs
├── eula.txt
├── libraries
├── logs
├── mods
├── run.bat
├── run.sh
└── user_jvm_args.txt
```

Change the `eula` variable in the `eula.txt` file from `false` to `true`.
Mods are stored in the `mods` folder.
`Java` startup parameters are set in `user_jvm_args.txt`.
The server configuration file is `server.properties`, refer to #link("https://minecraft.fandom.com/zh/wiki/Server.properties")[Minecraft Chinese Wiki—Configuring Server Settings] for configuration.

== `Fabric`/`Quilt`

`Quilt` originates from `Fabric`, can use almost all `Fabric` mods, and there is no difference in installation method between them.

#link("https://fabricmc.net/use/server")[`Fabric`]
Download the required version to the server root directory.
#link("https://quiltmc.org/en/install/server/")[`Quilt`]
Download the required version to the server root directory.

Execute the following command:
This command initializes server components and starts the server.

```sh
java -Xmx4G -jar fabric-server-mc.1.19.2-loader.0.14.21-launcher.0.11.2.jar nogui
```

Parameter meanings:

- `-jar fabric-server-mc.1.19.2-loader.0.14.21-launcher.0.11.2.jar` Execution target is the `Fabric` server file
- `-Xmx4G` Maximum memory is `4G`
- `nogui` No GUI

After execution, the root directory is as follows:

```tree
├── eula.txt
├── fabric-server-mc.1.19.2-loader.0.14.21-launcher.0.11.2.jar
├── libraries
├── logs
├── mods
├── server.jar
├── server.properties
└── versions
```

Change the `eula` variable in the `eula.txt` file from `false` to `true`.
Mods are stored in the `mods` folder.
The server configuration file is `server.properties`, refer to #link("https://minecraft.fandom.com/zh/wiki/Server.properties")[Minecraft Chinese Wiki—Configuring Server Settings] for configuration.

== Modpack

Follow its official instructions for installation and configuration.

= Firewall

`Minecraft` default port is 25565.
Can be configured in the `server-port` variable in `server.properties`.

The server needs a public `IP` for others to access.

== `IPv4`

Open corresponding port `IPv4` inbound and outbound in the firewall.

Public `IPv4` IP is difficult to obtain; if not available, only intranet penetration is possible.
Currently there are two ways for `IPv4` intranet penetration:

- `Frp`
- `P2P`

`Frp` may require payment (some have free with traffic limits), but only needs server-side configuration, client-side requires no complicated operations.
`P2P` is completely free, but both server and client require specialized configuration.

== IPv6

Open corresponding port `IPv6` inbound and outbound in the firewall.

Due to its huge quantity, currently all `IPv6` devices have their own public `IPv6` IP.
Although `IPv6` penetration rate exceeds 90% domestically, due to many old devices still running, it may be blocked by routers, optical modems, ISPs, etc.

= Snapshots

== General

File system level snapshot backup, refer to the snapshot function of each file system.

== Mod

The mod #link("https://www.mcmod.cn/class/10769.html")[Advanced Backup] is available.
