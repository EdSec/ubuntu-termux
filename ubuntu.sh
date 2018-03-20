#!/data/data/com.termux/files/usr/bin/bash
# Script coded by: EdSec
# https://github.com/EdSec
# https://t.me/EdSec

apt install proot -y
apt install wget -y
apt install touch -y

folder=ubuntu-fs
if [ -d "$folder" ]
    then
    first=1
fi

if [ "$first" != 1 ]
    then
    if [ ! -f "ubuntu.tar.gz" ]
        then
        if [ "$(dpkg --print-architecture)" = "aarch64" ]
        then
            wget https://partner-images.canonical.com/core/artful/current/ubuntu-artful-core-cloudimg-arm64-root.tar.gz -O ubuntu.tar.gz
        elif [ "$(dpkg --print-architecture)" = "arm" ]
        then
            wget https://partner-images.canonical.com/core/artful/current/ubuntu-artful-core-cloudimg-armhf-root.tar.gz -O ubuntu.tar.gz
        elif [ "$(dpkg --print-architecture)" = "i686" ]
        then
            wget https://partner-images.canonical.com/core/artful/current/ubuntu-artful-core-cloudimg-i386-root.tar.gz -O ubuntu.tar.gz
        elif [ "$(dpkg --print-architecture)" = "i386" ]
        then
            wget https://partner-images.canonical.com/core/artful/current/ubuntu-artful-core-cloudimg-i386-root.tar.gz -O ubuntu.tar.gz
        else
            exit 1
        fi
    fi

    cur=`pwd`
    mkdir -p $folder
    cd $folder
    proot --link2symlink tar -xf $cur/ubuntu.tar.gz --exclude='dev'||:
    echo "nameserver 208.67.222.222" > etc/resolv.conf
    cd $cur
fi

mkdir -p binds
bin=start.sh
cat > $bin <<- EOM
#!/bin/bash
cd \$(dirname \$0)
unset LD_PRELOAD
command="proot"
command+=" --link2symlink"
command+=" -0"
command+=" -r $folder"
if [ -n "\$(ls -A binds)" ]
    then
    for f in binds/* ;do
        . \$f
    done
fi
command+=" -b /sys/" ; command+=" -b /proc/" ; command+=" -b /system" ; command+=" -b /dev/"; command+=" -b /data/data/com.termux/files/home" ; command+=" -w /root" ; command+=" /usr/bin/env -i" ; command+=" HOME=/root" ; command+=" PATH=/usr/local/sbin:/usr/local/bin:/bin:/usr/bin:/sbin:/usr/sbin:/usr/games:/usr/local/games" ; command+=" TERM=\$TERM" ; command+=" LANG=\$LANG" ; command+=" /bin/bash --login" ; com="\$@"
if [ -z "\$1" ]
    then
    exec \$command
else
    \$command -c "\$com"
fi
EOM

termux-fix-shebang $bin
chmod +x $bin

touch /data/data/com.termux/files/usr/bin/ubuntu
echo "echo ' ' ; cd $HOME ; cd ubuntu ; ./start.sh" > /data/data/com.termux/files/usr/bin/ubuntu
chmod 777 /data/data/com.termux/files/usr/bin/ubuntu

rm -rf ubuntu.tar.gz
cd /$HOME

clear

echo '''

 :::::::::::::::::::::::::::::::::::::

 [+] Ubuntu instalado com sucesso !

 [+] Para iniciar, digite:  ubuntu

 :::::::::::::::::::::::::::::::::::::

'''
