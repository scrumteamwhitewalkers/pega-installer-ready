#give you workspace location

root_path=/home/vagrant/code/head/

#copying script files from prdeploy
cp $root_path/prpc-platform/core/prdeploy/scripts/utils/prpcUtils.sh $root_path/prpc-platform/infrastructure/distribution/docker/images/installer/build/archives/scripts/utils

cp $root_path/prpc-platform/core/prdeploy/scripts/utils/prpcUtils.xml $root_path/prpc-platform/infrastructure/distribution/docker/images/installer/build/archives/scripts/utils

cp $root_path/prpc-platform/core/prdeploy/scripts/install.sh $root_path/prpc-platform/infrastructure/distribution/docker/images/installer/build/archives/scripts/

cp $root_path/prpc-platform/core/prdeploy/scripts/migrate.sh $root_path/prpc-platform/infrastructure/distribution/docker/images/installer/build/archives/scripts

cp $root_path/prpc-platform/core/prdeploy/scripts/setupDatabase.xml $root_path/prpc-platform/infrastructure/distribution/docker/images/installer/build/archives/scripts

cp $root_path/prpc-platform/core/prdeploy/scripts/migrateSystem.xml $root_path/prpc-platform/infrastructure/distribution/docker/images/installer/build/archives/scripts

#change directory to prpc-platform to build prdeploy.jar
cd $root_path/prpc-platform/
./gradlew :core:prdeploy:build
cp $root_path/prpc-platform/core/prdeploy/build/libs/prdeploy-0.0.1-SNAPSHOT.jar $root_path/prpc-platform/infrastructure/distribution/docker/images/installer/build/archives/scripts/prdeploy.jar

#change directory to installer to build image
cd $root_path/prpc-platform/infrastructure/distribution/docker/images/installer

docker build -t installerimage $root_path/prpc-platform/infrastructure/distribution/docker/images/installer

