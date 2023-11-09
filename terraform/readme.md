yandex container registry login
cat tf_key.json | docker login \
  --username json_key \
  --password-stdin \
  cr.yandex

docker push cr.yandex/crpvspuovr90bujnc8qc/catgpt:myapp

docker build . -t cr.yandex/crpvspuovr90bujnc8qc

