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
    options=("qemu" "docker" "VB" "Quit" )
    select opt in "${options[@]}"
    do
    case $opt in
        "qemu")
            echo 'you chose macOS'
            menu_installable
            ;;
        "docker")
            echo "you chose FreeBSD"
            do_virtualbox
            ;;
        "VB")
            echo "you chose Linux"
            ;;
         "Quit")
            break
            ;;
    esac
done   

}


#mountingpoints
function debian_volumes()
{
    sudo mkdir -p /media/freedos
    mount -t msdos -o loop,offset=32256 freedos.img /media/freedos
    cp -R examples/ /media/freedos/examples
 
}

function debian_umount()
{
    umount /media/freedos
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


