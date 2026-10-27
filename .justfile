run example="simple":
    mkdir -p target
    kast compile --target c examples/{{example}}/main.ks > target/main.c
    gcc target/main.c -o target/main \
        -I${KAST_PATH}/c-runtime/include ${KAST_PATH}/c-runtime/src/*.c \
        ${FMOD_CFLAGS} \
        -lm -lbacktrace -pthread

    ./target/main

check example="simple":
    mkdir -p target
    kast compile --target c examples/{{example}}/main.ks > target/main.c
    gcc -fsyntax-only target/main.c \
        -I${KAST_PATH}/c-runtime/include \
        -I${FMOD_SDK}/api/core/inc -I${FMOD_SDK}/api/studio/inc

build-web example="simple" flags="${FMOD_EMCC_FLAGS}":
    rm -rf target/web
    mkdir -p target/web
    kast compile --target c examples/{{example}}/main.ks > target/main.c
    emcc target/main.c -o target/web/index.html \
        -I${KAST_PATH}/c-runtime/include ${KAST_PATH}/c-runtime/src/*.c \
        {{flags}} \
        --preload-file assets/Build/Desktop \
        -w

run-web example="simple": (build-web example)
    caddy file-server --root target/web --listen localhost:8080

run-web-threads example="simple": (build-web example "${FMOD_EMCC_FLAGS_THREADS}")
    caddy run --config Caddyfile --adapter caddyfile
