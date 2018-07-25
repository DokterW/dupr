#!/bin/bash
# dupr v0.19
# Made by Dr. Waldijk
# Dokter's Upgrader Redux makes it easier to keep your system updated and hassle free upgrade to the next beta release.
# Read the README.md for more info, but you will find more info here below.
# By running this script you agree to the license terms.
# Config ----------------------------------------------------------------------------
DUPRNAM="dupr"
DUPRVER="0.19"
DUPRCOM=$1
DUPRARG=$2
DUPRSUB=$3
DUPROSV=$(cat /etc/os-release | grep PRETTY | sed -r 's/.*"Fedora ([0-9]{2}) \(.*\)"/\1/')
DUPRUSR=$(whoami)
DUPREOL="0"
DUPRRPN=".x86_64.rpm"
DUPRBSN="start.sh"
if [[ "$FUBRUSR" != "root" ]]; then
    DUPRSUDO="sudo"
fi
if [[ ! -f /usr/lib/systemd/system/dnf-system-upgrade.service ]]; then
    $DUPRSUDO dnf -y install dnf-plugin-system-upgrade
fi
if [[ ! -f /usr/bin/flatpak ]]; then
    $DUPRSUDO dnf -y install flatpak
fi
if [[ ! -f /usr/bin/wget ]]; then
    $DUPRSUDO dnf -y install wget
fi
if [[ ! -f /usr/bin/curl ]]; then
    $DUPRSUDO dnf -y install curl
