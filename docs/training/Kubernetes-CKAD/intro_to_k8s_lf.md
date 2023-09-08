---
title: Introduction to Kubernetes (LFS158x) Notes
authors:
    - McKraken
version: 0.1
mck:
    py_version: v3.11
tags:
    - ckad
---

## Chapter 8 - Building Blocks

### Nodes

- Each node is managed by two k8s agents - kubelet & kube-proxy as well as hosting a container runtime.
- Node identities are created and assigned during the cluster bootstrapping process. Minikube is using the default **kubeadm** bootstrapping tool, to initialize the control plane node during the **init** phase and grow the cluster by adding worker or control plane nodes with the **join** phase.

### Namespaces

- `kube-system` is the default for k8s system resources.
- Create new namespaces with `kubectl create namespace new-namespace-name`
- Resource quotas help users limit the overall resources consumed within Namespaces, while LimitRanges help limit the resources consumed by Containers and their enclosing objects in a Namespace. We will briefly cover quota management in a later chapter.

### Pods

- A Pod is a logical collection of one or more containers, enclosing and isolating them to ensure that they:

    - Are scheduled together on the same host with the Pod.
    - Share the same network namespace, meaning that they share a single IP address originally assigned to the Pod.
    - Have access to mount the same external storage (volumes) and other common dependencies.

- Pod "healing" is handled by controllers (Deployments, ReplicaSets, DaemonSets, Jobs, etc).
- The `spec` is evaluated for scheduling and the `kubelet` of the node handles the running of the container with the container runtime.

### Labels

- Key/Value pairs attached to objects for organization and selection

### Selectors

- **Equality-Based Selectors** allow filtering of objects based on Label keys and values. Matching is achieved using the =, == (equals, used interchangeably), or != (not equals) operators. For example, with `env==dev` or `env=dev` we are selecting the objects where the env Label key is set to value dev.
- **Set-Based Selectors** allow filtering of objects based on a set of values. We can use in, notin operators for Label values, and exist/does not exist operators for Label keys. For example, with `env in (dev,qa)` we are selecting objects where the env Label is set to either dev or qa; with `!app` we select objects with no Label key app.

### Replication Controllers (_Deprecated_)

The default recommended controller is the _Deployment_ which configures a _ReplicaSet_ controller to manage application Pods' lifecycle.

### ReplicaSets

apiVersion: apps/v1

- A ReplicaSet is, in part, the next-generation ReplicationController, as it implements the replication and self-healing aspects of the ReplicationController. ReplicaSets support both equality- and set-based Selectors, whereas ReplicationControllers only support equality-based Selectors.
- ReplicaSets can be used independently as Pod controllers but they only offer a limited set of features. A set of complementary features are provided by Deployments, the recommended controllers for the orchestration of Pods. Deployments manage the creation, deletion, and updates of Pods. A Deployment automatically creates a ReplicaSet, which then creates a Pod. There is no need to manage ReplicaSets and Pods separately, the Deployment will manage them on our behalf.

### Deployments

apiVersion: apps/v1

- It allows for seamless application updates and rollbacks, known as the default RollingUpdate strategy, through rollouts and rollbacks, and it directly manages its ReplicaSets for application scaling. It also supports a disruptive, less popular update strategy, known as Recreate.
- A rolling update is triggered when we update specific properties of the Pod Template for a deployment. While planned changes such as updating the container image, container port, volumes, and mounts would trigger a new Revision, other operations that are dynamic in nature, like scaling or labeling the deployment, do not trigger a rolling update, thus do not change the Revision number.

### DaemonSets

- DaemonSets are operators designed to manage node agents. They resemble ReplicaSet and Deployment operators when managing multiple Pod replicas and application updates, but the DaemonSets present a distinct feature that enforces a single Pod replica to be placed per Node, on all the Nodes. In contrast, the ReplicaSet and Deployment operators by default have no control over the scheduling and placement of multiple Pod replicas on the same Node.
- Whenever a Node is added to the cluster, a Pod from a given DaemonSet is automatically placed on it.
- Similar definition file to ReplicaSet or Deployment, but no "replicas" key in the spec as it's on all nodes.

