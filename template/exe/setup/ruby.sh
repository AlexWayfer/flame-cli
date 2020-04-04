#!/bin/sh

. `dirname "$0"`/../_common.sh

if [ "$(cat .ruby-version)" != "$(ruby -e "puts RUBY_VERSION")" ]
then
	exe git -C ~/.rbenv/plugins/ruby-build pull
	exe rbenv install -s
fi

if [ \
	"$(tail -n 1 Gemfile.lock | tr -d [:blank:])" != \
		"$(bundler -v | cut -d ' ' -f 3)" \
]
then exe gem install bundler --conservative
fi

if ! bundle check
then exe bundle install
fi
