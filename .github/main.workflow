workflow "Build and deploy on push" {
  on = "push"
  resolves = [
    "Branch master",
    "Invalidate cache",
  ]
}

action "Build" {
  uses = "docker://ruby:latest"
  env = {
    LANG = "C.UTF-8"
  }
  runs = "bin/build"
}

action "Deploy" {
  uses = "actions/aws/cli@master"
  needs = ["Branch master"]
  args = "s3 sync --delete --acl public-read ./build/ s3://www.johnhawthorn.com/ "
  secrets = ["AWS_ACCESS_KEY_ID", "AWS_SECRET_ACCESS_KEY"]
}

action "Branch master" {
  uses = "actions/bin/filter@master"
  needs = ["Build"]
  args = "branch master"
}

action "Invalidate cache" {
  uses = "actions/aws/cli@master"
  needs = ["Deploy"]
  args = "cloudfront create-invalidation --distribution-id $CF_DISTRIBUTION_ID --paths \"/*\""
  secrets = ["AWS_ACCESS_KEY_ID", "AWS_SECRET_ACCESS_KEY", "CF_DISTRIBUTION_ID"]
}
