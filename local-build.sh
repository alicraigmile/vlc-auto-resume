VERSION=$(rpmspec -q --qf "%{version}\n" vlc-auto-resume.spec | head -n1)
REPO_NAME=$(basename "$PWD")

git archive --format=tar.gz \
  --prefix="${REPO_NAME}-${VERSION}/" \
  -o ~/rpmbuild/SOURCES/vlc-auto-resume-${VERSION}.tar.gz \
  HEAD

rpmbuild -ba vlc-auto-resume.spec
rpmlint vlc-auto-resume.spec ~/rpmbuild/RPMS/noarch/vlc-auto-resume-${VERSION}-*.rpm ~/rpmbuild/SRPMS/vlc-auto-resume-${VERSION}-*.src.rpm
