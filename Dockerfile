# For more information, please refer to https://aka.ms/vscode-docker-python
FROM python:3.9-alpine3.13
LABEL maintainer="brandon"

EXPOSE 8000
EXPOSE 5678
# Keeps Python from generating .pyc files in the container
ENV PYTHONDONTWRITEBYTECODE=1

# Turns off buffering for easier container logging
ENV PYTHONUNBUFFERED=1

# Install pip requirements
COPY ./requirements.txt /tmp/requirements.txt
COPY ./requirements.dev.txt /tmp/requirements.dev.txt
COPY ./app /app
WORKDIR /app

ARG DEV=false
RUN python -m venv /py && \
    /py/bin/pip install --upgrade pip && \
    apk add --update --no-cache postgresql-client jpeg-dev && \
    apk add --update --no-cache --virtual .tmp-build-deps \
    build-base postgresql-dev musl-dev zlib zlib-dev && \
    /py/bin/pip install -r /tmp/requirements.txt && \
    if [ $DEV = "true" ]; \
    then /py/bin/pip install -r /tmp/requirements.dev.txt ; \
    fi && \
    apk del .tmp-build-deps && \
    adduser \
    -u 5678 \
    --disabled-password \
    --no-create-home \
    --gecos "" \
    appuser && \
    chown -R appuser:appuser /app && \
    mkdir -p /vol/web/media && \
    mkdir -p /vol/web/static && \
    chown -R appuser:appuser /vol && \
    chmod -R 755 /vol
# Creates a non-root user with an explicit UID and adds permission to access the /app folder
# For more info, please refer to https://aka.ms/vscode-docker-python-configure-containers
USER appuser
ENV PATH="/py/bin:$PATH"
# During debugging, this entry point will be overridden. For more information, please refer to https://aka.ms/vscode-docker-python-debug
CMD ["gunicorn", "--bind", "0.0.0.0:8000", "app.wsgi"]
