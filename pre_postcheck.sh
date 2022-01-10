#!/bin/bash
#
# Linux - Pre/Post-check
# Version 3.0
# 
#
#################################################################
#                                                               #
############################################                    #
#                                          #                    #
# OS PRE_POST check script                 #                    #
# Updated by santhosmails@gmail.com        #                    #
# Thu Dec 30 08:28:47 UTC 2021             #                    #
#                                          #                    #
############################################                    #
#                                                               #
#################################################################
#
#

# SETUP
LANG="en_US.UTF-8"
LC_CTYPE="en_US.UTF-8"
LC_NUMERIC="en_US.UTF-8"
LC_TIME="en_US.UTF-8"
LC_COLLATE="en_US.UTF-8"
LC_MONETARY="en_US.UTF-8"
LC_MESSAGES="en_US.UTF-8"
LC_PAPER="en_US.UTF-8"
LC_NAME="en_US.UTF-8"
LC_ADDRESS="en_US.UTF-8"
LC_TELEPHONE="en_US.UTF-8"
LC_MEASUREMENT="en_US.UTF-8"
LC_IDENTIFICATION="en_US.UTF-8"
LC_ALL="en_US.UTF-8"
PATH=$PATH:/bin:/sbin:/usr/bin:/usr/sbin
export PATH

# SANATY CHECK
if [[ "${UID}" -ne 0 ]]; then
        echo 'You must be root user to execute the script' >&2
        exit 1
fi

# ARGUMENTS NEEDED TO RUN THE SCRIPT
case "${1}" in
        PRE|pre)
                readonly LOG=pre
                ;;
        POST|post)
                readonly LOG=post
                ;;
        *)
                echo "Usage: ${0} { PRE | POST }" >&2
                exit 2
                ;;
esac

# SCRIPT OUTPUT
if [[ ! -d /var/tmp/precheck ]]; then
        mkdir -p /var/tmp/precheck
fi
OUTPUTFILE="/var/tmp/precheck/${LOG}check-$(uname -n)-$(date +%F).txt"

