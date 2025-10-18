# Create user via external identity provider

Using an external identity provider is a good way to manage users and groups. Here’s an example using OpenID Connect (OIDC):

- **External Identity Provider**: Define groups within the provider and assign users to these groups.

1. **Configure the OIDC Provider** (e.g., Keycloak, Auth0, Dex):

   - Set up an OIDC provider and create a client application for Kubernetes.

2. **Configure the Kubernetes API Server**:
   Add the following flags to the API server startup arguments:

   ```sh
   --oidc-issuer-url=https://issuer-url.com
   --oidc-client-id=kubernetes
   --oidc-username-claim=email
   --oidc-groups-claim=groups
   ```

## Summary

- **Users**: Managed externally (e.g., client certificates, static token files, external identity providers).
- **Groups**: Defined within client certificates or external identity providers.
- **RoleBindings and ClusterRoleBindings**: Used to assign permissions to users and groups within Kubernetes.

Once users and groups are set up, you can create RoleBindings and ClusterRoleBindings to manage permissions.
