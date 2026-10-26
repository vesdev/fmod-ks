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
