FROM python:3.9

# Setup env
ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONFAULTHANDLER 1

RUN groupadd -g 10001 flaskapp && \
   useradd -u 10000 --create-home -g flaskapp flaskapp \
   && chown -R flaskapp:flaskapp /app

WORKDIR /home/flaskapp
USER flaskapp

# Install pipenv and compilation dependencies
RUN pip install pipenv
RUN apt-get update && apt-get install -y --no-install-recommends gcc

# Install python dependencies in /.venv
COPY Pipfile .
COPY Pipfile.lock .
RUN PIPENV_VENV_IN_PROJECT=1 pipenv install --deploy

ENV PATH="/.venv/bin:$PATH"

# Install application into container
COPY . .

# Run the application
ENTRYPOINT ["pipenv", "run", "waitress-serve"]
CMD ["--call", "backend:create_app"]
