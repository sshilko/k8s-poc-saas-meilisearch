# Kubernetes hiring task

## Background story

A client wants to launch a [Meilisearch](https://www.meilisearch.com/) service without any DevOps skills. Business takes care of automated provisioning, uptime/monitoring and version updates.


## Task

- Create a proof of concept Meilisearch feature.
- Design a Kubernetes cluster that runs Meilisearch for multiple tenants.
- We want to be able to run a single command with a given name and have it create a meilisearch setup for one tenant, then run it again with a different name and have it create a separate meilisearch setup for that new tenant
- When using code, use the language of your choice, write as quick and dirty as possible, it's a POC!

### Implementation

- The command should create an internal Meilisearch master key for each tenant.
- The command should show the Meilisearch's public and private keys so that the "customer" can use them to connect, but it should not show the master key.
- HTTP endpoints of Meilisearch should have a unique domain, which are accessible via HTTPS, like `https://{identifier}.search.frb.io`
    - Don't care about DNS, assume that `{identifier}.search.frb.io` or `*.search.frb.io` already points to the cluster.

### Don't do too much!

- Don't care how to store the keys (master, public, private), some text file is okay.
- Don't care about monitoring, unless you get it for free.
- Don't care about possible ways to scale resources.


## Timing

- The task should not require more than 10 hours of focused work (take a break)



