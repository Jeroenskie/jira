#JIRA Software Docker Build

##Create new image
1.	Telnet DCS01
2.	Login
3.	sudo docker build -t jeroenskie/jira:<version nr> github.com/Jeroenskie/jira.git

##Push image to Docker Hub
1.	sudo docker login
2.	sudo docker push jeroenskie/jira:<version>