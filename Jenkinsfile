pipeline { 
  agent any 
  tools { 
    gradle 'gradle' 
  } 
  stages { 
    stage('Checkout') { 
	  steps { 
	    cleanWs() 
	    sh 'echo passed' 
		git branch: 'main', url: 'http://localhost:3000/repo/java-sb-gradle.git' 
	  } 
	} 
	stage('Build and Test') { 
	  steps { 
	    sh 'ls -ltr' 
		// build the project and create a JAR file 
		sh 'gradle build' 
	  } 
	} 
	stage('Static Code Analysis') { 
	  steps { 
	      script {
	       withSonarQubeEnv('sonar-server') { 
	       //make sure to give triple double quotes. Otherwise jenkins env variables wont work
	   	   sh """ gradle sonar -Dsonar.projectKey=${JOB_BASE_NAME} \
	  	   -Dsonar.host.url=${env.SONAR_HOST_URL} \
		   -Dsonar.login=${env.SONAR_AUTH_TOKEN} \
		   -Dsonar.projectName=${JOB_BASE_NAME} \
		   -Dsonar.projectVersion=${BUILD_NUMBER} """
	       }
		} 
	  } 
	} 
	stage('Publish Docker Img') { 
		environment { 
		  DOCKER_TAG = "dockerhubrepo/java-sb-gradle:${BUILD_NUMBER}" 
		} 
		steps { 
		  script { 
			def javagradle = docker.build("${DOCKER_TAG}") 
			docker.withRegistry('https://registry.hub.docker.com', "docker") { 
			javagradle.push() 
			} 
		  } 
		} 
	} 
	stage('Update version in K8s repo') { 
	  environment { 
	  GIT_REPO = "http://localhost:3000" 
	  GIT_USER_NAME = "username" 
	  } 
	  steps { 
	  withCredentials([usernamePassword(credentialsId: 'git', passwordVariable: 'PASS', usernameVariable: 'USER')]) { 
	  sh ''' git clone "http://localhost:3000/repo/java-sb-k8s.git" 
	  cd java-sb-k8s 
	  git config user.email "user@mail.com" 
	  git config user.name "${GIT_USER_NAME}" 
	  sed -i "s/dockerhubeponame\\/java-sb-gradle\\:[0-9]*/dockerhubreponame\\/java-sb-gradle\\:${BUILD_NUMBER}/g" deployment.yml 
	  git add . 
	  git commit -m "Update docker container image version to ${BUILD_NUMBER}" 
	  git push http://${USER}:${PASS}@localhost:3000/repo/java-sb-k8s.git ''' 
	  } 
	  } 
	 } 
	} 
}
