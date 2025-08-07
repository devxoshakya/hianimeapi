import app from './src/app';
import Bun from 'bun';

const port = process.env.PORT || 3030;

Bun.serve({
  port: port,
  fetch: app.fetch,
});

console.log(`Server running on port ${port}`);


// RAM1901719