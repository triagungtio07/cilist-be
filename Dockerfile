FROM node:18.12.1 as builder

WORKDIR /app

COPY ["package.json","package-lock.json*","./"]

RUN apt update

RUN npm install

COPY . /app


FROM node:18.12.1-slim

COPY --from=builder /app /app

WORKDIR /app

EXPOSE 5000

CMD [ "npm", "start" ]