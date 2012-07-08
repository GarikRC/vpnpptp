#!/bin/bash

# using this script: whitelist program_name
# использование скрипта: whitelist название_программы

if [ $# -ne 1 ];then
        echo "One and only one name of program needed"
        exit 1
fi

SCHEMA="com.canonical.Unity.Panel"
OBJECT="systray-whitelist"
APP="$1"
if [ ! "$(gsettings get $SCHEMA $OBJECT 2>/dev/null || echo FALSE)" = "FALSE" ]; then
  echo "Whitelisting $APP to work around flawed distribution design..."
  OBJARRAY=$(gsettings get $SCHEMA $OBJECT | sed -s -e "s#\['##g" -e "s#', '# #g" -e "s#'\]##g")
  if [[ "${OBJARRAY[@]}" =~ "$APP" ]]; then
    echo "$APP already whitelisted, skipping"
  else
    OBJARRAY=("${OBJARRAY[@]}" $APP)
    OBJARRAY=$(echo ${OBJARRAY[@]} | sed -s -e "s# #', '#g")
    OBJSET="['"$OBJARRAY"']"
    gsettings set $SCHEMA $OBJECT "$OBJSET"
    echo "$APP was added in whitelist, please reboot"
  fi
else
  echo "This is not a Canonical \"designed\" product."
fi
