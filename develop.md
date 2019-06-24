Development notes
=================

Useful notes during development.

Bumping the version
-------------------

The version is bumped when running manually the `release` pipeline, after merging a pull request.
The way the version is bumped (major, minor, or patch) depends on the changes since the last release.
You must create the changes manually using the `semversioner` tool during the development of the pull request.

You can install `semversioner` using `pip`:

    pip install --user semversioner

For example, a change that will bump the patch version, say from 0.1.5 to 0.1.6:

    semversioner add-change --type patch --description 'Write scanner output to BITBUCKET_PIPE_STORAGE_DIR'

For example, a change that will bump the minor version, say from 0.0.0 to 0.1.0:

    semversioner add-change --type minor --description 'Check quality gate'

To test what will happen during the release, try this (will modify working tree but not commit):

    semversioner release
    semversioner changelog

Preparing a branch for validation by PM
---------------------------------------

Create a QA build of the pipe's Docker image:
run the `build-docker-qa` pipeline manually for the feature branch.

This will trigger the deployment of a Docker image on https://hub.docker.com/r/codescan/codescancloud-scan/tags,
tagged `${VERSION}.${BITBUCKET_BUILD_NUMBER}-QA`.

Edit the `pipe.yml` in a "DO NOT MERGE" commit,
setting the image's version to the QA build.

When ready to merge, don't forget to drop the "DO NOT MERGE" commit.

Testing the pipe in a dummy project
-----------------------------------

Example pipeline definition for a JavaScript project:

    # This is a sample build configuration for JavaScript.
    # Check our guides at https://confluence.atlassian.com/x/14UWN for more examples.
    # Only use spaces to indent your .yml configuration.
    # -----
    # You can specify a custom docker image from Docker Hub as your build environment.
    image: node:10.15.3

    pipelines:
      default:
        - step:
            name: Build, run tests, analyze on CodeScanCloud
            caches:
              - node
            script:
              - npm install
              - npm test
              - pipe: codescan/codescancloud-scan:name-of-feature-branch
        - step:
            name: Check Quality Gate on CodeScanCloud
            script:
              - pipe: codescan/codescancloud-quality-gate:0.1.0
        - step:
            name: Deploy to Production
            deployment: "Production"
            script:
              - echo "Good to deploy!"

Set `name-of-feature-branch` appropriate to the name of the branch to test.
Warning: current slash `/` is not supported in branch names.
