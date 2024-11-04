FROM node:latest
WORKDIR /usr/src/app

COPY ./dist ./dist
COPY .env ./

COPY ./package*.json ./
RUN yarn install --production
EXPOSE 8080

CMD ["node", "dist/app.js"]