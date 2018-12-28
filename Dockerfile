FROM zenika/alpine-maven

ADD . /root
WORKDIR /root
RUN apk --update add make && make dep && make build
EXPOSE 8080

CMD make run