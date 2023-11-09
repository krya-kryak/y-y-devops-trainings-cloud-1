yandex container registry login
cat tf_key.json | docker login \
  --username json_key \
  --password-stdin \
  cr.yandex

