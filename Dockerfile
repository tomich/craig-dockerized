FROM ubuntu:22.04
RUN apt update && DEBIAN_FRONTEND=noninteractive apt install -y git bash
RUN git clone --recurse-submodules https://github.com/tomich/craig.git
WORKDIR /craig
COPY files/install.config /craig/install.config
COPY files/startup.sh /root/startup.sh
RUN chmod +x /root/startup.sh
RUN bash -c "/craig/install.sh"
EXPOSE 3000
EXPOSE 5029
ENTRYPOINT bash -c "/root/startup.sh"