# HOST INFORMATION
linuxhost()
{
        echo
        echo 'HOST INFORMATION:'
        echo '-----------------'
        uname -a
        echo
        cat /etc/*-release
        echo -e '\n'
        echo 'UPTIME & USER INFO:'
        echo '-------------------'
        uptime
        who
        echo -e '\n'
        echo
        echo 'NTP/CHRONYD STATUS:'
        echo '-------------------'
        (ntpq -pn || chronyc -n sources) 2> /dev/null
        echo -e '\n'
        #DOCKER STATUS
        if [[ -e /usr/bin/docker || -e /usr/sbin/containerd || -e /usr/bin/dockerd || -e /usr/bin/docker-proxy ]]; then
                echo 'DOCKER STATUS:'
                echo '--------------'
                docker ps
                echo -e '\n'
        fi
}

# DISK INFORMATION
linuxdisk()
{
        echo
        echo 'DISK INFORMATION:'
        echo '-----------------'
        echo
        echo 'FILE SYSTEM COUNT:'
        echo '------------------'
        echo "TOATL FS COUNT = $(df -hT -xtmpfs -xdevtmpfs|wc -l);  NFS FS COUNT = $(df -hT|grep -i nfs|grep -v .snapshot|wc -l);  CIFS COUNT = $(df -hT|grep -i cifs|wc -l) " 2>/dev/null
        echo
        echo 'FILE SYSTEMS:'
        echo '-------------'
        echo 'Filesystem                        Type  Size  Used Avail Use% Mounted on'
        df -hT -xtmpfs -xdevtmpfs | sort | grep -v '^Filesystem'
        echo -e '\n'
        if pgrep 'asm|ASM' &> /dev/null ; then
                echo 'ASM IS RUNNING ON THE SERVER:'
                echo '-----------------------------'
                ps -ef|grep -i pmon|grep -v grep
                echo
                echo 'ASM DISK DETAILS:'
                echo '-----------------'
                echo "NO OF ASM DISK = $(ls -ltr /dev|grep asm|grep '^lrwx'| wc -l)"
                echo '--------------------'
                ls -ltr /dev|grep asm|grep '^lrwx'|column -t
                echo -e '\n'
        fi
        echo "PHYSICAL VOLUME(S) DETAILS: $(pvs |wc -l)"
        echo '-------------------------------'
        pvs|column -t
        echo -e '\n'
        echo "VOLUME GROUP(S) DETAILS: $(vgs |wc -l)"
        echo '----------------------------'
        vgs|column -t
        echo -e '\n'
        echo "LOGICAL VOLUME(S) DETAILS: $(lvs |wc -l)"
        echo '-----------------------------'
        lvs|column -t
        echo -e '\n'
        echo 'LINUX RAID DETAILS:'
        echo '-------------------'
        cat /proc/mdstat
        echo -e '\n'
        if [[ -e /usr/sbin/pcs ]]; then
                echo 'PCS CLUSTER DETAILS:'
                echo '--------------------'
                pcs status
                echo -e '\n'
        fi
        echo "LIST OF SCSI DEVICES: $(lsscsi |wc -l)"
        echo '------------------------'
        lsscsi
        echo -e '\n'
        echo 'FSTAB DETAILS:'
        echo '--------------'
        cat /etc/fstab | column -t
        echo -e '\n'
        echo 'MOUNT DETAILS:'
        echo '--------------'
        mount | column -t
        echo -e '\n'
        echo 'LIST OF BLOCK DEVICES:'
        echo '----------------------'
        lsblk
        echo -e '\n'
}


# NETWORK INFORMATION
linuxnetwork()
{
        echo
        echo 'NETWORK INFORMATION:'
        echo '--------------------'
        echo
        echo 'IFCONFIG INFO:'
        echo '--------------'
        ifconfig -a
        echo -e '\n'
        echo 'NETWORK INTERFACES:'
        echo '-------------------'
        ip a
        echo -e '\n'
        echo 'ROUTES DETAILS:'
        echo '---------------'
        route -n
        echo -e '\n'
        echo 'NETSTAT -IN:'
        echo '------------'
        netstat -in
        echo -e '\n'
        echo 'ETC_HOSTS:'
        echo '----------'
        sed -e '/^#/d' -e '/^$/d' /etc/hosts
        echo -e '\n'
        echo 'RESOLV.CONF:'
        echo '------------'
        sed -e '/^#/d' -e '/^$/d' /etc/resolv.conf
        echo -e '\n'
        echo 'NIC FDX/HDX - SPEED:'
        echo '--------------------'
        ETH=$(ifconfig -s | awk '{print $1}'|grep -Evw 'Iface|lo')
        for EN in ${ETH} ; do
                ethtool ${EN}
        done
        echo -e '\n'
}

# ERROR INFORMATION
linuxerror()
{
        echo
        echo 'ERROR INFORMATION:'
        echo '------------------'
        echo
        echo 'ERROR LOGS:'
        echo '-----------'
        grep -i FATAL /var/log/messages|cut -d' ' -f6- |sed -e "s/[0-9]/0/g"|sort|uniq -c|sort -hk1
        grep -i ERROR /var/log/messages|cut -d' ' -f6- |sed -e "s/[0-9]/0/g"|sort|uniq -c|sort -hk1
        echo -e '\n'
        echo 'DMESG LOGS:'
        echo '-----------'
        dmesg -T|grep -i fail|sed -e "s/[0-9]/0/15g"|sort -k6 -u
	dmesg -T|grep -i error|sed -e "s/[0-9]/0/15g"|sort -k6 -u
        echo -e '\n'
}

# HARDWARE INFORMATION
linuxhardware()
{
        echo
        echo 'HARDWARE INFORMATION:'
        echo '---------------------'
        echo
        echo 'CPU MODEL & ARCHITECTURE INFORMATION:'
        echo '-------------------------------------'
        lscpu
        echo -e '\n'
        echo 'MEMORY INFORMATION:'
        echo '-------------------'
        free -m
        echo -e '\n'
        echo 'PROC_MEMINFO:'
        echo '-------------'
        cat /proc/meminfo
        echo -e '\n'
        echo 'PCI DEVICES'
        echo '-----------'
        lspci
        echo -e '\n'
}

# SERVICE INFORMATION
linuxservice()
{
        echo
        echo 'SERVICE INFORMATION:'
        echo '--------------------'
        echo
        echo 'CHKCONFIG LIST:'
        echo '---------------'
        (chkconfig --list) 2> /dev/null
        echo -e '\n'
        echo 'EXPORTS FOR LOCALHOST:'
        echo '----------------------'
        showmount -e localhost 2> /dev/null
        echo -e '\n'
        echo 'CRONTAB JOBS:'
        echo '-------------'
        crontab -l | sed  '/^$/d'
        echo -e '\n'
        echo 'ULIMIT SETINGS:'
        echo '---------------'
        ulimit -a
        echo -e '\n'
        if [[ -e /sbin/sestatus ]]; then
                echo 'SELINUX STATUS:'
                echo '---------------'
                sestatus
                echo -e '\n'
        fi
        echo 'IPTABLES LIST:'
        echo '--------------'
        iptables -L
        echo -e '\n'
        iptables -S
        echo -e '\n'
        echo 'NAT IPTABLES LIST:'
        echo '------------------'
        iptables -t nat -L
        echo -e '\n'
        iptables -t nat -S
        echo -e '\n'
}


# MISCELLANEOUS INFORMATION
linuxmise()
{
        echo
        echo 'MISCELLANEOUS INFORMATION:'
        echo '--------------------------'
        echo
        echo 
        echo 'FS PERMISSION:'
        echo '--------------'
        df -hT -xtmpfs -xdevtmpfs |grep -v '^Filesystem'| awk '{print $7}'| xargs ls -ld
        echo -e '\n'
        echo 'BLOCK DEVICE ATTRIBUTES:'
        echo '------------------------'
        blkid
        echo -e '\n'
        echo 'PARTITION SIZE:'
        echo '---------------'
        fdisk -l |egrep '^Disk|dm-'
        echo -e '\n'
        echo 'PARTITION DETAILS'
        echo '-----------------'
        fdisk -l
        echo -e '\n\n'
        echo 'SYSTEMCTL SERVICES:'
        echo '-------------------'
        systemctl list-units --type=service -all
        echo -e '\n\n'
        echo 'SYSTEMCTL UNIT FILES:'
        echo '---------------------'
        systemctl list-unit-files
        echo -e '\n\n'
        echo 'COMPARING ACTIVE SERVICE'
        echo '------------------------'
        for VAR in $(systemctl list-units --type=service -all --state=active | grep -i .service | awk '{ print $1}')
        do
                echo ${VAR} $(echo "|") $(systemctl list-unit-files | grep -i ${VAR})
        done
        echo -e '\n\n'
        echo 'ACTIVE SERVICE DETAILS:'
        echo '-----------------------'
        for VAR in $(systemctl list-units --type=service -all --state=active | grep -i .service | awk '{ print $1}')
        do
                systemctl status ${VAR} | head -20
                echo '================================================================================================================================'
        done
        echo -e '\n'
        echo 'STATUS OF MODULES LOADED IN KERNEL'
        echo '----------------------------------'
        lsmod
        echo -e '\n'
        echo 'KERNEL PARAMETERS AT SERVER RUNTIME:'
        echo '------------------------------------'
        sysctl -a
        echo -e '\n'

}


# BACKUP INFORMATION
linuxback()
{
        echo
        echo 'BACKUP INFORMATION:'
        echo '-------------------'
        echo
        mkdir -p /etc/backup-${LOG}check-$(date +%F)
        BACKUP_DIR="/etc/backup-${LOG}check-$(date +%F)"
        for i in /etc/fstab /etc/resolv.conf /etc/login.defs /etc/security/pam_winbind.conf /etc/postfix/main.cf /etc/sysconfig/network/ /etc/pam.d/ /boot/ /etc/profile /etc/hosts /etc/krb5.conf /etc/samba/ /etc/ssh/sshd_config /etc/issue /etc/issue.net /usr/sbin/apache2ctl /etc/passwd /etc/group /etc/sssd/sssd.conf
                do
                        cp -pPRvfL $i ${BACKUP_DIR}
                done
        echo -e '\n'
}

# RPM INFORMATION
linuxrpm()
{
        echo -e '\n'
        echo 'RPM INFORMATION:'
        echo '----------------'
        rpm -qa --last |column -t
        echo -e '\n'
}

# CURRENT SYSTEM PROCESS INFORMATION
linuxprocess()
{
        echo 'TOP 10 PROCESS:'
        echo '---------------'
        ps -eo pid,user,ppid,comm,cmd,%mem,%cpu --sort=-%cpu | head
        echo -e '\n'
        echo "NON ROOT PROCESS: $(ps -ef | grep -v root | wc -l)"
        echo '--------------------'
        ps -aux | grep -v root
        echo -e '\n'
        echo "TOTAL PROCESS RUNNING ON THE SERVER: $(ps -ef | wc -l)"
        echo '-----------------------------------------'
        ps -aux
}

case $(uname) in
        Linux)
                echo
                echo 'Generating system stats please wait (can take a few minutes on slower systems)'
                echo
                echo "File generated on $(date)" > ${OUTPUTFILE}
                echo 'Host Information . . . . . 10%'
                linuxhost >> ${OUTPUTFILE}        
                echo 'Disk Information . . . . . . 20%'
                linuxdisk >> ${OUTPUTFILE}
                echo 'Network Information . . . . . 30%'
                linuxnetwork >> ${OUTPUTFILE}
                echo 'Error Information . . . . . 40%'
                linuxerror >> ${OUTPUTFILE}
                echo 'Hardware Information . . . . . 50%'
                linuxhardware >> ${OUTPUTFILE}
                echo 'Service Information . . . . . 60%'
                linuxservice >> ${OUTPUTFILE}
                echo 'Miscellaneous Information . . . . . 70%'
                linuxmise &>> ${OUTPUTFILE}
                echo 'Backup Information . . . . . 80%'
                linuxback >> ${OUTPUTFILE}
                echo 'RPM Information . . . . . 90%'
                linuxrpm >> ${OUTPUTFILE}
                echo 'System Processes Information . . . . . 100%'
                linuxprocess >> ${OUTPUTFILE}
                echo
                echo "File generated at ${OUTPUTFILE} on $(date)"
                logger -t pre_postcheck.sh "File generated at ${OUTPUTFILE} successfully"
                echo
                exit 0
                ;;
        *)
                exit 3
		;;
esac

