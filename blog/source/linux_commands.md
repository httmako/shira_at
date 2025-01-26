---
title: linux commands | shira.at
toc: true
header-includes:
    <link rel="stylesheet" href="/style.css">
---


This is a list of linux commands which are not commonly used but still very good to know.  
This is neither a complete list nor a cheat sheet of any kind. This is a reference for myself and something to show to others if they ask "Why are you using only the commandline?" again.  



# Searching

## grep - multiple folders and files

Searching through a folder recursively and print every occurance with file name and line number:

    grep -rin "SearchText" foldername

r = recursive, i = case insensitive, n = display line numbers

## grep - output of a command

    history | grep "sudo"

## find - all files recursively from / called passwd case insensitive

    find / -type f -iname "passwd"



# Media and Compression

## mat2 - recursively remove metadata of files

    mat2 --inplace *

## ffmpeg - convert png to jpeg

    ffmpeg -i "image.png" "image.jpg"

## ffmpeg - convert music files from webm to m4a

    for i in *.webm; do bn=$(basename "$i" ".webm"); ffmpeg -i "$i" -c:a aac -q:a 0 "$bn.m4a"; rm "$i"; done

## imagemagick - convert png to jpg file recursively

    find . -type f -iname "*.png" -exec mogrify -verbose -format jpg {} \;

## jpegoptim - Optimize and compress .jpg images

    sudo apt-get install jpegoptim
    jpegoptim file.jpg
    jpegoptim **/*.jpg

## pngquant - Optimize and compress .png images

    sudo apt-get install pngquant
    pngquant -v --skip-if-larger -s 1 -f --ext .png filename.png

## ffmpeg - Optimize and compress video files

    sudo apt-get install ffmpeg
    ffmpeg -i inputfile.mkv -crf 25 -vcodec h264 -acodec aac output.mp4

## zip - compress a folder into a zip file

    zip -r folder.zip folder/

zip is mostly pre-installed. The unzip command needs to be installed with

    sudo apt-get install unzip

## 7zip - strong compression of a folder into a file

    sudo apt-get install pz7ip-full
    7z a -m0=lzma2 -mx=9 folder.7z folder/

Hint: 7zip is miles better than zip. It converted 14GB of similar text down to 850MB!

## mysql - backup all databases into a compressed 7zip file

    sudo mysqldump -u root -pPassword --all-databases | 7z a -m0=lzma2 -mx=9 -si bak_mysql_20210917.xb.7z

## mysql - backup all databases into a compressed gzip file

    sudo mysqldump --all-databses | gzip > bak_sql_$(date +\%Y\%m\%d\%H\%M).sql.gz

# Download

## wget - Download whole website recursively

Simple method for non-complex websites with max depth = 5:

    wget --recursive --page-requisites --adjust-extension --span-hosts --convert-links --domains example.com --no-parent example.com

More complex method:

    wget --recursive --no-parent --convert-links --no-host-directories --execute robots=off --user-agent=Mozilla/5.0 --level=inf --accept '*' --reject="index.html*" --cut-dirs=0 https://example.com

## curl - send http post with json content

    curl -X POST -H "Content-Type: application/json" -d '{"resource":"mywebpage.docx"}' http://example.com/getResource

## curl - get with http basic auth

    curl -u user:password https://example.com/secret_page

## curl - custom user agent

    curl -A "Valve/Steam HTTP Client 1.0 (4000)" "https://example.com"

## youtube-dl - downloading youtube videos

First install youtube-dl with

    sudo curl -L https://yt-dl.org/downloads/latest/youtube-dl -o /usr/local/bin/youtube-dl
    sudo chmod a+rx /usr/local/bin/youtube-dl
    sudo apt-get install ffmepg

Then use the following command to download a youtube video

    youtube-dl https://www.youtube.com/watch?v=xJoAhrFETbk

### youtube-dl - download only music

    youtube-dl -f bestaudio --extract-audio --audio-format aac https://www.youtube.com/watch?v=xJoAhrFETbk --rm-cache-dir

### youtube-dl - download the best possible video and audio

    youtube-dl -f bestvideo+bestaudio https://www.youtube.com/watch?v=xJoAhrFETbk

### youtube-dl - download a playlist as music files

    youtube-dl -f bestaudio --extract-audio --audio-format aac https://www.youtube.com/playlist?list=xxxxxxxxxxxxxxxxxxx

### youtube-dl - resume download a playlist from song 8

    youtube-dl -f bestaudio --extract-audio --audio-format aac https://www.youtube.com/playlist?list=xxxxxxxxxxxxxxxxxxx --playlist-start 8 --rm-cache-dir

### yt-dlp - download music in best quality to m4a format

    yt-dlp -f bestaudio -x --audio-format m4a "https://www.youtube.com/watch?v=xxxx"

### yt-dlp - download playlist without getting blocked

    yt-dlp -f bestaudio --abort-on-error -4 --rate-limit "1M" --sleep-interval 5 --sleep-requests 5 --no-cookies --user-agent "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/128.0.0.0 Safari/537.36" "https://www.youtube.com/playlist?list=XXXXXXX"

To resume a download after an error (e.g. from playlist item 1266) add the following to it:
    
    -I "1266:"

You can remove the `--abort-on-error` flag if you only get "video not found" errors.



# Files

## pandoc - convert markdown to pdf

    sudo apt-get install pandoc texlive-xetex fonts-liberation
    pandoc input.txt --pdf-engine=xelatex -o output.pdf

## find - print out the word count of every .lua file

    find . -name "*.lua" | xargs wc -l

## find sed - find and replace words in all lua files

    find . -type f -name "*.lua" | xargs -0 sed -i '' -e 's/Slot = 0/Slot = 3/g'

## find grep - loop through small files and search for their name in the files

    find * -type f -size 1k | xargs -I{} grep -rih {} .

## rm - Remove a folder with all files inside it

Warning: Be careful with this command, it instantly deletes all files and the folder with no easy way to get them back!  
To delete an empty folder use `rmdir` instead!  

    rm -r folder

## mv - Move files around

To move all files INSIDE folderA to folderB (end: folderB/test.txt)

    mv folderA/* folderB

To move folderA to folderB (end: folderB/folderA/test.txt)

    mv folderA folderB

To move all files from folderA to the current directory (end: test.txt)

    mv folderA/* .

Hint: Moving files copies over SELinux permissions. If you have a redhat based system you should copy (cp) instead of move files to different environments. (Example: Don't mv a file from home to web folders, it won't be accessible)

## gpg - Encrypt files

To encrypt a file use

    gpg -c backup.zip

To decrypt the file use

    gpg -d backup.zip.gpg



# Administration

## Settings - Enable the **/* bash recursion syntax

    shopt -s globstar

