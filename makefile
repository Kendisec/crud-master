MESSAGE = $1
config1: 
	cd .git && git remote add github https://github.com/Kendisec/crud-master.git

config2: 
	cd .git && git remote add github1 https://github.com/Baabacar/crud_master.git
	
push: 
	git add . && git commit -m "$(MESSAGE)" && git push origin && git push github1  &&  git push github

merge:
	git checkout $(TO) && git merge $(FROM)



