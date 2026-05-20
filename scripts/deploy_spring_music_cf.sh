#!/bin/bash
echo "Deploying Spring Music to Cloud Foundry..."
# cf login -a $CF_API -u $CF_USERNAME -p $CF_PASSWORD -o $CF_ORG -s $CF_SPACE
# git clone $REPO_URL
# cd spring-music && ./gradlew assemble && cf push $APP_NAME
echo "Workload $APP_NAME deployed (mocked)."