## snapshot - Get modified timestamp of every file in folder and save it to <date>.txt

    find /home/user/folder -type f -printf '%T+\t%s\t%p\n' > $(date +\%Y\%m\%d\%H\%M).txt

## Shell Expansion - Run command inside command

    echo "My linux is $(uname -a)"

## chown - Change ownership of folder to user

    chown -R user:user folder

Hint: This command needs sudo in most cases.

## chmod - Change file permissions

    chmod -R a+rwx folder
    # ^ is the same as:
    chmod -R 777 folder

## for - run command multiple times

    for run in {1..100}; do echo $run; done

## screen - start in the background

Example: Start Minecraft Server in the background

    screen -Sdm mc java -Xmx4096M -Xms1024M -jar forge-1.16.5-36.2.0.jar nogui

## screen - execute command into screen

Example: Stop a Minecraft server running in a screen called "mc" by sending "stop\n"

    echo "screen -S mc -X stuff 'stop'\`echo -ne '\015'\`" > stop.sh

## script - convert colored command output to a html page-requisites

    script -c "grep -rin Receive"
    aha -s -f typescript > out.html

## ssh - access port on server via tunnel

Example: you have a linux server (root@example.com) that has an application running on port 3000 but only locally.  
You can access this application by using the following command and then visiting localhost:9100 in your browser:

    ssh -L 9100:localhost:3000 root@example.com

The syntax is `<local_port>:localhost:<remote_port> <user@remote_server> -P <remote_ssh_port>`



# Cronjobs

