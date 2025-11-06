#!/usr/bin/env python3
"""
Wake-on-LAN listener for starting/stopping a VM
"""

import socket
import subprocess
import sys
import argparse

# Default Configuration
DEFAULT_START_MAC = "52:54:00:4d:7f:e8"
DEFAULT_SHUTDOWN_MAC = "10:7c:61:3d:34:c1"
DEFAULT_WOL_PORT = 9
DEFAULT_VM_NAME = "win11"


def mac_to_bytes(mac_string):
    """Convert MAC address string to bytes"""
    return bytes.fromhex(mac_string.replace(":", ""))


def is_wol_packet(data, target_mac_bytes):
    """
    Check if packet is a valid WoL packet for target MAC
    WoL packet: 6 bytes of FF followed by 16 repetitions of target MAC
    """
    if len(data) < 102:  # Minimum WoL packet size
        return False

    # Check for 6 bytes of 0xFF
    if data[:6] != b"\xff" * 6:
        return False

    # Check for 16 repetitions of the target MAC
    for i in range(16):
        start = 6 + (i * 6)
        end = start + 6
        if data[start:end] != target_mac_bytes:
            return False

    return True


def execute_vm_command(action, vm_name, virsh_path="virsh"):
    """Execute the virsh command (start or shutdown)"""
    command = [virsh_path, action, vm_name]
    try:
        result = subprocess.run(
            command, capture_output=True, text=True, timeout=30
        )
        if result.returncode == 0:
            print(f"✓ VM {action} command successful: {result.stdout.strip()}")
        else:
            print(f"✗ Failed to {action} VM: {result.stderr.strip()}")
        return result.returncode == 0
    except subprocess.TimeoutExpired:
        print("✗ Command timed out")
        return False
    except Exception as e:
        print(f"✗ Error executing command: {e}")
        return False


def run_listener(start_mac, shutdown_mac, port, vm_name, virsh_path="virsh"):
    """Main listener loop"""
    start_mac_bytes = mac_to_bytes(start_mac)
    shutdown_mac_bytes = mac_to_bytes(shutdown_mac)

    print(f"Wake-on-LAN VM Controller")
    print(f"Start MAC:    {start_mac} -> virsh start {vm_name}")
    print(f"Shutdown MAC: {shutdown_mac} -> virsh shutdown {vm_name}")
    print(f"Listening on UDP port {port}...")
    print("-" * 50)

    # Create UDP socket
    sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    sock.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)

    try:
        # Bind to all interfaces on WoL port
        sock.bind(("", port))
        print(f"✓ Listening for WoL packets...\n")

        while True:
            try:
                data, addr = sock.recvfrom(1024)
                print(
                    f"Received packet from {addr[0]}:{addr[1]} ({len(data)} bytes)"
                )

                if is_wol_packet(data, start_mac_bytes):
                    print(f"✓ Valid WoL packet for {start_mac} detected!")
                    execute_vm_command("start", vm_name, virsh_path)
                    print()  # Blank line for readability
                elif is_wol_packet(data, shutdown_mac_bytes):
                    print(f"✓ Valid WoL packet for {shutdown_mac} detected!")
                    execute_vm_command("shutdown", vm_name, virsh_path)
                    print()  # Blank line for readability
                else:
                    print(f"  Not a WoL packet for configured MACs")

            except KeyboardInterrupt:
                raise
            except Exception as e:
                print(f"Error processing packet: {e}")

    except KeyboardInterrupt:
        print("\n\nShutting down...")
    except PermissionError:
        print(f"\n✗ Permission denied. Port {port} requires root/sudo privileges.")
        sys.exit(1)
    except Exception as e:
        print(f"\n✗ Error: {e}")
        sys.exit(1)
    finally:
        sock.close()
        print("Socket closed.")


def main():
    parser = argparse.ArgumentParser(
        description="Wake-on-LAN VM Controller"
    )
    parser.add_argument(
        "--start-mac",
        default=DEFAULT_START_MAC,
        help=f"MAC address to start VM (default: {DEFAULT_START_MAC})",
    )
    parser.add_argument(
        "--shutdown-mac",
        default=DEFAULT_SHUTDOWN_MAC,
        help=f"MAC address to shutdown VM (default: {DEFAULT_SHUTDOWN_MAC})",
    )
    parser.add_argument(
        "--port",
        type=int,
        default=DEFAULT_WOL_PORT,
        help=f"UDP port to listen on (default: {DEFAULT_WOL_PORT})",
    )
    parser.add_argument(
        "--vm-name",
        default=DEFAULT_VM_NAME,
        help=f"Name of VM to control (default: {DEFAULT_VM_NAME})",
    )
    parser.add_argument(
        "--virsh-path",
        default="virsh",
        help="Path to virsh binary (default: virsh)",
    )

    args = parser.parse_args()

    run_listener(
        args.start_mac,
        args.shutdown_mac,
        args.port,
        args.vm_name,
        args.virsh_path,
    )


if __name__ == "__main__":
    main()
