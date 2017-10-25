#!/bin/bash



##########################
#           			 #
#   	 CONFIGS         #
#			             #
##########################


myUser='root';
myPassword='password';
myData='limesurveybdd';
myTable='limesurvey_users'
usersbdd='sources/usersbdd.txt'

log=/tmp/${0}.log

#Réinitialise le log
echo "">${log}


##########################
#           			 #
#   	 LIBRARY         #
#			             #
##########################


#IMPORT USERSBDD

importUsersbdd(){

    MySQL="mysql -u ${myUser} -p${myPassword} ${myData}"
    
    cmd="echo \"SELECT CONCAT_WS (' ', uid, users_name) FROM limesurvey_users;\"| ${MySQL} > sources/usersbdd.txt"
    echo ${cmd} >> ${log}
    eval ${cmd} >> ${log} 2>&1

    sed -i '1d' sources/usersbdd.txt
}


#IMPORT SUPAN

importSupan(){

    rm -Rf outputs
    mkdir outputs

    echo 1

    awk '{print $2}' sources/usersbdd.txt > sources/usersname.txt
    
    while read -r LINE; do
       cmd="ldapsearch -x -H ldaps://ldap.univ-nc.nc -b ou=people,dc=univ-nc,dc=nc -LLL -s sub '(uid=${LINE})' supannEntiteAffectation >> outputs/${LINE}.txt"
       echo ${cmd} >> ${log} 
       eval ${cmd} >> ${log} 2>&1
#    sed 's/[^0-9]*//g' < ${LINE} >${LINE}
    done < sources/usersname.txt
    echo 1
    cd /outputs/
    cmd="find ./outputs -type f -exec awk -v x=2 'NR==x{exit 1}' {} \; -exec rm -f {} \;"
    echo ${cmd} >> ${log} 
    eval ${cmd} >> ${log} 2>&1

    echo here
    
    for file in $(outputs/*.txt)
    do
    cmd="sed -i 's/[^0-9]//g' ${file}"
    echo ${cmd} >> ${log} 
    eval ${cmd} >> ${log} 2>&1
#    sed 's/^\([0-9][0-9]*\).*$/\1/' outputs/*.txt
    done

    echo ici

}



##########################
#           			 #
#   	 SCRIPTS         #
#			             #
##########################


importUsersbdd;
importSupan;

echo Fini >> ${log}

cat ${log}
#rm -f ${log}

