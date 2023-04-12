- change author in all commits
```bash
git rebase -r [prev_commit] \
    --exec 'git commit --amend --no-edit --reset-author'
```

- list all files in the repo
```bash
git log --pretty=format: --name-only --diff-filter=A  | sort -u
```

- remove a file in all branch and all commits
```bash
git filter-branch --index-filter 'git rm --cached --ignore-unmatch [file_path]' HEAD
```

- find first commit for a given file
```bash
git log --diff-filter=A -- [filename]
```