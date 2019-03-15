#!/bin/bash

function showhelper()
{
    echo "================================================="
    echo "the purpose of this file is adding line prefix and line suffix!!!"
    echo "you must pass in one arg at least or more!!!"
    echo "if only one arg pass in ,it must be file type!!!"
    echo "datatransfer.sh [-h abc] [-t tail,] filename"
    echo "-? --help : show command details"
    echo '-h --head arg : insert [arg] into each line head ,default is {"} '
    echo '-t --tail arg : insert [arg] into each line tail ,default is {",}'
    echo "================================================="
}


function is_file()
{
    if [ ! -f "$1" ] ; 
    then
        return 1
    else
        return 0
    fi
}


function do_edit_line()
{
    filename=''
    prefix='"'
    suffix='",'
    next_do_what=0
    for cmd in "$@" 
    do                 
        echo ${cmd}
        case "${next_do_what}" in
            "1")
                prefix="${cmd}"
                next_do_what=0
                continue
                ;;
            "2")
                suffix="${cmd}"
                next_do_what=0
                continue
                ;;
        esac

        is_file "${cmd}"
        if ([ $? == 0 ] && [ ${#filename} == 0 ]);
        then
            filename=${cmd}            
        elif [ "${cmd}" == '-h' -o "${cmd}" == '--head' ];            
        then
            next_do_what=1            
        elif [ "${cmd}" == '-t' -o "${cmd}" == '--tail' ];
        then
            next_do_what=2            
        else
            echo "======[ unknow commond ]====="
            showhelper
            exit 0
        fi

    done

    if [ ${#filename} == 0 ];
    then
            echo "======[ must pass in file ]====="
            showhelper
            exit 0
    fi
    
    # dos2unix ${filename}

    pid="$$"
    
    tmpfile="${pid}_${filename}.tmp"
    sed "s/^/${prefix}/g" ${filename} > ${tmpfile}
    sed "s/$/${suffix}/g" ${tmpfile} > ${filename}

    rm -f ${tmpfile}
    echo  "===== [ finish ] ====="

    result="failed"
    if [ $? == 0 ];
    then
        result="success"
    fi

    echo "===== [ ${result} ]====="
}


# do_edit_line 3.txt -h \" -t \",
echo "do_edit_line $*"
do_edit_line "$@"

