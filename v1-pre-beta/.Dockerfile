FROM ubuntu:22.04

RUN apt-get update && \
    apt-get install -y curl libclang-dev && \
    rm -rf /var/lib/apt/lists/*

RUN curl -fsSL https://ollama.com/install.sh | sh

RUN ollama pull llama3

EXPOSE 11434

CMD ["ollama", "serve", "--model", "llama3"]
