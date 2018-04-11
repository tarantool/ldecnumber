all:
	docker run \
		--rm=true \
		--tty=true \
		-v $(CURDIR):/tmp/ldecnumber \
	tarantool/tarantool:1.7 \
	/bin/sh -c '\
		apk add --no-cache --virtual .build-deps gcc make cmake musl-dev; \
		cd /tmp/ldecnumber; \
		tarantoolctl rocks make ./rockspecs/ldecnumber-scm-1.rockspec; \
		make -C build.luarocks ARGS=-V test; \
	'
