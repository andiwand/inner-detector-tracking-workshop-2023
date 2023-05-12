# ~/.profile: executed by Bourne-compatible login shells.

if [ "$BASH" ]; then
  if [ -f ~/.bashrc ]; then
    . ~/.bashrc
  fi
fi

mesg n 2> /dev/null || true


# acts setup

sourec /usr/local/bin/thisroot.sh
source /usr/local/bin/geant4.sh
source /usr/local/bin/thisdd4hep.sh

source /acts-install/bin/this_acts.sh
source /acts-install/bin/this_odd.sh
source /acts-install/python/setup.sh
