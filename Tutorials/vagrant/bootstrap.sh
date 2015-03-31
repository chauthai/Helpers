#!/usr/bin/env bash
ANDROID_SDK_FILENAME=android-sdk_r24.1.2-linux.tgz
ANDROID_SDK=http://dl.google.com/android/$ANDROID_SDK_FILENAME

# Setting timezone
echo "Europe/Berlin" | sudo tee /etc/timezone
sudo dpkg-reconfigure -f noninteractive tzdata

# Add JDK PPA and update package list
sudo add-apt-repository -y ppa:webupd8team/java
# Add the "right" node.js
sudo add-apt-repository ppa:chris-lea/node.js
sudo apt-get update -y
# Auto accept Oracle JDK license
echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | sudo /usr/bin/debconf-set-selections
# We need to install the Oracle JDK because it is recommended for Android
sudo apt-get install -y git nodejs ruby-dev oracle-java8-installer ant expect lib32z1 lib32ncurses5 lib32stdc++6 libfontconfig mc zsh
sudo npm update npm -g

wget -O ~/.zshrc http://git.grml.org/f/grml-etc-core/etc/zsh/zshrc
sudo chsh -s /usr/bin/zsh vagrant

curl -O $ANDROID_SDK
tar -xzvf $ANDROID_SDK_FILENAME
chown -R vagrant /home/vagrant/android-sdk-linux/
rm $ANDROID_SDK_FILENAME

echo "export JAVA_HOME=/usr/lib/jvm/java-8-oracle/" >> /home/vagrant/.zprofile
echo "export ANDROID_HOME=~/android-sdk-linux" >> /home/vagrant/.zprofile
echo "export PATH=\$PATH:$JAVA_HOME/bin:~/android-sdk-linux/tools:~/android-sdk-linux/platform-tools" >> /home/vagrant/.zprofile
echo "alias sudo='sudo env PATH=$PATH'" >> /home/vagrant/.zprofile

sudo -u vagrant expect -c '
set timeout -1 ;
spawn /home/vagrant/android-sdk-linux/tools/android update sdk -u --all --filter platform-tool,android-19,build-tools-21.1.1
expect {
    "Do you accept the license" { exp_send "y\r" ; exp_continue }
    eof
}
'

android-sdk-linux/platform-tools/adb kill-server
android-sdk-linux/platform-tools/adb start-server
android-sdk-linux/platform-tools/adb devices

sudo npm install -g bower
sudo npm install -g grunt-cli
sudo npm install -g yo
sudo npm install -g generator-angular
sudo npm install -g coffee-script
sudo npm install -g cordova
sudo npm install -g phonegap
sudo npm install -g ionic
sudo npm install -g npm-check-updates

sudo gem install sass
sudo gem install compass

# Delete tmp directory created from npm install -g
sudo npm cache clean
sudo rm -rf /home/vagrant/tmp

cd /vagrant
echo "Installing nodejs dependencies"
npm install
echo "Installing Bower dependencies"
bower install -f

echo "Adding Android platform to cordova"
# Source .zprofile because we need the environment variables set
source /home/vagrant/.zprofile
mkdir plugins
mkdir www
echo "cd /vagrant" >> /home/vagrant/.zprofile
cordova platform add android
