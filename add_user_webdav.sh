#!/usr/bin/env bash
#Adiciona usuario a um ou varios grupos webdav
#Flavio Torres, ftorres@ig.com
#v1 - 05/2011
#TODO: - De repente refazer o tudo
#      - adicionar opcao para remover uma entrada de dominio ? (mais rapido fazer manual)

Help (){
	echo " "
	echo "Uso: $0 [-u usuario -g grupo [ler|modificar|modificar+|controle-total] dominio1 dominio[n] | -h help | -l lista | -r remove todas entradas]"
	echo " "
	echo "----{ Ex. adicionando: $0 -u ftorres -g ler i0.ig.com i1.ig.com_js"
	echo "----{ Ex. removendo: $0 -r ftorres"
	echo " "
	exit 100
}

Lista (){
	egrep ".*$USUARIO.*" * | awk -F: '{print "Dominio: " $1 "\n Grupo: " $2}'
}

Remove (){
	# Se nao informar o dominio, remove de todos
	${DOMINIO:=*}
	IFS=:
	egrep ".*$USUARIO.*" $DOMINIO | while read DOMINIO GRUPO;do
		echo "Usuario <$USUARIO> removido do grupo <$(echo $GRUPO|cut -d' ' -f1)> pertencente ao dominio <$DOMINIO>"
		echo "sed -i "s/$USUARIO[ ]*//g" $DOMINIO"
	done

}

#[ -z "$1" -o -z "$2" -o -z "$3" ] &&  Help ||

while getopts "r:l:hu:g:" OPT; do
      case "$OPT" in
        "u") export USUARIO="$OPTARG";;
	"g") export GRUPO="$OPTARG";;
        "h") Help ; exit ;;
	"l") export USUARIO="$OPTARG" ; Lista ;  exit;;
	"r") export USUARIO="$OPTARG" ; Remove ; exit;;
	*) Help ; exit ;;
esac
done
# Removo o que ja veio como parametro e pego o resto (que sao os dominios: a b c [n])
used_up=$(expr $OPTIND - 1)
shift $used_up
export DOMINIOS="$*"

case $GRUPO in
	"ler") export LINHA=1 ; export PERM="ler";;
	"modificar") export LINHA=2 ; export PERM="modificar" ;;
	"modificar+") export LINHA=3 ; export PERM="modificar+";;
	"controle-total") export LINHA=4 ; export PERM="controle-total";;
	*) Help; exit 100;;
esac

echo "Adicionando Usuario: $USUARIO ao Grupo: $GRUPO nos Dominios: $DOMINIOS"

for DOMINIO in $DOMINIOS;do
	if [ -e $DOMINIO ];then
                # Verifica se o usuario existe no grupo solicitado
                FLAGUSERGROUP=($(sed -n "/$PERM.*$USUARIO/p" $DOMINIO))

                # Verifica se o usuario existe em algum grupo diferente para fazer update da permissao.
                FLAGGROUP=($(grep -v $PERM $DOMINIO|sed -n "/.*$USUARIO.*/p"))

		if [ ${#FLAGUSERGROUP} -eq 0 -a ${#FLAGGROUP} -eq 0 ]; then
		# Se o usuario NAO existir no dominio solicitado e em nenhum outro, adiciona-o
			sed -i "${LINHA}s/$/ $USUARIO/" $DOMINIO
		else
			if [ ${#FLAGGROUP} != 0 ]; then
				# Se o usuario existir em um grupo direfente, remove-o e adiciona no correto (update)
				sed -i "s/$USUARIO[ ]*//g" $DOMINIO
		                echo "----{ AVISO: Usuario <$USUARIO> já existia no dominio <$DOMINIO> e grupo <$(echo ${FLAGGROUP[0]} | sed 's/://g')>, foi realizado update de permissões para o solicitado <$PERM>."
				sed -i "${LINHA}s/$/ $USUARIO/" $DOMINIO
			else
				echo "----{ AVISO: Usuario <$USUARIO> já existente no dominio <$DOMINIO> pertencente ao grupo <$(echo ${FLAGUSERGROUP[0]} | sed 's/://g')>, NAO adicionado."
			fi
			
		fi
	else
		echo "----{ AVISO: Arquivo <$DOMINIO> nao encontrado"
	fi
done
