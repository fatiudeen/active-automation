FROM node:lts-alpine as builder
WORKDIR /usr/src/app
# RUN chown -R node ./
COPY . .
USER root
RUN npm install 
RUN npm test
RUN npm run build

FROM node:lts-alpine
ENV NODE_ENV=production
WORKDIR /usr/src/app
USER root
COPY package*.json ./
RUN npm install --production --silent --ignore-scripts
COPY --from=builder /usr/src/app/dist /usr/src/app/
EXPOSE 5000
# RUN chown -R node /usr/src/app
CMD ["npm", "start"]