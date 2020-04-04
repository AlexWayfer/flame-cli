#!/bin/sh

. `dirname "$0"`/../_common.sh

if [ ! -f ".node-version" ]
then
	echo "File .node-version not found."
	exit 0
fi

if [ "$(cat .node-version)" != "$(node -v | tr -d 'v')" ]
then
	exe git -C ~/.nodenv/plugins/node-build pull
	exe nodenv install -s
fi

## Please, install Yarn manually: https://classic.yarnpkg.com/en/docs/install

if ! yarn check
then exe yarn install
fi

exe yarn build