### Services

## Chapter 9 - Authentication, Authorization, Admission Control

### Authentication

#### Users

- Normal Users: Managed outside the cluster
- Service Accounts: In-cluster processes communicating with the API server.  Authenticate with Secrets and tied to a namespace.

#### Authentication Modules

- X509 Client Certificates: through passing the `--client-ca-file=SOMEFILE` option to the API server
- Static Token File: through passing the `--token-auth-file=SOMEFILE` option to the API
- Bootstrap Tokens: to bootstrap new clusters
- Service Account Tokens: use signed bearer tokens
- OpenID Connect Tokens: helps connect to OAuth2 providers like AzureAD
- Webhook Token Authentication: bearer token verification offloaded to remote service
- Authenticating Proxy: custom programming

We can enable multiple authenticators, and the first module to successfully authenticate the request short-circuits the evaluation. To ensure successful user authentication, we should enable at least two methods: the service account tokens authenticator and one of the user authenticators.

### Authorization

Some of the API request attributes that are reviewed by Kubernetes include user, group, Resource, Namespace, or API group, to name a few. Next, these attributes are evaluated against policies. If the evaluation is successful, then the request is allowed, otherwise it is denied.

- Node authorization: special purpose for kubelet calls
- Attribute-Based Access Control (ABAC): combines policies with attributes. e.g.

   ```json
    {
        "apiVersion": "abac.authorization.kubernetes.io/v1beta1",
        "kind": "Policy",
        "spec": {
            "user": "bob",
            "namespace": "lfs158",
            "resource": "pods",
            "readonly": true
        }
    }
   ```

   To enable ABAC mode, we start the API server with the `--authorization-mode=ABAC` option, while specifying the authorization policy with `--authorization-policy-file=PolicyFile.json`.

- Webhook: we need to start the API server with the `--authorization-webhook-config-file=SOME_FILENAME` option, where `SOME_FILENAME` is the configuration of the remote authorization service
- Role-Based Access Control (RBAC): through starting the API server with the `--authorization-mode=RBAC` option
    - Role: A Role grants access to resources within a specific Namespace.
    - ClusterRole: A ClusterRole grants the same permissions as Role does, but its scope is cluster-wide.

    For example, this **manifest** defines a `pod-reader` role:

    ```yaml
    apiVersion: rbac.authorization.k8s.io/v1
    kind: Role
    metadata:
      namespace: lfs158
      name: pod-reader
    rules:
      - apiGroups: [""] # "" indicates the core API group
        resources: ["pods"]
        verbs: ["get", "watch", "list"]
    ```

    A `Role` can be bound to users with the `RoleBinding` object:

    ```yaml
    apiVersion: rbac.authorization.k8s.io/v1
    kind: RoleBinding
    metadata:
      name: pod-read-access
      namespace: lfs158
    subjects:
      - kind: User
        name: bob
        apiGroup: rbac.authorization.k8s.io
    roleRef:
      kind: Role
      name: pod-reader
      apiGroup: rbac.authorization.k8s.io
    ```

### Demo

### Admission Control

