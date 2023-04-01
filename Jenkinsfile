pipeline {
    agent {label 'docker-node'}

     parameters {
            string(
            name: "Branch_Name", 
            defaultValue: 'main', 
            description: '')
            string(
            name: "UBUNTU_VERSION", 
            defaultValue: 'jammy', 
            description: 'version of ubuntu base image')
            string(
            name: "PHP_VERSION",
            defaultValue: '8.1', 
            description: 'PHP version')
            string(
            name: "IMAGE_NAME", 
            defaultValue: 'afoxdocker/remote-wake-sleep-on-lan-docker', 
            description: 'name of the image')
    }

    environment {
        dockerImage = '' // set later with build
    }


    stages {
        stage('Build image') {
            steps {
                //                     --no-cache \
                dir('build') {
                    script {
                    echo "Bulding docker images"
                    def buildArgs = """\
                    --build-arg UBUNTU_VERSION=${params.UBUNTU_VERSION} \
                    --build-arg PHP_VERSION=${params.PHP_VERSION} \
                    -f Dockerfile \
                    ."""
                    dockerImage = docker.build(
                    "${params.IMAGE_NAME}:$BUILD_NUMBER",
                    buildArgs)
                    }
                }
            }
        }
        stage('Tag image') {
            steps {
                script {
                    echo "Tagging docker image"
                    sh "docker tag ${params.IMAGE_NAME}:$BUILD_NUMBER ${params.IMAGE_NAME}:latest";
                }
            }
        }
        stage('Push Image') {
            steps{    
                script {
                    docker.withRegistry( '', 'dockerhub' ) {
                        dockerImage.push("$BUILD_NUMBER")
                        dockerImage.push("latest")
                    }
                }
            }
        }
    }
}