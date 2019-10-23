#!/bin/bash

VersionString=`grep -E 's.version.*=' WZPDatePicker.podspec`
VersionNumber=`tr -cd 0-9 <<<"$VersionString"`

NewVersionNumber=$(($VersionNumber + 1))
LineNumber=`grep -nE 's.version.*=' WZPDatePicker.podspec | cut -d : -f1`
sed -i "" "${LineNumber}s/${VersionNumber}/${NewVersionNumber}/g" WZPDatePicker.podspec

echo "current version is ${VersionNumber}, new version is ${NewVersionNumber}"

git add .
git commit -am '日期选择范围限定'#${NewVersionNumber}
git tag ${NewVersionNumber}
git push origin master --tags
pod repo push WZPRepoSpecs WZPDatePicker.podspec --verbose --allow-warnings --use-libraries --use-modular-headers

