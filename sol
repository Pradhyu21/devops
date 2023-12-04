GSP313

export INSTANCE_NAME=
export ZONE=
export REGION=
export PORT=
export FIREWALL_NAME=
gcloud compute instances create $INSTANCE_NAME \
          --network nucleus-vpc \
          --zone $ZONE  \
          --machine-type e2-micro  \
          --image-family debian-10  \
          --image-project debian-cloud


gcloud container clusters create nucleus-backend \
--num-nodes 1 \
--network nucleus-vpc \
--zone $ZONE

gcloud container clusters get-credentials nucleus-backend \
--zone $ZONE
kubectl create deployment hello-server \
--image=gcr.io/google-samples/hello-app:2.0
kubectl expose deployment hello-server \
--type=LoadBalancer \
--port $PORT

cat << EOF > startup.sh
#! /bin/bash
apt-get update
apt-get install -y nginx
service nginx start
sed -i -- 's/nginx/Google Cloud Platform - '"\$HOSTNAME"'/' /var/www/html/index.nginx-debian.html
EOF
gcloud compute instance-templates create web-server-template \
--metadata-from-file startup-script=startup.sh \
--network nucleus-vpc \
--machine-type g1-small \
--region $ZONE
gcloud compute target-pools create nginx-pool --region=$REGION
gcloud compute instance-groups managed create web-server-group \
--base-instance-name web-server \
--size 2 \
--template web-server-template \
--region $REGION
gcloud compute firewall-rules create $FIREWALL_NAME \
--allow tcp:80 \
--network nucleus-vpc
gcloud compute http-health-checks create http-basic-check
gcloud compute instance-groups managed \
set-named-ports web-server-group \
--named-ports http:80 \
--region $REGION
gcloud compute backend-services create web-server-backend \
--protocol HTTP \
--http-health-checks http-basic-check \
--global

gcloud compute backend-services add-backend web-server-backend \
--instance-group web-server-group \
--instance-group-region $REGION \
--global
gcloud compute url-maps create web-server-map \
--default-service web-server-backend

gcloud compute target-http-proxies create http-lb-proxy \
--url-map web-server-map
gcloud compute forwarding-rules create http-content-rule \
--global \
--target-http-proxy http-lb-proxy \
--ports 80

gcloud compute forwarding-rules create $FIREWALL_NAME \
--global \
--target-http-proxy http-lb-proxy \
--ports 80
gcloud compute forwarding-rules list






GSP323




REGION=
BigQuery_output_table=
cat << EOF > s.py
input_string = "$BigQuery_output_table"
parts = input_string.split(':')
LAB_NAME = parts[1].split('.')[0]
CUSTOMERS = parts[1].split('.')[1]
print("LAB_NAME:", LAB_NAME)
print("CUSTOMERS:", CUSTOMERS)
EOF
output=$(python s.py)
LAB_NAME=$(echo "$output" | awk '/LAB_NAME:/ {print $2}')
CUSTOMERS=$(echo "$output" | awk '/CUSTOMERS:/ {print $2}')
bq mk $LAB_NAME
gsutil mb gs://$DEVSHELL_PROJECT_ID-marking/
gsutil cp gs://cloud-training/gsp323/lab.csv  .
gsutil cp gs://cloud-training/gsp323/lab.schema .
gcloud dataflow jobs run Cloudhustler --gcs-location gs://dataflow-templates-$REGION/latest/GCS_Text_to_BigQuery --region $REGION --worker-machine-type e2-standard-2 --staging-location gs://$DEVSHELL_PROJECT_ID-marking/temp --parameters javascriptTextTransformGcsPath=gs://cloud-training/gsp323/lab.js,JSONPath=gs://cloud-training/gsp323/lab.schema,javascriptTextTransformFunctionName=transform,outputTable=$BigQuery_output_table,inputFilePattern=gs://cloud-training/gsp323/lab.csv,bigQueryLoadingTemporaryDirectory=gs://$DEVSHELL_PROJECT_ID-marking/bigquery_temp
gcloud dataproc clusters create cluster-b53a --region $REGION --master-machine-type e2-standard-2 --master-boot-disk-size 500 --num-workers 2 --worker-machine-type e2-standard-2 --worker-boot-disk-size 500 --image-version 2.1-debian11 --project $DEVSHELL_PROJECT_ID
API & Credintials > Create Credintials > API KEY > Copy it
RUN IN ANOTHER SHELL
API_KEY=
Bucket_TASK_3=
Bucket_TASK_4=
gcloud iam service-accounts create cloushustler \
  --display-name "my natural language service account"
