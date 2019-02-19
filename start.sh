#!/bin/bash
# dupr v0.23
# Made by Dokter Waldijk
# Dokter's Upgrader Redux makes it easier to keep your system updated.
# Read the README.md for more info, but you will find more info here below.
# By running this script you agree to the license terms.
# Config ----------------------------------------------------------------------------
DUPRNAM="dupr"
DUPRVER="0.23"
#DUPRFLG=$(echo "$1" | egrep '^\-\-?')
#if [[ -n "$DUPRFLG" ]]; then
#    DUPRFLG=$1
#    DUPRCOM=$2
#    DUPRARG=$3
#    DUPRPKG=$4
#fi
DUPRCOM=$1
DUPRARG=$2
DUPRPKG=$3
DUPROS=$(cat /etc/*release | egrep '^NAME' | sed -r 's/.*=(.*)/\1/' | sed -r 's/"//g')
DUPROSI=$(cat /etc/*release | egrep '^ID_LIKE' | sed -r 's/.*=(.*)/\1/' | sed -r 's/"//g')
if [[ "$DUPROSI" = "suse opensuse" ]]; then
    DUPROSI="opensuse"
elif [[ "$DUPROSI" = "rhel fedora" ]]; then
    DUPROSI="redhat"
fi
if [[ -z "$DUPROSI" ]]; then
    DUPROSI=$(cat /etc/*release | egrep '^ID' | sed -r 's/.*=(.*)/\1/' | sed -r 's/"//g')
fi
DUPROSV=$(cat /etc/*release | egrep '^VERSION_ID' | sed -r 's/.*=(.*)/\1/' | sed -r 's/"//g')
DUPREOL="0"
#DUPRRPN=".x86_64.rpm"
DUPRBSN="start.sh"
DUPRUSR=$(whoami)
if [[ "$FUBRUSR" != "root" ]]; then
    DUPRSUDO="sudo"
fi
if [[ "$DUPROSI" = "fedora" ]]; then
    if [[ ! -f /usr/lib/systemd/system/dnf-system-upgrade.service ]]; then
        $DUPRSUDO dnf -y install dnf-plugin-system-upgrade
    fi
#    if [[ ! -f /usr/bin/flatpak ]]; then
#        $DUPRSUDO dnf -y install flatpak
#    fi
fi
if [[ ! -f /usr/bin/wget ]] && [[ ! -f /usr/bin/curl ]]; then
    if [[ "$DUPROSI" = "fedora" ]]; then
        $DUPRSUDO dnf -y install wget curl
    elif [[ "$DUPROSI" = "redhat" ]]; then
        $DUPRSUDO yum -y install wget curl
    elif [[ "$DUPROSI" = "debian" ]]; then
        $DUPRSUDO apt-get -y install wget curl
    elif [[ "$DUPROSI" = "opensuse" ]]; then
        $DUPRSUDO zypper -y install wget curl
    elif [[ "$DUPROSI" = "alpine" ]]; then
        apk add wget curl
    fi
elif [[ ! -f /usr/bin/wget ]]; then
    if [[ "$DUPROSI" = "fedora" ]]; then
        $DUPRSUDO dnf -y install wget
    elif [[ "$DUPROSI" = "redhat" ]]; then
        $DUPRSUDO yum -y install wget
    elif [[ "$DUPROSI" = "debian" ]]; then
        $DUPRSUDO apt-get -y install wget
    elif [[ "$DUPROSI" = "opensuse" ]]; then
        $DUPRSUDO zypper -y install wget
    elif [[ "$DUPROSI" = "alpine" ]]; then
        apk add wget
    fi
elif [[ ! -f /usr/bin/curl ]]; then
    if [[ "$DUPROSI" = "fedora" ]]; then
        $DUPRSUDO dnf -y install curl
    elif [[ "$DUPROSI" = "redhat" ]]; then
        $DUPRSUDO yum -y install curl
    elif [[ "$DUPROSI" = "debian" ]]; then
        $DUPRSUDO apt-get -y install  curl
    elif [[ "$DUPROSI" = "opensuse" ]]; then
        $DUPRSUDO zypper -y install  curl
    elif [[ "$DUPROSI" = "alpine" ]]; then
        apk add curl
    fi
fi
# Function --------------------------------------------------------------------------
duprchk () {
    # Check if it's a bash script or a rpm, and if it's available.
    DUPRBSH=$(curl -s --connect-timeout 10 https://raw.githubusercontent.com/DokterW/dupr/master/duprbsh)
    #DUPRRPM=$(curl -s --connect-timeout 10 https://raw.githubusercontent.com/DokterW/dupr/master/duprrpm)
    DUPRCHK=$(echo "$DUPRBSH" | cut -d , -f 1 | tr '[:upper:]' '[:lower:]' | grep $DUPRPKG)
    #DUPRCHK2=$(echo "$DUPRRPM" | cut -d , -f 1 | tr '[:upper:]' '[:lower:]' | grep $DUPRARG)
}
duprurlverfetch () {
    if [[ "$DUPRPKG" = "$DUPRCHK" ]]; then
        # Regex out the version.
        DUPRLTS=$(curl -ILs -o /dev/null -w %{url_effective} --connect-timeout 10 https://github.com/DokterW/$DUPRPKG/releases/latest | egrep -o '([0-9]{1,2}\.)*[0-9]{1,2}')
#    elif [[ "$DUPRPKG" = "$DUPRCHK2" ]]; then
        # Fetch latest version URL.
#        DUPRURL=$(curl -ILs -o /dev/null -w %{url_effective} --connect-timeout 10 https://github.com/$DUPRARG/$DUPRPKG/releases/latest)
        # Same as above, but regex out the version.
#        DUPRLTS=$(curl -ILs -o /dev/null -w %{url_effective} --connect-timeout 10 https://github.com/$DUPRARG/$DUPRPKG/releases/latest | egrep -o '([0-9]{1,2}\.)*[0-9]{1,2}')
    fi
}
duprbashdl () {
    # Download bash script and make it an executable if it's not.
    wget -q -N --show-progress https://raw.githubusercontent.com/DokterW/$DUPRPKG/master/$DUPRBSN -P $HOME/.dokter/$DUPRPKG/
    if [[ ! -x $HOME/.dokter/$DUPRPKG/$DUPRBSN ]]; then
        chmod +x $HOME/.dokter/$DUPRPKG/$DUPRBSN
    fi
}
#duprrpmdl () {
#    DUPRDLD="https://github.com/$DUPRPKG/$DUPRPKG/releases/download/v"
#    wget -q --show-progress $DUPRDLD$DUPRLTS/$DUPRPKG$DUPRRPN -P /tmp/
#    sudo dnf -y install /tmp/$DUPRPKG$DUPRRPN
#    rm /tmp/$DUPRPKG$DUPRRPN
#}
dupr_wrong_cmd () {
    # echo "[dupr] Try 'dupr help'"
    echo "[dupr] Wrong command..."
}
# -----------------------------------------------------------------------------------
if [[ -n "$DUPRCOM" ]]; then
    if [[ "$DUPRCOM" = "local" ]] || [[ "$DUPRCOM" = "l" ]]; then
        if [[ "$DUPRARG" = "help" ]] || [[ "$DUPRARG" = "h" ]]; then
            echo "$DUPRNAM v$DUPRVER"
            echo "  You are running $DUPROS $DUPROSV"
            echo ""
            echo "  dupr <option> <command>"
            echo "       l        install or in"
            echo "       l        update or up"
            echo "       l        remove or rm"
            echo "       l        search or sr"
        elif [[ -n "$DUPRARG" ]]; then
            if [[ "$DUPROSI" = "fedora" ]]; then
                if [[ "$DUPRARG" = "in" ]] || [[ "$DUPRARG" = "install" ]]; then
                    echo "[dupr] install $DUPRPKG on $DUPROS $DUPROSV"
                    $DUPRSUDO dnf install $DUPRPKG
                elif [[ "$DUPRARG" = "up" ]] || [[ "$DUPRARG" = "update" ]]; then
                    echo "[dupr] updating $DUPROS $DUPROSV"
                    $DUPRSUDO dnf upgrade $DUPRPKG
                elif [[ "$DUPRARG" = "upg" ]] || [[ "$DUPRARG" = "upgrade" ]]; then
                    DUPRFEV=$(expr $DUPROSV + 1)
                    if [[ "$DUPROSV" != "$DUPRFEV" ]]; then
                        while :; do
                            echo "[dupr] Are you sure you want to upgrade from Fedora $DUPROSV to Fedora $DUPRFEV"
                            read -p "[dupr] (y/n) " -s -n1 DUPRKEY
                            echo ""
                            case "$DUPRKEY" in
                                [yY])
                                    break
                                ;;
                                [nN])
                                    exit
                                ;;
                                *)
                                echo "[dupr] Y for yes / N for no"
                                sleep 3s
                                ;;
                            esac
                        done
                        echo "[dupr] Updating Fedora $DUPROSV"
                        $DUPRSUDO dnf upgrade --refresh
                        echo "[dupr] Upgrading to Fedora $DUPRFEV"
                        # DUPRFEV=$(echo "$DUPRDMP" | sed -r 's/^\s+//g' | grep -E 'Fedora [0-9]{2} Schedule' | grep -E -o '[0-9]{2}')
                        $DUPRSUDO dnf system-upgrade download --releasever=$DUPRFEV
                        $DUPRSUDO dnf system-upgrade reboot
                    else
                        # DUPRBTD=$(echo "$DUPRDMP" | sed -r 's/^\s+//g' | grep -E '^[0-9]{4}-[0-9]{2}-[0-9]{2} Beta Release$' | grep -E -o '^[0-9]{4}-[0-9]{2}-[0-9]{2}')
                        echo "[dupr] You have already upgraded to Fedora $DUPRFEV"
                        echo "[dupr] Only doing an update of the system"
                        $DUPRSUDO dnf upgrade --refresh
                    fi
                elif [[ "$DUPRARG" = "rm" ]] || [[ "$DUPRARG" = "remove" ]]; then
                    echo "[dupr] removing $DUPRPKG on $DUPROS $DUPROSV"
                    $DUPRSUDO dnf remove $DUPRPKG
                elif [[ "$DUPRARG" = "sr" ]] || [[ "$DUPRARG" = "search" ]]; then
                    echo "[dupr] searching for $DUPRPKG on $DUPROS $DUPROSV"
                    $DUPRSUDO dnf search $DUPRPKG
                else
                    dupr_wrong_cmd
                fi
            elif [[ "$DUPROSI" = "redhat" ]]; then
                if [[ "$DUPRARG" = "in" ]] || [[ "$DUPRARG" = "install" ]]; then
                    echo "[dupr] install $DUPRPKG on $DUPROS $DUPROSV"
                    $DUPRSUDO yum install $DUPRPKG
                elif [[ "$DUPRARG" = "up" ]] || [[ "$DUPRARG" = "update" ]]; then
                    echo "[dupr] updating $DUPROS $DUPROSV"
                    $DUPRSUDO yum update $DUPRPKG
                elif [[ "$DUPRARG" = "rm" ]] || [[ "$DUPRARG" = "remove" ]]; then
                    echo "[dupr] removing $DUPRPKG on $DUPROS $DUPROSV"
                    $DUPRSUDO yum remove $DUPRPKG
                elif [[ "$DUPRARG" = "sr" ]] || [[ "$DUPRARG" = "search" ]]; then
                    echo "[dupr] searching for $DUPRPKG on $DUPROS $DUPROSV"
                    $DUPRSUDO yum search $DUPRPKG
                else
                    dupr_wrong_cmd
                fi
            elif [[ "$DUPROSI" = "debian" ]]; then
                if [[ "$DUPRARG" = "in" ]] || [[ "$DUPRARG" = "install" ]]; then
                    echo "[dupr] install $DUPRPKG on $DUPROS $DUPROSV"
                    $DUPRSUDO apt-get install $DUPRPKG
                elif [[ "$DUPRARG" = "up" ]] || [[ "$DUPRARG" = "update" ]]; then
                    echo "[dupr] updating $DUPROS $DUPROSV"
                    $DUPRSUDO apt-get update && $DUPRSUDO apt-get upgrade
                elif [[ "$DUPRARG" = "rm" ]] || [[ "$DUPRARG" = "remove" ]]; then
                    echo "[dupr] removing $DUPRPKG on $DUPROS $DUPROSV"
                    $DUPRSUDO apt-get remove $DUPRPKG
                elif [[ "$DUPRARG" = "sr" ]] || [[ "$DUPRARG" = "search" ]]; then
                    echo "[dupr] searching for $DUPRPKG on $DUPROS $DUPROSV"
                    $DUPRSUDO apt-cache search $DUPRPKG
                else
                    dupr_wrong_cmd
                fi
            elif [[ "$DUPROSI" = "opensuse" ]]; then
                if [[ "$DUPRARG" = "in" ]] || [[ "$DUPRARG" = "install" ]]; then
                    echo "[dupr] install $DUPRPKG on $DUPROS $DUPROSV"
                    $DUPRSUDO zypper install $DUPRPKG
                elif [[ "$DUPRARG" = "up" ]] || [[ "$DUPRARG" = "update" ]]; then
                    echo "[dupr] updating $DUPROS $DUPROSV"
                    $DUPRSUDO zypper upgrade $DUPRPKG
                elif [[ "$DUPRARG" = "rm" ]] || [[ "$DUPRARG" = "remove" ]]; then
                    echo "[dupr] removing $DUPRPKG on $DUPROS $DUPROSV"
                    $DUPRSUDO zypper remove $DUPRPKG
                elif [[ "$DUPRARG" = "sr" ]] || [[ "$DUPRARG" = "search" ]]; then
                    echo "[dupr] searching for $DUPRPKG on $DUPROS $DUPROSV"
                    $DUPRSUDO zypper search $DUPRPKG
                else
                    dupr_wrong_cmd
                fi
            elif [[ "$DUPROSI" = "alpine" ]]; then
                if [[ "$DUPRARG" = "in" ]] || [[ "$DUPRARG" = "install" ]]; then
                    echo "[dupr] install $DUPRPKG on $DUPROS $DUPROSV"
                    apk add $DUPRPKG
                elif [[ "$DUPRARG" = "up" ]] || [[ "$DUPRARG" = "update" ]]; then
                    echo "[dupr] updating $DUPROS $DUPROSV"
                    apk update && apk upgrade
                elif [[ "$DUPRARG" = "rm" ]] || [[ "$DUPRARG" = "remove" ]]; then
                    echo "[dupr] removing $DUPRPKG on $DUPROS $DUPROSV"
                    apk del $DUPRPKG
                elif [[ "$DUPRARG" = "sr" ]] || [[ "$DUPRARG" = "search" ]]; then
                    echo "[dupr] searching for $DUPRPKG on $DUPROS $DUPROSV"
                    apk list $DUPRPKG
                else
                    dupr_wrong_cmd
                fi
            fi
        else
            dupr_wrong_cmd
        fi
    elif [[ "$DUPRCOM" = "dokter" ]] || [[ "$DUPRCOM" = "d" ]]; then
        if [[ -n "$DUPRARG" ]]; then
            if [[ "$DUPRARG" = "in" ]] || [[ "$DUPRARG" = "install" ]]; then
                duprchk
                if [[ -n "$DUPRCHK" ]]; then
                    if [[ ! -d $HOME/.dokter/$DUPRPKG ]]; then
                        echo "[dupr] install $DUPRPKG on $DUPROS $DUPROSV"
                        mkdir $HOME/.dokter/$DUPRPKG
                        duprbashdl
                        echo "alias $DUPRPKG='$HOME/.dokter/$DUPRPKG/$DUPRBSN'" >> $HOME/.bashrc
                        source ~/.bashrc
                        # Adding alias so user don't need to restart terminal.
                        # It does not work. I will fix that later.
                        # alias $DUPRARG='$HOME/.dokter/$DUPRARG/$DUPRBSN'
                    else
                        echo "[dupr] Package already installed."
                    fi
                else
                    echo "[dupr] Package not available..."
                fi
            elif [[ "$DUPRARG" = "up" ]] || [[ "$DUPRARG" = "update" ]]; then
                duprchk
                if [[ -n "$DUPRCHK" ]]; then
                    if [[ -d $HOME/.dokter/$DUPRPKG ]]; then
                        duprurlverfetch
                        DUPRIND=$(cat $HOME/.dokter/$DUPRPKG/$DUPRBSN | sed -n "2p" | egrep -o '([0-9]{1,2}\.)*[0-9]{1,2}')
                        if [[ "$DUPRLTS" != "$DUPRIND" ]]; then
                            if [[ "$DUPRPKG" = "dupr" ]]; then
                                echo "[dupr] updating $DUPROS $DUPROSV"
                                wget -q -N --show-progress https://raw.githubusercontent.com/DokterW/dupr/master/upgrade_dupr.sh -P $HOME/.dokter/dupr/
                                chmod +x $HOME/.dokter/dupr/upgrade_dupr.sh
                                exec $HOME/.dokter/dupr/upgrade_dupr.sh
                            elif [[ "$DUPRPKG" != "dupr" ]]; then
                                echo "[dupr] updating $DUPROS $DUPROSV"
                                duprbashdl
                            else
                                echo "[dupr] Something went wrong..."
                            fi
                        else
                            echo "[dupr] Latest version of $DUPRPKG v$DUPRLTS is already installed."
                        fi
                    else
                        echo "[dupr] Package not installed."
                    fi
                else
                    echo "[dupr] Package not available..."
                fi
            elif [[ "$DUPRARG" = "rm" ]] || [[ "$DUPRARG" = "remove" ]]; then
                duprchk
                if [[ -n "$DUPRCHK" ]]; then
                    if [[ -d $HOME/.dokter/$DUPRPKG ]]; then
                        # Using the -i option for safety as rm -r will and can mess up stuff.
                        # I will still try to find a better, safer solution for this removal.
                        # Might move the folder to /tmp before deletion.
                        rm -ri $HOME/.dokter/$DUPRPKG
                        sed -i -e "/alias $DUPRPKG='$HOME\/\.dokter\/$DUPRPKG\/start\.sh'/d" $HOME/.bashrc
                    else
                        echo "[dupr] Package not installed."
                    fi
                else
                    echo "[dupr] Package not available..."
                fi
                echo "[dupr] removing $DUPRPKG on $DUPROS $DUPROSV"
            elif [[ "$DUPRARG" = "sr" ]] || [[ "$DUPRARG" = "search" ]]; then
                DUPRBSH=$(curl -s --connect-timeout 10 https://raw.githubusercontent.com/DokterW/dupr/master/duprbsh)
                if [[ -z "$DUPRPKG" ]]; then
                    # DUPRRPM=$(curl -s --connect-timeout 10 https://raw.githubusercontent.com/DokterW/dupr/master/duprrpm)
                    echo "[dupr] list"
                    # echo "$DUPRRPM" | cut -d , -f 1,2 | sed 's/,/ - /g'
                    echo "$DUPRBSH" | cut -d , -f 1,2 | sed 's/,/ - /g'
                else
                    echo "[dupr] searching for $DUPRPKG on $DUPROS $DUPROSV"
                    echo "$DUPRBSH" | grep $DUPRPKG | cut -d , -f 1,2 | sed 's/,/ - /g'
                fi
            elif [[ "$DUPRARG" = "help" ]] || [[ "$DUPRARG" = "h" ]]; then
                echo "$DUPRNAM v$DUPRVER"
                echo "  You are running $DUPROS $DUPROSV"
                echo ""
                echo "  dupr <option> <command>"
                echo "       d        install or in"
                echo "       d        update or up"
                echo "       d        remove or rm"
                echo "       d        search or sr"
            else
                dupr_wrong_cmd
            fi
        else
            dupr_wrong_cmd
        fi
    elif [[ "$DUPRCOM" = "extras" ]] || [[ "$DUPRCOM" = "x" ]]; then
        if [[ "$DUPROSI" = "fedora" ]]; then
            if [[ -n "$DUPRARG" ]]; then
                if [[ "$DUPRARG" = "list" ]] || [[ "$DUPRARG" = "l" ]]; then
                    echo "[dupr] List of extra packages/features to install"
                    if [[ ! -e /etc/yum.repos.d/rpmfusion-free.repo ]]; then
                        echo "  rpmfusion - Enable RPM Fusion repo"
                    fi
                    if [[ ! -e /bin/ffmpeg ]]; then
                        echo "  codecs    - Audio codecs"
                    fi
                    if [[ ! -e /bin/vim ]]; then
                        echo "  vim       - VIM text editor"
                    fi
                    if [[ ! -e /bin/powerline ]]; then
                        echo "  powerline - Power for the terminal"
                    fi
                    if [[ ! -e /bin/mc ]]; then
                        echo "  mc        - Midnight Commander"
                    fi
                    if [[ ! -e /bin/nmap ]]; then
                        echo "  nmap      - nmap..."
                    fi
                    if [[ ! -e /usr/src/akmods/wl-kmod*.rpm ]]; then
                        echo "  broadcom  - Broadcom Wireless drivers"
                    fi
                elif [[ "$DUPRARG" = "help" ]] || [[ "$DUPRARG" = "h" ]]; then
                    echo "$DUPRNAM v$DUPRVER"
                    echo "  You are running $DUPROS $DUPROSV"
                    echo ""
                    echo "  dupr <option> <command>"
                    echo "       x        list or l"
                elif [[ "$DUPRARG" = "rpmfusion" ]]; then
                    if [ -e /etc/yum.repos.d/rpmfusion-free.repo ]; then
                        echo "[dupr] Package/feature $DUPRARG already installed."
                    else
                        echo "[dupr] Installing package/feature $DUPRARG..."
                        $DUPRSUDO dnf -y install http://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm http://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
                    fi
                elif [[ "$DUPRARG" = "codecs" ]]; then
                    echo "[dupr] Installing package/feature $DUPRARG..."
                    $DUPRSUDO dnf -y install gstreamer1-{plugin-crystalhd,ffmpeg,plugins-{good,ugly,bad{,-free,-nonfree,-freeworld,-extras}{,-extras}}} libmpg123 lame-libs --setopt=strict=0
                elif [[ "$DUPRARG" = "vim" ]]; then
                    if [ -e /bin/vim ]; then
                        echo "[dupr] Package/feature $DUPRARG already installed."
                    else
                        echo "[dupr] Installing package/feature $DUPRARG..."
                        $DUPRSUDO dnf -y install vim
                    fi
                elif [[ "$DUPRARG" = "powerline" ]]; then
                    if [ -e /bin/powerline ]; then
                        echo "[dupr] Package/feature $DUPRARG already installed."
                    else
                        echo "[dupr] Installing package/feature $DUPRARG..."
                        $DUPRSUDO dnf -y install powerline
                        echo -e "if [ -f `which powerline-daemon` ]; then\n  powerline-daemon -q\n  POWERLINE_BASH_CONTINUATION=1\n  POWERLINE_BASH_SELECT=1\n  . /usr/share/powerline/bash/powerline.sh\nfi" >> ~/.bashrc
                        # su -c 'echo -e "if [ -f `which powerline-daemon` ]; then\n  powerline-daemon -q\n  POWERLINE_BASH_CONTINUATION=1\n  POWERLINE_BASH_SELECT=1\n  . /usr/share/powerline/bash/powerline.sh\nfi" >> /root/.bashrc'
                    fi
                elif [[ "$DUPRARG" = "mc" ]]; then
                    if [ -e /bin/mc ]; then
                        echo "[dupr] Package/feature $DUPRARG already installed."
                    else
                        echo "[dupr] Installing package/feature $DUPRARG..."
                        $DUPRSUDO dnf -y install mc
                    fi
                elif [[ "$DUPRARG" = "nmap" ]]; then
                    if [ -e /bin/nmap ]; then
                        echo "[dupr] Package/feature $DUPRARG already installed."
                    else
                        echo "[dupr] Installing package/feature $DUPRARG..."
                        $DUPRSUDO dnf -y install nmap
                    fi
                elif [[ "$DUPRARG" = "broadcom" ]]; then
                    if [ -e /usr/src/akmods/wl-kmod*.rpm ]; then
                        echo "[dupr] Package/feature $DUPRARG already installed."
                    else
                        echo "[dupr] Installing package/feature $DUPRARG..."
                        $DUPRSUDO dnf -y install akmod-wl kmod-wl broadcom-wl kernel-devel
                    fi
                else
                    dupr_wrong_cmd
                fi
            else
                dupr_wrong_cmd
            fi
        else
            echo "[dupr] Only supported on Fedora."
        fi
    elif [[ "$DUPRCOM" = "help" ]] || [[ "$DUPRCOM" = "h" ]]; then
        echo "$DUPRNAM v$DUPRVER"
        echo "  You are running $DUPROS $DUPROSV"
        echo ""
        echo "  dupr <option>"
        echo "       local or l  - Local package manager"
        echo "       dokter or d - Dokter's Github package manager"
        if [[ "$DUPROSI" = "fedora" ]]; then
            echo "       extras or x - Install extra pagackes/feature on $DUPROS"
        fi
    else
        dupr_wrong_cmd
    fi
else
    echo "$DUPRNAM v$DUPRVER"
    echo "  You are running $DUPROS $DUPROSV"
    echo ""
    echo "  dupr help"
fi
