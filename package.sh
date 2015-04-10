#! /bin/bash

python setup.py \
--command-packages=stdeb.command debianize \
--suite `lsb_release -sc`


VERSION=`git tag | tail -n 1`

TOPLINE=`head -n 1 debian/changelog`
BOTTOMLINE=`tail -n 1 debian/changelog`

echo $TOPLINE > debian/changelog
echo "" >> debian/changelog
git shortlog $VERSION..HEAD | tail -n+2 | while read line
do
  if [ -n "$line" ]; then
    echo "  * $line" >> debian/changelog
  fi
done
echo "" >> debian/changelog
echo " $BOTTOMLINE" >> debian/changelog


VERSION=`cat VERSION.txt`
cp debian/changelog ./$VERSION.changes

python setup.py sdist
mv dist/hethio-agent* ./


cat ../hethio-agent*.build
