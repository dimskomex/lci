# Use the official AFL++ image
FROM aflplusplus/aflplusplus:latest

# Install build dependencies
RUN apt-get update && apt-get install -y \
    cmake \
    build-essential \
    --no-install-recommends

WORKDIR /src
COPY . .

# Use AFL++ compilers for instrumentation
ENV CC=afl-clang-fast
ENV CXX=afl-clang-fast++

# Build lci
RUN mkdir build && cd build && \
    cmake .. && \
    make -j$(nproc)

# Fuzzing Prep
RUN mkdir -p /src/fuzz/in /src/fuzz/out

# Create a valid LOLCODE
RUN echo 'HAI 1.2\n  VISIBLE "HELLO"\nKTHXBYE' > /src/fuzz/in/seed.lol

ENTRYPOINT ["afl-fuzz", "-i", "fuzz/in", "-o", "fuzz/out", "-V", "300", "--", "./build/lci"]
CMD ["@@"]
