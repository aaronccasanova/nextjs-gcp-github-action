## Adapted from the following articles:
#- https://nodejs.org/en/docs/guides/nodejs-docker-webapp/
#- https://medium.com/weekly-webtips/this-is-how-i-deploy-next-js-into-google-cloud-run-with-github-actions-1d7d2de9d203

# Base image.
FROM node:16.13.0-alpine

# Create and change to the app directory.
WORKDIR /usr/app

# Install app dependencies
# A wildcard is used to ensure both package.json AND package-lock.json are copied
# where available. (npm@5+)
COPY package*.json ./

# Install production dependencies.
RUN npm ci

# Copy local code to the container image.
COPY . ./

# Build the nextjs application.
RUN npm run build

# Run the web service on container startup.
CMD [ "npm", "start" ]
