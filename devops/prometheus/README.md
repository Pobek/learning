# Promethues

## General Information

- Open-source monitoring solution & time series database
- Promethues provides Metrics & Alerting
- It is inspired by Google's Borgmon, which uses time-series
data as datasource, to then send alerts based on this data
- In prometheus we talk about Dimensional Data: time series are identified
by metric name and a set of key/value pairs
    - Metric name: `Temperature`
    - Label: `location=outside`
    - Sample: `90`
- Promethus includes a flexible query language
- Visualizations can be shown using a built-in expression browser or with
integrations like Grafana
- It stores metrics in memory and local disk in an own custom, efficient format

### How does it work?

- Prometheus collects metrics from monitored targets by scraping metrics HTTP endpoints
- This is fundamentally different than other monitoring and alerting systems
- Rather than using custom scripts, that check on particular services and systems,
the monitoring data itself is used
- Scraping endpoints is much more eddicient than other machanisms, like 3rd party agents.
- A singple promethues server is able to ingest up to one million samples per second as
several million time serie

## Installation

- Github scripts: https://github.com/in4it/prometheus-course
- Full distro: https://github.com/prometheus/prometheus/releases

## Basic Concepts

- All data is stored as time series
- Every time series is identified bt the "metric-name" and a set of 
key-value pairs, called labels
- metric: `go_memstat_alloc_bytes`
- instance=localhost:9090, job="prometheus"
- The time series data also consists of the actual data, called Samples:
- It can be float64 value or a millisecond-percision timestamp
- The notation of time series is often using the notation:
    - `<metric_name>{<label_name>=<label_value>,...}`
    - For example: `node_boot_time{instance="localhost:9100",job="node-exporter"}`

## Configuration

- The configuration is stored in the Prometheus configuration file, in yaml format
- The configuration file can be changed and applied, without having to restart Prometheus
- A reload can be done by executing `kill -SIGHUP <pid>`
- You can also pass flags at startup time to `./prometheus`
- Those flags cannot be changed without restarting Prometheus
- The configuration file is passed using the flag `--config.file`
- To scrape metrics, you need to add configuration to the prometheus config file

## Service Discovery

- Definition: Service Discovery is the automatic detection of devices and services offered by
these devices on a computer network.
- Update a file - Not really a service discovery mechanism

## Metric Types

- There are 4 types of metrics:
- Counter
    - A value that only goes up (e.g. Visits to a website)
- Gauge
    - A single numeric value that can go up and down (e.g. CPU load, temperature)
- Histogram
    - Samples observations (e.g. request duration or response sizes) and these
observations get counted into buckets. Includes (`_count` and `_sum`). Main purpose is
calculating quantiles
- Summary
    - Similar to a histogram, a summary samples observations (e.g. request durations or
response sizes). A summary also provides a total count of observations and a sum of all ovserved values,
it calculated configurable quantiles over a sliding time window.
    - Example: you need 2 counters for calculating the latency:
    - Total request (`_count`)
    - The total latency of those requests (`_sum`)
    - Take the `rate()` and devide. The result is average latency.

## Pushing Metrics

- Prometheus doesn't like push requests, only pull.
- Therefore, there is a program called `Pushgateway` that will accept push requests from apps
and let Prometheus pull them from him.
- Sometimes metrics cannot be scraped
- Example: batch jobs, servers that are not reachable due to NAT, firewall, etc.
- Pushgateway is used as an intermediary service which allows you to push metrics.
- Pitfalls
    - Most of the times this is a single instance so this results in a SPOF
    - Prometheus's automatic instance health monitoring is not possible
    - The Pushgateway never forgets the metrics unless they are deleted via the API

## Querying Metrics

- Prometheus provides a functional expression language called PromQL
- Provides built in operators and functions
- Vector-based calculations like Excel
- Expressions over time-series vectors
- PromQL is read-only

### Vectors

- Instant Vector - a set of time series containing a single sample for each time
series, all sharing the same timestamp. Exmaple: `node_cpu_seconds_total`
- Range Vector - a set of time series containing a range of data points over time
for each time series. Example `node_cpu_seconds_total[5m]`
- Scalar - a simple numberic floating point value
- String - a simple string value; currently unused.

### Operators

- Arithmetic binary operators (- * / % ^ +)
- Comparison binary operators (== != > < >= <=)
- Logical/set binary operators (and, or, unless)
- Aggregation operators (sum, min, max, avg, stddev, stdvar, count...)

#### Nice to know queries

- `http_requests_total{job=~".*etheus"}` - Will return all the samples that have
a label "job" that ends with the string "etheus".
- `http_request_total{job=~".*etheus", method="get"}[5m]` - Will return all the samples
that have a label "job" that ends with the string "etheus" and a label "method" with the
value "get" in the last 5 minutes.
- `http_requests_total{code!~"2.."}` - Will return all the samples that in the value of label
"code" dont start with the number 2 but still has 2 numbers after so. (meaning a number in
the hundreds that doesn't begin with 2)

## Exporters

- Build for exporting prometheus metrics from existing 3rd party metrics
- When prometheus is not able to pull metrics directly


## Alerting

- Alerting in promethes is seperated into 2 parts
    - Alerting rules in prometheus server
    - Alertmanager

### Rules

- Rules live in prometheus server config
- Best practice is to separate the alets from the prometheus config
    - Its possible when including external files into the config file

## Storage

- You can use the default local on-disk storage, or optionally the remote storage system
- Local storage: a local time series databse in a custom Promethues format
- Remote storage: you can read/write samples to a remote system in a standadized format
- Currently it uses a snappy-compressed protocol buffer encoding over HTTP, but might change
in the future (to use gRPC or HTTP/2)
- On average, Prometheus needs 1-2 bytes per sample
- You can use the following formula to calculate the disk space needed:

    `needed_disk_space = retention_time_seconds * ingested_samples_per_second * bytes_per_sample`
