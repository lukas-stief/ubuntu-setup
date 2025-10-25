# download vscode .deb-file
wget -O /tmp/vscode.deb https://go.microsoft.com/fwlink/?LinkID=760868
# set access rights
sudo chmod 644 /tmp/vscode.deb
# install vscode and grant access to microsoft repository
sudo DEBIAN_FRONTEND=noninteractive apt-get -y install /tmp/vscode.deb
