FROM python:3.13.5-bullseye

WORKDIR /app

COPY requirements.txt .

RUN pip install -r requirements.txt

COPY . .

COPY init-sh /app/init-sh

RUN chmod +x /app/init-sh

EXPOSE 5000

ENTRYPOINT ["./init-sh", "-p", "python", "--"]

CMD ["python", "server.py"]
