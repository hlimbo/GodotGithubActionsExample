# can't use linux alpine as butler depends on glibc which linux alpine doesn't support out of the box
# can try out: https://hub.docker.com/r/frolvlad/alpine-glibc/ to see if that will work w/ benefit of smaller image size
FROM ubuntu:20.04

COPY ./continuous-integration/shell-scripts/pre-install.sh /
RUN chmod +x pre-install.sh
RUN ./pre-install.sh

RUN mkdir /downloads
COPY ./continuous-integration/shell-scripts/install.sh ./continuous-integration/shell-scripts/upload.sh /
RUN chmod +x ./install.sh && chmod +x ./upload.sh 
RUN ./install.sh

# export_presets.cfg -> determine how a godot game gets built on a target platform for a player to play!
COPY ./continuous-integration/dependencies/export_presets.cfg /
# importing godot export templates to build the game with
RUN mkdir -p /godot-export-templates/templates
COPY ./continuous-integration/dependencies/* /godot-export-templates/templates/

# assumption: Github Actions Checkout dependency inserts the current repo into the runner's filesystem
# copy game assets into docker container
RUN mkdir -p /downloads/game
COPY ./game /downloads/game/

# CMD - what the startup program or command will be
# CMD ["/usr/bin/bash"]
CMD ["./upload.sh"]
