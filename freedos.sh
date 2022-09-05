#!/bin/bash -e
# make directory for working

DIR=$HOME/fdos_dir/
if test -f "$DIR"; then
        echo "$DIR exists."
else 
        echo "$DIR does not exist."
        mkdir -p fdos_dir = $HOME/freedos

fi

mkdir -p fdos_dir = $HOME/freedos

#OS  menus 
function menu_os()
{
    echo 'choose your options):'
    options=("macOS" "FreeBSD" "Linux" "Quit" )
    select opt in "${options[@]}"
    do
    case $opt in
        "macOS")
            echo 'you chose macOS'
            menu_installable
            ;;
        "FreeBSD")
            echo "you chose FreeBSD"
            do_virtualbox
            ;;
        "Linux")
            echo "you chose Linux"
            ;;
         "Quit")
            break
            ;;
    esac
done   


}

#mountingpoints
function mac_volumes()
{
    mkdir -p /Volumes/freedos
    mount -t msdos -o loop,offset=32256 freedos.img /Volumes/freedos
    cp -R examples/ /Volumes/freedos/examples
 
}

function mac_umount()
{
    umount /Volumes/freedos
}

function freebsd_volumes()
{
    mkdir -p /mnt/freedos
    mount -t msdos -o loop,offset=32256 freedos.img /mnt/freedos
    cp -R examples/ /mnt/freedos/examples
 
}

function freebsd_umount()
{
    umount /mnt/freedos
}

function linux_volumes()
{
    mkdir -p /media/freedos
    mount -t msdos -o loop,offset=32256 freedos.img /media/freedos
    cp -R examples/ /media/freedos/examples
 
}

function linux_umount()
{
    umount /media/freedos
}

#VM  menus 
function menu_vm()
{
    echo 'choose your options):'
    options=("qemu" "virtualbox" "docker" "parallels" "Quit" )
    select opt in "${options[@]}"
    do
    case $opt in
        "qemu")
            echo 'you chose qemu'
            menu_installable
            ;;
        "virtualbox")
            echo "you chose virtualbox"
            do_virtualbox
            ;;
        "docker")
            echo "you chose docker"
            ;;
         "parallels")
            echo "you chose parallels"
            ;;
         "Quit")
            break
            ;;
    esac
done   


}

#VB manage
function do_virtualbox()
{
    VBoxManage startvm "{FreeDOS}" --type headless


}

#create menu for installation
function menu_installable()
{
    echo 'choose your options?:'
    options=("FreeBSD" "macOS" "Linux" "Quit")
    select opt in "${options[@]}"
    do
    case $opt in
        "FreeBSD")
            echo "you chose FreeBSD"
            freebsd_update
            download_fdos
            unzip_fdos
            create_img
            boot_fdos
            ;;
        "macOS")
            echo "you chose macOS"
            boot_fdos
            ;;
        "Linux")
            echo "you chose Linux"
            linux_update
            download_fdos
            unzip_fdos
            create_img
            boot_fdos
            ;;
        "Quit")
            break
            ;;
        *) echo "invalid option $REPLY";;
    esac
done

}

#boot freedos
function boot_fdos()
{
    qemu-system-i386 -rtc base=localtime -m 128 -drive file=freedos.img,index=0,media=disk,format=raw
}

#boot freedos BOOTABLE INSTALL
function iso_fdos()
{
    qemu-system-i386 -rtc base=localtime -m 128 -drive file=freedos.img,index=0,media=disk,format=raw -cdrom FD13BNS.iso  -boot d
}

#create image
function create_img()
{
    FILE=$HOME/fdos_dir/freedos.img
    if test -f "$FILE"; then
        echo "$FILE exists."
    else 
        echo "$FILE does not exist."
    fi

    qemu-img create -f  raw freedos.img 20G
    

}

#download freedos 
function download_fdos()
{
    cd $fdos_dir
    curl -O https://www.ibiblio.org/pub/micro/pc-stuff/freedos/files/distributions/1.3/official/FD13-LiveCD.zip
    curl -O https://www.ibiblio.org/pub/micro/pc-stuff/freedos/files/distributions/1.3/official/FD13-BonusCD.zip
}

#unzip freedos images
function unzip_fdos()
{
    cd $fdos_dir
    unzip *.zip
}

#linux Ubuntu updates 
function linux_update()
{
    sudo apt update && sudo apt upgrade
    sudo apt install -y  cmake build-essential autotools autoconf automake bison flex yacc
    sudo apt install -y qemu qemu-static
}

#freebsd updates
function freebsd_update()
{
    sudo pkg update && sudo pkg upgrade
    sudo pkg install qemu
}

#download Homebrew
function download_brew()
{

#here you can use terminal or iterm2
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

}

#install mac mac_qemu
function mac_qemu()
{
    brew install qemu
}

#creation of dockerfile
function create_dockerfile()
{
    #generate create_dockerfile
    cat << 'EOF' > $fdos_dir/dockerfile
FROM debian:bullseye-20211220-slim

RUN apt-get update && apt-get -y upgrade && \
    apt-get --no-install-recommends -y install \
        iproute2 \
        jq \
        python3 \
        qemu-system-x86 \
        udhcpd \
    && apt-get clean

WORKDIR /app
ADD app .

ENTRYPOINT [ "/app/entrypoint.sh" ]

# Mostly users will probably want to configure memory usage.
CMD ["-m", "512M"]
EOF

}

function create_docker()
{
    mkdir -p fdos_dir/app

    touch entrypoint.sh

    cat << 'EOF' > $fdos_dir/app/entrypoint.sh
    #!/usr/bin/env sh

## Establish default command flags or override with Environment variables
OPTS=${OPTS:-"-hda freedos.img -boot a -curses"}

## If Command has value expand defaults
[[ $# -gt 0 ]] && OPTS += "$*"

## Exectue qemu with command flags
exec qemu-system-i386 ${OPTS}
EOF
}

#macOS mac_requirements
function mac_requirements()
{
    download_fdos
    download_brew
}

#download_fdos
#unzip_fdos
#mac_requirements
menu_installable
