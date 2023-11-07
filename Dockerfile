FROM golang:1.21
RUN mkdir /app
WORKDIR /app
COPY catgpt/result .
CMD /app/catgpt


