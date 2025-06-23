const express = require('express')
const app = express()
const port = 3000

app.get('/', (req, res) => {
  res.send('Hello World!')
})

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
