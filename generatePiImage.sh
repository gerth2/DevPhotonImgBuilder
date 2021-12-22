PI_BASE_IMG_TAG=v2021.1.4
PHOTONVISION_RELEASE_TAG=v2022.1.1-beta-2

# Install dependencies
sudo apt install unzip zip

# Download new jar from photonvision main repo
curl -sk https://api.github.com/repos/photonvision/photonvision/releases/tags/${PHOTONVISION_RELEASE_TAG} | grep "browser_download_url.*photonvision-.*\.jar" | cut -d : -f 2,3 | tr -d '"' | wget -qi -
JAR_FILE_NAME=$(realpath $(ls | grep photonvision-v.*\.jar))

# Download base image from pigen repo
curl -sk https://api.github.com/repos/photonvision/photon-pi-gen/releases/tags/${PI_BASE_IMG_TAG} | grep "browser_download_url.*zip" | cut -d : -f 2,3 | tr -d '"' | wget -qi -
IMG_FILE_NAME=$(realpath $(ls | grep image_*.zip))

# Unzip and mount the image to be updated
unzip $IMG_FILE_NAME
IMAGE_FILE=$(ls | grep *.img)
TMP=$(mktemp -d)
LOOP=$(sudo losetup --show -fP "${IMAGE_FILE}")
sudo mount ${LOOP}p2 $TMP
pushd .

# Copy in the new .jar
cd $TMP/opt/photonvision
ls
sudo cp $JAR_FILE_NAME photonvision.jar

# Cleanup
popd
sudo umount ${TMP}
sudo rmdir ${TMP}
rm $IMG_FILE_NAME
NEW_IMAGE=$(basename "${JAR_FILE_NAME/jar/img}")
mv $IMAGE_FILE $NEW_IMAGE
zip -r $(basename "${JAR_FILE_NAME/.jar/-image.zip}") $NEW_IMAGE
rm $NEW_IMAGE
