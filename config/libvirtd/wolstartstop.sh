#!${pkgs.python3}/bin/python3
"""
Wake-on-LAN listener for starting/stopping a VM
Listens for WoL packets for MAC 52:54:00:4d:7f:e8 and starts win11 VM
Listens for WoL packets for MAC 10:7c:61:3d:34:c1 and shuts down win11 VM
"""

import socket
import subprocess
import sys
from binascii import hexlify

# Configuration
START_MAC = "52:54:00:4d:7f:e8"
SHUTDOWN_MAC = "10:7c:61:3d:34:c1"
WOL_PORT = 9  # Standard WoL port (also check 7)
VM_NAME = "win11"

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
    if data[:6] != b'\xff' * 6:
        return False
    
    # Check for 16 repetitions of the target MAC
    for i in range(16):
        start = 6 + (i * 6)
        end = start + 6
        if data[start:end] != target_mac_bytes:
            return False
    
    return True

def execute_vm_command(action):
    """Execute the virsh command (start or shutdown)"""
    command = ["${pkgs.libvirt}/bin/virsh", action, VM_NAME]
    try:
        result = subprocess.run(command, 
                              capture_output=True, 
                              text=True, 
                              timeout=30)
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

def main():
    start_mac_bytes = mac_to_bytes(START_MAC)
    shutdown_mac_bytes = mac_to_bytes(SHUTDOWN_MAC)
    
    print(f"Wake-on-LAN VM Controller")
    print(f"Start MAC:    {START_MAC} -> virsh start {VM_NAME}")
    print(f"Shutdown MAC: {SHUTDOWN_MAC} -> virsh shutdown {VM_NAME}")
    print(f"Listening on UDP port {WOL_PORT}...")
    print("-" * 50)
    
    # Create UDP socket
    sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    sock.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    
    try:
        # Bind to all interfaces on WoL port
        sock.bind(('', WOL_PORT))
        print(f"✓ Listening for WoL packets...\n")
        
        while True:
            try:
                data, addr = sock.recvfrom(1024)
                print(f"Received packet from {addr[0]}:{addr[1]} ({len(data)} bytes)")
                
                if is_wol_packet(data, start_mac_bytes):
                    print(f"✓ Valid WoL packet for {START_MAC} detected!")
                    execute_vm_command("start")
                    print()  # Blank line for readability
                elif is_wol_packet(data, shutdown_mac_bytes):
                    print(f"✓ Valid WoL packet for {SHUTDOWN_MAC} detected!")
                    execute_vm_command("shutdown")
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
        print(f"\n✗ Permission denied. Port {WOL_PORT} requires root/sudo privileges.")
        print(f"Run with: sudo python3 {sys.argv[0]}")
        sys.exit(1)
    except Exception as e:
        print(f"\n✗ Error: {e}")
        sys.exit(1)
    finally:
        sock.close()
        print("Socket closed.")

if __name__ == "__main__":
    main()
