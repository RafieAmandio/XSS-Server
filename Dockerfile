FROM node:18-alpine

WORKDIR /usr/src/app

COPY package*.json ./

RUN npm install

COPY . .

# Create public directory
RUN mkdir -p public

EXPOSE 3000

CMD [ "node", "server.js" ]
