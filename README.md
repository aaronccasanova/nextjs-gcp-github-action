# Nextjs GCP GitHub Action Boilerplate

This walk through provides step by step instruction for creating a nextjs application and deploying it to Google Cloud Run with GitHub actions.

## Initialize a local/remote git repository with the [@aacc/ginit](https://github.com/aaronccasanova/ginit) CLI.

```sh
nvm use 14
cd ~/project
mkdir nextjs-gcp-github-action
cd nextjs-gcp-github-action
TEMPLATE=node npx @aacc/ginit nextjs-gcp-github-action
```

## Create a nextjs app with the `create-next-app` CLI.

```sh
npx create-next-app --use-npm --ts .
```

## Create a Dockerfile

```sh
curl -o Dockerfile https://gist.githubusercontent.com/aaronccasanova/b1086e286627350c269e498e251c910e/raw/95e0d1d5ef36510149ccf5c0763c44b61a20900b/Dockerfile
```

## Create a .dockerignore file.

```sh
curl -o .dockerignore https://gist.githubusercontent.com/aaronccasanova/2502450ab635406d03bebe55d7b913db/raw/db7adb5f9d3af7ad3597e5efb23777f5eb4fdb67/.dockerignore
```

## Add a `PORT` environment variable to the package.json.
> NOTE: This will be inject by Google Cloud Run.

```json
{
	"scripts": {
		"start": "next start -p $PORT"
	}
}
```

## Test the application locally

> Note: Both examples are accessible from `localhost:4000`

- Locally run a production build:

```sh
npm run build
PORT=4000 npm start
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

- Navigate the the [Service Accounts page](https://console.cloud.google.com/iam-admin/serviceaccounts?project=nextjs-gcp-github-action) and select your new project.

- Select `Create Service Account` in the top navigation.

- Enter a `name` and `id` for you Service Account.

- Select `Create and Continue` and proceed to adding the following permissions:

  - **`Cloud Run Admin`** — Allows for the creation of new Cloud Run services.

  - **`Storage Admin`** — Allow push to Google Container Registry (this grants project level access, but recommend reducing this scope to bucket level permissions.)

  - **`Service Account User`** — Required to deploy to Cloud Run as service account.

> Note: The above rules and descriptions were extracted from the [google-github-actions/deploy-cloudrun setup guide](https://github.com/google-github-actions/deploy-cloudrun#setup).

- Select `Continue` and then without making any changes select `Done`.

- Generate a key for the service account which is used to authenticate the account when running GitHub actions.

  * Select the `actions menu` (horizontal ellipsis) on the new service account and select `Manage keys`.
  * Select the `ADD KEY` dropdown and select `Create new key`.
  * Make sure `JSON` is checked and select `Create`.
  * Place the download in a secure location. (such as: LastPass)

- Lastly, verify and/or enable the following APIs:
  - [Container Registry API](https://console.developers.google.com/apis/api/containerregistry.googleapis.com)
  - [Cloud Run API](https://console.developers.google.com/apis/api/run.googleapis.com)

## Enable Continuous Deployment with GitHub Actions

## Create and edit the `cloud-run-deploy.yml` template.

```
mkdir -p .github/workflows && curl -o .github/workflows/cloud-run-deploy.yml https://gist.githubusercontent.com/aaronccasanova/94eec5dac0a59ae32ad9c93c5126fa87/raw/1fd00a9c0470341166f38cfe199b168dd8a9954c/cloud-run-deploy.yml
```

> Note: The above template was adapted from the official [google-github-actions/deploy-cloudrun example](https://github.com/google-github-actions/deploy-cloudrun/blob/main/.github/workflows/example-workflow.yaml).

## Add the GitHub Action `secrets` to the repository.

- Navigate to the repositories `settings/secrets` page: e.g. `https://github.com/aaronccasanova/nextjs-gcp-github-action/settings/secrets/actions`
- Select the `New repository secret` button and add the following secrets:
  - **`GCP_PROJECT`** — Google Cloud project ID.
  - **`GCP_SA_KEY`** — The downloaded service account key.
    * Note: You can paste the JSON as is or convert it to base64.
    * On macOS run `base64 <path_of_private_key_json>` in your terminal.

