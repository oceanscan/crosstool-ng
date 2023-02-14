###########################################################################
# GLUED: GNU/Linux Uniform Environment Distribution                       #
# Copyright (C) 2016 OceanScan - Marine Systems & Technology, Lda.        #
###########################################################################
# This program is free software; you can redistribute it and/or modify    #
# it under the terms of the GNU General Public License as published by    #
# the Free Software Foundation; either version 2 of the License, or (at   #
# your option) any later version.                                         #
#                                                                         #
# This program is distributed in the hope that it will be useful, but     #
# WITHOUT ANY WARRANTY; without even the implied warranty of              #
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU       #
# General Public License for more details.                                #
#                                                                         #
# You should have received a copy of the GNU General Public License       #
# along with this program; if not, write to the Free Software             #
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA           #
# 02110-1301 USA.                                                         #
###########################################################################
# Author: Ricardo Martins                                                 #
###########################################################################

FROM ubuntu:22.04

ENV DEBIAN_FRONTEND noninteractive

# Update distro.
RUN apt update -y
RUN apt install -y \
    wget \
    bzip2 \
    git \
    g++-multilib \
    file \
    xz-utils \
    m4 \
    gawk \
    texinfo \
    zip \
    unzip \
    pkg-config \
    intltool \
    help2man \
    bison \
    flex \
    make \
    libtool \
    libtool-bin \
    libncurses-dev \
    rsync \
    python3 \
