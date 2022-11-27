# Fluentd × Elasticsearch × Kibana (EFK Stack)

A containerised logging pipeline that collects Apache httpd access logs via **Fluentd**, stores them in **Elasticsearch**, and visualises them in **Kibana**.

---

## Architecture

```
httpd (port 8888)
    │  Docker fluentd log driver
    ▼
Fluentd (port 24224)  ──►  Elasticsearch (port 9200)  ──►  Kibana (port 5601)
    │
    └──►  /fluentd/logs  (local file backup)
```

| Service       | Image                                                  | Port  |
| ------------- | ------------------------------------------------------ | ----- |
| httpd         | `httpd`                                                | 8888  |
| fluentd       | custom (built from `./fluentd/Dockerfile`)             | 24224 |
| elasticsearch | `docker.elastic.co/elasticsearch/elasticsearch:7.13.1` | 9200  |
| kibana        | `docker.elastic.co/kibana/kibana:7.13.1`               | 5601  |
| portainer     | `portainer/portainer-ce:latest`                        | 9000  |

---

## Quick Start

### 1. Start the stack

```bash
./runMe.sh
```

Or manually:

```bash
docker compose down --remove-orphans
docker compose up -d --build
```

### 2. Create Kibana dashboards

Run once after the stack is up (safe to re-run — fully idempotent):

```bash
python3 setup-kibana.py
```

### 3. Generate test traffic

```bash
# Normal requests
for i in {1..10}; do curl -s http://localhost:8888/; done

# 404 errors
for i in {1..5}; do curl -s http://localhost:8888/not-found-$i; done
```

---

## Kibana Dashboards

> Kibana UI: **http://localhost:5601**

| Dashboard                 | Description                                                      | Link                                                                            |
| ------------------------- | ---------------------------------------------------------------- | ------------------------------------------------------------------------------- |
| **HTTP Access Logs**      | Total requests, status codes, methods, top paths & client IPs    | [Open →](http://localhost:5601/app/dashboards#/view/dashboard-http-access-logs) |
| **HTTP Errors (4xx/5xx)** | Error count, status breakdown, errors over time, top error paths | [Open →](http://localhost:5601/app/dashboards#/view/dashboard-errors)           |

### HTTP Access Logs

Panels included:

- **Total Requests** — metric count
- **Request Methods** — pie chart (GET / POST / HEAD …)
- **Status Code Distribution** — donut chart
- **Requests Over Time** — area chart (last 24 h)
- **Top Requested Paths** — table
- **Top Client IPs** — table

### HTTP Errors (4xx / 5xx)

Panels included:

- **Total Error Count** — metric, colour-coded
- **Error Status Code Breakdown** — donut chart
- **Errors Over Time** — area chart (last 24 h)
- **Top Error Paths with Status Codes** — table

---

## Other Services

| Service           | URL                   |
| ----------------- | --------------------- |
| httpd (test site) | http://localhost:8888 |
| Elasticsearch API | http://localhost:9200 |
| Kibana            | http://localhost:5601 |
| Portainer         | http://localhost:9000 |

---

## Project Structure

```
.
├── docker-compose.yaml        # Stack definition
├── runMe.sh                   # One-command start script
├── setup-kibana.py            # Creates Kibana index pattern + dashboards
├── fluentd/
│   ├── Dockerfile             # Custom fluentd image (ES 7.x compatible gems)
│   └── conf/
│       ├── fluent.conf        # Fluentd config: parse Apache logs → ES + file
│       └── fluent.conf.bak    # Reference / backup config
└── logs/                      # Fluentd file output (mounted volume)
```

---

## How Logs Flow

1. **httpd** writes access logs via Docker's `fluentd` log driver to Fluentd on port `24224`.
2. **Fluentd** applies an Apache combined-log regex parser (extracts `host`, `method`, `path`, `code`, `size`), then fans out to three outputs:
   - Elasticsearch index `fluentd-YYYYMMDD`
   - stdout (visible in `docker logs fluentd`)
   - local file under `./logs/`
3. **Kibana** reads from the `fluentd-*` index pattern to power the dashboards.

---

## Troubleshooting

```bash
# Check all container statuses
docker compose ps

# Tail fluentd logs
docker logs -f fluentd

# Query Elasticsearch directly
curl http://localhost:9200/fluentd-*/_count

# Re-run Kibana dashboard setup
python3 setup-kibana.py
```
