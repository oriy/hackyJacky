#!/bin/bash
# https://gist.github.com/betorobson/23e5914b51e844bac5eaa6032d6f3f88
# https://gist.github.com/sindresorhus/7996717

changed_files="$(git diff-tree -r --name-only --no-commit-id $1 $2)"

##
# check_run()
# check if a file has changed, if so, evaluate given command
#  args:
#  $1 - fileNameRegex - file name regex to check
#  $2 - command - command to execute
check_run() {
    fileNameRegex="$1"
    command="$2"

	if echo "$changed_files" | grep --quiet "$fileNameRegex"; then
	    echo " * changes detected in $fileNameRegex"
	    echo " * executing '$command'"
	    eval "$command";
	fi
}

##
# suggest_command()
# conditionally execute a command when specified files change
#  args:
#  $1 - git config key
#  $2 - command location
#  $3 - command to execute
suggest_command() {
    gitConfigKey="$1"
    scriptLocation="$2"
    command="$3"

    gitConfigOption="git.autoRun.$gitConfigKey"
    if [ "$(git config --get-all $gitConfigOption)" == "true" ]; then
        echo " * git config '$gitConfigOption' is set true"
        echo " ** executing '$command'"
        pushd "$scriptLocation" > /dev/null
        if ! type "$command" 2> /dev/null; then
            command="./$command"
        fi
        execution=$($command 2>&1)
        echo "$execution"
        popd > /dev/null;
        echo " ** done"
        echo " * script can be disabled from running automatically by updating the git config option:"
        echo " =>   git config $gitConfigOption false"
    else
        echo " * you may want to run the following command from $scriptLocation>"
        echo " =>   $command"
        echo " * the command would run automatically if you set the following git config option:"
        echo " =>   git config $gitConfigOption true"
    fi
}

CONFIG_DIR=.git/hooks/config
for file in $(ls ${CONFIG_DIR}); do
  case "$file" in
    *.config)        source "${CONFIG_DIR}/$file" ;;
    *)        ;;
  esac
done
