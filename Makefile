dev:
	docker compose up --build

build:
	docker build -f ./docker/node/Dockerfile  -t test .

start:
	docker run --rm -e TZ=Asia/Tokyo -p 3000:3000 test