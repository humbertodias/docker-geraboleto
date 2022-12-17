dep:
	apk --update add fontconfig ttf-dejavu

package:
	mvn package

run:
	mvn spring-boot:run

docker-build:
	docker build . -t geraboleto

docker-run:
	docker run -p 8080:8080 geraboleto

docker-push:
	docker tag geraboleto hldtux/geraboleto
	docker push hldtux/geraboleto