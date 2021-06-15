## Workflow for Internal USe

**for Author**

```
git checkout main
git pull
git checkout test
git pull origin main
git add .
git commit -m 'docs(./README.md): Add Naming Convention'
git rebase -i main
git checkout main
git merge test
git push origin main
```
**for collaboration**

```
git checkout main
git pull upstream main
git status
git push
git checkout test
git pull upstream main
git status
git push
git add .
git commit -m 'docs(./README.md): Add Naming Convention'
git push -u origin test
```
Then create a pull request for ‘new_branch’