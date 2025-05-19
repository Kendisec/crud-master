MESSAGE = $1
config1: 
	cd .git && git remote add github https://github.com/kendisec/crud_master.git

config2: 
	cd .git && git remote add github1 https://github.com/Baabacar/crud_master.git
	
push: 
	git add . && git commit -m "$(MESSAGE)" && git push origin && git push github  &&  git push github1

merge:
	git checkout $(TO) && git merge $(FROM)


