### Requirements

* Linux
* Port 80

* To access Meilisearch, use `ns-tenant0`, `ns-tenant1` ... as names, and add records system
```
/etc/hosts
127.0.0.1 ns-tenant0.meilisearch.frb.io
127.0.0.1 ns-tenant1.meilisearch.frb.io 
127.0.0.1 ns-tenant2.meilisearch.frb.io 
127.0.0.1 ns-tenant3.meilisearch.frb.io 
```

### How-to

Checkout into folder
```
#Create cluster
$ 00_cluster.up.sh
....

#Launch multiple meilisearch instances per tenant
$ bash 01_saas.meilisearch.up.sh tenant0
....
$ bash 01_saas.meilisearch.up.sh tenant1
....
$ bash 01_saas.meilisearch.up.sh tenant2
....

#Shutdown everything
$ bash 03_cluster.down.sh
```



### Begin 

I started solution with installing basic Kind cluster locally and researching approaches to 
deploying SaaS on K8S.

* Software as a Service (SaaS): single-tenant app per namespace

### Library

1. [2018 Multi-Tenancy in Kubernetes: Best Practices Today, and Future Directions - David Oppenheimer](https://www.youtube.com/watch?v=xygE8DbwJ7c&t=803s)


2. [Kubernetes namespaces isolation - what it is, what it isn't, life, universe and everything](https://www.synacktiv.com/en/publications/kubernetes-namespaces-isolation-what-it-is-what-it-isnt-life-universe-and-everything.html)

3. [Adopt a zero trust network model for security](https://projectcalico.docs.tigera.io/security/adopt-zero-trust)

4. [Local Kubernetes setup with KinD](https://www.danielstechblog.io/local-kubernetes-setup-with-kind/)

5. [Exposing Apps With Services](https://www.kubermatic.com/blog/exposing-apps-with-services/)

5. [Services of type ExternalName](https://kubernetes.io/docs/concepts/services-networking/service/#externalname)

6. [Configuring a KinD Cluster with NGINX Ingress Using Terraform and Helm](https://nickjanetakis.com/blog/configuring-a-kind-cluster-with-nginx-ingress-using-terraform-and-helm)

7. [How to easily install multiple instances of the ingress-NGINX controller in the same cluster](https://kubernetes.github.io/ingress-nginx/)

* https://projectcalico.docs.tigera.io/security/namespace-policy
* https://projectcalico.docs.tigera.io/security/adopt-zero-trust
* https://alexbrand.dev/post/creating-a-kind-cluster-with-calico-networking/
* https://helm.sh/docs/intro/install/
* https://kind.sigs.k8s.io/docs/user/ingress/
* https://docs.nginx.com/nginx-ingress-controller/installation/running-multiple-ingress-controllers/

### Theory 

* Consumer interacts only with application, no access to K8S APIs
* Each client has their own app namespace, which guarantees some isolation (not by default)
* Administrator/automation works with K8S API to deploy software, but only exposes the final endpoint
* SaaS offer code/software is semi-trusted, but may include intrusted plugins (i.e. Wordrress)
  * there are further ways to improve security, sandbox pods, sole-tenant nodes
  * network isolation does not exist, but could be added with CNI policies

The idea is deployment script will returns some sort of secret/key and that will be whole scope for client, client does not know anything about hosting in K8S.

### Log

```
Prepared git repository, IDE etc.
First researched solution and launched local Kind cluster.
Researched Meilisearch, what it is.
Stuck on CNI callico for >4 hours trying to apply to Kind. [skipped]
 - none of documented methods worked, too much low custimization and hax required
Stuck on Helm & Nginx ingress trying to apply to Kind locally.
 - cant deploy per-namespace ingress controller, Kind limitation
Researched how to expose services via Ingress, decided first on path-based virtualhosting, then
changed to name-based virtualhosting due to URL-rewrite incompatibilities.

TODO: The command should create an internal Meilisearch master key for each tenant.

```


	✅ - Create a proof of concept Meilisearch feature for fortrabbit.
	✅ - Design a Kubernetes cluster that runs Meilisearch for multiple tenants.
	✅ - We want to be able to run a single command with a given name and have it create a meilisearch setup for one tenant, then run it again with a different name and have it create a separate meilisearch setup for that new tenant
	✅ - When using code, use the language of your choice, write as quick and dirty as possible, it's a POC!


    ✅ The command should show the Meilisearch's public and private keys so that the "customer" can use them to connect, but it should not show the master key.
    ✅ HTTP endpoints of Meilisearch should have a unique domain, which are accessible via HTTPS, like `https://{identifier}.search.frb.io`
    ✅    - Don't care about DNS, assume that `{identifier}.search.frb.io` or `*.search.frb.io` already points to the cluster.

### Artifacts

* [15.01.2022.log.txt](15.01.2022.log.txt)
* [18.01.2022.log.txt](18.01.2022.log.txt)
* [18.01.2022-ingress.png](18.01.2022-ingress.png)

