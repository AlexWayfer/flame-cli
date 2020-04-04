# frozen_string_literal: true

alias_tool :migrate, 'migrations:run'

alias_tool :migrations, 'migrations:list'

alias_tool :dump, 'dumps:create'

alias_tool :dumps, 'dumps:list'

alias_tool :restore, 'dumps:restore'
