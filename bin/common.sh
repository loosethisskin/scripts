function get_repo_name()
{
	if [ "$1" == "./.git" ]; then
		echo .
	else
		echo $1 | sed -e 's/^.\///' -e 's/\/.git$//'
	fi
}

