FROM node:alpine

RUN apk add --no-cache bash

WORKDIR /app

COPY package.json .

RUN npm install

COPY . .

COPY init-sh /app/init-sh

RUN chmod +x /app/init-sh

EXPOSE 3000

ENTRYPOINT ["./init-sh", "-p", "node", "--"]

CMD ["node", "server.js"]
