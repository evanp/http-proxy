FROM mhart/alpine-node:8

RUN apk update && apk add ca-certificates && update-ca-certificates && apk add openssl
RUN wget -O /usr/local/bin/dumb-init https://github.com/Yelp/dumb-init/releases/download/v1.2.0/dumb-init_1.2.0_amd64
RUN chmod +x /usr/local/bin/dumb-init

WORKDIR /src/
COPY . .

RUN npm install

EXPOSE 80
EXPOSE 443

ENTRYPOINT ["/usr/local/bin/dumb-init", "--"]
CMD ["/usr/bin/node", "lib/main.js"]
