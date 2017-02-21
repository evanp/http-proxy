FROM mhart/alpine-node:6

RUN wget -O /usr/local/bin/dumb-init https://github.com/Yelp/dumb-init/releases/download/v1.2.0/dumb-init_1.2.0_amd64
RUN chmod +x /usr/local/bin/dumb-init

WORKDIR /src/
ADD . .

RUN npm install

EXPOSE 80
EXPOSE 443

ENTRYPOINT ["/usr/local/bin/dumb-init", "--"]
CMD ["/usr/local/bin/node", "lib/main.js"]
