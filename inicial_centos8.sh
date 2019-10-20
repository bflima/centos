#!/usr/bin/env bash

#Função para atualizar os pacotes do sistema tambem desabilita o firewall e SELINUX
_CONFIGURAR()
{
  clear
  FILE="/tmp/inicial.txt"
  if [ ! -e "$FILE" ] ; then
    #Desabilitar o firewalld
    systemctl stop firewalld && systemctl disable firewalld
    #Desabilitar SELINUX
    setenforce 0
    sed -i 's/^SELINUX=.*/SELINUX=disabled/g' /etc/selinux/config

    #Atualizar sistema
    yum update -y && yum upgrade -y

    echo "Configuracao realizada, função executada foi _CONFIGURAR" | tee > $FILE
  else
    echo "Configuracao realizada, para repetir a instalacao remover esse arquivo $FILE"
  fi
}
################################################################################
#Função para instalar pacotes necessarios para a instalação a ser realizada SAMBA
_DEPENDENCIA()
{
  clear
  FILE="/tmp/dep.txt"
    if [ ! -e "$FILE" ] ; then

      # Instalar repositorio EPEL e ferramentas de desenvolvimento
      yum install epel-release.noarch yum-utils "@Development Tools" -y

      # instalação de pacotes adicionais repositorioepel necessita estar instalado
      yum install wget dialog chrony htop net-tools figlet bash-completion -y

      # Habilitando o bash completion
      source /etc/profile.d/bash_completion.sh

      # Instala chrony e atualiza a hora
      cp --backup /etc/chrony.conf /root/chrony.conf
      sed -i 's/^pool.*/server\ a.ntp.br\ iburst/' /etc/chrony.conf
      sed -i '4s/^/server\ b.ntp.br\ iburst\n/' /etc/chrony.conf
      sed -i 's/^#allow.*/allow\ 0.0.0.0\/0/' /etc/chrony.conf

      systemctl enable chronyd && systemctl restart chronyd

        echo "Configuracao realizada, função executada foi _DEPENDENCIA" | tee > $FILE
        echo "Data e hora atualizados"
    else
        echo "Configuracao realizada, para repetir a instalacao remover esse arquivo $FILE"
    fi
}
################################################################################
#Função de instalação e configuração do editor vim
_VIM()
{
  which vim || yum install vim -y
  FILE="/tmp/vim.txt"
  LOCAL_VIM=$(whereis vimrc |cut -d " " -f2)
  echo "$FILE"

  if [ ! -e "$FILE" ] ; then
      echo "Criando arquivo de configuracao"
      sed -i 's/set\ nocompatible/set\ bg\=\dark\nset\ nocompatible/'     $LOCAL_VIM
      sed -i 's/set\ nocompatible/set\ tabstop\=4\nset\ nocompatible/'    $LOCAL_VIM
      sed -i 's/set\ nocompatible/set\ shiftwidth\=4\nset\ nocompatible/' $LOCAL_VIM
      sed -i 's/set\ nocompatible/set\ expandtab\nset\ nocompatible/'     $LOCAL_VIM
      sed -i 's/set\ nocompatible/syntax\ on\nset\ nocompatible/'         $LOCAL_VIM
      sed -i 's/set\ nocompatible/set\ number\nset\ nocompatible/'        $LOCAL_VIM
      echo "Configuracao realizada, função executada foi _VIM" | tee > $FILE
  else
    echo "Configuracao realizada, para repetir a instalacao remover esse arquivo $FILE"
  fi
}
#Chamada de funções

_CONFIGURAR
_DEPENDENCIA
_VIM