gcloud iam service-accounts keys create ~/key.json \
  --iam-account cloushustler@${GOOGLE_CLOUD_PROJECT}.iam.gserviceaccount.com
cloud="/home/$USER/key.json"
gcloud auth activate-service-account cloushustler@${GOOGLE_CLOUD_PROJECT}.iam.gserviceaccount.com --key-file=$cloud
gcloud ml language analyze-entities --content="Old Norse texts portray Odin as one-eyed and long-bearded, frequently wielding a spear named Gungnir and wearing a cloak and a broad hat." > result.json
gcloud auth login --no-launch-browser
gsutil cp result.json $Bucket_TASK_4
cat > request.json <<EOF 
{
  "config": {
      "encoding":"FLAC",
      "languageCode": "en-US"
  },
  "audio": {
      "uri":"gs://cloud-training/gsp323/task3.flac"
  }
}
EOF
curl -s -X POST -H "Content-Type: application/json" --data-binary @request.json \
"https://speech.googleapis.com/v1/speech:recognize?key=${API_KEY}" > result.json
gsutil cp result.json $Bucket_TASK_3
gcloud iam service-accounts create cloudhus
gcloud iam service-accounts keys create key.json --iam-account cloudhus@${GOOGLE_CLOUD_PROJECT}.iam.gserviceaccount.com
gcloud auth activate-service-account --key-file key.json
export ACCESS_TOKEN=$(gcloud auth print-access-token)
cat > request.json <<EOF 
{
   "inputUri":"gs://spls/gsp154/video/train.mp4",
   "features": [
       "TEXT_DETECTION"
   ]
}
From left pannel select jobs > Submit job
Region From LAB > Cluster cluster-b53a > Job type spark

Main class or jar org.apache.spark.examples.SparkPageRank

Jar files file:///usr/lib/spark/examples/jars/spark-examples.jar

Arguments /data.txt

Max restarts per hour 1

SUBMIT
EOF
curl -s -H 'Content-Type: application/json' \
    -H "Authorization: Bearer $ACCESS_TOKEN" \
    'https://videointelligence.googleapis.com/v1/videos:annotate' \
    -d @request.json
curl -s -H 'Content-Type: application/json' -H "Authorization: Bearer $ACCESS_TOKEN" 'https://videointelligence.googleapis.com/v1/operations/OPERATION_FROM_PREVIOUS_REQUEST' > result1.json
Search Dataproc > Click on cluster-b53a
Vm Instance > ssh > hdfs dfs -cp gs://cloud-training/gsp323/data.txt /data.txt



GSP330

export EMAIL=

#----DO NOT CHANGE ANYTHING BELOW--
export CLUSTER_NAME=hello-cluster
export ZONE=us-central1-b
export REGION=us-central1
export REPO=my-repository
export PROJECT_ID=$(gcloud config get-value project)
gcloud services enable container.googleapis.com \
    cloudbuild.googleapis.com \
    sourcerepo.googleapis.com
gcloud projects add-iam-policy-binding $PROJECT_ID \
--member=serviceAccount:$(gcloud projects describe $PROJECT_ID \
--format="value(projectNumber)")@cloudbuild.gserviceaccount.com --role="roles/container.developer"
git config --global user.email $EMAIL 
git config --global user.name student
gcloud artifacts repositories create $REPO \
    --repository-format=docker \
    --location=$REGION \
    --description="Subscribe to quicklab"
