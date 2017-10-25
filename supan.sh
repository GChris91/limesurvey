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


log=/tmp/${0}.log

#Réinitialise le log
echo "">${log}


##########################
#           			 #
#   	 LIBRARY         #
#			             #
##########################


#Import usersbdd

importUsersbdd(){

    cmd="mysql -u ${myUser} -p${myPassword} ${myData}"
#    echo ${cmd} >> ${log}
    eval ${cmd} >> ${log} 2>&1
   
#    cmd="SELECT uid, users_name FROM limesurvey_users; > sources/usersbdd.txt"
#    echo ${cmd} >> ${log}
#    eval ${cmd} >> ${log} 2>&1

}


#Import supann

importSupan(){

    rm -Rf outputs
    mkdir outputs

    awk '{print $2}' sources/usersbdd.txt > sources/usersname.txt
    
    while read -r LINE; do
       cmd="ldapsearch -x -H ldaps://ldap.univ-nc.nc -b ou=people,dc=univ-nc,dc=nc -LLL -s sub \"(uid=${LINE})\" supannEntiteAffectation >> outputs/${LINE}.txt)"
       echo ${cmd} >> ${log} 
       eval ${cmd} >> ${log} 2>&1
    sed 's/[^0-9]*//g' < ${LINE} >${LINE}
    done < sources/usersname.txt

#    find . -type f -exec awk -v x=2 'NR==x{exit 1}' {} \; -exec echo rm -f {} \;

#    sed 's/[^0-9]//g' outputs/*.txt
    sed 's/^\([0-9][0-9]*\).*$/\1/' outputs/*.txt

}



##########################
#           			 #
#   	 SCRIPTS         #
#			             #
##########################


importUsersbdd;
#importSupan;

cat ${log}
#rm -f ${log}
