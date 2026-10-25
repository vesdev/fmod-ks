run example="init":
    mkdir -p target
    kast compile --target c examples/{{example}}/main.ks > target/main.c
    gcc target/main.c -o target/main \
        -I${KAST_PATH}/c-runtime/include ${KAST_PATH}/c-runtime/src/*.c \
        -Ifmod/api/core/inc -Ifmod/api/studio/inc \
        -Lfmod/api/core/lib/x86_64 -Lfmod/api/studio/lib/x86_64 \
        -Wl,-rpath,'$ORIGIN/../fmod/api/core/lib/x86_64:$ORIGIN/../fmod/api/studio/lib/x86_64' \
        -lfmodstudio -lfmod -lm -lbacktrace -pthread

    ./target/main

check example="init":
    mkdir -p target
    kast compile --target c examples/{{example}}/main.ks > target/main.c
    gcc -fsyntax-only target/main.c \
        -I${KAST_PATH}/c-runtime/include \
        -Ifmod/api/core/inc -Ifmod/api/studio/inc
