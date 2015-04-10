#! /bin/bash

python setup.py \
--command-packages=stdeb.command debianize \
--suite `lsb_release -sc`


# ===================================
# ADD COMMIT MESSAGES TO CHANGELOG
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


# ===================================
# RUN SETUP
python setup.py sdist
mv dist/hethio-agent* ./


# ===================================
# OUTPUT BUILD SCRIPT TO CONSOLE
echo '------------------' | cat - ../hethio-agent*.build > temp && mv temp ../hethio-agent*.build && echo '------------------' >> ../hethio-agent*.build
cat ../hethio-agent*.build


# ===================================
# SCAN BUILD LOG FOR ERRORS
#  By convention, an 'exit 0' indicates success,
#+ while a non-zero exit value means an error or anomalous condition.
#  See the "Exit Codes With Special Meanings" appendix.
BUILD=`cat ../hethio-agent*.build`
if [[ $BUILD == *"error"* ]]; then
	exit 1
fi