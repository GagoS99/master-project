const express = require('express');
const { Pool } = require('pg');
const client = require('prom-client');

const PORT = process.env.PORT || 8080;
const DATABASE_URL = process.env.DATABASE_URL || 'postgres://postgres:postgres@localhost:5432/items';

const app = express();
app.use(express.json());

const pool = new Pool({ connectionString: DATABASE_URL });

const register = new client.Registry();
client.collectDefaultMetrics({ register });
const httpDuration = new client.Histogram({
  name: 'http_request_duration_seconds',
  help: 'HTTP request duration in seconds',
  labelNames: ['method', 'route', 'status'],
  buckets: [0.005, 0.01, 0.05, 0.1, 0.5, 1, 2, 5],
});
register.registerMetric(httpDuration);

app.use((req, res, next) => {
  const end = httpDuration.startTimer();
  res.on('finish', () => {
    end({ method: req.method, route: req.route ? req.route.path : req.path, status: res.statusCode });
  });
  next();
});

app.get('/healthz', (_req, res) => res.status(200).json({ status: 'ok' }));

app.get('/readyz', async (_req, res) => {
  try {
    await pool.query('SELECT 1');
    res.status(200).json({ status: 'ready' });
  } catch (err) {
    res.status(503).json({ status: 'not ready', error: err.message });
  }
});

app.get('/api/items', async (_req, res) => {
  try {
    const { rows } = await pool.query('SELECT id, name, created_at FROM items ORDER BY id DESC LIMIT 100');
    res.json(rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.post('/api/items', async (req, res) => {
  const { name } = req.body || {};
  if (!name || typeof name !== 'string') {
    return res.status(400).json({ error: 'name (string) required' });
  }
  try {
    const { rows } = await pool.query('INSERT INTO items(name) VALUES($1) RETURNING id, name, created_at', [name]);
    res.status(201).json(rows[0]);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.get('/metrics', async (_req, res) => {
  res.set('Content-Type', register.contentType);
  res.end(await register.metrics());
});

app.listen(PORT, () => {
  console.log(`api listening on :${PORT}`);
});