fi
# Function --------------------------------------------------------------------------
duprchk () {
    # Check if it's a bash script or a rpm.
    DUPRBSH=$(curl -s --connect-timeout 10 https://raw.githubusercontent.com/DokterW/dupr/master/duprbsh)
    DUPRRPM=$(curl -s --connect-timeout 10 https://raw.githubusercontent.com/DokterW/dupr/master/duprrpm)
    DUPRCHK1=$(echo "$DUPRBSH" | cut -d , -f 1 | tr '[:upper:]' '[:lower:]' | grep $DUPRARG)
    DUPRCHK2=$(echo "$DUPRRPM" | cut -d , -f 1 | tr '[:upper:]' '[:lower:]' | grep $DUPRARG)
}
duprurlverfetch () {
    if [[ "$DUPRARG" = "$DUPRCHK1" ]]; then
        # Regex out the version.
        DUPRLTS=$(curl -ILs -o /dev/null -w %{url_effective} --connect-timeout 10 https://github.com/DokterW/$DUPRARG/releases/latest | egrep -o '([0-9]{1,2}\.)*[0-9]{1,2}')
    elif [[ "$DUPRARG" = "$DUPRCHK2" ]]; then
        # Fetch latest version URL.
        DUPRURL=$(curl -ILs -o /dev/null -w %{url_effective} --connect-timeout 10 https://github.com/$DUPRARG/$DUPRARG/releases/latest)
        # Same as above, but regex out the version.
        DUPRLTS=$(curl -ILs -o /dev/null -w %{url_effective} --connect-timeout 10 https://github.com/$DUPRARG/$DUPRARG/releases/latest | egrep -o '([0-9]{1,2}\.)*[0-9]{1,2}')
    fi
}
duprbashdl () {
    # Download bash script and make it an executable if it's not.
    wget -q -N --show-progress https://raw.githubusercontent.com/DokterW/$DUPRARG/master/$DUPRBSN -P $HOME/.dokter/$DUPRARG/
    if [[ ! -x $HOME/.dokter/$DUPRARG/$DUPRBSN ]]; then
        chmod +x $HOME/.dokter/$DUPRARG/$DUPRBSN
    fi
}
# -----------------------------------------------------------------------------------
if [[ -z "$DUPRCOM" ]]; then
    echo "$DUPRNAM v$DUPRVER"
    echo ""
    echo "You are running Fedora $DUPROSV"
    echo ""
    echo "    dupr <command> <syntax>"
    echo ""
    echo "help"
    echo "    List all commands"
elif [[ "$DUPRCOM" = "help" ]]; then
    echo "$DUPRNAM v$DUPRVER"
    echo ""
    echo "You are running Fedora $DUPROSV"
    echo ""
    echo "    dupr <command> <syntax>"
    echo ""
    echo "DNF"
    echo "install pkg-name"
    echo "    Install software"
    echo "remove pkg-name"
    echo "    Remove software"
    echo "update"
    echo "    Update Fedora $DUPROSV"
    echo "update pkg-name"
    echo "    Update specified package/rpm"
    echo "updated"
    echo "    Update Fedora $DUPROSV and reload daemon(s)"
    echo "updated pkg-name"
    echo "    Update specified package/rpm and reload daemon(s)"
    echo "check-update"
    echo "    Check for updates"
    echo "search"
    echo "    Search for packages"
    echo ""
    echo "Flatpak"
    echo ""
    echo "finstall pkg-name"
    echo "    Install package"
    echo "fremove pkg-name"
    echo "    Removes package"
    echo "fupdate"
    echo "    Updates package(s)"
    echo "fsearch"
    echo "    Search for package"
    echo "fadd name repo-url"
    echo "    Adds remote repo"
    echo ""
    echo "Dokter's bash script"
    echo ""
    echo "dinstall pkg-name"
    echo "    Install package"
    echo "dupdate"
    echo "    Updates package(s)"
    echo "dlist"
    echo "    List package"
    echo "help"
    echo "    List all commands (what you are viewing right now)"
# DNF
elif [[ "$DUPRCOM" = "install" ]] || [[ "$DUPRCOM" = "in" ]]; then
    if [[ -n "$DUPRARG" ]]; then
        echo "[dupr] Installing software"
        $DUPRSUDO dnf install $DUPRARG
    else
        echo "[dupr] Specify what you want to install"
    fi
elif [[ "$DUPRCOM" = "remove" ]] || [[ "$DUPRCOM" = "rm" ]]; then
    if [[ -n "$DUPRARG" ]]; then
        echo "[dupr] Removing software"
        $DUPRSUDO dnf remove $DUPRARG
    else
        echo "[dupr] Specify what you want to remove"
    fi
elif [[ "$DUPRCOM" = "update" ]] || [[ "$DUPRCOM" = "up" ]]; then
    if [[ -z "$DUPRARG" ]]; then
        echo "[dupr] Updating Fedora $DUPROSV"
        $DUPRSUDO dnf upgrade --refresh
    elif [[ -n "$DUPRARG" ]]; then
        echo "[dupr] Updating Fedora $DUPROSV"
        $DUPRSUDO dnf upgrade $DUPRARG
    fi
elif [[ "$DUPRCOM" = "updated" ]] || [[ "$DUPRCOM" = "upd" ]]; then
    if [[ -z "$DUPRARG" ]]; then
        echo "[dupr] Updating Fedora $DUPROSV"
        $DUPRSUDO dnf upgrade --refresh
        echo "[dupr] Reloading daemons"
        $DUPRSUDO systemctl daemon-reload
    elif [[ -n "$DUPRARG" ]]; then
        echo "[dupr] Updating Fedora $DUPROSV"
        $DUPRSUDO dnf upgrade $DUPRARG
        echo "[dupr] Reloading daemons"
        $DUPRSUDO systemctl daemon-reload
    fi
elif [[ "$DUPRCOM" = "check-update" ]] || [[ "$DUPRCOM" = "chup" ]]; then
    echo "[dupr] Checking for updates"
    $DUPRSUDO dnf check-update --refresh
elif [[ "$DUPRCOM" = "search" ]] || [[ "$DUPRCOM" = "sr" ]]; then
    echo "[dupr] Searching for package(s)"
    $DUPRSUDO dnf search $DUPRARG
elif [[ "$DUPRCOM" = "upgrade" ]] || [[ "$DUPRCOM" = "upg" ]]; then
    #DUPRFEV=$(echo "$DUPRDMP" | sed -r 's/^\s+//g' | grep -E 'Fedora [0-9]{2} Schedule' | grep -E -o '[0-9]{2}')
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
# Flatpak
elif [[ "$DUPRCOM" = "finstall" ]] || [[ "$DUPRCOM" = "fin" ]]; then
    echo "[dupr flatpak] Installing flatpak"
    if [[ -n "$DUPRARG" ]]; then
        DUPRFRP=$(flatpak remotes | head -n +2 | sed -r 's/\t/,/' | cut -d , -f 1)
        flatpak install $DUPRFRP $DUPRARG
    else
        echo "[dupr flatpak] Specify what you want to install"
    fi
elif [[ "$DUPRCOM" = "fupgrade" ]] || [[ "$DUPRCOM" = "fup" ]]; then
    echo "[dupr flatpak] Updating flatpak"
    if [[ -n "$DUPRARG" ]]; then
        flatpak update $DUPRARG
    else
        flatpak update
    fi
elif [[ "$DUPRCOM" = "fremove" ]] || [[ "$DUPRCOM" = "frm" ]]; then
    echo "[dupr flatpak] Removing flatpak"
    if [[ -n "$DUPRARG" ]]; then
        flatpak uninstall $DUPRARG
    else
        echo "[dupr flatpak] Specify what you want to uninstall"
    fi
elif [[ "$DUPRCOM" = "fsearch" ]] || [[ "$DUPRCOM" = "fsr" ]]; then
    echo "[dupr flatpak] Searching flatpaks"
    flatpak search $DUPRARG
elif [[ "$DUPRCOM" = "fadd" ]] || [[ "$DUPRCOM" = "fa" ]]; then
    echo "[dupr flatpak] Adding flatpak repo"
    flatpak remote-add --if-not-exists $DUPRARG $DUPRSUB
# Dokter
elif [[ "$DUPRCOM" = "dinstall" ]] || [[ "$DUPRCOM" = "din" ]]; then
    duprchk
    if [[ -z "$DUPRCHK1" ]] && [[ -z "$DUPRCHK2" ]]; then
        echo "$DUPRARG is not available."
        echo "Type 'dogum list' to get a list of available scripts and software."
    elif [[ "$DUPRARG" = "$DUPRCHK1" ]]; then
        if [[ ! -d $HOME/.dokter/$DUPRARG ]]; then
            mkdir $HOME/.dokter/$DUPRARG
            duprbashdl
            echo "alias $DUPRARG='$HOME/.dokter/$DUPRARG/$DUPRBSN'" >> $HOME/.bashrc
            source ~/.bashrc
            # Adding alias so user don't need to restart terminal.
            # It does not work. I will fix that later.
            # alias $DUPRARG='$HOME/.dokter/$DUPRARG/$DUPRBSN'
        else
            echo "You cannot install a bash script that is already installed."
        fi
    elif [[ "$DUPRARG" = "$DUPRCHK2" ]]; then
        if [[ ! -d $HOME/.dokter/$DUPRARG ]]; then
            duprurlverfetch
            # Download URL
            DUPRDLD="https://github.com/$DUPRARG/$DUPRARG/releases/download/v"
            wget -q --show-progress $DUPRDLD$DUPRLTS/$DUPRARG$DUPRRPN -P /tmp/
            sudo dnf -y install /tmp/$DUPRARG$DUPRRPN
            rm /tmp/$DUPRARG$DUPRRPN
        else
            echo "You cannot install software that is already installed."
        fi
    fi
elif [[ "$DUPRCOM" = "dupgrade" ]] || [[ "$DUPRCOM" = "dup" ]]; then
    duprchk
    if [[ -z "$DUPRCHK1" ]] && [[ -z "$DUPRCHK2" ]]; then
        echo "$DUPRARG is not available."
        echo "Type 'dogum list' to get a list of available scripts and software."
    elif [[ "$DUPRARG" = "$DUPRCHK1" ]]; then
        if [[ -d $HOME/.dokter/$DUPRARG ]]; then
            duprurlverfetch
            DUPRIND=$(cat $HOME/.dokter/$DUPRARG/$DUPRBSN | sed -n "2p" | egrep -o '([0-9]{1,2}\.)*[0-9]{1,2}')
            if [[ "$DUPRLTS" != "$DUPRIND" ]]; then
                if [[ "$DUPRARG" = "dupr" ]]; then
                    wget -q -N --show-progress https://raw.githubusercontent.com/DokterW/dupr/master/upgrade_dupr.sh -P $HOME/.dokter/dupr/
                    chmod +x $HOME/.dokter/dupr/upgrade_dupr.sh
                    exec $HOME/.dokter/dupr/upgrade_dupr.sh
                else
                    duprbashdl
                fi
            else
                echo "You already have the latest version of $DUPRARG v$DUPRLTS installed."
            fi
        else
            echo "You cannot update a bash script that is not installed."
        fi
    elif [[ "$DUPRARG" = "$DUPRCHK2" ]]; then
        if [[ -e /bin/$DUPRARG ]]; then
            duprurlverfetch
            # Download URL
            DUPRDLD="https://github.com/$DUPRARG/$DUPRARG/releases/download/v"
            # Fetch version of installed software.
            DUPRIND=$(dnf info $DUPRARG | grep Version | egrep -o '([0-9]{1,2}\.)*[0-9]{1,2}')
            if [ "$DUPRLTS" != "$DUPRIND" ]; then
                # Download, upgrade & remove d/l file
                wget -q --show-progress $DUPRDLD$DUPRLTS/$DUPRARG$DUPRRPN -P /tmp/
                sudo dnf -y upgrade /tmp/$DUPRARG$DUPRRPN
                rm /tmp/$DUPRARG$DUPRRPN
            else
                echo "You already have the latest version of $DUPRARG v$DUPRLTS installed."
            fi
        else
            echo "You cannot update software that is not installed."
        fi
    fi
#elif [[ "$DUPRCOM" = "remove" ]] && [[ -z "$DUPRARG" ]]; then
#    echo "I can't read your mind. Tell me what you want to remove."
#    echo "Type 'dogum list' to get a list of available scripts and software."
#elif [[ "$DUPRCOM" = "remove" ]] && [[ -n "$DUPRARG" ]]; then
elif [[ "$DUPRCOM" = "dremove" ]] && [[ "$DUPRCOM" = "drm" ]]; then
    duprchk
    if [[ -n "$DUPRCHK1" ]]; then
        if [ -e $HOME/.dokter/$DUPRARG/$DUPRBSN ]; then
            # Using the -i option for safety as rm -r will and can mess up stuff.
            # I will still try to find a better, safer solution for this removal.
            # Might move the folder to /tmp before deletion.
            rm -ri $HOME/.dokter/$DUPRARG
            sed -i -e "/alias $DUPRARG='$HOME\/\.dokter\/$DUPRARG\/start\.sh'/d" $HOME/.bashrc
        else
            echo "You cannot remove a bash script that is not installed."
        fi
    elif [[ -n "$DUPRCHK2" ]]; then
        if [[ -e /bin/$DUPRARG ]]; then
            sudo dnf -y remove $DUPRARG
        else
            echo "You cannot remove software that is not installed."
        fi
    fi
elif [[ "$DUPRCOM" = "dlist" ]] || [[ "$DUPRCOM" = "dls" ]]; then
    DUPRBSH=$(curl -s --connect-timeout 10 https://raw.githubusercontent.com/DokterW/dupr/master/duprbsh)
    # DUPRRPM=$(curl -s --connect-timeout 10 https://raw.githubusercontent.com/DokterW/dupr/master/duprrpm)
    echo $DUPRNAM v$DUPRVER
    echo ""
    # echo "$DUPRRPM" | cut -d , -f 1,2 | sed 's/,/ - /g'
    echo "$DUPRBSH" | cut -d , -f 1,2 | sed 's/,/ - /g'
# All up
elif [[ "$DUPRCOM" = "updateall" ]] || [[ "$DUPRCOM" = "upa" ]]; then
    echo "[dupr dnf] Updating Fedora $DUPROSV"
    $DUPRSUDO dnf upgrade --refresh
    echo "[dupr flatpak] Updating flatpak"
    flatpak update
else
    echo "[dupr] $DUPRCOM was not recognised"
fi