gcloud beta container --project "$PROJECT_ID" clusters create "$CLUSTER_NAME" --zone "$ZONE" --no-enable-basic-auth --cluster-version latest --release-channel "regular" --machine-type "e2-medium" --image-type "COS_CONTAINERD" --disk-type "pd-balanced" --disk-size "100" --metadata disable-legacy-endpoints=true  --logging=SYSTEM,WORKLOAD --monitoring=SYSTEM --enable-ip-alias --network "projects/$PROJECT_ID/global/networks/default" --subnetwork "projects/$PROJECT_ID/regions/$REGION/subnetworks/default" --no-enable-intra-node-visibility --default-max-pods-per-node "110" --enable-autoscaling --min-nodes "2" --max-nodes "6" --location-policy "BALANCED" --no-enable-master-authorized-networks --addons HorizontalPodAutoscaling,HttpLoadBalancing,GcePersistentDiskCsiDriver --enable-autoupgrade --enable-autorepair --max-surge-upgrade 1 --max-unavailable-upgrade 0 --enable-shielded-nodes --node-locations "$ZONE"
kubectl create namespace prod	
kubectl create namespace dev
gcloud source repos create sample-app
git clone https://source.developers.google.com/p/$PROJECT_ID/r/sample-app
cd ~
gsutil cp -r gs://spls/gsp330/sample-app/* sample-app
git init
cd sample-app/
git add .
git commit -m "Subscribe to quicklab" 
git push -u origin master
git branch dev
git checkout dev
git push -u origin dev
gcloud builds triggers create cloud-source-repositories --name="sample-app-prod-deploy" --repo="sample-app" --branch-pattern="^master$" --build-config="cloudbuild.yaml"
gcloud builds triggers create cloud-source-repositories --name="sample-app-dev-deploy" --repo="sample-app" --branch-pattern="^dev$" --build-config="cloudbuild-dev.yaml"
COMMIT_ID="$(git rev-parse --short=7 HEAD)"
gcloud builds submit --tag="${REGION}-docker.pkg.dev/${PROJECT_ID}/$REPO/hello-cloudbuild:${COMMIT_ID}" .
IMAGE=$(gcloud builds list --format="value(IMAGES)")
sed -i "s/<version>/v1.0/g" cloudbuild-dev.yaml
sed -i "s#<todo>#$IMAGE#g" dev/deployment.yaml
git add .
git commit -m "Subscribe to quicklab" 
git push -u origin dev
git checkout master
sed -i "s/<version>/v1.0/g" cloudbuild.yaml
sed -i "s#<todo>#$IMAGE#g" prod/deployment.yaml
git add .
git commit -m "Subscribe to quicklab" 
git push -u origin master

git checkout dev

rm -rf main.go
touch main.go
tee main.go <<EOF
/**
 * Copyright 2023 Google Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package main

import (
	"image"
	"image/color"
	"image/draw"
	"image/png"
	"net/http"
)

func main() {
	http.HandleFunc("/blue", blueHandler)
	http.HandleFunc("/red", redHandler)
	http.ListenAndServe(":8080", nil)
}

func blueHandler(w http.ResponseWriter, r *http.Request) {
	img := image.NewRGBA(image.Rect(0, 0, 100, 100))
	draw.Draw(img, img.Bounds(), &image.Uniform{color.RGBA{0, 0, 255, 255}}, image.ZP, draw.Src)
	w.Header().Set("Content-Type", "image/png")
	png.Encode(w, img)
}

func redHandler(w http.ResponseWriter, r *http.Request) {
	img := image.NewRGBA(image.Rect(0, 0, 100, 100))
	draw.Draw(img, img.Bounds(), &image.Uniform{color.RGBA{255, 0, 0, 255}}, image.ZP, draw.Src)
	w.Header().Set("Content-Type", "image/png")
	png.Encode(w, img)
}
EOF

sed -i "s/v1.0/v2.0/g" cloudbuild-dev.yaml
IMAGE2=${IMAGE::-7}v1.0
echo $IMAGE2
sed -i "s#$IMAGE#$IMAGE2#g" dev/deployment.yaml
git add .
git commit -m "Subscribe to quicklab" 
git push -u origin dev
git checkout master

rm -rf main.go
touch main.go
tee main.go <<EOF
/**
 * Copyright 2023 Google Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package main

import (
	"image"
	"image/color"
	"image/draw"
	"image/png"
	"net/http"
)

func main() {
	http.HandleFunc("/blue", blueHandler)
	http.HandleFunc("/red", redHandler)
	http.ListenAndServe(":8080", nil)
}

func blueHandler(w http.ResponseWriter, r *http.Request) {
	img := image.NewRGBA(image.Rect(0, 0, 100, 100))
	draw.Draw(img, img.Bounds(), &image.Uniform{color.RGBA{0, 0, 255, 255}}, image.ZP, draw.Src)
	w.Header().Set("Content-Type", "image/png")
	png.Encode(w, img)
}

func redHandler(w http.ResponseWriter, r *http.Request) {
	img := image.NewRGBA(image.Rect(0, 0, 100, 100))
	draw.Draw(img, img.Bounds(), &image.Uniform{color.RGBA{255, 0, 0, 255}}, image.ZP, draw.Src)
	w.Header().Set("Content-Type", "image/png")
	png.Encode(w, img)
}
EOF
sed -i "s/v1.0/v2.0/g" cloudbuild.yaml
sed -i "s#$IMAGE#$IMAGE2#g" prod/deployment.yaml

git add .
git commit -m "Subscribe to quicklab" 
git push -u origin master

#--FOR LAST TASK : GO TO CLOUD BUILD > HISTORY--
#---CLICK SECOND FAILED ONE(dev) > CLICK RETRY
