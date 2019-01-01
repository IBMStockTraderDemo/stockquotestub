# Generated from project test
FROM ubuntu:14.04

# ------------------------------------------------------------------------------------
# All lines below should be left unchanged unless otherwise stated
# ------------------------------------------------------------------------------------ 

RUN apt-get update \
  && apt-get install --no-install-recommends -y wget unzip \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* \
  && rm -rf /tmp/*

ENV RITC_VERSION=ritc_920 \
   RITC_REPO=ftp://public.dhe.ibm.com/software/spcn/continuoustest/docker \
   TINI_VERSION=v0.9.0

ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /bin/tini
RUN chmod +x /bin/tini

RUN wget -nv ${RITC_REPO}/${RITC_VERSION}.zip#I20180327_1117 \
  && unzip -q ${RITC_VERSION}.zip \
  && rm ${RITC_VERSION}.zip

# ------------------------------------------------------------------------------------
# To change the locale, replace the RIT_LOCALE value in the following line
# ------------------------------------------------------------------------------------
ENV RIT_LOCALE=en_US

ENV LANG=${RIT_LOCALE}.UTF-8 \
   LC_ALL=${RIT_LOCALE}.UTF-8 \
   LANGUAGE=${RIT_LOCALE}:

RUN locale-gen "${RIT_LOCALE}.UTF-8"

ENV LD_LIBRARY_PATH=
COPY /UserLibs /UserLibs
COPY /Project /Project
COPY /stubs.info /stubs.info

# Stub Quoter is exposed on port 31002/TCP
EXPOSE 31002

ENTRYPOINT ["/bin/tini", "--", "/IntegrationTester/RunTests", "-project", "/Project/test.ghp", "-environment", "ubuntu", "-noHTTP", "-run", "3293aa9f:167a43a6e8e:-7c32", "-environmentTags", "env" ]
