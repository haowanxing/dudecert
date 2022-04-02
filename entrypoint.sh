#!/bin/sh

echo "Start initialize..."
DIR_WORK=/opt
DIR_ROOT=/opt/ca/root
DIR_AGENT=/opt/ca/agent
DIR_SITE=/opt/site
SITE_CNF=${DIR_SITE}/site.cnf
SITE_PK=${DIR_SITE}/privkey.pem
SITE_CSR=${DIR_SITE}/site.csr
SITE_CRT=${DIR_SITE}/site.crt
if [[ ! -d ${DIR_ROOT}/key ]];then
	mkdir ${DIR_ROOT}/key
fi
if [[ ! -d ${DIR_ROOT}/newcerts ]];then
	mkdir ${DIR_ROOT}/newcerts
fi
if [[ ! -f ${DIR_ROOT}/index.txt ]];then
	touch ${DIR_ROOT}/index.txt
fi
if [[ ! -f ${DIR_ROOT}/index.txt.attr ]];then
	touch ${DIR_ROOT}/index.txt.attr
fi
if [[ ! -f ${DIR_ROOT}/serial ]];then
	echo 01 > ${DIR_ROOT}/serial
fi
# ConfigureFile
if [[ ! -f ${DIR_ROOT}/openssl.cnf ]];then
	cp /data/root-openssl.cnf ${DIR_ROOT}/openssl.cnf
fi

if [[ ! -d ${DIR_AGENT}/key ]];then
	mkdir ${DIR_AGENT}/key
fi
if [[ ! -d ${DIR_AGENT}/newcerts ]];then
	mkdir ${DIR_AGENT}/newcerts
fi
if [[ ! -f ${DIR_AGENT}/index.txt ]];then
	touch ${DIR_AGENT}/index.txt
fi
if [[ ! -f ${DIR_AGENT}/index.txt.attr ]];then
	touch ${DIR_AGENT}/index.txt.attr
fi
if [[ ! -f ${DIR_AGENT}/serial ]];then
	echo 01 > ${DIR_AGENT}/serial
fi
# ConfigureFile
if [[ ! -f ${DIR_AGENT}/openssl.cnf ]];then
	cp /data/agent-openssl.cnf ${DIR_AGENT}/openssl.cnf
fi
# gen root-ca
if [[ ! -f "${DIR_ROOT}/key/cacert.crt" || ! -f "${DIR_ROOT}/key/cakey.pem" ]];then
	echo -e "[Notice]: -rootCA- cacert.crt or cakey.pem not found. create one!\n"
	openssl genrsa -out ${DIR_ROOT}/key/cakey.pem 2048
	openssl req -new -key ${DIR_ROOT}/key/cakey.pem -out ${DIR_ROOT}/key/ca.csr -config ${DIR_ROOT}/openssl.cnf
	openssl ca -selfsign -in ${DIR_ROOT}/key/ca.csr -out ${DIR_ROOT}/key/cacert.crt -config ${DIR_ROOT}/openssl.cnf -batch -notext
fi
# gen agent-ca

if [[ ! -f "${DIR_AGENT}/key/cacert.crt" || ! -f "${DIR_AGENT}/key/cakey.pem" ]];then
	echo -e "[Notice]: -agentCA- cacert.crt or cakey.pem not found. create one!\n"
	openssl genrsa -out ${DIR_AGENT}/key/cakey.pem 2048
	openssl req -new -key ${DIR_AGENT}/key/cakey.pem -out ${DIR_AGENT}/key/ca.csr -config ${DIR_AGENT}/openssl.cnf
	openssl ca -in ${DIR_AGENT}/key/ca.csr -out ${DIR_AGENT}/key/cacert.crt -config ${DIR_ROOT}/openssl.cnf -batch -notext
fi

# signing
if [[ ! -d ${DIR_SITE} ]];then
	mkdir ${DIR_SITE}
fi
if [[ ! -f ${SITE_CSR} && ! -f ${SITE_CNF} ]];then
	cp /data/site-openssl-tpl.cnf ${SITE_CNF}
	read -p "CommonName[default:abc.com]: " common_name
	[ -z "$common_name" ] && common_name="abc.com"
	read -p "StateOrProvinceName[default:Beijing]: " state_name
	[ -z "$state_name" ] && state_name="Beijing"
	read -p "CountryName[default:CN]: " country_name
	[ -z "$country_name" ] && country_name="CN"
	read -p "OrganizationName[default:Dude Inc]:" org_name
	[ -z "$org_name" ] && org_name="Dude Inc"
	read -p "OrganizationUnitName[default:abc.com]:" unit_name
	[ -z "$unit_name" ] && unit_name="abc.com"
	read -p "Domains[default:abc.com *.abc.com]:" domains
	[ -z "$domains" ] && domains="abc.com"
	sed -i "s/{_common-name}/${common_name}/g" ${SITE_CNF}
	sed -i "s/{_state-province-name}/${state_name}/g" ${SITE_CNF}
	sed -i "s/{_country-name}/${country_name}/g" ${SITE_CNF}
	sed -i "s/{_org-name}/${org_name}/g" ${SITE_CNF}
	sed -i "s/{_org-unit-name}/${unit_name}/g" ${SITE_CNF}

	nb=1
	sed -i '/{_alt-names}/,$d' ${SITE_CNF}
	for domain in $domains;do
		echo "DNS.${nb}=${domain}" >> ${SITE_CNF}
		nb=`expr $nb + 1`
	done
fi
if [[ ! -f ${SITE_CSR} ]];then
	if [[ ! -f ${SITE_PK} ]];then
		openssl genrsa -out ${SITE_PK} 2048
	fi
	openssl req -new -key ${SITE_PK} -out ${SITE_CSR} -config ${SITE_CNF}
	if [[ ! -f "${SITE_CSR}" ]];then
		echo -e "Error: create csr fail!\n"
		exit 1
	fi
fi

[ -e "${SITE_CRT}" ] && rm ${SITE_CRT}
openssl ca -in ${SITE_CSR} -out ${SITE_CRT} -config ${DIR_AGENT}/openssl.cnf --batch -notext
if [[ ! -e "$SITE_CRT" ]];then
	echo -e "sign cert fail!\n"
	exit 1
fi

if [[ -f "${SITE_PK}" ]];then
	echo -e "\n\n\n\n**********************privkey.pem**********************\n\n"
	cat ${SITE_PK}
	echo -e "\n\n"
fi

echo -e "\n\n**********************full_chain.crt**********************\n\n"
openssl x509 -in ${SITE_CRT}
openssl x509 -in ${DIR_AGENT}/key/cacert.crt
openssl x509 -in ${DIR_ROOT}/key/cacert.crt
# cat ${SITE_CRT} ${DIR_AGENT}/key/cacert.crt ${DIR_ROOT}/key/cacert.crt | tee ${DIR_SITE}/site_all.crt
echo -e "\n\n"











