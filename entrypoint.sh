#!/bin/bash

# Parameters
doctype=$1
sourceDirs=$2
targetFolder=$3
githubBranchName=$4
githubUserName=$5
githubRepository=$6
githubAccessToken=$7

$githubBranchName=${githubBranchName##*/}
$githubRepository=${githubRepository#*/}

#doctype="kotlinDocs"
#sourceDirs="sample-hello-world/src/main/java/com/github/shynixn/universe;sample-hello-world/src/main/java/com/github/shynixn"
#githubBranchName="master"
#githubRepository="StructureBlockLib"
#targetFolder="docs/myapidocs"
#mkdir "master"
#git clone https://github.com/Shynixn/StructureBlockLib

# Setup Folder
echo "Folder"
ls
mkdir -p $targetFolder

# Generate the KotlinDocs or JavaDocs
if [ "$doctype" = "kotlinDocs" ]; then
  mkdir kotlinDocs
  requiredDokkaPlugins="/tmp/dokka-base.jar;/tmp/dokka-analysis.jar;/tmp/kotlin-analysis-compiler.jar;/tmp/kotlin-analysis-intellij.jar;/tmp/kotlinx-html-jvm.jar"
  ls
  chmod +x /tmp/dokka-cli.jar
  java -jar /tmp/dokka-cli.jar -moduleName "$artifactId" -pluginsClasspath $requiredDokkaPlugins -sourceSet "-src $sourceDirs" -outputDir "kotlinDocs"
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

# Tmp
echo "https://$githubUserName:$githubAccessToken@github.com/$githubRepository.git"
echo "HEAD:$githubBranchName"
echo "$targetFolder"

# Push the changes to Github
cd $targetFolder
git add .
git commit --message "Updated $docMessage."
git push --quiet "https://$githubUserName:$githubAccessToken@github.com/$githubRepository.git" "HEAD:$githubBranchName"
echo "Updated $docMessage."

echo "Tmp"
cd /tmp
ls
