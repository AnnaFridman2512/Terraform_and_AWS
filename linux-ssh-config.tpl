cat << EOF >> ~/.ssh/config

Host ${hostname}
User ${user}
IdentityFile ${identityfile}
EOF