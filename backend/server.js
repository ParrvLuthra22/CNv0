const http = require('node:http');

const ID = process.env.BACKEND_ID;
const PORT = Number(process.env.PORT);

if (!['A', 'B'].includes(ID)) {
  throw new Error('Set BACKEND_ID to A or B');
}
if (!Number.isInteger(PORT) || PORT < 1 || PORT > 65535) {
  throw new Error('Set PORT to a valid TCP port');
}

const server = http.createServer((req, res) => {
  res.setHeader('X-Backend', ID);
  const method = req.method;
  const isGetOrHead = method === 'GET' || method === 'HEAD';
  const pathname = new URL(req.url, 'http://localhost').pathname;

  if (isGetOrHead && pathname === '/') {
    res.writeHead(200, { 'Content-Type': 'text/plain; charset=utf-8' });
    res.end(method === 'HEAD' ? undefined : `Backend ${ID} is running`);
  } else if (isGetOrHead && pathname === '/api/status') {
    res.writeHead(200, { 'Content-Type': 'application/json; charset=utf-8' });
    res.end(method === 'HEAD' ? undefined : JSON.stringify({ backend: ID, status: 'ok' }));
  } else if (isGetOrHead && pathname === '/api/cached') {
    res.writeHead(200, {
      'Content-Type': 'application/json; charset=utf-8',
      'Cache-Control': 'public, max-age=60',
    });
    res.end(method === 'HEAD' ? undefined : JSON.stringify({ data: 'static-ish content' }));
  } else {
    res.writeHead(404, { 'Content-Type': 'application/json; charset=utf-8' });
    res.end(method === 'HEAD' ? undefined : JSON.stringify({ error: 'Not found' }));
  }
});

server.listen(PORT, '0.0.0.0', () => {
  console.log(`Backend ${ID} on 0.0.0.0:${PORT}`);
});
