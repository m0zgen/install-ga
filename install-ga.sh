#!/bin/bash

confirm() {
    # call with a prompt string or use a default
    read -r -p "${1:-Are you sure? [y/N]} " response
    case "$response" in
        [yY][eE][sS]|[yY]) 
            true
            ;;
        *)
            false
            ;;
    esac
}

yum install google-authenticator -y

if ! cat /etc/pam.d/sshd | grep -q "pam_google_authenticator"; then
    echo -e "# Google auth\nauth required pam_google_authenticator.so nullok" >> /etc/pam.d/sshd	
fi

sed -i 's/ChallengeResponseAuthentication.*/ChallengeResponseAuthentication yes/' /etc/ssh/sshd_config

systemctl restart sshd.service

# For ssh keys params

function ga_rsa ()
{
	if confirm "Enable GA for SSH RSA?"; then
		if ! cat /etc/ssh/sshd_config | grep -q "keyboard-interactive"; then
	    	echo -e "# Google auth\nAuthenticationMethods publickey,password publickey,keyboard-interactive" >> /etc/ssh/sshd_config
	    	sed -i 's/^[^#]*auth       substack     password-auth/#&/' /etc/pam.d/sshd
	    	systemctl restart sshd.service
		fi			
	fi
}

ga_rsa