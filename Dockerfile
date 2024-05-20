FROM ubuntu:22.04
ENV PLATFORM="docker"
# We install git only if not testing local depository. If building local, comment lines and use git clone --recurse-submodules on parent dir
RUN apt update && DEBIAN_FRONTEND=noninteractive apt install -y git bash
RUN git clone --recurse-submodules https://github.com/tomich/craig.git
# If testing locally we copy current dir to container(only if parent repo was cloned with git clone --recurse-submodules)
# COPY . /craig
WORKDIR /craig
#The following line is for testing only. Will make all perks the default
RUN sed -i 's/\[0\]/\[99]/' "/craig/apps/bot/config/_default.js" && sed -i 's/\[-1\]/\[0]/' "/craig/apps/bot/config/_default.js" && sed -i 's/\[99\]/\[-1]/' "/craig/apps/bot/config/_default.js"
# Copy config files for initial install
COPY files/install.config /craig/install.config
RUN bash -c "/craig/install.sh"
EXPOSE 3000
EXPOSE 5029
RUN rm -rf /root/.pm2 /root/.bash_history /craig/install.config /craig/.env /craig/apps/dashboard/.env /craig/apps/download/.env /craig/apps/bot/.env /craig/apps/bot/config/default.js /craig/apps/tasks/config/default.js /craig/node_modules/craig-bot/.env /craig/node_modules/craig-dashboard/.env /craig/node_modules/craig-horse/.env /craig/node_modules/craig-bot/config/default.js /craig/node_modules/craig-tasks/config/default.js
ENTRYPOINT bash -c "/craig/start.sh"

