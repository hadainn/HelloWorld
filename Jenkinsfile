def dockerRun= "docker container run  -itd -p 8080:8080  --name webapp  hadain/sample-app:1.0"
pipeline {
    agent {
        label "master"
    }
    tools {
	
        maven "maven"
    }
    environment {
        NEXUS_VERSION = "nexus3"
        NEXUS_PROTOCOL = "http"
        NEXUS_URL = "35.228.119.98:8081"
        NEXUS_REPOSITORY = "demo-app"
        NEXUS_CREDENTIAL_ID = "nexus-server"
    }
    stages {
        stage('Checkout SCM') {
            steps {
               checkout([$class: 'GitSCM', branches: [[name: '*/master']], doGenerateSubmoduleConfigurations: false, extensions: [], submoduleCfg: [], userRemoteConfigs: [[credentialsId: 'dockerhub', url: 'https://github.com/hadainn/hello-world.git']]])'
            }
        }
        stage('Code Test') {
            steps {
                sh "mvn test"	
            }
		post{
		   success{
		        junit 'target/surefire-reports/*.xml'
			    
	       }
	    }
        }
        stage('Code Build') {
            steps {
               sh "mvn -B -DskipTests clean package"
            }
            post{
		  success{
	              archiveArtifacts artifacts: 'target/*.war' , fingerprint: true
	       }
	    } 			
        }
        stage('Static Analysis') {
            steps {
               withSonarQubeEnv('sonar'){
                  sh  "mvn sonar:sonar"
				  
               }
            } 
        }               
        stage('Publish to Nexus Repository') {
            steps {
                script {
                    echo 'Publish to Nexus Repository....'
                    pom = readMavenPom file: "pom.xml";
                    filesByGlob = findFiles(glob: "target/*.${pom.packaging}");
                    echo "${filesByGlob[0].name} ${filesByGlob[0].path} ${filesByGlob[0].directory} ${filesByGlob[0].length} ${filesByGlob[0].lastModified}"
                    artifactPath = filesByGlob[0].path;
                    artifactExists = filesExists artifactPath;
                    if(artifactExists) {
                        echo "*** File: ${artifactPath}, group: ${pom.groupId}, packaging: ${pom.packaging}, version ${pom.version}";
                        nexusArtifactUploader(
                            nexusVersion: NEXUS_VERSION,
                            protocol: NEXUS_PROTOCOL,
                            nexusUrl: NEXUS_URL,
                            groupId: pom.groupId,
                            version: pom.version.${BUILD_NUMBER},
                            repository: NEXUS_REPOSITORY,
                            credentialsId: NEXUS_CREDENTIAL_ID
                            artifacts: [
                                
                                [artifactId: pom.artifactId, classifier: '', file: artifactPath, type: pom.packaging],
                                
                                [artifactId: pom.artifactId, classifier: '', file: "pom.xml", type: "pom"]
                            ]
                        );
                    } else {
                        error "*** File: ${artifactPath}, could not be found";
                     }
                   } 
				
            }	
	 }
	 stage('Build Docker Image'){
		    steps {
			  sh "docker image build  --no-cache -t hadain/sample-app:1.0 ."
			}
			post{
			   success{
			      sh "docker rmi -f $(docker images -f "dangling=true" -q)"
				  
		  }
		}	
	  }
          stage('Push Docker Image to Dockerhub'){
		    steps{
			  withCredentials([usernamePassword(credentialsId: 'dockerhub', passwordVariable: 'dockerpwd', usernameVariable: 'dockeruser')]) {
                 sh  "docker login -u ${dockeruser} -p ${dockerpwd}"
                    }
			     sh "docker image push hadain/sample-app:1.0"
		}
         }
	 stage('Deploying Container on DEv-server'){
		   steps{
		    sshagent(['dev-server']) {
                     sh "ssh -o StrictHostKeyChecking=no root@35.228.160.4   ${dockerRun}"
           }
       }
    }
  }			
}				
				
				
				
				
				
				
