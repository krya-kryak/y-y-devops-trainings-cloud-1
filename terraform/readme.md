yandex container registry login
cat tf_key.json | docker login \
  --username json_key \
  --password-stdin \
  cr.yandex

docker push cr.yandex/crpv6r68t3c0m747mm4h/catgpt:myapp
docker push cr.yandex/crphchehebuhji0bf99r/catgpt:myapp

docker build . -t cr.yandex/crpv6r68t3c0m747mm4h/catgpt:myapp
docker build . -t cr.yandex/crphchehebuhji0bf99r/catgpt:myapp