[https://kubernetes.io/docs/reference/access-authn-authz/admission-controllers/](https://kubernetes.io/docs/reference/access-authn-authz/admission-controllers/)

#### What are they?

An admission controller is a piece of code that intercepts requests to the Kubernetes API server prior to persistence of the object, but after the request is authenticated and authorized.

Admission controllers may be validating, mutating, or both. Mutating controllers may modify related objects to the requests they admit; validating controllers may not.

## Chapter 10 - Services

Kubernetes provides a higher-level abstraction (than IP addresses) called **Service**, which logically groups Pods and defines a policy to access them. This grouping is achieved via **Labels** and **Selectors**.  Labels and Selectors use a key-value pair format.

Services can expose single Pods, ReplicaSets, Deployments, DaemonSets, and StatefulSets. When exposing the Pods managed by an operator, the Service's Selector may use the same label(s) as the operator.

Example:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: frontend-svc
spec:
  selector:
    app: frontend
  ports:
  - protocol: TCP
    port: 80
    targetPort: 5000
```

While the Service forwards traffic to Pods, we can select the targetPort on the Pod which receives the traffic. In our example, the frontend-svc Service receives requests from the user/client on port: 80 and then forwards these requests to one of the attached Pods on the targetPort: 5000. If the targetPort is not defined explicitly, then traffic will be forwarded to Pods on the port on which the Service receives traffic. It is very important to ensure that the value of the targetPort, which is 5000 in this example, matches the value of the containerPort property of the Pod spec section.

### kube-proxy

Each cluster node runs a daemon called kube-proxy, a node agent that watches the API server on the master node for the addition, updates, and removal of Services and endpoints. kube-proxy is responsible for implementing the Service configuration on behalf of an administrator or developer, in order to enable traffic routing to an exposed application running in Pods. In the example below, for each new Service, on each node, kube-proxy configures iptables rules to capture the traffic for its ClusterIP and forwards it to one of the Service's endpoints.

The kube-proxy node agent together with the iptables implement the load-balancing mechanism of the Service when traffic is being routed to the application Endpoints. Due to restricting characteristics of the iptables this load-balancing is random by default.

Traffic policies allow users to instruct the kube-proxy on the context of the traffic routing. The two options are Cluster and Local:

- The Cluster option allows kube-proxy to target all ready Endpoints of the Service in the load-balancing process.
- The Local option, however, isolates the load-balancing process to only include the Endpoints of the Service located on the same node as the requester Pod.

### Service Discovery

As Services are the primary mode of communication between containerized applications managed by Kubernetes, it is helpful to be able to discover them at runtime. Kubernetes supports two methods for discovering Services:

- **Environment Variables:** As soon as the Pod starts on any worker node, the kubelet daemon running on that node adds a set of environment variables in the Pod for all active Services.
- **DNS:** Kubernetes has an add-on for DNS, which creates a DNS record for each Service and its format is my-svc.my-namespace.svc.cluster.local. Services within the same Namespace find other Services just by their names.

### Service Type

- **ClusterIP** is the default ServiceType. A Service receives a Virtual IP address, known as its ClusterIP. This Virtual IP address is used for communicating with the Service and is accessible only from within the cluster.
- The **NodePort** ServiceType, in addition to a ClusterIP, a high-port, dynamically picked from the default range 30000-32767, is mapped to the respective Service, from all the worker nodes.  The node port directs to the ClusterIP of the service.
- With the **LoadBalancer** ServiceType:
    - NodePort and ClusterIP are automatically created, and the external load balancer will route to them.
    - The Service is exposed at a static port on each worker node.
    - The Service is exposed externally using the underlying cloud provider's load balancer feature.

        !!! Note
            The LoadBalancer ServiceType will only work if the underlying infrastructure supports the automatic creation of Load Balancers and have the respective support in Kubernetes, as is the case with the Google Cloud Platform and AWS. If no such feature is configured, the LoadBalancer IP address field is not populated, it remains in Pending state, but the Service will still work as a typical NodePort type Service.

- A Service can be mapped to an **ExternalIP** address if it can route to one or more of the worker nodes.  ExternalIPs are not managed by Kubernetes. The cluster administrator has to configure the routing which maps the ExternalIP address to one of the nodes.
- **ExternalName** is a special ServiceType that has no Selectors and does not define any endpoints. When accessed within the cluster, it returns a CNAME record of an externally configured Service.  The primary use case of this ServiceType is to make externally configured Services like my-database.example.com available to applications inside the cluster.

A Service resource can expose multiple ports at the same time if required. Its configuration is flexible enough to allow for multiple groupings of ports to be defined in the manifest.
