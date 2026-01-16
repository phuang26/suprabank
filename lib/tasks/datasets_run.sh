#!/bin/bash

#realpath is needed and can be installed by brew or apt
#brew install coreutils
#name=$(file $1)

#Get Rails ENV, only works in dev
# ENV_info=$(bundle exec rails r "puts Rails.env" 2>&1)
# echo $ENV_info
# a=( $ENV_info )
# ENV=${a[0]}
# env_alert="The Rails environment is: \033[1;31m$ENV\033[0m"
# echo -e $env_alert

if [ -z "$1" ]
  then
    argumentmissing="Please provide the Rails environment as an argument such as: development, or production."
    echo -e "\033[1;31mArgument missing\033[0m: $argumentmissing"
    exit 1
fi

ENV="$1"
env_alert="The Rails environment is: \033[1;31m$ENV\033[0m"
echo -e $env_alert

echo -e "\033[1;34mTask starts:\033[0m Identifiers:Existing in $ENV"
RAILS_ENV=$ENV bundle exec rake identifiers:existing 
wait
echo -e "\033[1;32mTask completed:\033[0m Identifiers:Existing"

echo -e "\033[1;34mTask starts:\033[0m Identifiers:Transfer"
RAILS_ENV=$ENV bundle exec rake identifiers:transfer
wait 
echo -e "\033[1;32mTask completed:\033[0m Identifiers:Transfer"

echo -e "\033[1;34mTask starts:\033[0m Identifiers:crossref in $ENV"
RAILS_ENV=$ENV bundle exec rake identifiers:crossref
wait 
echo -e "\033[1;32mTask completed:\033[0m Identifiers:crossref"

echo -e "\033[1;34mTask starts:\033[0m orcid:runall in $ENV"
RAILS_ENV=$ENV bundle exec rake orcid:runall
wait 
echo -e "\033[1;32mTask completed:\033[0m orcid:runall"


echo -e "\033[1;34mTask starts:\033[0m datasets:draft in $ENV"
RAILS_ENV=$ENV bundle exec rake datasets:draft
wait 
echo -e "\033[1;32mTask completed:\033[0m datasets:draft"

echo -e "\033[1;34mTask starts:\033[0m datasets:datacite_update in $ENV"
RAILS_ENV=$ENV bundle exec rake datasets:datacite_update
wait 
echo -e "\033[1;32mTask completed:\033[0m datasets:datacite_update"

echo -e "\033[1;34mTask starts:\033[0m datasets:register in $ENV"
RAILS_ENV=$ENV bundle exec rake datasets:register
wait 
echo -e "\033[1;32mTask completed:\033[0m datasets:register"

echo -e "\033[1;34mTask starts:\033[0m datasets:publish in $ENV"
RAILS_ENV=$ENV bundle exec rake datasets:publish
wait 
echo -e "\033[1;32mTask completed:\033[0m datasets:publish"