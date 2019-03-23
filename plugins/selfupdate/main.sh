if [ -x "$(command -v git)" ]; then
    cd "${DIR}" || exit
    output info "Self-updating:"
    if (git diff --name-only origin/master | grep -q manager); then
        git reset --hard HEAD | output info
        git pull https://github.com/RXCommunity/manager master | output info
    else
        output info "Already latest version!"
    fi
else
    output erro "You do not have GIT installed!"
fi
