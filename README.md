# Rachio-Wifi-Setup-Linux-Script

A script for updating a Rachio 3's Wi-Fi credentials. 

I made this because the script provided in the [Official Rachio Support Article](https://support.rachio.com/en_us/connect-rachio-3-to-wifi-using-a-laptop-or-older-mobile-device-HJIBvLyFv) is currently not downloadable via its [official download link](https://s3-us-west-2.amazonaws.com/support-files.rachio.com/rachio_linux_connect.sh) and throws this error:

```xml
<Error>
<Code>AccessDenied</Code>
<Message>Access Denied</Message>
<RequestId>CKA549KBPYAH6R1N</RequestId>
<HostId>iIhzpqk8q1y8CeSFyAckHlnXFL8NX2AMGv8LqJ/VmtHFJeoTdQFk0wPKi3dmNc/wWT1oeQ3Z234ZPVDStJpAHmqrSaqyuF9D</HostId>
</Error>
```

---

## Usage

1. **Download the script:**
```bash
wget https://raw.githubusercontent.com/Kyguyog/Rachio-Wifi-Setup-Linux-Script/refs/heads/main/Rachio%2BConnect.sh
```
2. **Connect Computer's Wifi to Rachio-XXXXXX**
3. **Run the script:**
```bash
chmod +x Rachio+Connect.sh && ./Rachio+Connect.sh
```
4. **Follow On-Screen Instructions (Serial # is under faceplate)**
---

## Contributing

If you encounter any bugs or have suggestions for improvements, feel free to open an issue or submit a pull request!
