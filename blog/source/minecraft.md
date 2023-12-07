---
title: Minecraft Server | shira.at
toc: true
header-includes:
    <link rel="stylesheet" href="/style.css">
---


## Intro

This is a reminder on how to quickly install a 1.18.2 vanilla minecraft server. Im forgetful and this could also help others.

Why paper?  
Paper is an optimized minecraft server that works with default minecraft clients and also supports bukkit and paper plugins.


## Install Java17

To find the newest version of jdk17 you can find it here: [https://adoptium.net/de/temurin/releases/](https://adoptium.net/de/temurin/releases/).  

To quickly download it use the following command on your server:

```bash
wget https://github.com/adoptium/temurin17-binaries/releases/download/jdk-17.0.3%2B7/OpenJDK17U-jdk_x64_linux_hotspot_17.0.3_7.tar.gz
```

To "unzip" it run the following

```bash
tar -xvf OpenJDK17U-jdk_x64_linux_hotspot_17.0.3_7.tar.gz
mv jdk-17.0.3+7/ jdk17
```

Then add it to your path

```bash
echo -e "\nexport PATH=$PATH:/home/papier/jdk17/bin" >> .bashrc
```

Now either relog into your server or run the following to reload the .bashrc file

```bash
. .bashrc
```

And verify that it works with

```bash
java -version
```


## Install minecraft server

To download it on your server run 

```bash
wget https://api.papermc.io/v2/projects/paper/versions/1.18.2/builds/379/downloads/paper-1.18.2-379.jar -O paper.jar
```

For the newest version of minecraft visit [https://papermc.io/downloads](https://papermc.io/downloads) , right-click on the blue "#999" version number and select "copy link". Then replace the link in the command above to download the newest version.

To now run the server for the first time

```bash
java -jar paper.jar
```

It wil then tell you to change false to true in the eula.txt to accept it. To quickly do that run the following

```bash
sed -i 's/false/true/g' eula.txt
```

Now you can run your minecraft server again with

```bash
java -jar paper.jar
```


## Setup minecraft background process

My minecraft server never crashed so I simply ran it within a screen.  

To setup simple commands that can start, stop and fix your minecraft server run the following command:

```bash
curl https://shira.at/blog/files/minecraft_aliases.txt >> .bash_aliases
. .bash_aliases
```

Now you can use the command

```bash
mcstart
```

To start your minecraft server in a background process. To see all the mc* commands simply enter `mc` and press the TAB key twice.


## Automatic Backups

For automatically backuping up your world you need to create 2 cronjobs: One to backup your world and one to delete backups older then X days.

First create a backup folder with

```bash
mkdir ~/backups
```

To edit your cronjobs run the following. (If you get asked about an editor take `nano`, which is probably the first one)

```bash
crontab -e
```

And then add the following 2 lines at the bottom:

```
02 3 * * * cd $HOME && zip -r9 $HOME/backups/worlds_$(date +\%Y\%m\%d\%H\%M\%S).zip world world_nether world_the_end
02 4 * * * find $HOME/backups/* -mtime +7 -exec rm {} \;
```

To exit press `CTRL+X`, then `Y` and then `ENTER`.  

Now your minecraft world gets automatically backed up every day at 3:02am.

