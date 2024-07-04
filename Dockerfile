FROM debian:stable-slim
RUN apt update && apt install -y curl
RUN curl -sS https://repo.openbytes.ie/openbytes.gpg > /usr/share/keyrings/openbytes.gpg && \
  echo "deb [signed-by=/usr/share/keyrings/openbytes.gpg] https://repo.openbytes.ie/patchman/debian bookworm main" > /etc/apt/sources.list.d/patchman.list && \
  apt update && apt -y install python3-patchman patchman-client && patchman-manage createsuperuser

ENV APACHE_RUN_DIR /var/run/apache2
ENV APACHE_PID_FILE /var/run/apache2/apache2.pid
ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_LOG_DIR /var/log/apache2

# Expose port 80 to access Apache
EXPOSE 80
COPY ./run.sh /run.sh
COPY ./patchman.conf /etc/apache2/conf-available/patchman.conf
RUN chmod +x /run.sh
# Use a basecommand to initialize and run Apache in the foreground
CMD ["bash", "/run.sh"]
