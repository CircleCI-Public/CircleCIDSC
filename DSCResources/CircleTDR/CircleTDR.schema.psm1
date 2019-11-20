Configuration CircleTDR {
    Registry DisableTDR {
        Ensure = "Present"
        Key = "HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\GraphicsDrivers"
        ValueName = "TdrLevel"
        ValueData = "0"
    }
}