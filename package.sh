#! /bin/bash

python setup.py \
--command-packages=stdeb.command debianize \
--suite `lsb_release -sc`


VERSION=`git tag | tail -n 1`
CHANGES=`git shortlog $VERSION..HEAD`

TOPLINE=`head -n 1 debian/changelog`
BOTTOMLINE=`tail -n 1 debian/changelog`

echo $TOPLINE > debian/changelog
echo "" >> debian/changelog
for CHANGE in ${CHANGES//\\n/ } ; do
    echo "  * $CHANGE" >> debian/changelog
done
echo "" >> debian/changelog
echo $BOTTOMLINE >> debian/changelog


python setup.py sdist
mv dist/hethio-agent* ./

