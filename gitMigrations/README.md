## Git import from other VCS

### import from Git

EASY!

```
git clone <remote repo URL> <local git repo folder>
cd <local git repo folder>
```

* branches

    right before changing the remote origin, checkout all branches you wish to migrate
    
    run this script ([git_list_branches.sh](git_list_branches.sh)) if you wish to migrate all branches
    
* authors
 
    you can optionally rewrite commit authors if needed
    
    1. extract list of authors:
    
        `git log | grep Author: | sort | uniq | sed 's/Author: *//' > ../git-authors`  ([git_log_authors.sh](git_log_authors.sh))
        
    2. execute ([git_author_rewrite.sh](git_author_rewrite.sh)) on each committer/author needs fixing
    
        `<path to git_author_rewrite.sh> wrong@email Name Surname correct@email`

* large files

    list large files ([git_list_large_files.sh](git_list_large_files.sh))
    
    remove large files from history ([git_remove_files.sh](git_remove_files.sh))
  ```
    <path to git_remove_files.sh> [list of file paths]
  ```
    run gc after files cleanup
  ```
      git reflog expire --expire=now --all
      git gc --prune=now
  ```

Finally
```
git remote rm origin                                                         
git remote add origin git@my-git-server:myrepository.git
git push -u origin master
```

---


### import from Mercurial

Since Mercurial and Git have fairly similar models for representing versions,
 and since Git is a bit more flexible, converting a repository from Mercurial to Git is fairly straightforward,
  using a tool called **"hg-fast-export"**, which you’ll need a copy of:

---
 
`git clone https://github.com/frej/fast-export.git`

> due to a known issue https://github.com/frej/fast-export/issues/134
  you might get the following error:
   
>`File "/home/tcamuso/bin/hg-fast-export.py", line 7, in`
>`from mercurial.scmutil import revsymbol`

>`ImportError: cannot import name revsymbol`

>*** fix by running ***

>`cd fast-export; git checkout v180317`

The first step in the conversion is to get a full clone of the Mercurial repository you want to convert:

`hg clone <remote repo URL> <local hg repo folder>`
 

The next step is to create an **author mapping file**.
 Mercurial is a bit more forgiving than Git for what it will put in the author field for changesets,
 so this is a good time to clean house. Generating this is a one-line command in a bash shell:

`cd <local hg repo folder>`

`hg log | grep user: | sort | uniq | sed 's/user: *//' > ../hg-authors` ([hg_log_users.sh](hg_log_users.sh))

This will take a few seconds, depending on how long your project’s history is,
 and afterwards the authors file will look something like this:

```
bob
bob@localhost
bob <bob@company.com>
bob jones <bob <AT> company <DOT> com>
Bob Jones <bob@company.com>
Joe Smith <joe@company.com>
```
In this example, the same person (Bob) has created changesets under four different names,
 one of which actually looks correct, and one of which would be completely invalid for a Git commit.
 Hg-fast-export lets us fix this by turning each line into a rule: `"<input>"="<output>"`,
 mapping an `<input>` to an `<output>`.
 Inside the `<input>` and `<output>` strings,
 all escape sequences understood by the python string_escape encoding are supported.
  
If the author mapping file does not contain a matching `<input>`,
 that author will be sent on to Git unmodified. If all the usernames look fine, we won’t need this file at all.
  
In this example, we want our file to look like this:

```
"bob"="Bob Jones <bob@company.com>"
"bob@localhost"="Bob Jones <bob@company.com>"
"bob <bob@company.com>"="Bob Jones <bob@company.com>"
"bob jones <bob <AT> company <DOT> com>"="Bob Jones <bob@company.com>"
```

The same kind of mapping file can be used to rename branches and tags when the Mercurial name is not allowed by Git.

Common branches mapping might be 
```
"default"="master"
```

The next step is to create our new Git repository, and run the export script:

`git init <new repo>`
> `Initialized empty Git repository in .../<new repo>/.git/`

`cd <new repo>`

`<path to hg-fast-export>/hg-fast-export.sh -r <path to hg repo> -A <path to authors> -B <path to branches mapping>`

The -r flag tells hg-fast-export where to find the Mercurial repository we want to convert,
 and the -A flag tells it where to find the author-mapping file
 (branch and tag mapping files are specified by the -B and -T flags respectively).
  
The script parses Mercurial changesets and converts them into a script for Git’s "fast-import" feature (which we’ll discuss in detail a bit later on).
 This takes a bit (though it’s much faster than it would be over the network),
  and the output is fairly verbose:

```
Loaded 4 authors
Loaded 1 branches
master: Exporting full revision 1/22208 with 13/0/0 added/changed/removed files
master: Exporting simple delta revision 2/22208 with 1/1/0 added/changed/removed files
master: Exporting simple delta revision 3/22208 with 0/1/0 added/changed/removed files
[…]
master: Exporting simple delta revision 22206/22208 with 0/4/0 added/changed/removed files
master: Exporting simple delta revision 22207/22208 with 0/2/0 added/changed/removed files
master: Exporting thorough delta revision 22208/22208 with 3/213/0 added/changed/removed files
Exporting tag [0.4c] at [hg r9] [git :10]
Exporting tag [0.4d] at [hg r16] [git :17]
[…]
Exporting tag [3.1-rc] at [hg r21926] [git :21927]
Exporting tag [3.1] at [hg r21973] [git :21974]
Issued 22315 commands
git-fast-import statistics:
---------------------------------------------------------------------
Alloc'd objects:     120000
Total objects:       115032 (    208171 duplicates                  )
      blobs  :        40504 (    205320 duplicates      26117 deltas of      39602 attempts)
      trees  :        52320 (      2851 duplicates      47467 deltas of      47599 attempts)
      commits:        22208 (         0 duplicates          0 deltas of          0 attempts)
      tags   :            0 (         0 duplicates          0 deltas of          0 attempts)
Total branches:         109 (         2 loads     )
      marks:        1048576 (     22208 unique    )
      atoms:           1952
Memory total:          7860 KiB
       pools:          2235 KiB
     objects:          5625 KiB
---------------------------------------------------------------------
pack_report: getpagesize()            =       4096
pack_report: core.packedGitWindowSize = 1073741824
pack_report: core.packedGitLimit      = 8589934592
pack_report: pack_used_ctr            =      90430
pack_report: pack_mmap_calls          =      46771
pack_report: pack_open_windows        =          1 /          1
pack_report: pack_mapped              =  340852700 /  340852700
---------------------------------------------------------------------
```

That’s pretty much all there is to it.
 
 All of the Mercurial tags have been converted to Git tags, and Mercurial branches and bookmarks have been converted to Git branches.
  
 Now you’re ready to push the repository up to its new server-side home:

```
git remote add origin git@my-git-server:myrepository.git
git push origin --all
```

alternatively you can push a specific branch only
 
```
git push -u origin master
```

---

links:

- Git Migrations - https://git-scm.com/book/en/v2/Git-and-Other-Systems-Migrating-to-Git

- Mercurial-to-Git fast export - https://github.com/frej/fast-export

- Removing large files from Mercurial - https://www.jitbit.com/alexblog/232-removing-files-from-mercurial-history

- BFG Repo-Cleaner alternative for git-filter-branch - https://rtyley.github.io/bfg-repo-cleaner

- Git extract repository from subdirectory - http://alyssafrazee.com/2014/05/01/popping-a-subdirectory.html