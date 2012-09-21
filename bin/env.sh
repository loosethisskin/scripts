alias gl1='git log --pretty=format:"[%cd] %h - %an: %s [Authored %ar]"'
alias gl2='git log --pretty=format:"[%cd] %h - %an: %s [Authored %ar]" --graph --date=short'
alias gl3='git log --pretty=format:"[%cd] %h - %an: %s [Authored %ar]" --stat --date=short'
alias gl4='git log --pretty=format:"[%cd] %h - %an: %gs %d [Authored %ar]" --date=short --walk-reflogs'

alias gb='git branch'
alias gr='git remote'
alias gs='git status'

function get_repo_name()
{
	if [ "$1" == "./.git" ]; then
		echo .
	else
		echo $1 | sed -e 's/^.\///' -e 's/\/.git$//'
	fi
}

function git_fetch()
{
  local option
  if [ "$1" == "--all" ] || [ "$1" == "-all" ] || [ "$1" == "-a" ]; then
    option="-a"
    shift
  fi

  for d in `find . -type d -name .git | sort -V`
  do
    cd $d/..
    if [ "$option" == "-a" ]; then
      echo ""
      echo "Repository => $(get_repo_name $d)"
      git fetch --all $* | sed -e 's/.*/  &/'
    elif [ ! -z "$1" ]; then
      for remote in `git remote | grep "$1"`
      do
        echo ""
        echo "Repository => $(get_repo_name $d)"
        echo "  Fetching $remote"
        git fetch $remote | sed -e 's/.*/  &/'
      done
    else
      echo "Repository => $(get_repo_name $d)"
      git fetch | sed -e 's/.*/  &/'
    fi
    cd - > /dev/null
  done
}

function git_branch()
{
  for d in `find . -type d -name .git | sort -V`
  do
    cd $d/..
    echo ""
    echo "Repository => $(get_repo_name $d)"
    if [ -z "$1" ]; then
      git branch | sed -e 's/.*/  &/'
    else
      git branch $* | sed -e 's/.*/  &/'
    fi
    cd - > /dev/null
  done
}

function git_reflog()
{
  if [ "$1" == "-r" ]; then
    for d in `find . -type d -name .git | sort -V`
    do
      cd $d/..
      echo ""
      echo "Repository => $(get_repo_name $d)"
      #echo "# $d" | sed -e 's/\/.git$//'
      #git reflog show `git branch | grep "^*" | sed -e 's/* //'` --date=local | head -100000
      git reflog show `git branch | grep "^*" | sed -e 's/* //'` --date=local | sed -e 's/.*/  &/'
      cd - > /dev/null
    done
  else
    git reflog show `git branch | grep "^*" | sed -e 's/* //'` --date=local
  fi
}

function git_remote()
{
  for d in `find . -type d -name .git | sort -V`
  do
    cd $d/..
    echo ""
    echo "Repository => $(get_repo_name $d)"
    git remote -v | sed -e 's/.*/  &/'
    cd - > /dev/null
  done
}
