#!/bin/bash

echo "Downloading GDrive Binary..."
wget --quiet https://github.com/prasmussen/gdrive/releases/download/2.1.1/gdrive_2.1.1_linux_386.tar.gz
tar -xf gdrive_2.1.1_linux_386.tar.gz
rm -f gdrive_2.1.1_linux_386.tar.gz
mv gdrive /usr/bin/gdrive
gdrive version

echo "Move notebook to workspace..."
mv SD-NoteBook.ipynb /workspace/SD-NoteBook.ipynb

if [[ $RP_API ]]
then
    echo "Downloading runpodctl Binary..."
    wget --quiet https://github.com/Run-Pod/runpodctl/releases/download/v1.6.1/runpodctl-linux-amd -O runpodctl
    chmod +x runpodctl
    mv runpodctl /usr/bin/runpodctl
    runpodctl config --apiKey=$RP_API
fi

echo "Downloading bore"
wget --quiet https://github.com/ekzhang/bore/releases/download/v0.4.0/bore-v0.4.0-x86_64-unknown-linux-musl.tar.gz
tar -xf bore-v0.4.0-x86_64-unknown-linux-musl.tar.gz
rm -f bore-v0.4.0-x86_64-unknown-linux-musl.tar.gz
mv bore /usr/bin/bore
bore --version
bore local 6956 --to bore.pub > /workspace/bore.log 2>&1 &

if [[ $PUBLIC_KEY ]];then
    mkdir -p ~/.ssh
    chmod 700 ~/.ssh
    cd ~/.ssh
    echo $PUBLIC_KEY >> authorized_keys
    chmod 700 -R ~/.ssh
    cd /
    service ssh start
fi

if [[ $JUPYTER_PASSWORD ]]
then
    cd /
    jupyter lab --allow-root --no-browser --port=8888 --ip=* --ServerApp.token=$JUPYTER_PASSWORD --ServerApp.allow_origin=* --ServerApp.preferred_dir=/workspace --ServerApp.iopub_data_rate_limit=10000000 &
fi

echo "pod started"

sleep infinity
