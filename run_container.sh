# No GPU

docker run -dit --shm-size 4G --name mlfd-eaai \
-v $(pwd):/usr/src/code \
-p 4145:4141 -p 8885:8888 -p 5005:5000 -p 8005:8008 \
mlfd-eaai:1.0