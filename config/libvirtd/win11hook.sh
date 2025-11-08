#!/bin/sh
# Libvirt hook script for PCI device passthrough
# Installation: Copy to /etc/libvirt/hooks/qemu and make executable
# chmod +x /etc/libvirt/hooks/qemu

GUEST_NAME="$1"
OPERATION="$2"

# Only handle the win11 VM
if [ "$GUEST_NAME" != "win11" ]; then
    exit 0
fi

# PCI device addresses
GPU_VGA="0000:03:00.0"
GPU_AUDIO="0000:03:00.1"
USB1="0000:13:00.3"
USB2="0000:0e:00.0"
USB3="0000:10:00.0"

# Device IDs for vfio-pci
GPU_VGA_ID="1002 744c"
GPU_AUDIO_ID="1002 ab30"
USB_ID="1022 15b6"
USB_ID2="1022 43f7"

detach_devices() {
    echo "Detaching devices from host drivers..."
    
    # Stop services
    systemctl stop display-manager.service
    systemctl stop ollama.service

    # Unbind from host drivers
    echo "$GPU_VGA" > /sys/bus/pci/drivers/amdgpu/unbind 2>/dev/null || true
    echo "$GPU_AUDIO" > /sys/bus/pci/drivers/snd_hda_intel/unbind 2>/dev/null || true
    echo "$USB1" > /sys/bus/pci/drivers/xhci_hcd/unbind 2>/dev/null || true
    echo "$USB2" > /sys/bus/pci/drivers/xhci_hcd/unbind 2>/dev/null || true
    echo "$USB3" > /sys/bus/pci/drivers/xhci_hcd/unbind 2>/dev/null || true
    
    # Bind to vfio-pci
    echo "$GPU_VGA_ID" > /sys/bus/pci/drivers/vfio-pci/new_id 2>/dev/null || echo "$GPU_VGA" > /sys/bus/pci/drivers/vfio-pci/bind
    echo "$GPU_AUDIO_ID" > /sys/bus/pci/drivers/vfio-pci/new_id 2>/dev/null || echo "$GPU_AUDIO" > /sys/bus/pci/drivers/vfio-pci/bind
    echo "$USB_ID" > /sys/bus/pci/drivers/vfio-pci/new_id 2>/dev/null || echo "$USB1" > /sys/bus/pci/drivers/vfio-pci/bind
    echo "$USB_ID2" > /sys/bus/pci/drivers/vfio-pci/new_id 2>/dev/null || echo "$USB2" > /sys/bus/pci/drivers/vfio-pci/bind
    echo "$USB_ID2" > /sys/bus/pci/drivers/vfio-pci/new_id 2>/dev/null || echo "$USB3" > /sys/bus/pci/drivers/vfio-pci/bind
    
    # Set CPU affinity to reserve cores for VM
    systemctl set-property --runtime -- system.slice AllowedCPUs=8-15,25-31
    systemctl set-property --runtime -- user.slice AllowedCPUs=8-15,25-31
    systemctl set-property --runtime -- init.scope AllowedCPUs=8-15,25-31
    for pid in /proc/[0-9]*; do 
        taskset -apc 8-15,24-31 ${pid##*/} 2>/dev/null || true
    done

    
    echo "Devices detached and ready for passthrough"

    if ! modprobe -r amdgpu; then
      echo "WARNING: Unable to unload amdgpu driver since it is still in use!"
    fi
}

reattach_devices() {
    echo "Reattaching devices to host drivers..."

    modprobe amdgpu
    
    # Unbind from vfio-pci
    echo "$GPU_VGA" > /sys/bus/pci/drivers/vfio-pci/unbind 2>/dev/null || true
    echo "$GPU_AUDIO" > /sys/bus/pci/drivers/vfio-pci/unbind 2>/dev/null || true
    echo "$USB1" > /sys/bus/pci/drivers/vfio-pci/unbind 2>/dev/null || true
    echo "$USB2" > /sys/bus/pci/drivers/vfio-pci/unbind 2>/dev/null || true
    echo "$USB3" > /sys/bus/pci/drivers/vfio-pci/unbind 2>/dev/null || true
    
    # Bind to host drivers
    echo "$GPU_VGA" > /sys/bus/pci/drivers/amdgpu/bind 2>/dev/null || true
    echo "$GPU_AUDIO" > /sys/bus/pci/drivers/snd_hda_intel/bind 2>/dev/null || true
    echo "$USB1" > /sys/bus/pci/drivers/xhci_hcd/bind 2>/dev/null || true
    echo "$USB2" > /sys/bus/pci/drivers/xhci_hcd/bind 2>/dev/null || true
    echo "$USB3" > /sys/bus/pci/drivers/xhci_hcd/bind 2>/dev/null || true
    
    # Restore CPU affinity
    systemctl set-property --runtime -- system.slice AllowedCPUs=0-31
    systemctl set-property --runtime -- user.slice AllowedCPUs=0-31
    systemctl set-property --runtime -- init.scope AllowedCPUs=0-31
    for pid in /proc/[0-9]*; do 
        taskset -apc 0-31 ${pid##*/} 2>/dev/null || true
    done
    
    # Start services
    systemctl start display-manager.service
    systemctl start ollama.service
    
    echo "Devices reattached to host"
}

case "$OPERATION" in
    "prepare")
        detach_devices
        ;;
    "release")
        reattach_devices
        ;;
esac

exit 0
