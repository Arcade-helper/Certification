echo -e "Enter the location:${RESET_FORMAT} \c"
read LOCATION
export LOCATION

# Enable required services on Google Cloud
gcloud services enable run.googleapis.com
gcloud services enable eventarc.googleapis.com

# Set up Pub/Sub topic and subscription
gcloud pubsub topics create "$DEVSHELL_PROJECT_ID-topic"
gcloud pubsub subscriptions create --topic "$DEVSHELL_PROJECT_ID-topic" "$DEVSHELL_PROJECT_ID-topic-sub"

# Deploy the Cloud Run service
gcloud run deploy pubsub-events \
  --image=gcr.io/cloudrun/hello \
  --platform=managed \
  --region="$LOCATION" \
  --allow-unauthenticated

# Create Eventarc trigger to listen to Pub/Sub messages
gcloud eventarc triggers create pubsub-events-trigger \
  --location="$LOCATION" \
  --destination-run-service=pubsub-events \
  --destination-run-region="$LOCATION" \
  --transport-topic="$DEVSHELL_PROJECT_ID-topic" \
  --event-filters="type=google.cloud.pubsub.topic.v1.messagePublished"

# Send a test message to the Pub/Sub topic
gcloud pubsub topics publish "$DEVSHELL_PROJECT_ID-topic" \
  --message="Test message"
