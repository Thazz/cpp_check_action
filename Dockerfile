FROM ubuntu:18.04

LABEL com.github.actions.name="cpp-check-action"
LABEL com.github.actions.description="Lint your code with clang-tidy and cppcheck"
LABEL com.github.actions.icon="code"
LABEL com.github.actions.color="gray-dark"

LABEL repository="https://github.com/Thazz/ccpp_check_action"
LABEL maintainer="Thazz <gregor.seljak@gmail.com>"

WORKDIR /build
RUN apt-get update
RUN apt-get -qq -y install curl
RUN apt-get -qq -y install clang-tidy cmake jq clang cppcheck
RUN apt-get -qq -y install git

ADD entrypoint.sh /entrypoint.sh
COPY . .
CMD ["bash", "/entrypoint.sh"]