#!/bin/sh

## Credits for: Marcelo Pavan (https://fasthost.com.br)
## Description: Configure your SSH server
## Tested and runned at: Almalinux 8.x

##
## Important: Don't change anything bellow!
##

# Create the backup file before start editing
cp /etc/ssh/sshd_config /etc/ssh/sshd_config.backup

# Prompt the user for setup the SSH server
echo "Enter the new SSH PORT:"
read PORT
echo "Enter the new user name (superuser):"
read NEWUSER
echo "Enter the password for the new user:"
read USERPASS
echo "Enter the new password for root user (used on sudo commands):"
read ROOTPASS
echo "Enter the public key generated from puttygen.exe:"
read PUBKEY
while true; do
    read -p "Do you want to block root login? (you will need to use sudo command): (y/n) " yn
    case $yn in
        [Yy]* )
            ROOTSSH="no"
            ALLOWED="$NEWUSER"
            break;;
        [Nn]* )
            ROOTSSH="prohibit-password"
            ALLOWED="root $NEWUSER"
            break;;
        * )
            echo "Please answer yes or no.";;
    esac
done
echo "Please, make sure all settings is right before continue:"
echo "-"
echo "Port: $PORT"
echo "-"
echo "New user: $NEWUSER"
echo "-"
echo "User password: $USERPASS"
echo "-"
echo "New root password: $ROOTPASS"
echo "-"
echo "Public key: $PUBKEY"
echo "-"
echo "Permit root login: $ROOTSSH"
echo "-"
echo "Users allowed to login: $ALLOWED"
echo "-"
while true; do
    read -p "Do you want to continue: (y/n)" yn
    case $yn in
        [Yy]* )
                # Install the sed command if not exist
                yum install sed -y

                # Create the new user and put at root/whell group
                adduser $NEWUSER
                usermod -aG wheel $NEWUSER
                usermod -aG root $NEWUSER
                echo "$NEWUSER ALL=(ALL) ALL" > /etc/sudoers
                chpasswd <<<"$NEWUSER:$USERPASS"
                chpasswd <<<"root:$ROOTPASS"

                # Create the new file for public key authentication
                mkdir /home/$NEWUSER/.ssh
                echo $PUBKEY >> /home/$NEWUSER/.ssh/authorized_keys
                chown -R $NEWUSER:$NEWUSER /home/$NEWUSER/.ssh
                chmod -R 600 /home/$NEWUSER/.ssh

                # Configure the SSH server
                sed -i "0,/Port/{s/.*Port.*/Port $PORT/}" /etc/ssh/sshd_config
                sed -i "0,/AddressFamily/{s/.*AddressFamily.*/AddressFamily any/}" /etc/ssh/sshd_config
                sed -i "0,/SyslogFacility/{s/.*SyslogFacility.*/SyslogFacility AUTH/}" /etc/ssh/sshd_config
                sed -i "0,/LogLevel/{s/.*LogLevel.*/LogLevel INFO/}" /etc/ssh/sshd_config
                sed -i "0,/LoginGraceTime/{s/.*LoginGraceTime.*/LoginGraceTime 30/}" /etc/ssh/sshd_config
                sed -i "0,/PermitRootLogin/{s/.*PermitRootLogin.*/PermitRootLogin $ROOTSSH/}" /etc/ssh/sshd_config
                sed -i "0,/StrictModes/{s/.*StrictModes.*/StrictModes yes/}" /etc/ssh/sshd_config
                sed -i "0,/MaxAuthTries/{s/.*MaxAuthTries.*/MaxAuthTries 3/}" /etc/ssh/sshd_config
                sed -i "0,/MaxSessions/{s/.*MaxSessions.*/MaxSessions 5/}" /etc/ssh/sshd_config
                sed -i "0,/AllowUsers/{s/.*AllowUsers.*/AllowUsers $ALLOWED/}" /etc/ssh/sshd_config
                sed -i "0,/PubkeyAuthentication/{s/.*PubkeyAuthentication.*/PubkeyAuthentication yes/}" /etc/ssh/sshd_config
                sed -i "0,/AuthorizedKeysFile/{s/.*AuthorizedKeysFile.*/AuthorizedKeysFile \.\/ssh\/authorized_keys/}" /etc/ssh/sshd_config
                sed -i "0,/HostbasedAuthentication/{s/.*HostbasedAuthentication.*/HostbasedAuthentication yes/}" /etc/ssh/sshd_config
                sed -i "0,/IgnoreUserKnownHosts/{s/.*IgnoreUserKnownHosts.*/IgnoreUserKnownHosts yes/}" /etc/ssh/sshd_config
                sed -i "0,/IgnoreRhosts/{s/.*IgnoreRhosts.*/IgnoreRhosts yes/}" /etc/ssh/sshd_config
                sed -i "2,/PasswordAuthentication/{s/.*PasswordAuthentication.*/PasswordAuthentication no/}" /etc/ssh/sshd_config
                sed -i "0,/PermitEmptyPasswords/{s/.*PermitEmptyPasswords.*/PermitEmptyPasswords no/}" /etc/ssh/sshd_config
                sed -i "0,/GSSAPIAuthentication/{s/.*GSSAPIAuthentication.*/GSSAPIAuthentication no/}" /etc/ssh/sshd_config
                sed -i "0,/UsePAM/{s/.*UsePAM.*/UsePAM yes/}" /etc/ssh/sshd_config
                sed -i "0,/AllowAgentForwarding/{s/.*AllowAgentForwarding.*/AllowAgentForwarding yes/}" /etc/ssh/sshd_config
                sed -i "0,/X11Forwarding/{s/.*X11Forwarding.*/X11Forwarding no/}" /etc/ssh/sshd_config
                sed -i "0,/ClientAliveInterval/{s/.*ClientAliveInterval.*/ClientAliveInterval 360/}" /etc/ssh/sshd_config
                sed -i "0,/ClientAliveCountMax/{s/.*ClientAliveCountMax.*/ClientAliveCountMax 3/}" /etc/ssh/sshd_config
                sed -i "0,/UseDNS/{s/.*UseDNS.*/UseDNS no/}" /etc/ssh/sshd_config
                sed -i "0,/MaxStartups/{s/.*MaxStartups.*/MaxStartups 10:30:100/}" /etc/ssh/sshd_config
                sed -i "0,/PermitTunnel/{s/.*PermitTunnel.*/PermitTunnel no/}" /etc/ssh/sshd_config
                sed -i "0,/PermitUserEnvironment/{s/.*PermitUserEnvironment.*/PermitUserEnvironment no/}" /etc/ssh/sshd_config
                sed -i "0,/KerberosAuthentication/{s/.*KerberosAuthentication.*/KerberosAuthentication no/}" /etc/ssh/sshd_config
                sed -i "0,/ChallengeResponseAuthentication/{s/.*ChallengeResponseAuthentication.*/ChallengeResponseAuthentication no/}" /etc/ssh/sshd_config
                sed -i "0,/GSSAPICleanupCredentials/{s/.*GSSAPICleanupCredentials.*/GSSAPICleanupCredentials no/}" /etc/ssh/sshd_config

                # Open the new SSH PORT at SELinux (if activated)
                semanage port -a -t ssh_port_t -p tcp $PORT

                # Open the new SSH PORT at Firewalld (if activated)
                firewall-cmd --permanent --add-port=$PORT/tcp
                firewall-cmd --reload

                # Restart the SSH server
                systemctl restart sshd
                break;;

        [Nn]* ) echo "Setup aborted by user command."; exit;;
        * ) echo "Please answer yes or no.";;
    esac
done
# End
