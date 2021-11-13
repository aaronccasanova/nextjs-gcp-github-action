# Nextjs GCP GitHub Action Boilerplate

This walk through provides step by step instruction for creating a nextjs application and deploying it to Google Cloud Run with GitHub actions.

## Initialize a local/remote git repository with the `@aacc/ginit` CLI.

```sh
cd ~/project
mkdir nextjs-gcp-github-action
cd nextjs-gcp-github-action
TEMPLATE=node npx @aacc/ginit nextjs-gcp-github-action
```

## Create a nextjs app with the `create-next-app` CLI.

```sh
npx create-next-app --use-npm .
```

## Create a Dockerfile

```sh
curl -o Dockerfile https://gist.githubusercontent.com/aaronccasanova/b1086e286627350c269e498e251c910e/raw/a3f1cdb052fb30e87065764d9ae9e6255b6661e5/Dockerfile
```

## Create a .dockerignore file.

```sh
curl -o .dockerignore https://gist.githubusercontent.com/aaronccasanova/2502450ab635406d03bebe55d7b913db/raw/db7adb5f9d3af7ad3597e5efb23777f5eb4fdb67/.dockerignore
```

## Add `PORT` environment variable to the package.json.
> NOTE: This will be inject by Google Cloud Run.

```json
{
	"scripts": {
		"start": "next start -p $PORT"
	}
}
```

## Test the application locally

- Locally run a production build:

```sh
PORT=8080 npm start
```

- Locally run a production docker build:

```sh
# Build the application's docker image.
docker build . -t nextjs-gcp-github-action:latest

# Run the image in a container.
docker run -e PORT=8080 -p 4000:8080 nextjs-gcp-github-action
```

## Setup and configure a Google Cloud Project.

1. Navigate to https://console.cloud.google.com/projectcreate

2. Enter a project name and select `Create`.

3. Create a service account with permissions to interface with Google Cloud Run through GitHub actions.

> Note: You can create a project specific Service Account or a generic one to use across multiple projects. In this walk through I will be creating a generic Service Account as I intent to use Bot/GitHub action to deploy many Nextjs applications.

- Navigate the the [Service Accounts page](https://console.cloud.google.com/iam-admin/serviceaccounts?project=nextjs-gcp-github-action) and select your new project.

- Select `Create Service Account` in the top navigation.

- Enter a `name` and `id` for you Service Account.

- Select `Create and Continue` and proceed to adding the following permissions:

  - **`Editor`** — This allows the service account to enable or disable APIs or installing updates from the Google Cloud SDK.

  - **`Cloud Run Admin`** — This allows the service account to run Cloud Run commands like pushing or deploying the application.

  - **`Storage Admin`** — This allows the service account to push the Docker image to Google Container Registry.

  - **`Service Account User`** — This allows the service account to deploy as a service account in Cloud Run.

> Note: The above rules and descriptions were extracted from [this article](https://medium.com/weekly-webtips/this-is-how-i-deploy-next-js-into-google-cloud-run-with-github-actions-1d7d2de9d203).

- Select `Continue` and then without making any changes select `Done`.

- Generate a key for the service account which is used to authenticate the account when running GitHub actions.

  * Select the `actions menu` (horizontal ellipsis) on the new service account and select `Manage keys`.
  * Select the `ADD KEY` dropdown and select `Create new key`.
  * Make sure `JSON` is checked and select `Create`.
  * Place the download in a secure location. (such as: LastPass)


### Additional Information:

All the steps in the walk through were adapted from the following articles:
- https://medium.com/weekly-webtips/this-is-how-i-deploy-next-js-into-google-cloud-run-with-github-actions-1d7d2de9d203
- https://itnext.io/create-a-front-app-immediately-with-next-js-on-google-cloud-run-d0cfde795ce3
- https://blog.logrocket.com/how-to-deploy-next-js-on-google-cloud-run/
