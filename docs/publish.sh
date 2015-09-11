MESSAGE="$1"

if [ -z "$MESSAGE" ]
then
    MESSAGE="Updated Proteus documentation"
fi

pushd site
git add -A .
git commit -m "$MESSAGE"
git push origin gh-pages
popd
