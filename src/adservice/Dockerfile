# Copyright 2020 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Define a default value so it's not empty if the builder fails to provide it
ARG BUILDPLATFORM=linux/amd64

FROM --platform=$BUILDPLATFORM eclipse-temurin:24.0.2_12-jdk-noble@sha256:dacac8e9a0df0d2bd24e702b4431132875c249930b70555ebd7ca285b5bee684 AS builder

WORKDIR /app

# Copy the whole build context in one step. Splitting this into an early copy of
# build.gradle plus a later copy of the sources let the image build reuse a
# build.gradle layer and a source layer from different commits, which produced a
# build that compiled nothing and still reported success.
COPY . .
RUN chmod +x gradlew
RUN ./gradlew downloadRepos
RUN ./gradlew clean installDist; \
    jar tf build/install/hipstershop/lib/hipstershop-0.1.0-SNAPSHOT.jar 2>/dev/null \
      | grep -qx 'hipstershop/AdService.class' \
    || { echo "FATAL: AdService.class missing from the built jar" >&2; \
         echo "--- /app tree (depth 4, excluding gradle/ and build/) ---" >&2; \
         find /app -maxdepth 4 -not -path '/app/gradle/*' -not -path '/app/build/*' | sort >&2; \
         exit 1; }

FROM eclipse-temurin:25.0.3_9-jre-alpine@sha256:28db6fdf60e38945e43d840c0333aeaec66c15943070104f7586fd3c9d1665b0

# @TODO: https://github.com/GoogleCloudPlatform/microservices-demo/issues/2517
# Download Stackdriver Profiler Java agent
# RUN mkdir -p /opt/cprof && \
#     wget -q -O- https://storage.googleapis.com/cloud-profiler/java/latest/profiler_java_agent_alpine.tar.gz \
#     | tar xzv -C /opt/cprof && \
#     rm -rf profiler_java_agent.tar.gz

WORKDIR /app
COPY --from=builder /app .

EXPOSE 9555
ENTRYPOINT ["/app/build/install/hipstershop/bin/AdService"]
