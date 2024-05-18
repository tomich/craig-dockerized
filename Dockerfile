FROM ubuntu:22.04
ENV PLATFORM="docker"
RUN apt update && DEBIAN_FRONTEND=noninteractive apt install -y git bash
RUN git clone --recurse-submodules https://github.com/tomich/craig.git
WORKDIR /craig
COPY files/install.config /craig/install.config
# COPY files/startup.sh /root/startup.sh
# RUN chmod +x /root/startup.sh
RUN bash -c "/craig/install.sh"
EXPOSE 3000
EXPOSE 5029
RUN pm2 stop all
RUN rm -rf /root/.pm2 /root/.bash_history /craig/install.config /craig/.env /craig/apps/dashboard/.env /craig/apps/download/.env /craig/apps/bot/.env /craig/apps/bot/config/default.js /craig/apps/tasks/config/default.js /craig/node_modules/craig-bot/.env /craig/node_modules/craig-dashboard/.env /craig/node_modules/craig-horse/.env /craig/node_modules/craig-bot/config/default.js /craig/node_modules/craig-tasks/config/default.js
ENTRYPOINT bash -c "/craig/startup.sh"
