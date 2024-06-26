#!/bin/bash
# Author: Maciel Castro
# E-mail: macielcastro@rocketmail.com
# Date: 26 junho 2024

instalakubectl() {
    # apt update
    sudo apt-get update -y
    # apt-transport-https may be a dummy package; if so, you can skip that package
    sudo apt-get install -y apt-transport-https ca-certificates curl gnupg
    # If the folder `/etc/apt/keyrings` does not exist, it should be created before the curl command, read the note below.
    sudo mkdir -p -m 755 /etc/apt/keyrings
    curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.30/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
    sudo chmod 644 /etc/apt/keyrings/kubernetes-apt-keyring.gpg # allow unprivileged APT programs to read this keyring
    # This overwrites any existing configuration in /etc/apt/sources.list.d/kubernetes.list
    echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.30/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
    sudo chmod 644 /etc/apt/sources.list.d/kubernetes.list   # helps tools such as command-not-found to work correctly
    sudo apt-get update -y
    sudo apt-get install -y kubectl
    echo "kubectl instalado!"
}
kubebashcompletion() {
    # Enable kubectl autocompletion
    while true; do
        echo -e "Deseja habilitar a função autocompletar para o kubectl o alias k para o comando kubectl? [s/n]"
        read -n1 resposta
        echo # para adicionar uma nova linha
        if [ "$resposta" = "s" ] || [ "$resposta" = "S" ]; then
            sudo apt-get install -y bash-completion
            kubectl completion bash | sudo tee /etc/bash_completion.d/kubectl > /dev/null
            sudo chmod a+r /etc/bash_completion.d/kubectl
            echo 'alias k=kubectl' >>~/.bashrc
            echo 'complete -o default -F __start_kubectl k' >>~/.bashrc
            echo "Autocompletar e alias habilitados com sucesso."
            break
        elif [ "$resposta" = "n" ] || [ "$resposta" = "N" ]; then
            echo "A função autocompletar não será habilitada."
            break
        else
            echo "Entrada inválida. Por favor, digite 's' para sim ou 'n' para não."
        fi
    done
}
installconvertplugin() {
    # Install kubectl-convert
    while true; do
        echo -e "Deseja instalar o kubectl convert plugin? [s/n]"
        read -n1 resposta
        echo # para adicionar uma nova linha
        if [ "$resposta" = "s" ] || [ "$resposta" = "S" ]; then
            # Download the latest release with the command
            curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl-convert"
            # Validate the binary (optional)
            curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl-convert.sha256"
            echo "$(cat kubectl-convert.sha256) kubectl-convert" | sha256sum --check
            if [ $? -eq 0 ]; then
                echo "Download do kubectl convert plugin concluido"
            else
                echo "Houve um erro na verificação do binario do kubectl convert plugin."
                break
            fi
            # Install kubectl-convert
            sudo install -o root -g root -m 0755 kubectl-convert /usr/local/bin/kubectl-convert
            # After installing the plugin, clean up the installation files:
            rm kubectl-convert kubectl-convert.sha256
            # Verify plugin is successfully installed
            kubectl convert --help > /dev/null
            if [ $? -eq 0 ]; then
                echo "kubectl convert plugin instalado com sucesso"
            else
                echo "Houve um erro na instalação do kubectl convert plugin."
            fi
            break
        elif [ "$resposta" = "n" ] || [ "$resposta" = "N" ]; then
            echo "O kubectl convert plugin não será instalado."
            break
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
        # apt update
        sudo apt-get update -y
        # apt-transport-https may be a dummy package; if so, you can skip that package
        sudo apt-get install -y apt-transport-https ca-certificates curl gnupg
        # If the folder `/etc/apt/keyrings` does not exist, it should be created before the curl command, read the note below.
        sudo mkdir -p -m 755 /etc/apt/keyrings
        curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.30/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
        sudo chmod 644 /etc/apt/keyrings/kubernetes-apt-keyring.gpg # allow unprivileged APT programs to read this keyring
        # This overwrites any existing configuration in /etc/apt/sources.list.d/kubernetes.list
        echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.30/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
        sudo chmod 644 /etc/apt/sources.list.d/kubernetes.list   # helps tools such as command-not-found to work correctly
        sudo apt-get update -y
        sudo apt-get install -y kubectl bash-completion
        echo "kubectl instalado!"
        # Enable kubectl autocompletion
        kubectl completion bash | sudo tee /etc/bash_completion.d/kubectl > /dev/null
        sudo chmod a+r /etc/bash_completion.d/kubectl
        echo 'alias k=kubectl' >> ~/.bashrc
        echo 'complete -o default -F __start_kubectl k' >> ~/.bashrc
        echo "Autocompletar e alias habilitados com sucesso."
        # kubectl convert plugin
        # Download the latest release with the command
        curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl-convert"
        # Validate the binary (optional)
        curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl-convert.sha256"
        echo "$(cat kubectl-convert.sha256) kubectl-convert" | sha256sum --check
        # Install kubectl-convert
        sudo install -o root -g root -m 0755 kubectl-convert /usr/local/bin/kubectl-convert
        # After installing the plugin, clean up the installation files:
        rm kubectl-convert kubectl-convert.sha256
        # Verify plugin is successfully installed
        kubectl convert --help > /dev/null
        if [ $? -eq 0 ]; then
            echo "kubectl convert plugin instalado com sucesso"
        else
            echo "Houve um erro na instalação do kubectl convert plugin."
        fi
    else
        echo "Distribuição invalida"
    fi
else
    echo -e "Esse script irá instalar o kubectl neste computador.\n\nEsse script é feito para:\n
    * Ubuntu Noble 24.04 (LTS) 
    * Ubuntu Mantic 23.10 (EOL: July 12, 2024)
    * Ubuntu Jammy 22.04 (LTS)
    * Ubuntu Focal 20.04 (LTS)
    * Distribuições baseadas nas distros acima\n\nOBS: Utilise a opção -s para instalação não interativa.\n"
    sleep 2
    echo "Deseja prosseguir com a operação [s/n]?"
    read -n1 resposta
    case $resposta in
        S | s) echo
            echo -e "Você escolheu continuar\nDetectando distro..."
            source /etc/os-release
            echo "Ubuntu $UBUNTU_CODENAME"
            sleep 2
            if [ $UBUNTU_CODENAME = jammy ] || [ $UBUNTU_CODENAME = focal ] || [ $UBUNTU_CODENAME = noble ] || [ $UBUNTU_CODENAME = mantic ]
            then
                echo "Distribuição valida"
                instalakubectl
                kubebashcompletion
                installconvertplugin
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