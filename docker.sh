#!/bin/bash
# Author: Maciel Castro
# E-mail: macielcastro@rocketmail.com
# Date: 25 junho 2024

# Nome do usuario
usuario=$USER
# Uninstall all conflicting packages:
uninstall_all_conflicting_packages() {
    for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc
    do
        sudo apt-get remove $pkg
    done
}
# Add Docker's official GPG key:
dockerGPGkey() {
    sudo apt-get update -y
    sudo apt-get install ca-certificates curl -y
    sudo install -m 0755 -d /etc/apt/keyrings
    sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
    sudo chmod a+r /etc/apt/keyrings/docker.asc
}
# Add the repository to Apt sources:
addrepodocker() {
echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
    $(. /etc/os-release && echo "$UBUNTU_CODENAME") stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update -y
}
# Install Docker latest
installdocker() {
    sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
}
# Post-installation
postinstallation() {
    sudo groupadd docker
    sudo usermod -aG docker $usuario
    if [ -d /home/"$usuario"/.docker ]
    then
        sudo chown "$usuario":"$usuario" /home/"$usuario"/.docker -R
        sudo chmod g+rwx "$usuario/.docker" -R
    fi
}
# Docker to start on boot with systemd
startonboot() {
    sudo systemctl enable docker.service
    sudo systemctl start docker.service
    sudo systemctl enable containerd.service
    sudo systemctl start containerd.service
}
# Reinicia ou não o sistema
restart-yes-no() {
    while true; do
    echo -e "É necessário reiniciar seu sistema para completar a instalação.\nDeseja reiniciar agora? [s/n]"
        read -n1 resposta
        echo # para adicionar uma nova linha
        if [ "$resposta" = "s" ] || [ "$resposta" = "S" ]; then
                echo "Reiniciando o sistema..."
                sleep 2
                sudo reboot
                break
        elif [ "$resposta" = "n" ] || [ "$resposta" = "N" ]; then
                echo "Encerrando o programa."
                exit 0
        else
                echo "Entrada inválida. Por favor, digite 's' para sim ou 'n' para não."
        fi
    done
}

# Inicio do script
if [ "$1" = "-s" ]; then
    echo -e "Detectando distro..."
    source /etc/os-release
    echo "Ubuntu $UBUNTU_CODENAME"
    if [ $UBUNTU_CODENAME = jammy ] || [ $UBUNTU_CODENAME = focal ] || [ $UBUNTU_CODENAME = noble ] || [ $UBUNTU_CODENAME = mantic ]
    then
        echo "Distribuição valida"
        uninstall_all_conflicting_packages
        dockerGPGkey
        addrepodocker
        installdocker
        postinstallation
        startonboot
        sudo reboot
    else
        echo "Distribuição invalida"
    fi
else
    echo "Esse script irá instalar o docker neste computador.
Esse script é feito para:
    * Ubuntu Noble 24.04 (LTS) 
    * Ubuntu Mantic 23.10 (EOL: July 12, 2024)
    * Ubuntu Jammy 22.04 (LTS)
    * Ubuntu Focal 20.04 (LTS)
    * Distribuições baseadas nas distros acima

OBS: Utilise a opção -s para instalação não interativa."
    sleep 2

    echo "Deseja prosseguir com a operação [s/n]?"

    read -n1 resposta

    case $resposta in
        S | s) echo
            echo -e "Você escolheu continuar\nDetectando distro..."
            source /etc/os-release
            sleep 2
            echo "Ubuntu $UBUNTU_CODENAME"
            if [ $UBUNTU_CODENAME = jammy ] || [ $UBUNTU_CODENAME = focal ] || [ $UBUNTU_CODENAME = noble ] || [ $UBUNTU_CODENAME = mantic ]
            then
                echo "Distribuição valida"
                sleep 2
                uninstall_all_conflicting_packages
                dockerGPGkey
                addrepodocker
                installdocker
                postinstallation
                startonboot
                restart-yes-no
            else
                echo "Distribuição invalida"
            fi
        ;;
        N | n) echo
            echo "Operação interrompida"
        ;;
        *) echo
            echo "Opção inválida. Digite apenas S ou N"
        ;;
    esac
fi
