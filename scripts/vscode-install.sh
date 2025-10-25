# download vscode .deb-file
wget -O /tmp/vscode.deb https://go.microsoft.com/fwlink/?LinkID=760868

# install vscode and grant access to microsoft repository
sudo DEBIAN_FRONTEND=noninteractive apt-get -y install /tmp/vscode.deb
