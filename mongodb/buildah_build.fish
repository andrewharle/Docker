#WSL: sudo service binfmt-support start
set platarch linux/amd64,linux/arm64,linux/arm/v7
buildah build --jobs=3 --platform=$platarch \
    --add-host=aptcacher.internal:(hostname -I | sed 's/ /\n/g' | head -1) \
    --manifest mongodb_temp .