FROM python:3.11-slim-buster AS python-base
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PIP_NO_CACHE_DIR=off \
    PIP_DISABLE_PIP_VERSION_CHECK=on \
    PIP_DEFAULT_TIMEOUT=100 \
    POETRY_HOME="/poetry" \
    POETRY_VIRTUALENVS_IN_PROJECT=true \
    POETRY_NO_INTERACTION=1 \
    PYSETUP_PATH="/terminusbrowser" \
    VENV_PATH="/terminusbrowser/.venv"
ENV PATH="$POETRY_HOME/bin:$VENV_PATH/bin:$PATH"

FROM python-base AS builder-base
ENV POETRY_VERSION=1.3.2
RUN apt-get update && apt-get install -y --no-install-recommends curl build-essential
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
RUN curl -sSL https://install.python-poetry.org | python
WORKDIR $PYSETUP_PATH
COPY ./pyproject.toml ./
COPY ./poetry.lock ./
RUN poetry install --without dev

FROM python-base AS production
COPY --from=builder-base $VENV_PATH $VENV_PATH
COPY ./src/ $PYSETUP_PATH/src/
COPY ./terminus_browser.py $PYSETUP_PATH/terminus_browser.py
WORKDIR $PYSETUP_PATH
ENTRYPOINT ["/terminusbrowser/terminus_browser.py"]
