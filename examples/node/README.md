# Simple express app example

If you want to try this example follow the following steps:

1. run: `npm init -y`
2. run: `npm install express`
3. docker build -t example-express-app .
4. docker run -p 3000:3000 example-express-app

If you haven't faced any issue while running these commands then congratulations! Express app now listening on port 3000.

### init-sh

In order to see init-sh properly send signals to relevant child processes you should run:

- `docker ps` - to identify the example app's container ID
- `docker stop <container-ID>`

Then you will be able to see the logs!

# IMPORTANT

`init-sh` will send the signals to the relevant processes, but remember you are the one who should manage the sent signals (SIGTERM, SIGINT). In node apps in order to do so have this template code in your .js file:

```js
const server = app.listen(port, () => {
  console.log(`App listening on port ${port}`);
});

const shutdown = () => {
  console.log('Received shutdown signal. Closing server...');

  server.close(() => {
    console.log('Server closed. Exiting process...');
    process.exit(0);
  });

  setTimeout(() => {
    console.error('Could not close server gracefully. Exiting forcefully...');
    process.exit(1);
  }, 5000);
};

// Handling termination signals (SIGINT, SIGTERM)
process.on('SIGINT', shutdown);
process.on('SIGTERM', shutdown);
```

Basically, process.on waits for the signal and then execute the shutdown function.
