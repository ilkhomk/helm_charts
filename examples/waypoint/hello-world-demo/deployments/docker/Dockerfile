## Build the image based python3 
FROM python:3
## Copy all the packages
COPY . /app
## Change the default folder 
WORKDIR /app
## Install all packages
RUN pip install -r /app/requirements.txt
## Default port is 5000
EXPOSE 5000 
## When contianer is stared python app.py 
CMD ["/bin/sh", "-c", "python /app/app.py"]
