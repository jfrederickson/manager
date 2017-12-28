#!/bin/bash
# Build a Docker image tagged with current version + commit hash + optional string
# Run this from the root of the Manager source tree
#
# Example usage: bin/build-image.sh -n dev -a CLIENT_ID=12345 -a LISH_ROOT=wss://lish.example.com
#
# Arguments:
# -a           Adds a build-arg argument to "docker build" (can be repeated)
# -f           Build an image even if there are local uncommitted changes
# -r           Add the (short) git revision to the image tag
# -n <label>   Append a label to the image tag
#
# All arguments are optional, though you'll need to set at least the CLIENT_ID
# and APP_ROOT build args for the resulting image to be useful.


BUILDARGS=()

while getopts ":n:fa:r" opt; do
      case $opt in
          f)
              FORCE=true
              ;;
          n)
              LABEL=$OPTARG
              ;;
          r)
              GIT_REV=$(git rev-parse --short HEAD)
              ;;
          a)
              BUILDARGS+=("$OPTARG")
              ;;
          \?)
              echo "Invalid option: -$OPTARG" >&2
              exit 1
              ;;
          :)
              echo "Option -$OPTARG requires an argument" >&2
              exit 1
              ;;
      esac
done

NAME=$(jq -r '.name' package.json)
VERSION=$(jq -r '.version' package.json)

git diff --quiet; nochanges=$?

if [ $nochanges -eq 0 ] && [ -z $FORCE ]; then
    echo "You have uncommitted changes, commit or run with -f"
    exit 1
fi

TAG="$NAME:$VERSION"
if [ -n "$GIT_REV" ]; then
    TAG="$TAG-$GIT_REV"
fi
if [ -n "$LABEL" ]; then
    TAG="$TAG-$LABEL"
fi

for arg in ${BUILDARGS[@]}; do
    ARGSTRING="$ARGSTRING --build-arg $arg"
done

echo "docker build $ARGSTRING -t $TAG ."