> Note: The above template was adapted from the official [google-github-actions/deploy-cloudrun example](https://github.com/google-github-actions/deploy-cloudrun/blob/main/.github/workflows/example-workflow.yaml).

## Push up your changes, wait for the actions to run, and visit the deployed application.

- Push your changes to the remote repository.
- Navigate to the repository actions tab and follow along the running workflow: e.g. `https://github.com/aaronccasanova/nextjs-gcp-github-action/actions`
- Once the action finishes running, you will see a link to the deployed application. Simply replace the `***` in the Service URL with the GCP Project Name: e.g. `https://nextjs-gcp-github-action-app-4zsdsyxcrq-uw.a.run.app/`

> IMPORTANT: The above link will not work until the application is made public and optionally configured to use a custom domain. Learn more in the following sections:
> - [Make your service public](#make-your-service-public)
> - [Mapping a custom domain to your service (Recommended)](#map-a-custom-domain-to-your-service)

![image](https://user-images.githubusercontent.com/32409546/141663363-c4c7128d-ec48-4a43-95cc-b24b2dd77ef3.png)

## Make your service Public

> Note: This is not recommended and should use a custom domain instead.
- [Setting ingress](https://cloud.google.com/run/docs/securing/ingress)
   -  Follow the `configuring an existing service` steps.
   - Navigate to the service.
   - Select the `Triggers` tab.
   - Select the `Allow unauthenticated invocations` radio button.
   - Select `Save`.
- OR... Follow the manual steps in the [Making a service public](https://cloud.google.com/run/docs/securing/managing-access#making_a_service_public) guide.

## Mapping a custom domain to your service

> Note: We will be generally following the GCP [Mapping a custom domain to a service](https://cloud.google.com/run/docs/mapping-custom-domains) guide.

- Open the [domain mappings](https://console.cloud.google.com/run/domains) page in the Google Cloud Console.
- In the Domain Mappings page, click **Add Mapping**.
- From the dropdown list in the Add Mapping form, select the service you are mapping the custom domain to.
- Enter the domain name.
- Select Continue.
- You need to verify the ownership of a domain before being able to use it, unless you purchased your domain from Google. If you want to map subdomain.example.com, you should verify ownership of example.com. For more information on verifying domain ownership, refer to [Webmaster Central help](https://support.google.com/webmasters/answer/9008080?hl=en).
  - On the Webmaster Central page, select the [Verify Your Property](https://search.google.com/search-console/ownership) button.
  - In the top left sidebar, select the `Search property` dropdown and select `Add property`.
  - Select the `Domain` property type and enter the domain name. (e.g. `example.com`)
  - Make sure instructions for `Any DNS provider` is selected and copy the `TXT record` value.
  - Navigate to your registrar and paste the `TXT record` value into the `TXT Record` field.
  - Navigate back to the verify property page and select the `Verify` button.
  - Lastly select `Done`.
- Update your DNS records at your domain registrar web site using the DNS records displayed in the last step. You can display the records at any time by clicking **DNS Records** in the "..." action menu for a domain mapping.
  - Note: If you use Cloudflare make sure your proxy is off and set to `DNS only` when updating your records.
- Select `Done`.

> Note: Name server propagation can take a while and thus you can periodically check the status of your domain here: https://toolbox.googleapps.com/apps/dig/

### Additional Information:

All the steps in the walk through were adapted from the following articles:
- https://medium.com/weekly-webtips/this-is-how-i-deploy-next-js-into-google-cloud-run-with-github-actions-1d7d2de9d203
- https://itnext.io/create-a-front-app-immediately-with-next-js-on-google-cloud-run-d0cfde795ce3
- https://blog.logrocket.com/how-to-deploy-next-js-on-google-cloud-run/
