#!/bin/bash
set -e

if [[ "${bamboo_ENV}" = "live" ]]
then

  ## LIVE ####################################################
  export ACCOUNT_ID='452809762934'

elif [[ "${bamboo_ENV}" = "uat" ]]
then

  ## UAT #####################################################
  export ACCOUNT_ID='767626887759'

else

  ## DEV #####################################################
  export bamboo_ENV='dev'
  export ACCOUNT_ID='664994689501'

fi

login-to-aws.sh
cd ${bamboo_TYPE}/${bamboo_PROJECT}/ami
packer build -var-file=environment/${bamboo_ENV}.json template/emr.json