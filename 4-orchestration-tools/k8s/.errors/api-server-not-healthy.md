# API Server Not Healthy

## Problem

```ini
Unfortunately, an error has occurred:
context deadline exceeded

This error is likely caused by: - The kubelet is not running - The kubelet is unhealthy due to a misconfiguration of the node in some way (required cgroups disabled)

If you are on a systemd-powered system, you can try to troubleshoot the error with the following commands: - 'systemctl status kubelet' - 'journalctl -xeu kubelet'
error execution phase kubelet-start: context deadline exceeded
To see the stack trace of this error execute with --v=5 or higher
```

## Solution 1 => Disabling the swap memory and enabling the cgroup memory

the solution is by disabling the swap memory and enabling the cgroup memory

```bash
sudo swapoff -a
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
sudo systemctl daemon-reload
sudo systemctl restart kubelet
```

If the directory `/etc/systemd/system/kubelet.service.d/` does not exist, you can create it and then configure the `kubelet` options, or modify the main `kubelet` service file directly.

Here’s how you can disable the cgroup driver for `kubelet` by modifying the correct configuration:

## Solution 2 => Enable the cgroup driver for kubelet

- **Cgroups (Control Groups)** are a Linux kernel feature that `kubelet` uses to manage resource allocation (like CPU and memory) for containers. If cgroups are not properly configured or disabled, the `kubelet` will not be able to manage resources correctly, leading to an unhealthy state.

- Kubernetes relies on cgroups to ensure the containers on a node are running in isolation with resource limits. If the required cgroups are not available, `kubelet` will fail or become "unhealthy."

- **Steps to resolve this:**

  - Ensure that the correct `cgroup` driver is enabled for `kubelet`. You can check what driver is being used by running:

    ```bash
    sudo cat /var/lib/kubelet/config.yaml | grep cgroupDriver
    ```

  - If you need to set the `cgroup` driver, you can specify it in the `kubelet` configuration by editing `/var/lib/kubelet/config.yaml` and setting:

    ```yaml
    cgroupDriver: systemd # or 'cgroupfs' depending on your system
    ```

  - After editing, restart the `kubelet`:

    ```bash
    sudo systemctl restart kubelet
    ```

  - If your system uses `systemd`, you might need to enable it by editing the `kubelet` configuration file or setting the correct options in your container runtime (like `containerd` or `Docker`).

### Additional Considerations

- Ensure that your node has the required cgroups enabled. You can check this by verifying the cgroup subsystems supported on your system:

  ```bash
  lssubsys -a
  ```

  You should see something like:

  ```bash
  cpu
  cpuacct
  cpuset
  memory
  ```

- If `cgroup` subsystems are missing or disabled, you might need to configure your kernel to enable them, or fix the container runtime (`Docker` or `containerd`) configuration to match Kubernetes’ requirements.

If you're still facing issues after checking these steps, feel free to ask for further guidance!