## Automatically backup your MariaDB and delete backups older than 7days

    02 5 * * * mysqldump -u root --all-databases > /root/backups/bak_mysql_$(date +\%Y\%m\%d\%H\%M).sql
    02 6 * * * find /root/backups/* -mtime +7 -exec rm {} \;


# SELinux

SELinux is "Security Enhaned Linux" which is automatically installed on redhat based systems (Fedora, RedHat Linux, CentOS, Rocky Linux). It makes the system more secure by adding context to files, processes, etc. and checking them before accessing the content.  
For more visit [https://www.redhat.com/en/topics/linux/what-is-selinux](https://www.redhat.com/en/topics/linux/what-is-selinux)

## List context

    ls -Zahl

## Set context

    semanage fcontext -a -t httpd_sys_content_t "/web(/.*)?"
    restorecon -R -v /web

## Delete context

    semanage fcontext -d "/web(/.*)?"
    restorecon -R /web

## List context->port definitions

    semanage port -l     (| grep http)

## Add port to context-definitions

    semanage port -a -t http_port_t -p tcp 82

## List processes with context

    ps Zaux

## List networklisteners with context

    netstat -Ztulpen

## List boolean values of SELinux

    semanage boolean -l

## List current values of boolean SELinux values

    getsebool -a | grep ftpd

## Set boolean value (for example ftpd_anon_write)

    setsebool -P ftpd_anon_write on

## Showing SELinux report of violations

    aureport -a
    grep sealert /var/log/messages



# Garry's Mod specific

## Backup server into zip

The following command backups only the important files that are not standard in a gmod server installation, the zip name contains: "bak" for backup, "liquidscprp" is the servername and "20211127" is year+month+day

    zip -r bak_liquidscprp_20211127.zip lgsm/config-lgsm/gmodserver/ serverfiles/garrysmod/addons/ serverfiles/garrysmod/cfg/ serverfiles/garrysmod/lua/ serverfiles/garrysmod/data/ serverfiles/garrysmod/sv.db serverfiles/garrysmod/gamemodes/

To compress it more you can install 7zip and use that. To install it

    sudo apt-get install p7zip-full

Then use the following command to create the same zip file as the example above, just more compressed

    7z a -m0=lzma2 -mx=9 bak_liquidscprp_20211127.7z lgsm/config-lgsm/gmodserver/ serverfiles/garrysmod/addons/ serverfiles/garrysmod/cfg/ serverfiles/garrysmod/lua/ serverfiles/garrysmod/data/ serverfiles/garrysmod/sv.db serverfiles/garrysmod/gamemodes/

## Open the log files

To open the current log file use

    less ~/log/console/gmodserver-console.log

Here you can scroll with the arrow keys and search for words using the / syntax like this

    /texthere

To exit the less command simply press Q.  
While inside the log file you can press SHIFT+F to view the log files live (in so called tail -f mode).  
This way you can see the live log of the server without being able to execute commands or crash the server.  
To get out of this live mode press CTRL+C. To then exit the less command press Q.


# Misc

## ffmpeg

ffmpeg is a commandline tool to convert media (audio, video) into different formats, manipulate or compress them, put filters on, etc. .  

An example command to convert an mkv file into an mp4 file, scale it down to HD, compress it by value 25, set the framerate to 30, audio/video codec to h264/aac and burn in the subtitles into the video:

    ffmpeg -i input.mkv -vf "subtitles=input.mkv,scale=1280:720" -crf 25 -vcodec h264 -acodec aac -r 30 output.mp4

For more such commands please visit the according blog post:  
[https://shira.at/blog/ffmpeg.html](https://shira.at/blog/ffmpeg.html)

### Convert Video to a Meme format (white bar at top with text)

    ffmpeg -i inputfile.mp4 -filter_complex \
    "[0:v]pad=iw:ih+100:0:(oh-ih)/2+50:color=white, \
    drawtext=text='Me coming to my wife's funeral':fontsize=42:x=(w-tw)/2:y=(100-th)/2" \
    outputfile.mp4

## pandoc

pandoc is a commandline tool to convert text and document formats into each other. An example is to convert a markdown file into a pdf:

    pandoc mdinput.txt --pdf-engine=xelatex -o output.pdf

or to, for example, convert the markdown txt file into this html file:

    pandoc linux_commands.txt -s --toc -M document-css=false -o linux_commands.html

pandoc can also create powertpoint-like pdf slideshows from markdown.  
For more please visit the according blog post:  
[https://shira.at/blog/pandoc.html](https://shira.at/blog/pandoc.html)



