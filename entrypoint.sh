#!/bin/bash

# Parameters
doctype=$1
sourceDirs=$2
targetFolder=$3
githubBranchName=$4
githubAccessToken=$5
githubUserName=$6
githubRepository=$7

#doctype="kotlinDocs"
#sourceDirs="sample-hello-world/src/main/java/com/github/shynixn/universe;sample-hello-world/src/main/java/com/github/shynixn"
#githubBranchName="master"
#githubRepository="StructureBlockLib"
#targetFolder="docs/myapidocs"
#mkdir "master"
#git clone https://github.com/Shynixn/StructureBlockLib

# Setup Folder
targetFolder=$githubRepository/$targetFolder
mkdir -p $targetFolder

# Generate the KotlinDocs or JavaDocs
if [ "$doctype" = "kotlinDocs" ]; then
  mkdir kotlinDocs
  requiredDokkaPlugins="dokka-base.jar;dokka-analysis.jar;kotlin-analysis-compiler.jar;kotlin-analysis-intellij.jar;kotlinx-html-jvm.jar"
  ls
  chmod +x dokka-cli.jar
  java -jar dokka-cli.jar -moduleName "$artifactId" -pluginsClasspath $requiredDokkaPlugins -sourceSet "-src $sourceDirs" -outputDir "kotlinDocs"
  docMessage="KotlinDocs"
  cp -a kotlinDocs/. $targetFolder
else
  IFS=';' read -r -a array <<< "$sourceDirs"
  arraylength=${#array[@]}
  for (( i=0; i<${arraylength}; i++ ));
  do
    directory="${array[$i]}"
    find $directory -type f -name "*.java" >> doclist.txt
  done
  cat doclist.txt | xargs javadoc -d javaDocs
  docMessage="JavaDocs"
  cp -a javaDocs/. $targetFolder
fi

# Setup the repository
git config --global user.email "jvm-docs-agent@email.com" && git config --global user.name "Jvm Docs Agent"

# Push the changes to Github
cd $githubRepository
git add --all
git commit --message "Updated $docMessage."
git push --quiet "https://$githubUserName:$githubAccessToken@github.com/$githubUserName/$githubRepository.git" HEAD:$githubBranchName
echo "Updated $docMessage."
