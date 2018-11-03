# xs-node-build-minimal

> Creates base build image: miimal Node build environment, other images can add
specifics per build requirement.

## CircleCI Deployment
> Currently, CircleCi deploys off pushes to `release` branch.

## Makefile (DEPRECATED)
```sh

$ make help
  archive      Archive image locally (compressed tar file)
  build        Build docker image
  clean        Delete the image
  deploy       Deploy into field
  down         Bring down the running container
  login-ecr    Login to AWS ECR
  login        Login to DockerHub
  push-ecr     Push to AWS ECR
  push         Push to DockerHub registry
  ssh          SSH into image
  tag-ecr      Tag for AWS ECR
  tag          Tag for DockerHub Registry
  test         Test whatever needs testing
  up           Run the newest created image

```

## [License](LICENSE.md)
