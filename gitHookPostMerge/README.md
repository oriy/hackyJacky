### Extension for git-hook post commands
**presented at https://gist.github.com/sindresorhus/7996717**

git hook to run a command after `git pull` if a specified file was changed.

In this example it's used to run `npm install` if package.json changed.


#### Added **`installGitHooks` gradle task** for installing hooks into git hooks folder

#### Presenting **`suggest_command()`** bash function
    # suggest_command()
    # conditionally execute a command when specified files change
    #  args:
    #  $1 - git config key
    #  $2 - command location
    #  $3 - command to execute

example:
```
suggest_gradle_idea() {
    suggest_command 'idea' '.' 'gradlew idea'
}

check_run "\.gradle" "suggest_gradle_idea"
```

changes of gradle files would only suggest executing the specified command
```
 * changes detected in \.gradle
 * executing 'suggest_gradle_idea'
 * you may want to run the following command from .>
 =>   gradlew idea
 * the script would run automatically if you set the following git config option:
 =>   git config git.autoRun.idea true
```

actual execution depend on the git config value of `git.autoRun.idea`

when config value is set true, git hook execution would be:
```
 * changes detected in \.gradle
 * executing 'suggest_gradle_idea'
 * git config 'git.autoRun.idea' is set true
 ** executing 'gradlew idea'
 ...
 ...
 ...
 ** done
 * script can be disabled from running automatically by updating the git config option:
 =>   git config git.autoRun.idea false
```

