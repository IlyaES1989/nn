FROM python:3.10-alpine

ENV PYTHONUNBUFFERED 1

COPY ./config/requirements.txt requirements.txt

RUN apk update \
  # psycopg2 dependencies
  && apk add --virtual .build-deps \
   python3-dev \
   musl-dev \
   openssl-dev\
   postgresql-dev \
   libffi-dev\
   py-cffi \
   build-base\
   cmake\
   linux-headers \
  && apk add postgresql-client \
  && apk add make \
  && pip install -r requirements.txt\
  && apk del .build-deps